resource "aws_iam_role" "ec2_role" {
  name = "ha_cluster_ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Module = "05-high-availability/00-security"
  })

  inline_policy {
    name = "ssm_access"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = "ssm:GetParameter"
          Effect   = "Allow"
          Resource = "arn:aws:ssm:*:*:parameter/${var.project_name}/production/image_tag"
        }
      ]
    })
  }
}

resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ha_cluster_ec2_profile"
  role = aws_iam_role.ec2_role.name
}
