# a hack to get instance profile name by iam role name
# the instance profile name is created by the managed nodegroup, and it can't output the instance profile name
data "external" "instance_profile" {
  program = ["bash", "get-instance-profile-by-iam-role-name.sh"]
}

locals {
  instance_profile_name = data.external.instance_profile.result.profile_name
}

module "nodegroup" {
  source = "../modules/customer-managed-nodegroup"

  cluster_name          = data.terraform_remote_state.eks.outputs.cluster_name
  nodegroup_name        = var.nodegroup_name
  cluster_endpoint      = data.terraform_remote_state.eks.outputs.endpoint
  cert_data             = data.terraform_remote_state.eks.outputs.kubeconfig-certificate-authority-data
  ssh_worker_key        = var.ssh_worker_key
  vpc_id                = data.terraform_remote_state.network.outputs.second_vpc_id
  worker_subnet_ids     = data.terraform_remote_state.network.outputs.second_vpc_private_subnet_ids
  instance_profile_name = local.instance_profile_name
  control_plane_sg_id   = data.terraform_remote_state.eks.outputs.eks_security_group_id
  peering_vpc_cidr      = data.terraform_remote_state.network.outputs.main_vpc_cidr
}
