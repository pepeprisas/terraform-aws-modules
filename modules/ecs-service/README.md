# albec2 Module
Create an ECS Service to deploy applications on Fargate (Serverless)

### Example

Include in your main.tf file:  
```
module "ecs_service" {
  source = "git::ssh://git@github.com/${var.githubproject}.git//modules/ecs-service"
  name = var.name
  country = var.country
  team = var.team
  subnet-id = terraform.workspace == "production" ? data.terraform_remote_state.environment_networking.outputs.public_subnet_ids[0] : data.terraform_remote_state.environment_networking.outputs.private_subnet_ids[0]
  ecs-id = module.ecs_cluster.id
  target-group-arn = module.alb.target-group-arn
  container-exposed-port = 9000
  container-image-url = "${var.country}-${var.team}-${terraform.workspace}-container-${var.name}"
  alb-sg-id = module.alb.alb-sg-id
  task_role_arn = aws_iam_role.task_role.arn
  fargate_cpu = var.fargate_cpu
  fargate_memory = var.fargate_memory
  add_volume = [
    {
      efs_id = module.efs.efs_id,
      volume_name = "config",
      root_directory = "/conf",
      file_system_id = aws_efs_access_point.conf.id
    },
    {
      efs_id = module.efs.efs_id,
      volume_name = "data",
      root_directory = "/data",
      file_system_id = aws_efs_access_point.data.id
    },
    {
      efs_id = module.efs.efs_id,
      volume_name = "logs",
      root_directory = "/logs",
      file_system_id = aws_efs_access_point.logs.id
    },
    {
      efs_id = module.efs.efs_id,
      volume_name = "extensions",
      root_directory = "/extensions",
      file_system_id = aws_efs_access_point.extensions.id
    }
  ]

  container-definitions = <<DEFINITION
[
  {
    "cpu": ${var.fargate_cpu},
    "image": "${var.app_image}:${var.app_version}",
    "memory": ${var.fargate_memory},
    "name": "${var.country}-${var.team}-${terraform.workspace}-container-${var.name}",
    "networkMode": "awsvpc",
    "ulimits": [
        {
          "softLimit": 65535,
          "hardLimit": 65535,
          "name": "nofile"
        }
      ],
    "command": [
      "-Dsonar.search.javaAdditionalOpts=-Dnode.store.allow_mmapfs=false"
    ],
    "mountPoints": [
          {
            "sourceVolume": "config",
            "containerPath": "/opt/sonarqube/config",
            "readOnly": false
          },
          {
            "sourceVolume": "data",
            "containerPath": "/opt/sonarqube/data",
            "readOnly": false
          },
          {
            "sourceVolume": "logs",
            "containerPath": "/opt/sonarqube/logs",
            "readOnly": false
          },
          {
            "sourceVolume": "config",
            "containerPath": "/opt/sonarqube/extensions",
            "readOnly": false
          }
        ],
    "portMappings": [
      {
        "containerPort": ${var.app_port}
      }
    ],
    "environment" : [
      { "name" : "sonar.jdbc.username", "value" : "${jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["username"]}" },
      { "name" : "sonar.jdbc.password", "value" : "${jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["password"]}" },
      { "name" : "sonar.jdbc.url", "value" : "jdbc:postgresql://${jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["host"]}:${jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["port"]}/${var.name}" },
      { "name" : "ENVIRONMENT", "value" : "${terraform.workspace}" }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
          "awslogs-group": "/${var.country}/${var.team}/${terraform.workspace}/${var.name}",
          "awslogs-region": "${var.region}",
          "awslogs-stream-prefix": "${var.name}"
      }
    },
    "command": [
    "-Dsonar.search.javaAdditionalOpts=-Dnode.store.allow_mmap=false"
  ]
  }
]
DEFINITION
}
```

  
Pass the rest of the variables needed in your `variable.tf` file. For example:  
```
variable "name"{
  description="Name of the cluster"
}
variable "country"{
  description="Country code https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes"
}
variable "team" {
  description = "devops|dev|data"
}

variable "subnet-id" {
  description = "Subnet id"
}

variable "ecs-id" {
  description = "ECS cluster Id in which this service will run"
}

variable "target-group-arn" {
  description = "ARN of the target group."
}

variable "additional-service-sg" {
  description = "Additional security group ids to be added to the ECS service"
  default = []
}

variable "container-exposed-port" {
  description = "Port exposed by the container."
  default = 80
}

variable "container-definitions" {
  description = "Array of container definitions that will run in the task."
}

variable "container-image-url" {
  description = "Container image url"
}

variable "alb-sg-id" {
  description = "ALB security group."
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
}

variable "add_volume" {
  type = list(map(string))
  description = "Defines if there is an EFS volume attached. Using the efs id, efs root directory and volume name chose, example: [{efs_if = id, volume_name = name, root_directory = /}]"
  default = []
}

variable "task_role_arn" {
  description = "Task role ARN attached to the ECS task"
}

variable "app_count" {
  description = "Number of task to run in this service"
  default = 1
}

```