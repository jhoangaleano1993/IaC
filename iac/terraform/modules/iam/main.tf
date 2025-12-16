# Módulo de IAM para crear usuario de Azure DevOps
# Este usuario tendrá los permisos necesarios para gestionar la infraestructura de Terraform

# Usuario IAM para Azure DevOps
resource "aws_iam_user" "azure_devops" {
  name = var.user_name
  path = "/ci-cd/"

  tags = {
    Name        = "Azure DevOps CI/CD User"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Purpose     = "Azure DevOps Pipeline Authentication"
  }
}

# Access Key para el usuario (se usará en Azure DevOps)
resource "aws_iam_access_key" "azure_devops" {
  user = aws_iam_user.azure_devops.name
}

# Política personalizada con permisos necesarios para Terraform
resource "aws_iam_policy" "terraform_permissions" {
  name        = "${var.user_name}-terraform-policy"
  description = "Permisos necesarios para que Terraform gestione la infraestructura EKS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EC2FullAccess"
        Effect = "Allow"
        Action = [
          "ec2:*"
        ]
        Resource = "*"
      },
      {
        Sid    = "EKSFullAccess"
        Effect = "Allow"
        Action = [
          "eks:*"
        ]
        Resource = "*"
      },
      {
        Sid    = "IAMManagement"
        Effect = "Allow"
        Action = [
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:GetRole",
          "iam:ListRoles",
          "iam:UpdateRole",
          "iam:PassRole",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:GetRolePolicy",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies",
          "iam:CreatePolicy",
          "iam:DeletePolicy",
          "iam:GetPolicy",
          "iam:ListPolicies",
          "iam:GetPolicyVersion",
          "iam:ListPolicyVersions",
          "iam:CreatePolicyVersion",
          "iam:DeletePolicyVersion",
          "iam:TagRole",
          "iam:UntagRole",
          "iam:TagPolicy",
          "iam:UntagPolicy",
          "iam:CreateOpenIDConnectProvider",
          "iam:DeleteOpenIDConnectProvider",
          "iam:GetOpenIDConnectProvider",
          "iam:ListOpenIDConnectProviders",
          "iam:TagOpenIDConnectProvider",
          "iam:UntagOpenIDConnectProvider"
        ]
        Resource = "*"
      },
      {
        Sid    = "S3TerraformBackend"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.terraform_state_bucket}",
          "arn:aws:s3:::${var.terraform_state_bucket}/*"
        ]
      },
      {
        Sid    = "DynamoDBStateLocking"
        Effect = "Allow"
        Action = [
          "dynamodb:DescribeTable",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = "arn:aws:dynamodb:*:*:table/${var.terraform_lock_table}"
      },
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:DeleteLogGroup",
          "logs:TagLogGroup",
          "logs:UntagLogGroup",
          "logs:PutRetentionPolicy",
          "logs:DeleteRetentionPolicy"
        ]
        Resource = "*"
      },
      {
        Sid    = "AutoScaling"
        Effect = "Allow"
        Action = [
          "autoscaling:*"
        ]
        Resource = "*"
      },
      {
        Sid    = "ElasticLoadBalancing"
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:*"
        ]
        Resource = "*"
      },
      {
        Sid    = "SSMParameterAccess"
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = "*"
      },
      {
        Sid    = "KMSManagement"
        Effect = "Allow"
        Action = [
          "kms:CreateKey",
          "kms:DescribeKey",
          "kms:GetKeyPolicy",
          "kms:GetKeyRotationStatus",
          "kms:ListResourceTags",
          "kms:PutKeyPolicy",
          "kms:ScheduleKeyDeletion",
          "kms:EnableKeyRotation",
          "kms:DisableKeyRotation",
          "kms:TagResource",
          "kms:UntagResource",
          "kms:CreateAlias",
          "kms:DeleteAlias",
          "kms:ListAliases",
          "kms:ListKeys"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name        = "Terraform EKS Policy"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Adjuntar la política personalizada al usuario
resource "aws_iam_user_policy_attachment" "terraform_permissions" {
  user       = aws_iam_user.azure_devops.name
  policy_arn = aws_iam_policy.terraform_permissions.arn
}

# NOTA: Para desarrollo/pruebas, también puedes usar AdministratorAccess (menos recomendado)
# Descomenta las siguientes líneas solo si necesitas permisos completos:
#
# resource "aws_iam_user_policy_attachment" "admin_access" {
#   user       = aws_iam_user.azure_devops.name
#   policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
# }
