#!/usr/bin/env bash
#
# Generate one presigned JupyterLab URL per learner.
#
# Presigned URLs let learners open JupyterLab WITHOUT an AWS account, an IAM
# user, or an SSO login. Hand each person exactly one link.
#
# Usage:
#   ./scripts/presigned-urls.sh                 # 12h links for every instance
#   ./scripts/presigned-urls.sh 7200            # 2h links
#   ./scripts/presigned-urls.sh 43200 csv       # CSV for a mail merge
#
set -euo pipefail

DURATION="${1:-43200}" # seconds; AWS maximum is 43200 (12 hours)
FORMAT="${2:-text}"
REGION="${AWS_REGION:-us-east-1}"
PREFIX="${NAME_PREFIX:-oilgas-lab}"

if [ "$DURATION" -lt 1800 ] || [ "$DURATION" -gt 43200 ]; then
  echo "ERROR: duration must be between 1800 and 43200 seconds." >&2
  exit 1
fi

mapfile -t INSTANCES < <(
  aws sagemaker list-notebook-instances \
    --region "$REGION" \
    --name-contains "$PREFIX" \
    --query 'NotebookInstances[].NotebookInstanceName' \
    --output text | tr '\t' '\n' | sort
)

if [ "${#INSTANCES[@]}" -eq 0 ]; then
  echo "No notebook instances found matching prefix '$PREFIX' in $REGION." >&2
  echo "Run 'terraform apply' first." >&2
  exit 1
fi

[ "$FORMAT" = "csv" ] && echo "instance,status,url"

for NAME in "${INSTANCES[@]}"; do
  STATUS=$(aws sagemaker describe-notebook-instance \
    --region "$REGION" \
    --notebook-instance-name "$NAME" \
    --query 'NotebookInstanceStatus' --output text)

  # A presigned URL for a non-running instance is useless — the learner lands
  # on an error page. Surface that here rather than at the start of the class.
  if [ "$STATUS" != "InService" ]; then
    if [ "$FORMAT" = "csv" ]; then
      echo "$NAME,$STATUS,"
    else
      printf '%-24s  %-12s  (not ready - start it before generating a link)\n' "$NAME" "$STATUS"
    fi
    continue
  fi

  URL=$(aws sagemaker create-presigned-notebook-instance-url \
    --region "$REGION" \
    --notebook-instance-name "$NAME" \
    --session-expiration-duration-in-seconds "$DURATION" \
    --query 'AuthorizedUrl' --output text)

  # Land learners in JupyterLab rather than the legacy Jupyter tree view.
  URL="${URL}&view=lab"

  if [ "$FORMAT" = "csv" ]; then
    echo "$NAME,$STATUS,\"$URL\""
  else
    printf '%-24s  %s\n\n' "$NAME" "$URL"
  fi
done

if [ "$FORMAT" != "csv" ]; then
  echo "Links expire in $((DURATION / 3600))h. Generate them the morning of delivery."
fi
