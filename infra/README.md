# infra — training environment

Terraform for a disposable SageMaker notebook environment: **one instance per learner, each with its
own private clone of this repository.**

Built around SageMaker **Notebook Instances** rather than Studio, deliberately. For a one-off
two-hour session that means no domain, no IAM Identity Center wiring, no VPC decisions, and learners
who need **no AWS account at all** — they open a presigned link.

## How each learner gets their own copy

`aws_sagemaker_code_repository` registers this repo once. Every instance sets it as
`default_code_repository`, so SageMaker clones it onto **that instance's own EBS volume** at launch.

```
                      oilgas-ai-labs (GitHub)
                               |
                 aws_sagemaker_code_repository
                               |
          +--------------------+--------------------+
          |                    |                    |
    oilgas-lab-01        oilgas-lab-02        oilgas-lab-03
    own EBS volume       own EBS volume       own EBS volume
    own clone            own clone            own clone
```

Same source, independent working copies. One learner's edits cannot reach another's. This is the
thing a **shared space** would get wrong — that model puts everyone in one copy of one notebook.

## Usage

```bash
cd infra
cp terraform.tfvars.example terraform.tfvars   # then set learner_count
terraform init
terraform plan
terraform apply
```

Then, on the morning of delivery:

```bash
./scripts/presigned-urls.sh            # 12h links, one per learner
./scripts/presigned-urls.sh 43200 csv  # CSV, for a mail merge
```

Afterwards — **this is the step that matters for cost**:

```bash
terraform destroy
```

## Timing

Instances take roughly **5 minutes** to reach `InService`, and they provision in parallel. Launch
them *before* learners arrive, never live. `presigned-urls.sh` reports any instance that is not yet
`InService` instead of handing out a link that lands on an error page.

## Cost

| Item | Rate | 20 learners × 2 hrs |
|---|---|---|
| `ml.t3.medium` compute | $0.0500/hr | **≈ $2.00** |
| EBS, 5 GB/instance | ~$0.10/GB-month | pennies if destroyed same day |

Rates are us-east-1 on-demand, verified against the AWS Price List API on 2026-10-04. The free tier
(250 hours of `ml.t3.medium` in the first two months) may absorb the compute entirely.

**The trap is storage, not compute.** Stopping an instance halts compute billing but the EBS volume
keeps charging until the instance is *deleted*. Twenty forgotten volumes cost more than the training
did. `terraform destroy` removes both — use it.

## Design decisions worth knowing

- **Minimal IAM.** The execution role grants CloudWatch Logs, scoped metrics, and self-describe —
  nothing more. These instances read a public CSV and run pandas. Attaching
  `AmazonSageMakerFullAccess` would give every learner broad account access for no benefit. Add
  scoped policies if a lab genuinely needs them.
- **No VPC configuration.** With no `subnet_id`, instances run in an AWS-managed VPC with outbound
  internet, which is what makes the git clone and dataset download work with zero network plumbing.
  It also sidesteps this account's single-subnet default VPC.
- **`learner_count` defaults to 2.** A bare `terraform apply` gives you a dry run, not a surprise
  classroom.
- **The dataset preload is opt-in and failure-tolerant.** The lifecycle script deliberately omits
  `set -e`: a failed download must never stop an instance from launching and strand a learner. It is
  also idempotent, since `on_start` runs on every start, not just the first.
- **No idle auto-stop.** It is a common pattern, but it adds a failure mode that can stop an instance
  mid-session. `terraform destroy` is the reliable control. Add auto-stop if these ever run unattended.

## Private repository

The repo is public, so no credentials are configured. To use a private repo, create a Secrets Manager
secret holding `{"username": "...", "password": "<PAT>"}` and set `git_credential_secret_arn` in the
`git_config` block in `main.tf`.

## Files

| File | Purpose |
|---|---|
| `main.tf` | Code repository, IAM role, optional lifecycle config, notebook instances |
| `variables.tf` | Inputs, with validation |
| `outputs.tf` | Instance names, role ARN, cost estimate |
| `versions.tf` | Provider constraints and default tags |
| `terraform.tfvars.example` | Copy to `terraform.tfvars` (gitignored) |
| `scripts/presigned-urls.sh` | Per-learner access links |
