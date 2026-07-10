# Terraform AWS EKS

A modular Terraform project that provisions an Amazon EKS cluster and its supporting infrastructure on AWS. The project is structured into four independent modules — state, vpc, iam, and ec2 — each responsible for a distinct layer of the infrastructure.

---

## Architecture

```
root/
├── main.tf              # Wires all modules together
├── variables.tf         # Root-level variable declarations
├── outputs.tf           # Exposes key values after apply
├── terraform.tfvars.example
└── modules/
    ├── state/           # S3 bucket + DynamoDB for remote state
    ├── vpc/             # VPC, subnets, IGW, route tables, security group
    ├── iam/             # IAM roles, EKS cluster, node group
    └── ec2/             # Bastion/worker EC2 instance
```

### What gets created

| Module | Resources |
|--------|-----------|
| `state` | S3 bucket (`ozort-terraform-state-file`) with versioning + AES256 encryption, DynamoDB table for state locking |
| `vpc` | VPC, 2 public subnets across 2 AZs, Internet Gateway, Route Table, Security Group (SSH ingress + all egress) |
| `iam` | IAM roles (`ed-eks-master`, `ed-eks-worker`), policy attachments, EKS cluster (`ed-eks-01`), managed node group (`dev`) |
| `ec2` | EC2 instance (bastion) in subnet 1 with public IP |

---

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.0
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) configured with appropriate credentials
- An existing AWS EC2 Key Pair
- IAM permissions to create VPC, EKS, EC2, IAM, S3, and DynamoDB resources

---

## Usage

### 1. Clone the repo

```bash
git clone https://github.com/Ozort/Terraform-aws-eks.git
cd Terraform-aws-eks
```

### 2. Create your tfvars file

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your real values:

```hcl
ami          = "ami-0c02fb55956c7d316"   # Amazon Linux 2 AMI for your region
key          = "your-ec2-keypair-name"
vpc-cidr     = "10.10.0.0/16"
subnet1-cidr = "10.10.1.0/24"
subnet2-cidr = "10.10.2.0/24"
subnet1-az   = "us-east-1a"
subnet2-az   = "us-east-1b"
```

### 3. Initialise Terraform

```bash
terraform init
```

### 4. Review the plan

```bash
terraform plan
```

### 5. Apply

```bash
terraform apply
```

> **Note:** The S3 bucket and DynamoDB table (state module) must be created before configuring an S3 backend. Run `terraform apply` first, then add the backend config and run `terraform init` again to migrate state.

---

## Variables

| Name | Description | Default |
|------|-------------|---------|
| `region` | AWS region to deploy resources | `us-east-1` |
| `ami` | AMI ID for the EC2 instance | required |
| `key` | Name of the SSH key pair | required |
| `instance-type` | EC2 instance type | `t3.micro` |
| `vpc-cidr` | CIDR block for the VPC | `10.10.0.0/16` |
| `subnet1-cidr` | CIDR block for subnet 1 | `10.10.1.0/24` |
| `subnet2-cidr` | CIDR block for subnet 2 | `10.10.2.0/24` |
| `subnet1-az` | Availability zone for subnet 1 | `us-east-1a` |
| `subnet2-az` | Availability zone for subnet 2 | `us-east-1b` |

---

## Outputs

| Name | Description |
|------|-------------|
| `endpoint` | EKS cluster API server endpoint |
| `worker_node_sg_id` | Security group ID attached to worker nodes |
| `s3_bucket_arn` | ARN of the S3 bucket used for Terraform state |
| `dynamodb_table_name` | Name of the DynamoDB table used for state locking |

---

## EKS Cluster Details

| Property | Value |
|----------|-------|
| Cluster name | `ed-eks-01` |
| Node group name | `dev` |
| Node instance type | `t3.micro` |
| Capacity type | ON_DEMAND |
| Node disk size | 20 GB |
| Desired nodes | 2 |
| Min nodes | 1 |
| Max nodes | 3 |

### IAM Policies attached to master role

- `AmazonEKSClusterPolicy`
- `AmazonEKSServicePolicy`
- `AmazonEKSVPCResourceController`

### IAM Policies attached to worker role

- `AmazonEKSWorkerNodePolicy`
- `AmazonEKS_CNI_Policy`
- `AmazonEC2ContainerRegistryReadOnly`
- `AmazonSSMManagedInstanceCore`
- `AWSXRayDaemonWriteAccess`
- `AmazonS3ReadOnlyAccess`
- Custom autoscaler policy

---

## Remote State (S3 Backend)

After the state module resources are created, you can configure the S3 backend by adding the following to a `backend.tf` file and running `terraform init`:

```hcl
terraform {
  backend "s3" {
    bucket         = "ozort-terraform-state-file"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}
```

---

## Security Notes

- `terraform.tfvars` is gitignored — never commit real values
- Use `terraform.tfvars.example` as a reference template
- The security group allows SSH (port 22) from `0.0.0.0/0` — restrict this to your IP in production
- All egress traffic is allowed — tighten this for production workloads

---

## Teardown

```bash
terraform destroy
```

> If you have versioned objects in the S3 bucket, you will need to delete all object versions manually before Terraform can remove the bucket.

---

## Author

**Abu Bobby (Ozort)**  
GitHub: [github.com/Ozort](https://github.com/Ozort)