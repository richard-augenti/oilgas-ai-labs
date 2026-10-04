data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
  # Instance names are 1-indexed and zero-padded: oilgas-lab-01, oilgas-lab-02, ...
  learner_names = [
    for i in range(var.learner_count) :
    format("%s-%02d", var.name_prefix, i + 1)
  ]

  preload_dataset = var.dataset_url != ""

  # us-east-1 on-demand notebook-instance rates, verified against the AWS Price
  # List API on 2026-10-04. Used only for the cost estimate output.
  hourly_rate_usd = {
    "ml.t3.medium" = 0.05
    "ml.t3.large"  = 0.10
    "ml.m5.large"  = 0.115
  }
}

# ---------------------------------------------------------------------------
# Git repository — the "template"
#
# Registered once, then set as default_code_repository on every instance below.
# SageMaker clones it onto each instance's own EBS volume at launch, so every
# learner gets an independent working copy of the same source. Edits by one
# learner cannot affect another.
#
# No git credentials are configured because the repo is public. For a private
# repo, create a Secrets Manager secret holding {"username":..,"password":..}
# and set git_credential_secret_arn below.
# ---------------------------------------------------------------------------
resource "aws_sagemaker_code_repository" "labs" {
  code_repository_name = "oilgas-ai-labs"

  git_config {
    repository_url = var.repo_url
    # git_credential_secret_arn = aws_secretsmanager_secret.git.arn  # private repos only
  }
}

# ---------------------------------------------------------------------------
# Execution role
#
# Deliberately minimal. These instances read a public CSV and run pandas; they
# do not train models, call SageMaker APIs, or touch account data. Attaching
# AmazonSageMakerFullAccess here would hand every learner broad account access
# for no benefit. Add scoped policies if a lab genuinely needs them.
# ---------------------------------------------------------------------------
resource "aws_iam_role" "notebook" {
  name               = "${var.name_prefix}-notebook-execution"
  description        = "Execution role for oilgas-ai-labs training notebook instances"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

data "aws_iam_policy_document" "assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["sagemaker.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "notebook" {
  # CloudWatch Logs: without this the instance cannot emit logs, which makes
  # a failed launch effectively undiagnosable.
  statement {
    sid    = "CloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/sagemaker/*",
    ]
  }

  statement {
    sid       = "CloudWatchMetrics"
    effect    = "Allow"
    actions   = ["cloudwatch:PutMetricData"]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "cloudwatch:namespace"
      values   = ["/aws/sagemaker/NotebookInstances"]
    }
  }

  # Allows the idle-stop pattern and lets the lifecycle script identify itself.
  statement {
    sid       = "SelfDescribe"
    effect    = "Allow"
    actions   = ["sagemaker:DescribeNotebookInstance"]
    resources = ["arn:${data.aws_partition.current.partition}:sagemaker:${var.region}:${data.aws_caller_identity.current.account_id}:notebook-instance/${var.name_prefix}-*"]
  }
}

resource "aws_iam_role_policy" "notebook" {
  name   = "${var.name_prefix}-notebook-policy"
  role   = aws_iam_role.notebook.id
  policy = data.aws_iam_policy_document.notebook.json
}

# ---------------------------------------------------------------------------
# Optional lifecycle configuration — pre-stage the dataset
#
# Created only when var.dataset_url is set. Runs on every start (not just the
# first), so it is written to be idempotent: an existing file is left alone and
# a failed download never blocks the instance from coming up.
# ---------------------------------------------------------------------------
resource "aws_sagemaker_notebook_instance_lifecycle_configuration" "preload" {
  count = local.preload_dataset ? 1 : 0

  name = "${var.name_prefix}-preload-dataset"

  on_start = base64encode(<<-BASH
    #!/bin/bash
    # Intentionally NOT `set -e`: a dataset download failure must not prevent
    # the notebook instance from starting and stranding a learner.
    set -u

    DEST_DIR="/home/ec2-user/SageMaker/data"
    DEST_FILE="$DEST_DIR/$(basename "${var.dataset_url}")"

    mkdir -p "$DEST_DIR"

    if [ -s "$DEST_FILE" ]; then
      echo "Dataset already present at $DEST_FILE — skipping download."
    else
      echo "Downloading dataset to $DEST_FILE"
      curl -fsSL --max-time 300 -o "$DEST_FILE.part" "${var.dataset_url}" \
        && mv "$DEST_FILE.part" "$DEST_FILE" \
        && echo "Download complete." \
        || echo "WARNING: dataset download failed; learners can download manually."
    fi

    chown -R ec2-user:ec2-user "$DEST_DIR" || true
  BASH
  )
}

# ---------------------------------------------------------------------------
# One notebook instance per learner
#
# direct_internet_access is Enabled (the default when no subnet_id is given):
# the instance runs in an AWS-managed VPC with outbound internet, which is what
# lets the clone and the dataset download work with no VPC plumbing. That also
# sidesteps this account's single-subnet default VPC entirely.
# ---------------------------------------------------------------------------
resource "aws_sagemaker_notebook_instance" "learner" {
  count = var.learner_count

  name          = local.learner_names[count.index]
  role_arn      = aws_iam_role.notebook.arn
  instance_type = var.instance_type
  volume_size   = var.volume_size
  root_access   = var.root_access

  default_code_repository = aws_sagemaker_code_repository.labs.code_repository_name

  lifecycle_config_name = local.preload_dataset ? aws_sagemaker_notebook_instance_lifecycle_configuration.preload[0].name : null

  tags = {
    Name    = local.learner_names[count.index]
    Learner = format("%02d", count.index + 1)
  }
}
