#!/bin/bash

set -e

# ===== CONFIG =====
AWS_PROFILE="deployer"
AWS_REGION="us-west-2"
REPO_NAME="time-api"
ACCOUNT_ID=$(aws sts get-caller-identity --profile $AWS_PROFILE --query Account --output text)
ECR_URI="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}"
LOAD_BALANCER_DOMAIN=""
TARGET_GROUP_ARN=""
INFRA_DIR="infra"
SCRIPT_PATH=$(dirname "$(readlink -f "$0")")
TF_VARS=${SCRIPT_PATH}/terraform.tfvars

echo "🧹 Checking for previous infra..."
cd $INFRA_DIR
if [ -f terraform.tfstate ]; then
  echo "🚨 Terraform state found. Destroying previous deployment..."
  AWS_PROFILE=$AWS_PROFILE terraform destroy -auto-approve -var-file=${TF_VARS} || true
fi
cd ..

echo "🔧 Building JAR..."
./mvnw clean package -DskipTests

echo "🐳 Building Docker image..."
docker buildx build --platform linux/amd64 -t ${REPO_NAME} . --load

echo "🔁 Tagging Docker image as ${ECR_URI}..."
docker tag ${REPO_NAME}:latest ${ECR_URI}

echo "🔐 Logging in to ECR..."
aws ecr get-login-password --region $AWS_REGION --profile $AWS_PROFILE \
  | docker login --username AWS --password-stdin ${ECR_URI}

echo "📦 Creating ECR repository if needed..."
aws ecr describe-repositories --repository-names $REPO_NAME \
  --region $AWS_REGION --profile $AWS_PROFILE > /dev/null 2>&1 || \
  aws ecr create-repository --repository-name $REPO_NAME \
    --region $AWS_REGION --profile $AWS_PROFILE

echo "🚀 Pushing image to ECR..."
docker push ${ECR_URI}

echo "📁 Moving into $INFRA_DIR and applying Terraform..."
cd $INFRA_DIR
terraform init
AWS_PROFILE=$AWS_PROFILE terraform apply -auto-approve -var-file=${TF_VARS}

# Get Load Balancer DNS name
LOAD_BALANCER_DOMAIN=$(terraform output -raw load_balancer_url)
cd ..

# Get target group ARN
echo "🔍 Locating target group ARN..."
TARGET_GROUP_ARN=$(aws elbv2 describe-target-groups \
  --names time-api-tg \
  --region $AWS_REGION \
  --profile $AWS_PROFILE \
  --query 'TargetGroups[0].TargetGroupArn' \
  --output text)

# Wait for ECS task target to be healthy
echo "⏳ Waiting for ECS target to become healthy..."
for i in {1..15}; do
  STATUS=$(aws elbv2 describe-target-health \
    --target-group-arn $TARGET_GROUP_ARN \
    --region $AWS_REGION \
    --profile $AWS_PROFILE \
    --query 'TargetHealthDescriptions[0].TargetHealth.State' \
    --output text 2>/dev/null || echo "not-ready")

  if [[ "$STATUS" == "healthy" ]]; then
    echo "✅ Target is healthy."
    break
  fi

  echo "⏳ Status: $STATUS (retrying in 10s)..."
  sleep 10
done

# Final check
if [[ "$STATUS" != "healthy" ]]; then
  echo "❌ Target never became healthy. Check ECS logs and target group config."
  exit 1
fi

# Test endpoint
echo "🌐 Testing app at: http://$LOAD_BALANCER_DOMAIN/time"
curl -s "http://$LOAD_BALANCER_DOMAIN/time" || {
  echo "❌ App did not respond correctly."
  exit 1
}

echo -e "\n🎉 App deployed and responding."
