FROM node:6
#MAINTAINER Ryan J. McDonough "ryan@damnhandy.com"
MAINTAINER Raul Sanchez <rawmind@gmail.com>

ENV SERVICE_HOME=/opt/cloud9 \
    SERVICE_URL=https://github.com/c9/core.git \
    SERVICE_WORK=/workspace
    
# install docker
RUN apt-get install \
     apt-transport-https \
     ca-certificates \
     curl \
     gnupg2 \
     software-properties-common
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"
RUN apt-get update
RUN apt-get install docker-ce

RUN mkdir -p $SERVICE_HOME $SERVICE_WORK && \
    apt-get update && \
    apt-get install -y python build-essential g++ libssl-dev apache2-utils git libxml2-dev && \
    git clone $SERVICE_URL $SERVICE_HOME && \
    cd $SERVICE_HOME && \
    scripts/install-sdk.sh && \
    sed -i -e 's_127.0.0.1_0.0.0.0_g' $SERVICE_HOME/configs/standalone.js && \
    apt-get autoremove -y python build-essential libssl-dev g++ libxml2-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

ADD root /
RUN chmod +x /tmp/*.sh 

WORKDIR $SERVICE_WORK

EXPOSE 8080

ENTRYPOINT ["/tmp/start.sh"]
CMD ["--listen", "0.0.0.0", "-p", "8080"]
