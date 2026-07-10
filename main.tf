# ─────────────────────────────────────────────
# ROOT main.tf
# Calls each module and wires their outputs
# together as inputs to other modules.
# No AWS resources are defined here directly.
# ─────────────────────────────────────────────

module "state" {
  source = "./modules/state"
}

module "vpc" {
  source = "./modules/vpc"

  vpc-cidr     = var.vpc-cidr
  subnet1-cidr = var.subnet1-cidr
  subnet2-cidr = var.subnet2-cidr
  subnet1-az   = var.subnet1-az
  subnet2-az   = var.subnet2-az
}

module "iam" {
  source = "./modules/iam"

  subnet_1_id = module.vpc.subnet_1_id
  subnet_2_id = module.vpc.subnet_2_id
  sg_id       = module.vpc.sg_id
  key         = var.key
}

module "ec2" {
  source = "./modules/ec2"

  ami           = var.ami
  instance-type = var.instance-type
  key           = var.key
  subnet_1_id = module.vpc.subnet_1_id
  subnet_2_id = module.vpc.subnet_2_id
  sg_id         = module.vpc.sg_id
}
