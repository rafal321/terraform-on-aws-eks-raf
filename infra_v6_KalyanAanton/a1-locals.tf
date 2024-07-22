locals {
  profile     = "lab"
  env         = "dev"
  region      = "eu-west-1"
  zone1       = "eu-west-1a"
  zone2       = "eu-west-1b"
  eks_version = "1.28"
  eks_name    = "kalant" # cluster
  subnets_pub = ["subnet-0e325118b5eed09ea", "subnet-04a4b5654d58a32e1"]
  subnets_pri = ["subnet-0d5470217e38223f0", "subnet-0ea99efb622eec153"]
}
