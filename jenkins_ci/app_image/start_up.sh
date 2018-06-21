# run when starting the container

export RAILS_SERVE_STATIC_FILES=true

start_app() {
  local app_root="/usr/src/app"

#   mkdir -p /home/vof/app/log"

    # One time actions
    # Check if the database was already imported
    if export PGPASSWORD=${POSTGRES_PASSWORD}; psql -h ${POSTGRES_HOST} -p 5432 -U ${POSTGRES_USER} -d ${POSTGRES_DB} -c 'SELECT key FROM ar_internal_metadata' 2>/dev/null | grep environment >/dev/null; then
        cd ${app_root} && env RAILS_ENV=${RAILS_ENV} rails db:migrate
        cd ${app_root} rails db:seed
    else
        # Import database dump.
        export PGPASSWORD=${POSTGRES_PASSWORD}; psql -h ${POSTGRES_HOST} -p 5432 -U ${POSTGRES_USER} -d ${POSTGRES_DB} < ./vof_login_microservice_${RAILS_ENV}.sql
    fi

  /usr/local/bin/bundle exec puma -b 'ssl://0.0.0.0:3000?key=shared/andela_key.key&cert=shared/andela_certificate.crt' -C config/puma.rb
}

# download crt:key file combination from bucket
setup_ssl(){
    if gcloud auth activate-service-account --key-file=account.json; then
        gsutil cp gs://${BUCKET_NAME}/ssl/andela_certificate.crt ./shared/andela_certificate.crt
        gsutil cp gs://${BUCKET_NAME}/ssl/andela_key.key ./shared/andela_key.key
    fi
}

copy_db_files() {
  if gcloud auth activate-service-account --key-file=account.json; then
      gsutil cp gs://${BUCKET_NAME}/login_microservice_databases/vof_login_microservice_production.sql /usr/src/app/vof_login_microservice_production.sql
      gsutil cp gs://${BUCKET_NAME}/login_microservice_databases/vof_login_microservice_staging.sql /usr/src/app/vof_login_microservice_staging.sql
      gsutil cp gs://${BUCKET_NAME}/login_microservice_databases/vof_login_microservice_sandbox.sql /usr/src/app/vof_login_microservice_sandbox.sql
  fi
}

create_secrets_yml() {
  cat <<EOF > ./config/secrets.yml
production:
  secret_key_base: "$(openssl rand -hex 64)"
staging:
  secret_key_base: "$(openssl rand -hex 64)"
development:
  secret_key_base: "$(openssl rand -hex 64)"
sandbox:
  secret_key_base: "$(openssl rand -hex 64)"
EOF
}

main() {

    echo "start up script invoked at $(date)" >> /tmp/script.log
    setup_ssl
    copy_db_files
    create_secrets_yml
    start_app
}

main "$@"
