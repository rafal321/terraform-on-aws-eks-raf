locals {
  env         = "dev"
  region      = "eu-west-1"
  zone1       = "eu-west-1a"
  zone2       = "eu-west-1b"
  profile     = "eksuser" #"eksuser" #"dev"
  eks_version = "1.28"
  eks_name    = "travelearth" # cluster
}
/*
TT=`date` ; terraform apply --auto-approve ; echo $TT ; date
TT=`date` ; terraform destroy --auto-approve ; echo $TT ; date
In this video you create all resources using direct terraform resources. But we also have publicly available modules from Anton Babenko to create EKS and simplify the terraform layer, in my opinion. What do you think is better to use in production cases? Is it worth using such public terraform modules or is it better to create all the resources yourself?

I respect him, i just generally don't like using open source modules. For example that open source module still uses auth configmap to manage users. It's very easy for them to start using API but it will break your infra and you would have to keep using old versions until you create new eks clusters (just from my personal experience) Modules are great for consulting and temporary envs, when you don't need to maintain clusters for over the year. I know a lot of copy pasting but when you have 20+ clusters, update module can in all envs can take months or even year :)

*/
