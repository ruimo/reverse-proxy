FROM ubuntu:16.04
MAINTAINER Shisei Hanai<ruimo.uno@gmail.com>

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install wget -y

# Set nginx mainline repository
RUN cd /tmp && \
  wget http://nginx.org/keys/nginx_signing.key && \
  apt-key add nginx_signing.key

RUN echo "deb http://nginx.org/packages/mainline/ubuntu/ xenial nginx" >> /etc/apt/sources.list
RUN echo "deb-src http://nginx.org/packages/mainline/ubuntu/ xenial nginx" >> /etc/apt/sources.list

RUN apt-get update
RUN apt-get install -y nginx monit openssh-server

ADD monit   /etc/monit/conf.d/

RUN useradd -s /bin/false --create-home --user-group sshnginx

# Prohibit password authentication.
RUN sed -i.bak \
  -e "s/^\s*PasswordAuthentication\(.*\)$/# PasswordAuthentication\1/" \
  /etc/ssh/sshd_config
RUN echo "PasswordAuthentication no" >> /etc/ssh/sshd_config

RUN mkdir /home/sshnginx/.ssh
RUN chmod 755 /home/sshnginx

ONBUILD ADD authorized_keys /home/sshnginx/.ssh/authorized_keys
ONBUILD RUN chmod 600 /home/sshnginx/.ssh/authorized_keys
ONBUILD RUN chown -R sshnginx:sshnginx /home/sshnginx/.ssh

EXPOSE 22
EXPOSE 80
EXPOSE 443

RUN mkdir -p /var/log/nginx

CMD ["/usr/bin/monit", "-I", "-c", "/etc/monit/monitrc"]
