# role Module
Create a rol with a data json format file that contains the policy 

The policy document for describe the role is added in the data.tf file.


### Example 
```

module "ec2" {
    source = "git::ssh://git@github.com/${var.githubproject}.git//modules/role"
    source = "./modules/role"
    policy=data.aws_iam_policy_document.instance-assume-role-policy.json
    service=var.service
    country=var.country
    environment=var.environment
}    
```

### Policy Example
```
data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    
  }
  statement {
    actions = [
                "s3:GetObject",
                "s3:ListBucketMultipartUploads",
                "s3:ListBucket",
                "s3:ListMultipartUploadParts"
            ]

    resources = [
                "arn:aws:s3:::es-temporalinputdata-borrame",
                "arn:aws:s3:::es-temporalinputdata-borrame/*"
    ]
    effect = "Allow"
  }

  statement {
    actions = [
                "s3:PutObject",
                "s3:GetObject",
                "s3:ListBucketMultipartUploads",
                "s3:AbortMultipartUpload",
                "s3:ListBucket",
                "s3:DeleteObject",
                "s3:ListMultipartUploadParts"
            ]

    resources = [
                "arn:aws:s3:::es-data-output",
                "arn:aws:s3:::es-data-output/*"
    ]
    effect = "Allow"
  }
}

```
