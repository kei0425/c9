FROM node:6
#MAINTAINER Ryan J. McDonough "ryan@damnhandy.com"
MAINTAINER Raul Sanchez <rawmind@gmail.com>

ENV SERVICE_HOME=/opt/cloud9 \
    SERVICE_URL=https://github.com/c9/core.git \
    SERVICE_WORK=/workspace
    
# install docker client
ENV DOCKER_CLIENT_VERSION=1.12.3
ENV DOCKER_API_VERSION=1.24
RUN curl -fsSL https://get.docker.com/builds/Linux/x86_64/docker-${DOCKER_CLIENT_VERSION}.tgz \
  | tar -xzC /usr/local/bin --strip=1 docker/docker

RUN mkdir -p $SERVICE_HOME $SERVICE_WORK && \
    apt-get update && \
    apt-get install -y sudo  tmux python build-essential g++ libssl-dev apache2-utils git libxml2-dev && \
    git clone $SERVICE_URL $SERVICE_HOME && \
    cd $SERVICE_HOME && \
    scripts/install-sdk.sh && \
    sed -i -e 's_127.0.0.1_0.0.0.0_g' $SERVICE_HOME/configs/standalone.js && \
    apt-get autoremove -y build-essential libssl-dev libxml2-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

ADD root /
RUN chmod +x /tmp/*.sh 

WORKDIR $SERVICE_WORK

EXPOSE 8080

ENTRYPOINT ["/tmp/start.sh"]
CMD ["--listen", "0.0.0.0", "-p", "8080"]
