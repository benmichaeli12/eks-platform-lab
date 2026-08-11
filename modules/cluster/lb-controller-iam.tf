data "aws_iam_policy_document" "lb_controller_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole", "sts:TagSession"]

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lb_controller" {
  name               = "${var.cluster_name}-lb-controller"
  description        = "Role assumed by the AWS Load Balancer Controller through Pod Identity"
  assume_role_policy = data.aws_iam_policy_document.lb_controller_assume_role.json
}

resource "aws_iam_policy" "lb_controller" {
  name        = "${var.cluster_name}-lb-controller"
  description = "Permissions for the AWS Load Balancer Controller"
  policy      = file("${path.module}/policies/aws-load-balancer-controller.json")
}

resource "aws_iam_role_policy_attachment" "lb_controller" {
  role       = aws_iam_role.lb_controller.name
  policy_arn = aws_iam_policy.lb_controller.arn
}

resource "aws_eks_pod_identity_association" "lb_controller" {
  cluster_name    = aws_eks_cluster.main.name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = aws_iam_role.lb_controller.arn

  depends_on = [aws_eks_addon.pod_identity]
}