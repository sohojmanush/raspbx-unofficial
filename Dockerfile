FROM sohojmanush/raspbx:base

RUN apt-get install -y supervisor

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

#RUN sed -i 's/\(^upload_max_filesize = \).*/\120M/' /etc/php/7.0/apache2/php.ini \
#	&& cp /etc/apache2/apache2.conf /etc/apache2/apache2.conf_orig \
#	&& sed -i 's/^\(User\|Group\).*/\1 asterisk/' /etc/apache2/apache2.conf \
#	&& sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

#ARG MARIADB_MYSQL_SOCKET_DIRECTORY='/var/run/mysqld'

#RUN mkdir -p $MARIADB_MYSQL_SOCKET_DIRECTORY && \
#    chown root:mysql $MARIADB_MYSQL_SOCKET_DIRECTORY && \
#    chmod 774 $MARIADB_MYSQL_SOCKET_DIRECTORY

CMD ["/usr/bin/supervisord"]

EXPOSE 80 3306 5060 5061 5160 5161 4569 10000-20000/udp
