# operations
#/*
locals {
  profile     = "lab"
  env         = "dev"
  region      = "eu-west-1"
  zone1       = "eu-west-1a"
  zone2       = "eu-west-1b"
  eks_ver     = "1.29"
  eks_ver_ng  = "1.29"
  eks_name    = "rkeks23" # cluster
  subnets_pub = ["subnet-0e325118b5eed09ea", "subnet-04a4b5654d58a32e1"]
  subnets_pri = ["subnet-0d5470217e38223f0", "subnet-0ea99efb622eec153"]
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
  eks_ver     = "1.29"
  eks_ver_ng  = "1.29"
  eks_name    = "rafeks07" # cluster
  subnets_pub = ["subnet-084bcf988f18d9c60", "subnet-08e6e55f015cd501a"]
  subnets_pri = ["subnet-020fec9e430ecf401", "subnet-09ab327853ccc1fa9"]
}
*/


# https://learnk8s.io/terraform-eks
