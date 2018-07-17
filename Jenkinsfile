pipeline {

    agent {
        docker {
            image 'vincentasante/jenkins-login-microservice'
            args '-v /usr/local/bundle:/usr/local/bundle -v /run/docker.sock:/var/run/docker.sock'
        }
    }
    environment {
        POSTGRES_USER=credentials("POSTGRES_USER")
        POSTGRES_PASSWORD=credentials("POSTGRES_PASSWORD")
        POSTGRES_HOST=credentials("POSTGRES_HOST")
        POSTGRES_DB=credentials("POSTGRES_DB")
        POSTGRES_TEST_DB=credentials("POSTGRES_TEST_DB")
        GMAIL_USERNAME=credentials("GMAIL_USERNAME")
        GMAIL_PASSWORD=credentials("GMAIL_PASSWORD")
        GOOGLE_CLIENT_ID=credentials("GOOGLE_CLIENT_ID")
        GOOGLE_CLIENT_SECRET=credentials("GOOGLE_CLIENT_SECRET")
        DOMAIN_PRODUCTION=credentials("DOMAIN_PRODUCTION")
        DOMAIN_STAGING=credentials("DOMAIN_STAGING")
        DOMAIN_SANDBOX=credentials("DOMAIN_SANDBOX")
        PROJECT_ID=credentials("PROJECT_ID")
        SERVICE_KEY=credentials("SERVICE_KEY")
        SERVICE_ACCOUNT_EMAIL=credentials("SERVICE_ACCOUNT_EMAIL")
        VOF_INFRASTRUCTURE_REPO=credentials("VOF_INFRASTRUCTURE_REPO")
        GCLOUD_VOF_BUCKET=credentials("GCLOUD_VOF_BUCKET")
        SLACK_CHANNEL=credentials("SLACK_CHANNEL")
        SLACK_CHANNEL_HOOK=credentials("SLACK_CHANNEL_HOOK")
        BUGSNAG_KEY=credentials("BUGSNAG_KEY")
        USER_MICROSERVICE_API_URL=credentials("USER_MICROSERVICE_API_URL")
        USER_MICROSERVICE_API_TOKEN=credentials("USER_MICROSERVICE_API_TOKEN")
        STAGING_RESERVED_IP=credentials("STAGING_RESERVED_IP")
        SANDBOX_RESERVED_IP=credentials("SANDBOX_RESERVED_IP")
        PRODUCTION_RESERVED_IP=credentials("PRODUCTION_RESERVED_IP")
        PRODUCTION_BUGSNAG_KEY=credentials("PRODUCTION_BUGSNAG_KEY")
        PRIVATE_KEY=credentials("PRIVATE_KEY")
    }
    stages {
        stage('Build') {
            steps {
                sh 'chmod 777 ./jenkins_ci/jenkins_scripts/pg-setup.sh'
                sh './jenkins_ci/jenkins_scripts/pg-setup.sh'
                sh 'sudo chmod -R 777 /usr/local && bundle install'
                sh "bundle exec rails db:setup"
                sh "bundle exec rake db:migrate"
            }
        }
        stage('Test'){
            steps {
                echo 'testing...'
                sh '#!/bin/bash \n ' +
                'bundle exec rspec spec'
            }
        }

        stage('Deploy') {
            when {
                anyOf {
                    branch 'master';
                    branch 'develop';
                    branch '*sandbox*'
                }
            }
            steps {
                echo 'deploying...'
                sh 'sudo find / -name docker'
                sh 'chmod 777 ./jenkins_ci/jenkins_scripts/deploy.sh'
                sh './jenkins_ci/jenkins_scripts/deploy.sh'
            }
        }
    }
}