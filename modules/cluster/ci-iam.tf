data "aws_caller_identity" "current" {}

resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

data "aws_iam_policy_document" "github_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repository}:ref:refs/heads/${var.github_branch}"]
    }
  }
}

# --- Image push role: builds and pushes images, nothing else ---------------

resource "aws_iam_role" "github_image_push" {
  name               = "${var.cluster_name}-github-image-push"
  description        = "Pushes application images to ECR. No cluster access."
  assume_role_policy = data.aws_iam_policy_document.github_assume_role.json
}

data "aws_iam_policy_document" "github_image_push" {
  statement {
    sid       = "GetAuthToken"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid    = "PushImages"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
      "ecr:DescribeImages",
    ]
    resources = ["arn:aws:ecr:${var.aws_region}:${data.aws_caller_identity.current.account_id}:repository/${var.project_name}-*"]
  }
}

resource "aws_iam_policy" "github_image_push" {
  name        = "${var.cluster_name}-github-image-push"
  description = "Push application images to the project ECR repositories"
  policy      = data.aws_iam_policy_document.github_image_push.json
}

resource "aws_iam_role_policy_attachment" "github_image_push" {
  role       = aws_iam_role.github_image_push.name
  policy_arn = aws_iam_policy.github_image_push.arn
}

# --- Terraform role: applies both roots ------------------------------------

resource "aws_iam_role" "github_terraform" {
  name               = "${var.cluster_name}-github-terraform"
  description        = "Runs terraform plan and apply from the main branch workflow"
  assume_role_policy = data.aws_iam_policy_document.github_assume_role.json
}

resource "aws_iam_role_policy_attachment" "github_terraform_poweruser" {
  role       = aws_iam_role.github_terraform.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

data "aws_iam_policy_document" "github_terraform_iam" {
  statement {
    sid    = "ManageProjectIdentities"
    effect = "Allow"
    actions = [
      "iam:CreateRole", "iam:DeleteRole", "iam:GetRole", "iam:TagRole",
      "iam:UntagRole", "iam:UpdateAssumeRolePolicy",
      "iam:AttachRolePolicy", "iam:DetachRolePolicy",
      "iam:ListRolePolicies", "iam:ListAttachedRolePolicies",
      "iam:ListInstanceProfilesForRole",
      "iam:CreatePolicy", "iam:DeletePolicy",
      "iam:CreatePolicyVersion", "iam:DeletePolicyVersion",
      "iam:CreateServiceLinkedRole", "iam:PassRole",
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.project_name}-*",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.project_name}-*",
    ]
  }

  statement {
    sid    = "ManageOidcProviders"
    effect = "Allow"
    actions = [
      "iam:GetOpenIDConnectProvider",
      "iam:CreateOpenIDConnectProvider",
      "iam:DeleteOpenIDConnectProvider",
      "iam:UpdateOpenIDConnectProviderThumbprint",
      "iam:TagOpenIDConnectProvider",
    ]
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/*"]
  }

  statement {
    sid    = "ReadIamGlobally"
    effect = "Allow"
    actions = [
      "iam:GetPolicy", "iam:GetPolicyVersion",
      "iam:ListPolicyVersions", "iam:ListRoles",
      "iam:ListOpenIDConnectProviders",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "TerraformState"
    effect = "Allow"
    actions = [
      "s3:ListBucket", "s3:GetObject", "s3:PutObject", "s3:DeleteObject",
    ]
    resources = [
      "arn:aws:s3:::${var.project_name}-tfstate-${data.aws_caller_identity.current.account_id}",
      "arn:aws:s3:::${var.project_name}-tfstate-${data.aws_caller_identity.current.account_id}/*",
    ]
  }
}

resource "aws_iam_policy" "github_terraform_iam" {
  name        = "${var.cluster_name}-github-terraform-iam"
  description = "Manage project IAM resources and Terraform state"
  policy      = data.aws_iam_policy_document.github_terraform_iam.json
}

resource "aws_iam_role_policy_attachment" "github_terraform_iam" {
  role       = aws_iam_role.github_terraform.name
  policy_arn = aws_iam_policy.github_terraform_iam.arn
}