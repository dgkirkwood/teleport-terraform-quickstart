resource "aws_iam_policy" "ec2rds" {
  name = "ec2rds"
  path = "/"
  description = "EC2 RDS Access"
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "rds:DescribeDBInstances",
                "rds:ModifyDBInstance",
                "rds:DescribeDBClusters",
                "rds:ModifyDBCluster",
                "rds-db:connect"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:GetUserPolicy",
                "iam:PutUserPolicy",
                "iam:DeleteUserPolicy"
            ],
            "Resource": [
                "arn:aws:iam::*:user/username"
            ]
        }
    ]
}
POLICY
}

resource "aws_iam_policy" "ec2rds_boundary" {
  name = "ec2rds_boundary"
  path = "/"
  description = "EC2 RDS Permissions boundary"
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "rds:DescribeDBInstances",
                "rds:ModifyDBInstance",
                "rds:DescribeDBClusters",
                "rds:ModifyDBCluster",
                "rds-db:connect"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:GetUserPolicy",
                "iam:PutUserPolicy",
                "iam:DeleteUserPolicy"
            ],
            "Resource": [
                "arn:aws:iam::*:user/username"
            ]
        }
    ]
}
POLICY
}

resource "aws_iam_role" "ec2_assume" {
  name = "ec2_rds_assume"
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
  role = aws_iam_role.ec2_assume.name
}

resource "aws_iam_instance_profile" "ec2_rds" {
  name = "${var.prefix}-ec2_rds_profile"
  role = aws_iam_role.ec2_assume.name
}
  
