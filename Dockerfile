# Errbot - the pluggable chatbot

FROM debian:jessie

MAINTAINER Bipeen Sawant <bsawant@cisco.com>

ENV ERR_USER err
ENV DEBIAN_FRONTEND noninteractive
ENV PATH /app/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Set default locale for the environment
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

COPY requirements.txt /tmp/requirements.txt
COPY docker-entrypoint.sh /tmp/docker-entrypoint.sh
COPY config.py /tmp/config.py
RUN chmod 644 /tmp/requirements.txt /tmp/config.py && chmod 777 /tmp/docker-entrypoint.sh

# Add err user and group
RUN groupadd -r $ERR_USER \
    && useradd -r \
       -g $ERR_USER \
       -d /srv \
       $ERR_USER

# Install packages and perform cleanup
RUN apt-get update \
  && apt-get -y install --no-install-recommends \
         vim \
         git \
         qalc \
         locales \
         dnsutils \
         libssl-dev \
         build-essential \
         python3-dnspython \
         python3-dev \
         python3-openssl \
         python3-pip \
         python3-cffi \
         python3-pyasn1 \
         python3-geoip \
         python3-lxml \
    && locale-gen C.UTF-8 \
    && /usr/sbin/update-locale LANG=C.UTF-8 \
    && echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen \
    && locale-gen \
    && pip3 install virtualenv \
    && pip3 install -U setuptools \
	&& rm -rf /var/lib/apt/lists/*

RUN mkdir /srv/data /srv/plugins /srv/errbackends /app

ADD plugins/ /srv/plugins/

RUN chown -R $ERR_USER: /srv /app

USER $ERR_USER
WORKDIR /srv

RUN cp -p /tmp/requirements.txt /app/requirements.txt
RUN cp -p /tmp/config.py /app/config.py

RUN virtualenv /app/venv
RUN . /app/venv/bin/activate; pip install --no-cache-dir -r /app/requirements.txt

RUN cp -p /tmp/docker-entrypoint.sh /app/venv/bin/docker-entrypoint.sh

EXPOSE 3141 3142
VOLUME ["/srv"]

CMD ["/app/venv/bin/docker-entrypoint.sh"]
