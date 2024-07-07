# ecr Module
Create an ECR repository for Docker images

### Example

Include in your main.tf file:  
```
module "ecr"{
  source = "git::ssh://git@github.com/${var.githubproject}.git//modules/ecr"
  country = var.country
  team = var.team
  resource = "ecr"
  service = var.service
  max_image_count = 5
}
```