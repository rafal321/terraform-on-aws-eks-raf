# https://www.youtube.com/watch?v=nMVXs8VnrF4&t=1557s [18:30]
data "terraform_remote_state" "vpc" {
    backend = "local"
    config = {
        path = "${path.module}/../01-vpc/terraform.tfstate"
    }
}
# output "vpc_out_test" {
#     value = data.terraform_remote_state.vpc.outputs
# }