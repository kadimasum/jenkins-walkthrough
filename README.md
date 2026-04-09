# Jenkins Walkthrough: React App + AWS Deployment Pipeline

This repository contains:

- A React single-page application built with Vite
- Unit tests using Vitest and Testing Library
- A Jenkins pipeline that installs, lints, tests, builds, and deploys to AWS S3
- CloudFront cache invalidation after deployment
- Terraform configuration to provision AWS resources

## Repository Structure

- `src/` - React application source code and tests
- `Jenkinsfile` - CI/CD pipeline definition
- `terraform/` - Infrastructure as code for S3, CloudFront, IAM, and backend config
- `Dockerfile` - Custom Jenkins image with required runtime dependencies

## Application Setup

### Prerequisites

- Node.js 20+
- npm
- Git

### Install Dependencies

```bash
npm install
```

### Run Locally

```bash
npm run dev
```

Vite will print a local URL, usually `http://localhost:5173`.

### Run Quality Checks

```bash
npm run lint
npm test
npm run build
```

## How the Pipeline Works

The Jenkins pipeline in `Jenkinsfile` runs these stages in order:

1. Clone repo
2. Install dependencies (`npm install`)
3. Lint (`npm run lint`)
4. Test (`npm test`)
5. Build (`npm run build`)
6. Deploy static assets to S3 (`aws s3 sync`)
7. Invalidate CloudFront cache (`aws cloudfront create-invalidation`)

If any stage fails, later stages are skipped and the job ends as failed.

## Jenkins Credentials Setup

Create an AWS credential in Jenkins with ID `aws-deploy-credentials`.

Pipeline binding uses:

```groovy
withCredentials([[
	$class: 'AmazonWebServicesCredentialsBinding',
	credentialsId: 'aws-deploy-credentials',
	accessKeyVariable: 'AWS_ACCESS_KEY_ID',
	secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
]])
```

The AWS CLI then authenticates via `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`.

## Configure Deployment Targets in Jenkinsfile

Set these environment values in `Jenkinsfile` from Terraform outputs:

- `S3_BUCKET`
- `CLOUDFRONT_DISTRIBUTION_ID`
- `AWS_REGION`

Useful commands:

```bash
cd terraform
terraform output s3_bucket_id
terraform output cloudfront_distribution_id
```

## Running Jenkins in Docker

### Option A: Build and run the custom image (recommended)

This repository includes a `Dockerfile` that installs:

- `libatomic1` (required by Node runtime on some environments)
- AWS CLI v2 (required for deploy stages)

Build and run:

```bash
docker build -t custom-jenkins:latest .
docker run -d \
	--name jenkins \
	-p 8080:8080 \
	-p 50000:50000 \
	-v jenkins_home:/var/jenkins_home \
	custom-jenkins:latest
```

### Option B: Update an existing running Jenkins container (no rebuild)

If you already have a running Jenkins container and do not want to recreate it, install dependencies in-place.

1. Identify the container ID or name:

```bash
docker ps
```

2. Install dependencies and AWS CLI in the current container:

```bash
docker exec -u root <jenkins-container> bash -c "
	apt-get update -qq &&
	apt-get install -y curl unzip libatomic1 &&
	curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o /tmp/awscliv2.zip &&
	unzip -q /tmp/awscliv2.zip -d /tmp &&
	/tmp/aws/install &&
	rm -rf /tmp/awscliv2.zip /tmp/aws &&
	aws --version
"
```

3. Verify from inside the container:

```bash
docker exec -it <jenkins-container> bash -c "node --version && npm --version && aws --version"
```

Important: in-place container installs are not persistent if the container is recreated. Use the custom image for a durable setup.

## Terraform Infrastructure

Terraform files are in `terraform/` and use modules for:

- S3
- CloudFront
- IAM deployment user
- Local backend configuration

Quick start:

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

## Triggering CI/CD

Once Jenkins is configured:

1. Push changes to GitHub
2. Jenkins webhook triggers the pipeline
3. The app is validated and deployed automatically
4. CloudFront cache is invalidated so latest assets are served

## Common Failure Checks

- `node: error while loading shared libraries: libatomic.so.1`
	- Install `libatomic1` in the Jenkins container

- `aws: not found`
	- Install AWS CLI in the Jenkins container

- Credentials binding or auth errors
	- Confirm Jenkins credential ID is `aws-deploy-credentials`
	- Confirm credential type is AWS Credentials

- S3/CloudFront permission failures
	- Verify IAM policy and bucket/distribution IDs in `Jenkinsfile`
