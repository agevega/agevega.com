resource "aws_iam_role" "bastion_role" {
  name = "bastion-host-role"

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
    Name = "bastion-host-role"
  })
}

resource "aws_iam_policy" "route53_policy" {
  name        = "bastion-route53-policy"
  description = "Allow Bastion to manage Route53 records for DNS-01 challenge"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "route53:ChangeResourceRecordSets",
          "route53:GetChange",
          "route53:ListResourceRecordSets" # Useful for debugging
        ]
        Resource = "arn:aws:route53:::hostedzone/*" # Scope down if zone ID is available via data source
      },
      {
        Effect = "Allow"
        Action = [
          "route53:ListHostedZones",
          "route53:ListHostedZonesByName"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "route53_attach" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = aws_iam_policy.route53_policy.arn
}

resource "aws_iam_instance_profile" "bastion_profile" {
  name = "bastion-instance-profile"
  role = aws_iam_role.bastion_role.name
}
