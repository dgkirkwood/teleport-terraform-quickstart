resource "aws_iam_policy" "nodegetidentity" {
  name = "node-getidentity"
  path = "/"
  description = "Get Identity for IAM join"
  policy = <<POLICY
{
   "Version": "2012-10-17",
   "Statement": [
	   {
		   "Effect": "Allow",
		   "Action": "sts:GetCallerIdentity",
		   "Resource": "*"
	   }
   ]
}
POLICY
}



resource "aws_iam_role" "ec2_assume" {
  name = "node_assume"
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

resource "aws_iam_role_policy_attachment" "ec2_get_identity" {
  policy_arn = aws_iam_policy.nodegetidentity.arn
  role = aws_iam_role.ec2_assume.name
}

resource "aws_iam_instance_profile" "ec2_get_identity" {
  name = "node_get_caller_identity"
  role = aws_iam_role.ec2_assume.name
}
  
