resource "aws_iam_policy" "ec2rds" {
  name        = "ec2redis"
  path        = "/"
  description = "EC2 RDS Access"
  policy      = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "elasticache:ListTagsForResource",
                "elasticache:DescribeReplicationGroups",
                "elasticache:DescribeCacheClusters",
                "elasticache:DescribeCacheSubnetGroups",
                "elasticache:DescribeUsers",
                "elasticache:ModifyUser"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:DescribeSecret",
                "secretsmanager:CreateSecret",
                "secretsmanager:UpdateSecret",
                "secretsmanager:DeleteSecret",
                "secretsmanager:GetSecretValue",
                "secretsmanager:PutSecretValue",
                "secretsmanager:TagResource"
            ],
            "Resource": [
                "arn:*:secretsmanager:*:*:secret:teleport/*"
            ]
        }
    ]
}
POLICY
}

resource "aws_iam_policy" "ec2rds_boundary" {
  name        = "ec2redis_boundary"
  path        = "/"
  description = "EC2 RDS Permissions boundary"
  policy      = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "elasticache:ListTagsForResource",
                "elasticache:DescribeReplicationGroups",
                "elasticache:DescribeCacheClusters",
                "elasticache:DescribeCacheSubnetGroups",
                "elasticache:DescribeUsers",
                "elasticache:ModifyUser"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:DescribeSecret",
                "secretsmanager:CreateSecret",
                "secretsmanager:UpdateSecret",
                "secretsmanager:DeleteSecret",
                "secretsmanager:GetSecretValue",
                "secretsmanager:PutSecretValue",
                "secretsmanager:TagResource"
            ],
            "Resource": [
                "arn:*:secretsmanager:*:*:secret:teleport/*"
            ]
        }
    ]
}
POLICY
}

resource "aws_iam_role" "ec2_assume" {
  name               = "ec2_redis_assume"
  assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Sid": "",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            }
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "ec2_rds" {
  policy_arn = aws_iam_policy.ec2rds.arn
  role       = aws_iam_role.ec2_assume.name
}

resource "aws_iam_instance_profile" "ec2_rds" {
  name = "${var.prefix}-ec2_redis_profile"
  role = aws_iam_role.ec2_assume.name
}

