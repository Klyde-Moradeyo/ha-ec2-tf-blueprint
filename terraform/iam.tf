
############################
#        IAM Role          #
############################
module "ec2_iam_role" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-role/aws"
  version = "0.0.1"

  name = var.name

  trust_policy_hcl = {
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  }

  policy_arns = {
    "ec2"                    = module.ec2_iam_policy.policy_arn
    "AmazonS3ReadOnlyAccess" = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  }

  tags = module.tags.tags
}

############################
#       IAM Policy         #
############################
module "ec2_iam_policy" {
  source  = "km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-policy/aws"
  version = "0.0.1"

  name        = var.name
  path        = "/example-policies/"
  description = "An IAM policy for ${var.name}"

  policy_hcl = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource = [
          "arn:aws:s3:::general-purpose-storage-s3-gminaqhj//terraform-registry/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::general-purpose-storage-s3-gminaqhj"
        ]
      }
    ]
  }

  tags = module.tags.tags
}
