#!/bin/bash

set -ex
set -o pipefail

declare_env_variables() {
    echo "Declaring environment variables"
  RESERVED_IP=${STAGING_RESERVED_IP}
  RAILS_ENV="staging"

  if [ "$GIT_BRANCH" == 'master' ]; then
    RESERVED_IP=${PRODUCTION_RESERVED_IP}
    BUGSNAG_KEY=${PRODUCTION_BUGSNAG_KEY}
    RAILS_ENV="production"
  fi

  if [[ "$GIT_BRANCH" =~ 'sandbox' ]]; then
    RESERVED_IP=${SANDBOX_RESERVED_IP}
    RAILS_ENV="sandbox"
  fi

  POSTGRES_DB="${RAILS_ENV}-login-microservice-database"
  STATE_FILE="state/${RAILS_ENV}/login-microservice/terraform.tfstate"
  EMOJIS=(":celebrate:"  ":party_dinosaur:"  ":andela:" ":aw-yeah:" ":carlton-dance:" ":partyparrot:" ":dancing-penguin:" ":aww-yeah-remix:" )
  RANDOM=$$$(date +%s)
  EMOJI=${EMOJIS[$RANDOM % ${#EMOJIS[@]} ]}
  GIT_REPO=$(echo ${GIT_URL%%.git*})
  COMMIT_LINK="${GIT_REPO}/commit/${GIT_COMMIT}"
  DEPLOYMENT_TEXT="Tag: ${PACKER_IMG_TAG} has just been deployed as the latest ${PROJECT_ID} in ${RAILS_ENV}  $COMMIT_LINK "
  DEPLOYMENT_CHANNEL=${SLACK_CHANNEL}
  IMG_TAG="$(git rev-parse --short HEAD)"
  SLACK_DEPLOYMENT_TEXT="Git Commit Tag: <$COMMIT_LINK|${IMG_TAG}> has just been deployed to *${PROJECT_ID}* in *${RAILS_ENV}* ${EMOJI}"
}

# get scripts to create infrastructure
check_out_infrastructure_code() {
    echo "Checkout infrastructure code"

    mkdir -p /home/jenkins/vof-repo

    if [ "$GIT_BRANCH" == "master" ]; then
      git clone -b login-master ${VOF_INFRASTRUCTURE_REPO} /home/jenkins/vof-repo
    else
      git clone -b login-develop ${VOF_INFRASTRUCTURE_REPO} /home/jenkins/vof-repo
    fi
}

# create terraform .tfvars file
create_tfvars_file(){
    echo "Creating login microservice secrets"

  touch /home/jenkins/terraform.tfvars
  sudo cat <<EOF > /home/jenkins/vof-repo/login-micro-service/terraform.tfvars
login_microservice_state_path="${STATE_FILE}"
login_microservice_project_id="${PROJECT_ID}"
login_microservice_bucket="${GCLOUD_VOF_BUCKET}"
login_microservice_env_name="${RAILS_ENV}"
reserved_env_ip="${RESERVED_IP}"
service_account_email="${SERVICE_ACCOUNT_EMAIL}"
slack_channel="${SLACK_CHANNEL}"
slack_webhook_url="${SLACK_CHANNEL_HOOK}"
bugsnag_key="${BUGSNAG_KEY}"
user_microservice_api_url="${USER_MICROSERVICE_API_URL}"
user_microservice_api_token="${USER_MICROSERVICE_API_TOKEN}"
EOF

    if [ "$RAILS_ENV" == "production" ]; then
        sudo cat <<EOF >> /home/jenkins/vof-repo/login-micro-service/terraform.tfvars
max_instances="${PRODUCTION_MAX_INSTANCES}"
db_instance_tier="${PRODUCTION_DB_TIER}"
EOF
    fi

}

authenticate_service_account() {
  if gcloud auth activate-service-account --key-file=${SERVICE_KEY}; then
    echo "Service account authentication successful"
    if ! gcloud container clusters get-credentials login-microservice-${RAILS_ENV}-cluster --zone europe-west1-b --project ${PROJECT_ID}; then
      echo "Creating a cluster"
      gcloud beta container --project "${PROJECT_ID}" clusters create "login-microservice-${RAILS_ENV}-cluster" --zone "europe-west1-b" --username "admin" --cluster-version "1.8.10-gke.0" --machine-type "n1-standard-1" --image-type "COS" --disk-size "100" --scopes "https://www.googleapis.com/auth/compute","https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --num-nodes "2" --network "default" --enable-cloud-logging --enable-cloud-monitoring --subnetwork "default" --addons HorizontalPodAutoscaling,HttpLoadBalancing,KubernetesDashboard --enable-autorepair
      gcloud container clusters get-credentials login-microservice-${RAILS_ENV}-cluster --zone europe-west1-b --project ${PROJECT_ID}
    fi
    sudo chmod 777 /var/lib/jenkins/workspace
    gsutil cp gs://vof-tracker-app/ssl/andela_certificate.crt /var/lib/jenkins/workspace/andela_certificate.crt
    gsutil cp gs://vof-tracker-app/ssl/andela_key.key /var/lib/jenkins/workspace/andela_key.key
  fi
}

initialise_terraform() {
    echo "Initializing terraform"

    pushd /home/jenkins/vof-repo/login-micro-service
        cat ${SERVICE_KEY} > /home/jenkins/vof-repo/shared/account.json
        terraform init -backend-config="path=${STATE_FILE}" -backend-config="project=${PROJECT_ID}" -backend-config="bucket=${GCLOUD_VOF_BUCKET}" -var="env_name=${RAILS_ENV}" -var="reserved_env_ip=${RESERVED_IP}"
    popd
}

build_infrastructure() {
    echo "Building VOF infrastructure and deploying VOF application"

    pushd /home/jenkins/vof-repo/login-micro-service
      touch terraform_output.log
        terraform apply --parallelism=1 2>&1 | tee terraform_output.log

        echo "Get values of needed resources"
        DB_USERNAME="$(terraform output db-username)"
        DB_PASSWORD="$(terraform output db-password)"
        DB_HOST="$(terraform output db-host)"

    popd
}

# create the secrets.yml file from env variables
create_secrets(){
    echo "Creating login microservice secrets"

  touch ./secrets.yml
  sudo cat <<EOF > ./secrets.yml
kind: Secret
apiVersion: v1
metadata:
    # Name to reference the secret
    name: vof-${RAILS_ENV}-login-microservice-secrets
type: Opaque
data:
    # Key value pairs of all your senstive records
    POSTGRES_USER: '$(echo -n ${DB_USERNAME} | base64)'
    POSTGRES_PASSWORD: '$(echo -n ${DB_PASSWORD} | base64)'
    POSTGRES_HOST: '$(echo -n ${DB_HOST} | base64)'
    POSTGRES_DB: '$(echo -n ${POSTGRES_DB} | base64)'
    BUCKET_NAME: '$(echo -n ${GCLOUD_VOF_BUCKET} | base64)'
    POSTGRES_TEST_DB: '$(echo -n ${POSTGRES_TEST_DB} | base64)'
    GMAIL_USERNAME: '$(echo -n ${GMAIL_USERNAME} | base64)'
    GMAIL_PASSWORD: '$(echo -n ${GMAIL_PASSWORD} | base64)'
    GOOGLE_CLIENT_SECRET: '$(echo -n ${GOOGLE_CLIENT_SECRET} | base64)'
    DOMAIN_PRODUCTION: '$(echo -n ${DOMAIN_PRODUCTION} | base64)'
    DOMAIN_STAGING: '$(echo -n ${DOMAIN_STAGING} | base64)'
    DOMAIN_SANDBOX: '$(echo -n ${DOMAIN_SANDBOX} | base64)'
    RAILS_ENV: '$(echo -n ${RAILS_ENV} | base64)'
EOF
}

# create the secrets.yml file from env variables
create_service(){
    echo "Creating login microservice service file"

  touch ./service.yml
  sudo cat <<EOF > ./service.yml
kind: Service
apiVersion: v1
metadata:
  name: login-service-${RAILS_ENV}
spec:
  selector:
    run: login-service-${RAILS_ENV}
  ports:
    - name: http
      protocol: TCP
      port: 80
      targetPort: 3000
    - name: https
      protocol: TCP
      port: 443
      targetPort: 3000
  loadBalancerIP: ${RESERVED_IP}
  type: LoadBalancer
EOF
}

# create the deployment.yml file
create_deployment(){
    echo "Creating login microservice deployment"

  touch ./deployment.yml
  sudo cat <<EOF > ./deployment.yml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: login-service-${RAILS_ENV}
  labels:
    run: login-service-${RAILS_ENV}
spec:
  replicas: 2
  template:
    metadata:
      labels:
        run: login-service-${RAILS_ENV}
    spec:
      containers:
      - name: login-service-${RAILS_ENV}
        image: gcr.io/${PROJECT_ID}/login-microservice:${GIT_COMMIT}
        env:
          - name: POSTGRES_USER
            valueFrom:
              secretKeyRef:
                  name: vof-${RAILS_ENV}-login-microservice-secrets
                  key: POSTGRES_USER
          - name: POSTGRES_PASSWORD
            valueFrom:
              secretKeyRef:
                  name: vof-${RAILS_ENV}-login-microservice-secrets
                  key: POSTGRES_PASSWORD
          - name: POSTGRES_HOST
            valueFrom:
              secretKeyRef:
                  name: vof-${RAILS_ENV}-login-microservice-secrets
                  key: POSTGRES_HOST
          - name: POSTGRES_DB
            valueFrom:
              secretKeyRef:
                  name: vof-${RAILS_ENV}-login-microservice-secrets
                  key: POSTGRES_DB
          - name: POSTGRES_TEST_DB
            valueFrom:
              secretKeyRef:
                  name: vof-${RAILS_ENV}-login-microservice-secrets
                  key: POSTGRES_TEST_DB
          - name: GMAIL_USERNAME
            valueFrom:
              secretKeyRef:
                  name: vof-${RAILS_ENV}-login-microservice-secrets
                  key: GMAIL_USERNAME
          - name: GMAIL_PASSWORD
            valueFrom:
              secretKeyRef:
                  name: vof-${RAILS_ENV}-login-microservice-secrets
                  key: GMAIL_PASSWORD
          - name: GOOGLE_CLIENT_SECRET
            valueFrom:
              secretKeyRef:
                  name: vof-${RAILS_ENV}-login-microservice-secrets
                  key: GOOGLE_CLIENT_SECRET
          - name: DOMAIN_PRODUCTION
            valueFrom:
              secretKeyRef:
                  name: vof-${RAILS_ENV}-login-microservice-secrets
                  key: DOMAIN_PRODUCTION
          - name: DOMAIN_STAGING
            valueFrom:
              secretKeyRef:
                  name: vof-${RAILS_ENV}-login-microservice-secrets
                  key: DOMAIN_STAGING
          - name: DOMAIN_SANDBOX
            valueFrom:
              secretKeyRef:
                  name: vof-${RAILS_ENV}-login-microservice-secrets
                  key: DOMAIN_SANDBOX
          - name: RAILS_ENV
            valueFrom:
              secretKeyRef:
                  name: vof-${RAILS_ENV}-login-microservice-secrets
                  key: RAILS_ENV
          - name: BUCKET_NAME
            valueFrom:
              secretKeyRef:
                  name: vof-${RAILS_ENV}-login-microservice-secrets
                  key: BUCKET_NAME
        - args:
            - /login-service-${RAILS_ENV}
            - "--default-backend-service=$(POD_NAMESPACE)/login-service-${RAILS_ENV}"
            - "--default-ssl-certificate=$(POD_NAMESPACE)/tls-certificate"
            env:
              - name: POD_NAME
                valueFrom:
                  fieldRef:
                    fieldPath: metadata.name
              - name: POD_NAMESPACE
                valueFrom:
                  fieldRef:
                    fieldPath: metadata.namespace
        ports:
        - containerPort: 443
          name: https
          protocol: TCP
        - containerPort: 80
          name: http
          protocol: TCP
EOF
}

build_docker_image_and_deploy(){
    echo "Running rolling update on application"

    # delete the secret if it exists
    if kubectl delete secrets vof-${RAILS_ENV}-login-microservice-secrets; then
      echo "Old secrets deleted.."
    fi

    kubectl create -f secrets.yml

    if kubectl create secret tls tls-certificate --key /var/lib/jenkins/workspace/andela_key.key --cert /var/lib/jenkins/workspace/andela_certificate.crt; then
       echo 'Created tls certificate'
    fi

    # create an account.json file for use within the docker image being built
    cat ${SERVICE_KEY} > account.json
    sudo /usr/bin/docker build --build-arg google_client_id=${GOOGLE_CLIENT_ID} --build-arg private_key="${PRIVATE_KEY}" -t gcr.io/${PROJECT_ID}/login-microservice:$GIT_COMMIT .

    # only create the deployment if it does not already exist, otherwise
    # push the image, and set the latest image in the deployment
    if kubectl get deployments login-service-${RAILS_ENV}; then
      /home/jenkins/google-cloud-sdk/bin/gcloud docker -- push gcr.io/${PROJECT_ID}/login-microservice:$GIT_COMMIT
      kubectl set image deployment/login-service-${RAILS_ENV} login-service-${RAILS_ENV}=gcr.io/${PROJECT_ID}/login-microservice:$GIT_COMMIT
    else

      # ensure to push the new image if a deployment does not exist and the image
      # also doesn't exist. This is to ensure the deployment has an image to pull
      if ! gcloud container images describe gcr.io/${PROJECT_ID}/login-microservice:$GIT_COMMIT; then
        /home/jenkins/google-cloud-sdk/bin/gcloud docker -- push gcr.io/${PROJECT_ID}/login-microservice:$GIT_COMMIT
      fi
      kubectl create -f deployment.yml
    fi

    # only create the service if it does not already exist
    if ! kubectl get services login-service-${RAILS_ENV}; then
      kubectl create -f service.yml
    fi

    # delete redundant image on jenkins instance
    sudo /usr/bin/docker image rm gcr.io/${PROJECT_ID}/login-microservice:$GIT_COMMIT

    # kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10

}

notify_vof_team_via_slack() {
  echo "Sending success message to slack"

  curl -X POST --data-urlencode \
  "payload={\"channel\": \"${DEPLOYMENT_CHANNEL}\", \"username\": \"DeployNotification\", \"text\": \"${SLACK_DEPLOYMENT_TEXT}\", \"icon_emoji\": \":rocket:\"}" \
  "${SLACK_CHANNEL_HOOK}"
}

main() {
  echo "deploy script invoked at $(date)" >> /tmp/script.log

declare_env_variables
check_out_infrastructure_code
create_tfvars_file

authenticate_service_account

initialise_terraform
build_infrastructure
create_secrets
create_deployment
create_service
build_docker_image_and_deploy
notify_vof_team_via_slack

}

main "$@"
