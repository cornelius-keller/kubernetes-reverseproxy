#
# Reverse proxy for kubernetes
#
FROM ubuntu:trusty

ENV DEBIAN_FRONTEND noninteractive

# Prepare requirements
RUN apt-get update -qy && \
    apt-get install --no-install-recommends -qy software-properties-common

# Install Nginx.
RUN add-apt-repository -y ppa:nginx/stable && \
    apt-get update -q && \
    apt-get install --no-install-recommends -qy nginx && \
    chown -R www-data:www-data /var/lib/nginx && \
    rm -f /etc/nginx/sites-available/default

# setup confd
ADD https://github.com/kelseyhightower/confd/releases/download/v0.10.0/confd-0.10.0-linux-amd64 /usr/local/bin/confd
RUN chmod u+x /usr/local/bin/confd && \
    mkdir -p /etc/confd/conf.d && \
    mkdir -p /etc/confd/templates

ADD ./src/confd/conf.d/nginx.toml /etc/confd/conf.d/nginx.toml
ADD ./src/confd/templates/nginx.tmpl /etc/confd/templates/nginx.tmpl
ADD ./src/confd/confd.toml /etc/confd/confd.toml

ADD ./src/boot.sh /opt/boot.sh
RUN chmod +x /opt/boot.sh

EXPOSE 80 443

# Run the boot script
CMD /opt/boot.sh
