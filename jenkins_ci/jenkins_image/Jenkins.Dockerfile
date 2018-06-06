# Custom Dockerfile with packer & terraform
#

FROM ruby:2.4.1

USER root
# ENV RAILS_ENV ${DEPLOY_ENV}

# set working directory
RUN apt-get -y update && apt-get install postgresql postgresql-contrib nodejs sudo -y && apt-get upgrade -y && \
/etc/init.d/postgresql start

RUN apt-get install -y --no-install-recommends apt-utils

RUN useradd jenkins --shell /bin/bash --create-home && \
echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers && \
usermod -u 113 jenkins

RUN mkdir -p ~/workdir && \
apt-get install unzip && \
cd ~/workdir && \
wget https://releases.hashicorp.com/terraform/0.10.6/terraform_0.10.6_linux_amd64.zip && \
unzip terraform_0.10.6_linux_amd64.zip && \
chmod +x terraform && \
mv terraform /usr/local/bin/ && \
rm -r ~/workdir

# Let's start with some basic stuff.
RUN apt-get update -qq && apt-get install -qqy \
    apt-transport-https \
    ca-certificates \
    curl \
    lxc \
    iptables

# Install Docker from Docker Inc. repositories.
RUN curl -sSL https://get.docker.com/ | sh

# Install the magic wrapper.
ADD ./wrapdocker /usr/local/bin/wrapdocker
RUN chmod +x /usr/local/bin/wrapdocker

# Define additional metadata for our image.
VOLUME /var/lib/docker

USER jenkins
RUN curl https://sdk.cloud.google.com | bash

ENV PATH $PATH:/home/jenkins/google-cloud-sdk/bin
RUN gcloud components install kubectl beta --quiet

CMD ["wrapdocker"]