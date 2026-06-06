# Terraform AWS EKS Cluster

Infrastructure-as-code project that provisions a fully functional Amazon EKS cluster on AWS using Terraform. Includes all supporting infrastructure: VPC, subnets, IAM roles, security groups, a managed node group, and an EC2 bastion host for cluster access.

---

## Architecture

```
AWS
└── VPC (custom CIDR)
    ├── Public Subnet 1 (AZ-a)
    ├── Public Subnet 2 (AZ-b)
    ├── Internet Gateway
    ├── EC2 Bastion Host (kubectl access)
    └── EKS Cluster (ed-eks-01)
        └── Managed Node Group (2x t3.micro, ON_DEMAND)
```

**Remote state** is stored in an S3 bucket with versioning and AES256 encryption enabled. A DynamoDB table handles state locking to prevent concurrent runs.

---

## Resources Provisioned

| File | Resources |
|------|-----------|
| `vpc.tf` | VPC, 2 public subnets, internet gateway, route tables, security groups |
| `iam.tf` | EKS cluster role, worker node role, autoscaler policy, instance profile, `aws_eks_cluster`, `aws_eks_node_group` |
| `main.tf` | EC2 bastion host, S3 state bucket, DynamoDB lock table |
| `provider.tf` | AWS provider configuration |
| `variables.tf` | Input variables |
| `outputs.tf` | Cluster endpoint and other outputs |

---

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.0
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) configured with appropriate permissions
- [kubectl](https://kubernetes.io/docs/tasks/tools/) installed
- An existing EC2 key pair in your target AWS region

---

## Usage

### 1. Clone the repo

```bash
git clone https://github.com/Ozort/Terraform-aws-eks.git
cd Terraform-aws-eks
```

### 2. Update variables

Edit `variables.tf` or create a `terraform.tfvars` file with your values:

```hcl
key        = "your-ec2-keypair-name"
vpc-cidr   = "10.0.0.0/16"
subnet1-az = "us-east-1a"
subnet2-az = "us-east-1b"
```

### 3. Initialise and apply

```bash
terraform init
terraform plan
terraform apply
```

> The EKS control plane takes approximately 10–15 minutes to provision.

### 4. Access the cluster via the bastion

```bash
# SSH into the bastion EC2
ssh -i your-key.pem ec2-user@<bastion-public-ip>

# Configure kubectl on the bastion
aws eks update-kubeconfig --region <your-region> --name ed-eks-01

# Verify nodes are ready
kubectl get nodes
```

---

## IAM Roles

**Cluster role (`ed-eks-master`)** — assumed by the EKS control plane. Attached policies:
- `AmazonEKSClusterPolicy`
- `AmazonEKSServicePolicy`
- `AmazonEKSVPCResourceController`

**Worker role (`ed-eks-worker`)** — assumed by EC2 node instances. Attached policies:
- `AmazonEKSWorkerNodePolicy`
- `AmazonEKS_CNI_Policy`
- `AmazonEC2ContainerRegistryReadOnly`
- `AmazonSSMManagedInstanceCore`
- `AWSXRayDaemonWriteAccess`
- `AmazonS3ReadOnlyAccess`
- Custom autoscaler policy (describe/set ASG desired capacity)

---

## Node Group Configuration

| Setting | Value |
|---------|-------|
| Instance type | t3.micro |
| Capacity type | ON_DEMAND |
| Disk size | 20 GB |
| Desired nodes | 2 |
| Min nodes | 1 |
| Max nodes | 3 |

---

## Cleanup

```bash
terraform destroy
```

> Make sure to destroy the cluster before manually deleting any VPC or subnet resources, as AWS will block deletion of resources still in use by EKS.

---

## Notes

- The S3 bucket has `prevent_destroy = true` set to protect the Terraform state file from accidental deletion. Remove this lifecycle rule before running `terraform destroy` if you want the bucket cleaned up too.
- Security groups currently allow SSH from `0.0.0.0/0`. Restrict the CIDR to your IP in any non-learning environment.
