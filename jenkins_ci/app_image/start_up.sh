# run when starting the container

export RAILS_SERVE_STATIC_FILES=true

start_app() {
  local app_root="/usr/src/app"
    # print environment variables needed incase you want to query the db
    echo 'RAILS_ENV': ${RAILS_ENV}
    echo 'POSTGRES_HOST': ${POSTGRES_HOST}
    echo 'POSTGRES_USER': ${POSTGRES_USER}
    echo 'POSTGRES_DB': ${POSTGRES_DB}
    echo 'POSTGRES_PASSWORD': ${POSTGRES_PASSWORD}
    ########################################################################
    if [[ "$RAILS_ENV" == "production" || "$RAILS_ENV" == "staging" || "$RAILS_ENV" == "sandbox" ]]; then
    # One time actions
    # Check if the database was already imported
      if export PGPASSWORD=${POSTGRES_PASSWORD}; psql -h ${POSTGRES_HOST} -p 5432 -U ${POSTGRES_USER} -d ${POSTGRES_DB} -c 'SELECT key FROM ar_internal_metadata' 2>/dev/null | grep environment >/dev/null; then
        cd ${app_root} && env RAILS_ENV=${RAILS_ENV} rails db:migrate
        cd ${app_root} rails db:seed
      else
        copy_db_files
        # Import database dump.
        export PGPASSWORD=${POSTGRES_PASSWORD}; pg_restore -h ${POSTGRES_HOST} -p 5432 -U ${POSTGRES_USER} -d ${POSTGRES_DB} < /usr/src/app/micro_login_db.dump
      fi
    else
      cd ${app_root} && env RAILS_ENV=${RAILS_ENV} rails db:setup
      cd ${app_root} && env RAILS_ENV=${RAILS_ENV} rails db:seed
    fi
    # cat /usr/src/app/andela_key.key /usr/src/app/andela_certificate.crt > /usr/src/app/root_bundle.crt
    # RAILS_ENV=${RAILS_ENV} /usr/local/bin/bundle exec puma -b 'ssl://0.0.0.0:3000?key=/usr/src/app/andela_key.key&cert=/usr/src/app/andela_certificate.crt&verify_mode=none&ca=/usr/src/app/root_bundle.crt' -C config/puma.rb
    /usr/local/bin/bundle exec passenger start --ssl --environment ${RAILS_ENV} --ssl-certificate "/usr/src/app/andela_certificate.crt" --ssl-certificate-key "/usr/src/app/andela_key.key" --port 3000
}

# download crt:key file combination from bucket
setup_ssl(){
  if gcloud auth activate-service-account --key-file=account.json; then
      gsutil cp gs://${BUCKET_NAME}/ssl/andela_certificate.crt /usr/src/app
      gsutil cp gs://${BUCKET_NAME}/ssl/andela_key.key /usr/src/app
  fi
}

copy_db_files() {
  if gcloud auth activate-service-account --key-file=account.json; then
      gsutil cp gs://${BUCKET_NAME}/login_microservice_databases/micro_login_db.dump /usr/src/app
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
  create_secrets_yml
  start_app
}

main "$@"
