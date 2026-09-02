data "aws_iam_policy_document" "pod_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole", "sts:TagSession"]

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

# --- ingest-api: writes documents, enqueues jobs -------------------------

resource "aws_iam_role" "ingest_api" {
  name               = "${var.cluster_name}-ingest-api"
  description        = "Role assumed by ingest-api pods"
  assume_role_policy = data.aws_iam_policy_document.pod_assume_role.json
}

data "aws_iam_policy_document" "ingest_api" {
  statement {
    sid       = "WriteDocuments"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${var.documents_bucket_arn}/documents/*"]
  }

  statement {
    sid       = "EnqueueJobs"
    effect    = "Allow"
    actions   = ["sqs:SendMessage"]
    resources = [var.jobs_queue_arn]
  }
}

resource "aws_iam_policy" "ingest_api" {
  name        = "${var.cluster_name}-ingest-api"
  description = "Write documents to S3 and enqueue processing jobs"
  policy      = data.aws_iam_policy_document.ingest_api.json
}

resource "aws_iam_role_policy_attachment" "ingest_api" {
  role       = aws_iam_role.ingest_api.name
  policy_arn = aws_iam_policy.ingest_api.arn
}

resource "aws_eks_pod_identity_association" "ingest_api" {
  cluster_name    = var.cluster_name
  namespace       = var.namespace
  service_account = "ingest-api"
  role_arn        = aws_iam_role.ingest_api.arn
}

# --- metadata-worker: reads documents, consumes jobs, reads the secret ---

resource "aws_iam_role" "metadata_worker" {
  name               = "${var.cluster_name}-metadata-worker"
  description        = "Role assumed by metadata-worker pods"
  assume_role_policy = data.aws_iam_policy_document.pod_assume_role.json
}

data "aws_iam_policy_document" "metadata_worker" {
  statement {
    sid       = "ReadDocuments"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${var.documents_bucket_arn}/documents/*"]
  }

  statement {
    sid    = "ConsumeJobs"
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:ChangeMessageVisibility",
    ]
    resources = [var.jobs_queue_arn]
  }
}

resource "aws_iam_policy" "metadata_worker" {
  name        = "${var.cluster_name}-metadata-worker"
  description = "Read documents from S3 and consume jobs from the queue"
  policy      = data.aws_iam_policy_document.metadata_worker.json
}

resource "aws_iam_role_policy_attachment" "metadata_worker" {
  role       = aws_iam_role.metadata_worker.name
  policy_arn = aws_iam_policy.metadata_worker.arn
}

resource "aws_eks_pod_identity_association" "metadata_worker" {
  cluster_name    = var.cluster_name
  namespace       = var.namespace
  service_account = "metadata-worker"
  role_arn        = aws_iam_role.metadata_worker.arn
}

# --- external-secrets: reads the database secret -------------------------

resource "aws_iam_role" "external_secrets" {
  name               = "${var.cluster_name}-external-secrets"
  description        = "Role assumed by the External Secrets Operator"
  assume_role_policy = data.aws_iam_policy_document.pod_assume_role.json
}

data "aws_iam_policy_document" "external_secrets" {
  statement {
    sid    = "ReadDatabaseSecret"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]
    resources = [var.database_secret_arn]
  }
}

resource "aws_iam_policy" "external_secrets" {
  name        = "${var.cluster_name}-external-secrets"
  description = "Read the database credentials secret"
  policy      = data.aws_iam_policy_document.external_secrets.json
}

resource "aws_iam_role_policy_attachment" "external_secrets" {
  role       = aws_iam_role.external_secrets.name
  policy_arn = aws_iam_policy.external_secrets.arn
}

resource "aws_eks_pod_identity_association" "external_secrets" {
  cluster_name    = var.cluster_name
  namespace       = "external-secrets"
  service_account = "external-secrets"
  role_arn        = aws_iam_role.external_secrets.arn
}

# --- keda: reads queue depth to make scaling decisions -------------------

resource "aws_iam_role" "keda" {
  name               = "${var.cluster_name}-keda"
  description        = "Role assumed by the KEDA operator to read queue metrics"
  assume_role_policy = data.aws_iam_policy_document.pod_assume_role.json
}

data "aws_iam_policy_document" "keda" {
  statement {
    sid       = "ReadQueueDepth"
    effect    = "Allow"
    actions   = ["sqs:GetQueueAttributes"]
    resources = [var.jobs_queue_arn]
  }
}

resource "aws_iam_policy" "keda" {
  name        = "${var.cluster_name}-keda"
  description = "Read queue attributes for autoscaling decisions"
  policy      = data.aws_iam_policy_document.keda.json
}

resource "aws_iam_role_policy_attachment" "keda" {
  role       = aws_iam_role.keda.name
  policy_arn = aws_iam_policy.keda.arn
}

resource "aws_eks_pod_identity_association" "keda" {
  cluster_name    = var.cluster_name
  namespace       = "keda"
  service_account = "keda-operator"
  role_arn        = aws_iam_role.keda.arn
}