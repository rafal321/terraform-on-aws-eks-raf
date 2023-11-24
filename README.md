# terraform-on-aws-eks-raf
Terraform on AWS EKS Kubernetes
based on "terraform-on-aws-eks" by Kalyan Reddy Daida | stacksimplify 

raf notes:
Prepare for faster disaster recovery: Deploy an Amazon Aurora global database with Terraform (Part 1)
https://aws.amazon.com/blogs/infrastructure-and-automation/disaster-recovery-deploy-amazon-aurora-global-database-with-terraform/

How we structure our Terraform project
https://blog.softup.co/how-we-structure-our-terraform-code/

infrastructure
├── modules
│   ├── containers
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── templates
│   │   │   └── app.json.tpl
│   │   ├── variables.tf
│   │   └── versions.tf
│   ├── database
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   │   └── versions.tf
│   ├── management
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   │   └── versions.tf
│   ├── network
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── variables.tf
│   │   └── versions.tf
│   ├── notifications
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── templates
│   │   │   └── email-sns-stack.json.tpl
│   │   └── variables.tf
│   │   └── versions.tf
│   ├── scaling
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── variables.tf
│   ├── security
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── templates
│   │   │   ├── ecs-ec2-role-policy.json.tpl
│   │   │   ├── ecs-ec2-role.json.tpl
│   │   │   └── ecs-service-role.json.tpl
│   │   ├── variables.tf
│   │   └── versions.tf
│   └── storage
│       ├── main.tf
│       ├── outputs.tf
│   	├── variables.tf
│   	└── versions.tf
├── development
│   ├── main.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── variables.tf
│   └── versions.tf
├── staging
│   ├── main.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── variables.tf
│   └── versions.tf
└── production
    ├── main.tf
    ├── outputs.tf
    ├── provider.tf
    ├── variables.tf
    └── versions.tf


[1] Each Terraform module should live in its own repository and versioning should be leveraged.
[2] Minimal structure: main.tf, variables.tf, outputs.tf.
[3] Use input and output variables (outputs can be accessed with module.module_name.output_name).
==================================================


