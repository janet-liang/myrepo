FROM alpine

ENV apr_version=1.7.0 apr_util_version=1.6.1 httpd_version=2.4.54

ADD files/* /tmp/

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && \
    apk update && \
    adduser -SHs /sbin/nologin apache && \
    apk add --no-cache -U gcc libc-dev make expat-dev pcre-dev openssl-dev libtool && \
    cd /tmp/apr-${apr_version} && \
    sed -i '/$RM "$cfgfile"/d' configure && \
    ./configure --prefix=/usr/local/apr && \
    make && make install && \
    cd /tmp/apr-util-${apr_util_version} && \
    ./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr && \
    make && make install && \
    cd /tmp/httpd-${httpd_version} && \
    ./configure --prefix=/usr/local/apache \
    --sysconfdir=/etc/httpd24 \
    --enable-so \
    --enable-ssl \
    --enable-cgi \
    --enable-rewrite \
    --with-zlib \
    --with-pcre \
    --with-apr=/usr/local/apr \
    --with-apr-util=/usr/local/apr-util/ \
    --enable-modules=most \
    --enable-mpms-shared=all \
    --with-mpm=prefork && \
    make && make install && \
    mv /tmp/entrypoint.sh / && \
    apk del gcc make && \
    rm -rf /tmp/* /var/cache/*

EXPOSE 80
WORKDIR /usr/local/apache
CMD ["/usr/local/apache/bin/httpd","-D","FOREGROUND"]
ENTRYPOINT ["/bin/bash","/entrypoint.sh"]
