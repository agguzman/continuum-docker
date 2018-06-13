FROM ubuntu:16.04
LABEL maintainer ="a.guillermo.guzman@gmail.com"


RUN apt-get update && apt-get install -y \
    build-essential \
    cron \
    curl \
    libffi-dev \
    libkrb5-dev \
    libldap2-dev \
    libsasl2-dev \
    libssl-dev \
    sudo

# Download and build latest version of Python
RUN set -ex && \
    cd /usr/src && \
    curl -O https://www.python.org/ftp/python/2.7.14/Python-2.7.14.tgz && \
    tar xvzf Python-2.7.14.tgz && \
    cd Python-2.7.14 && \
    ./configure && \
    make install

ARG INSTALLER=""
ENV MY_CTM_INSTALLER=$INSTALLER

RUN set -xe && \
    cd /tmp && \
    # Download installer
    curl -o install.sh $INSTALLER && \
    chmod +x install.sh && \
    # Installation wasn't successful until source line was removed
    sed -i '/source ${WHICHPROFILE}/d' install.sh && \
    # -s silent, -m skip data initialization, -p skip starting services
    ./install.sh -m -p -s

ENV APP=/opt/continuum/current
WORKDIR $APP

ADD ./entrypoint.sh $APP

# ui and messagehub
EXPOSE 8080 8083

ENTRYPOINT ["/opt/continuum/current/entrypoint.sh"]
CMD ["ctm-start-services"]