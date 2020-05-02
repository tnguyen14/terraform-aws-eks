data "aws_iam_policy_document" "ec2_instance_profile" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "worker" {
  name = "EKSWorker-${var.cluster_name}"
  path = "/"

  assume_role_policy = data.aws_iam_policy_document.ec2_instance_profile.json
}

resource "aws_iam_instance_profile" "worker" {
  name = "EKSWorker-${var.cluster_name}"
  role = aws_iam_role.worker.name
}

resource "aws_iam_policy_attachment" "ssm_role_attach" {
  role       = aws_iam_role.worker
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
