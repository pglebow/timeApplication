# Variables
REGION=us-west-2
REPO_NAME=time-api

# Authenticate Docker to ECR
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin <your-account-id>.dkr.ecr.$REGION.amazonaws.com

# Create ECR repo if needed
aws ecr create-repository --repository-name $REPO_NAME

# Build and tag Docker image
docker build -t $REPO_NAME .
docker tag $REPO_NAME:latest <your-account-id>.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME:latest

# Push to ECR
docker push <your-account-id>.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME:latest