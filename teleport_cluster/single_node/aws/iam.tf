resource "aws_iam_policy" "describeinstances" {
  name = "${var.prefix}-proxy-ec2decribe"
  path = "/"
  description = "Describe EC2"
  policy = <<POLICY
{
   "Version": "2012-10-17",
   "Statement": [
	   {
		   "Effect": "Allow",
		   "Action": "ec2:DescribeInstances",
		   "Resource": "*"
	   },
     {
       "Effect": "Allow",
       "Action": "sts:AssumeRole",
       "Resource": "*"
    }
   ]
}
POLICY
}



resource "aws_iam_role" "ec2_assume" {
  name = "${var.prefix}-proxy-ec2_assume"
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

resource "aws_iam_role_policy_attachment" "ec2_describe" {
  policy_arn = aws_iam_policy.describeinstances.arn
  role = aws_iam_role.ec2_assume.name
}

resource "aws_iam_instance_profile" "ec2_describe" {
  name = "${var.prefix}-proxy-ec2_describe"
  role = aws_iam_role.ec2_assume.name
}
  
