<<<<<<< HEAD
# Terraform-Module
=======
# Terraform Module — Hands-On Lab

> **Part of the Zen Pharma DevOps Masterclass**

This repo teaches **why Terraform modules exist** by showing the same
EC2 + Security Group infrastructure written two ways:

| Folder | Approach | Problem |
|--------|----------|---------|
| `without-module/` | Plain resources, copy-pasted per env | 3× duplicated code, bug fixes in 3 places |
| `with-module/` | Reusable `modules/ec2` module | Write once, call for dev / qa / prod |

---

## Pre-requisites

- Terraform >= 1.6 installed (`terraform -version`)
- AWS CLI configured (`aws configure` or `AWS_PROFILE` set)
- An AWS account with permissions to create EC2, VPC, Security Groups
- A default VPC **or** provide your own `vpc_id` / `subnet_id`

---

## Lab Part 1 — Without a Module (the problem)

```bash
cd without-module/dev
terraform init
terraform plan
terraform apply
terraform destroy   # clean up!
```

Repeat for `qa/` and `prod/`.  
**Observe**: identical `aws_security_group` block copy-pasted three times.  
**Ask yourself**: what happens when you need to add port 443?

---

## Lab Part 2 — With a Module (the solution)

```bash
cd with-module/envs/dev
terraform init
terraform plan      # shows 2 resources — same as Part 1
terraform apply
terraform output    # prints instance_id and public_ip

# Call the SAME module for prod
cd ../prod
terraform init
terraform plan      # t3.medium instead of t3.micro — same module!
terraform apply
terraform destroy
```

**Observe**: `modules/ec2/` has ONE copy of the logic.  
`envs/dev` and `envs/prod` just pass different variables.

---

## Stretch Challenge

1. Add a **`qa`** environment that uses `t3.small`
2. Add a **`key_name`** variable to the module to attach an SSH key pair
3. Add an **`output`** for `private_ip`
4. Change the SG to also allow **port 443** — notice you only edit ONE file

---

## File Structure

```
.
├── README.md
├── without-module/
│   ├── dev/
│   │   ├── main.tf        ← full resources (dev)
│   │   └── terraform.tfvars
│   ├── qa/
│   │   ├── main.tf        ← full resources (qa) — copy of dev, edited
│   │   └── terraform.tfvars
│   └── prod/
│       ├── main.tf        ← full resources (prod) — copy again
│       └── terraform.tfvars
└── with-module/
    ├── modules/
    │   └── ec2/
    │       ├── main.tf        ← ONE copy of the logic
    │       ├── variables.tf   ← inputs
    │       └── outputs.tf     ← outputs
    └── envs/
        ├── dev/
        │   ├── main.tf        ← calls module("ec2") with dev vars
        │   ├── variables.tf
        │   └── terraform.tfvars
        ├── qa/
        │   ├── main.tf
        │   ├── variables.tf
        │   └── terraform.tfvars
        └── prod/
            ├── main.tf
            ├── variables.tf
            └── terraform.tfvars
```
>>>>>>> 69ed10b (feat: add EC2 hands-on lab — with and without module)
