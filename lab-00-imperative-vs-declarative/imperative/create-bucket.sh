#!/usr/bin/env bash
# =============================================================================
# IMPERATIVE S3 Bucket Creation Script
#
# This script is IMPERATIVE -- we are giving the computer step-by-step orders:
#   1. Set a bucket name
#   2. Call the AWS API to create it
#
# Notice: there is NO state tracking. If the bucket already exists this script
# will fail on the second run. That is intentional -- it demonstrates why
# imperative infrastructure management breaks down at scale.
# =============================================================================

# ---------------------------------------------------------------------------
# Step 1: Define the bucket name.
# STUDENTS: Replace the value below with a globally unique bucket name.
# Example: shopsmart-images-lab00-jd-8294
# ---------------------------------------------------------------------------
BUCKET_NAME="shopsmart-images-lab00-CHANGE-ME"

# ---------------------------------------------------------------------------
# Step 2: Set the AWS region.
# ---------------------------------------------------------------------------
REGION="us-east-1"

# ---------------------------------------------------------------------------
# Step 3: Create the S3 bucket.
# This is a direct, imperative command: "AWS, create this bucket NOW."
# It does not check whether the bucket already exists.
# ---------------------------------------------------------------------------
echo "Creating S3 bucket: ${BUCKET_NAME} in region ${REGION}..."

aws s3api create-bucket \
  --bucket "${BUCKET_NAME}" \
  --region "${REGION}"

# ---------------------------------------------------------------------------
# Step 4: Print the result.
# ---------------------------------------------------------------------------
if [ $? -eq 0 ]; then
  echo "SUCCESS: Bucket '${BUCKET_NAME}' created."
else
  echo "ERROR: Failed to create bucket '${BUCKET_NAME}'."
  echo "If the bucket already exists, this script has no way to handle that."
  echo "This is the problem with imperative scripts -- no idempotency."
  exit 1
fi
