# operations
#/*
locals {
  profile     = "dev" 
  env         = "dev25"
  region      = "eu-west-1"
  zone1       = "eu-west-1a"
  zone2       = "eu-west-1b"
  eks_ver     = "1.32" # how about upgrade in console and then update terrafoorm so it matches versions
  eks_ver_ng  = "1.32" # ??? 1st   
  eks_name    = "infrav6-1"
  subnets_pub = ["subnet-0ae783ef65d0e3f98", "subnet-00d0776b2f2e04b8b"]
  subnets_pri = ["subnet-0c356595cb97b2e5a", "subnet-084a53ca561cc55a0"]
  # subnets_pri = ["subnet-0ab479a802b7b8b99", "subnet-0ab479a802b7b8b99"] # secondary
}
#*/


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
