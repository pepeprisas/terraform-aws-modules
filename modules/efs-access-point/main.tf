resource "aws_efs_access_point" "data" {
  for_each = [for access_point in var.access_point_list: {
    efs_id = access_point.efs_id
    path = access_point.path
    name = access_point.name
  }]
  file_system_id = each.value.efs_id
  posix_user {
    gid = 1000
    uid = 1000
  }
  root_directory {
    path = each.value.path
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = 755
    }
  }
  tags = {
    Environment = terraform.workspace
    Name  = "${var.country}-${var.team}-${terraform.workspace}-${var.service}-accessPoint${each.value.name}"
    Country = var.country
    Resource = "accessPoint"
    Environment = terraform.workspace
    Team = var.team
    Service = var.service
  }
}