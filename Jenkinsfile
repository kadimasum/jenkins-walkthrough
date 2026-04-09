pipeline {
    agent any
    
    environment {
        // AWS credentials configured in Jenkins
        AWS_CREDENTIALS = credentials('aws-deploy-credentials')
        AWS_REGION = 'us-east-1'
        
        // Update these with values from: terraform output
        S3_BUCKET = 'jenkins-walkthrough-demo-20260409-abc123'  // Change to your bucket
        CLOUDFRONT_DISTRIBUTION_ID = 'd1234abcd.cloudfront.net' // Change to your distribution ID
    }
    
    stages {
        stage('Clone repo') {
            steps {
                git branch: 'master', url:'https://github.com/kadimasum/jenkins-walkthrough'
                echo "Code checked out from ${GIT_BRANCH}"
            }
        }
        
        stage('Install Dependencies') {
            steps {
                sh 'npm install'
                echo "Dependencies installed"
            }
        }
        
        stage('Lint') {
            steps {
                sh 'npm run lint'
                echo "Code linting passed"
            }
        }
        
        stage('Test') {
            steps {
                sh 'npm test'
                echo "Unit tests passed"
            }
        }
        
        stage('Build') {
            steps {
                sh 'npm run build'
                echo "Production build created"
                sh 'ls -la dist/'
            }
        }
        
        stage('Deploy to S3') {
            steps {
                withAWS(credentials: 'aws-deploy-credentials', region: "${AWS_REGION}") {
                    sh '''
                        echo "Uploading files to S3..."
                        aws s3 sync dist/ s3://${S3_BUCKET}/ --delete --cache-control "max-age=3600" --exclude ".git*"
                        echo "Files uploaded to S3"
                    '''
                }
            }
        }
        
        stage('Invalidate CloudFront Cache') {
            steps {
                withAWS(credentials: 'aws-deploy-credentials', region: "${AWS_REGION}") {
                    sh '''
                        echo "Invalidating CloudFront cache..."
                        DISTRIBUTION_ID="${CLOUDFRONT_DISTRIBUTION_ID}"
                        aws cloudfront create-invalidation \
                            --distribution-id ${DISTRIBUTION_ID} \
                            --paths "/*"
                        echo "CloudFront cache invalidated"
                    '''
                }
            }
        }
    }
    
    post {
        success {
            echo """
            ========================================
            DEPLOYMENT SUCCESSFUL!
            ========================================
            Site is live at:
            https://${CLOUDFRONT_DISTRIBUTION_ID}
            
            S3 Bucket: ${S3_BUCKET}
            CloudFront Distribution: ${CLOUDFRONT_DISTRIBUTION_ID}
            Build: ${BUILD_NUMBER}
            ========================================
            """
        }
        
        failure {
            echo "Deployment failed. Check logs above for details."
        }
        
        always {
            cleanWs()
        }
    }
}
