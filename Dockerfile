FROM       ubuntu:14.04
MAINTAINER Yefry Figueroa "https://github.com/yefryf/webserver"

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN apt-get update
RUN apt-get -y upgrade

#***Public Keys SSH***#
RUN mkdir /root/.ssh/
RUN touch /root/.ssh/authorized_keys
RUN echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/LV6HJ+gUapiGGCuYo2f+yCPchTBbJ0xN58Nspu34IeW4ZQrp/9UT7OlfXz5L20FLV2LSjmJlUI+bYXzzl7LGjifFfmoiim6AxlpsGARTe5dqxFeNzPA4cBaUpSTtjSC0E1UISlaUCPeP47w6iLREdJhrfGsQ9DKTEqdDiJdu9fMs+u12rOS1P5D4RviN+gSztaISwA57X5ZyeMw6K1CiTQkWb9T2mudQc2G39UdUohijbFvBrfBreXDqZBOnGM1YKBfeJPog5hJGhNl2kpI9u7tmTcdSpcmtXwAtsAJn5+rwvlKpPQz9dFqB5pbwSlgCWKZgGl7WNgTvTlpxkjfT yefryf@yefry-neen" >> /root/.ssh/authorized_keys

#***OpenSSH***#
RUN apt-get install -y openssh-server vim
RUN mkdir /var/run/sshd \
&& mkdir /var/run/supervisor

RUN echo 'root:root' |chpasswd

RUN sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

#***APACHE***#

# Install apache, PHP, and supplimentary programs.
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install apache2 libapache2-mod-php5 php5-mysql php5-gd php-pear php-apc php5-curl curl lynx-cur supervisor
RUN mkdir -p /var/lock/apache2 /var/run/apache2 /var/log/supervisor

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Enable apache mods.
RUN a2enmod php5
RUN a2enmod rewrite

# Update the PHP.ini file, enable <? ?> tags and quieten logging.
RUN sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php5/apache2/php.ini
RUN sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php5/apache2/php.ini

# Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2

#***MariaDB 5.5***#
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db && \
    echo 'deb http://mirrors.syringanetworks.net/mariadb/repo/5.5/ubuntu trusty main' >> /etc/apt/sources.list && \
    echo 'deb-src http://mirrors.syringanetworks.net/mariadb/repo/5.5/ubuntu trusty main' >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y mariadb-server pwgen && \
    rm -rf /var/lib/mysql/* && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# setup mysql
RUN sed -i -r 's/bind-address.*$/bind-address = 0.0.0.0/' /etc/mysql/my.cnf

# Set password root/toor to mysql + install_db to fix issue not starting
COPY mysql.sh /opt/mysql.sh
RUN mysql_install_db --user=mysql --ldata=/var/lib/mysql/

# Add VOLUMEs to allow backup of config and databases
# VOLUME  ["/etc/mysql", "/var/lib/mysql"]

# Copy site into place.
ADD www /var/www/site

# Update the default apache site with the config we created.
ADD apache-config.conf /etc/apache2/sites-enabled/000-default.conf

EXPOSE 22 80 443 3306

CMD ["/usr/bin/supervisord"]
