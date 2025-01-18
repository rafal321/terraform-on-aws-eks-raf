# operations
#/*
locals {
  profile     = "eksuser" # "lab"
  env         = "dev25"
  region      = "eu-west-1"
  zone1       = "eu-west-1a"
  zone2       = "eu-west-1b"
  eks_ver     = "1.30" # how about upgrade in console and then update terrafoorm so it matches versions
  eks_ver_ng  = "1.30" # ??? 1st    Problems when upgrade: https://itnext.io/terraform-dont-use-kubernetes-provider-with-your-cluster-resource-d8ec5319d14a
  eks_name    = "rkeks01-17"
  subnets_pub = ["subnet-0e325118b5eed09ea","subnet-04a4b5654d58a32e1"]
#  subnets_pri = ["subnet-0d5470217e38223f0","subnet-0ea99efb622eec153"]
  subnets_pri = ["subnet-059fcd3909335769d","subnet-078f93eaa906462d6"] # secondary
}
#*/
/*
# ops-devops
locals {
  profile     = "dev"
  env         = "dev"
  region      = "eu-west-1"
  zone1       = "eu-west-1a"
  zone2       = "eu-west-1b"
  eks_ver     = "1.30"
  eks_ver_ng  = "1.30"
  eks_name    = "rafeks12-09"
  subnets_pub = ["subnet-084bcf988f18d9c60","subnet-08e6e55f015cd501a"]
# subnets_pri = ["subnet-020fec9e430ecf401","subnet-09ab327853ccc1fa9"]
  subnets_pri = ["subnet-0a41f1516199eebd5","subnet-01180a7b6d234694f"] # secondary
}
*/


# https://learnk8s.io/terraform-eks
# aws cloudformation update-stack --stack-name raf-dev-eks03 --use-previous-template --parameters ParameterKey=EnableNAT,ParameterValue=DISABLED --capabilities CAPABILITY_IAM --profile lab
# ===============
# aws cloudformation update-stack \
#   --stack-name <your-stack-name> \
#   --use-previous-template \
#   --parameters ParameterKey=EnableNAT,ParameterValue=ENABLED \
#   --capabilities CAPABILITY_IAM

# aws cloudformation update-stack \
#   --stack-name <your-stack-name> \
#   --use-previous-template \
#   --parameters ParameterKey=EnableNAT,ParameterValue=DISABLED \
#   --capabilities CAPABILITY_IAM

# # To Upgrade Cluster version
# 1. Update cluster version in the console - wait
# 2. update cluster version in terraform (it detects change and updates state file)
# 3. update nodegroup verson in terraform and apply (it replaces nodes and redeploys all pods)
