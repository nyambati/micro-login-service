FROM ruby:2.4.1

USER root

# set working directory
RUN mkdir /usr/src/app
WORKDIR /usr/src/app

# get bash scripts for execution
COPY ./jenkins_ci/app_image .

# install and cache app dependancies
COPY . .


RUN apt-get update && apt-get install -y --no-install-recommends apt-utils && \
apt-get install nodejs postgresql postgresql-contrib  -y && \
curl https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz > /tmp/google-cloud-sdk.tar.gz && \
mkdir -p /usr/local/gcloud && \
tar -C /usr/local/gcloud -xf /tmp/google-cloud-sdk.tar.gz && \
/usr/local/gcloud/google-cloud-sdk/install.sh && \
/usr/local/gcloud/google-cloud-sdk/bin/gcloud components install beta --quiet && \
/etc/init.d/postgresql start

ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin

RUN bundle install --without development test

ARG google_client_id
ENV GOOGLE_CLIENT_ID=$google_client_id

ARG private_key
ENV PRIVATE_KEY=$private_key

EXPOSE 3000

# start the app
CMD ["/bin/bash", "./start_up.sh"]