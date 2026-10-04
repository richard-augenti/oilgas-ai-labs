output "notebook_instance_names" {
  description = "Names of the provisioned notebook instances, one per learner."
  value       = aws_sagemaker_notebook_instance.learner[*].name
}

output "code_repository_name" {
  description = "The registered SageMaker code repository cloned into each instance."
  value       = aws_sagemaker_code_repository.labs.code_repository_name
}

output "execution_role_arn" {
  description = "IAM execution role shared by the notebook instances."
  value       = aws_iam_role.notebook.arn
}

output "dataset_preload_enabled" {
  description = "Whether a lifecycle configuration pre-stages the dataset onto each instance."
  value       = local.preload_dataset
}

output "estimated_cost_per_hour_usd" {
  description = <<-EOT
    Rough compute-only cost while all instances are RUNNING. Excludes EBS, which
    keeps billing on stopped instances until they are deleted. Rates are
    us-east-1 on-demand, verified against the AWS Price List API on 2026-10-04;
    an instance type not in the table reports "unknown rate" rather than guessing.
  EOT
  value       = lookup(local.hourly_rate_usd, var.instance_type, null) == null ? format("unknown rate for %s - check the AWS Pricing Calculator", var.instance_type) : format("$%.2f/hr for %d x %s", var.learner_count * local.hourly_rate_usd[var.instance_type], var.learner_count, var.instance_type)
}

output "next_step" {
  description = "How to hand access to learners."
  value       = "Generate per-learner links: ./scripts/presigned-urls.sh"
}
