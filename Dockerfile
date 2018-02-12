FROM centos:7
LABEL maintainer "DI GREGORIO Nicolas <ndigregorio@ndg-consulting.tech>"

### Environment variables
ENV LANG='en_US.UTF-8' \
    LANGUAGE='en_US.UTF-8' \
    GIT_BRANCH='master' \
		GOPATH='/go' \
    PATH="$GOPATH/bin:/usr/local/go/bin:$PATH"

### Install Application
RUN	yum install -y epel-release && \
    yum update -y && \
    yum install -y golang && \
		yum install -y gcc \
		               glide \
		               git \
									 make \
		&& \
    git clone --depth 1 https://github.com/ncopa/su-exec /tmp/su-exec && \
    cd /tmp/su-exec && \
    make && \
    cp /tmp/su-exec/su-exec /usr/local/bin/su-exec && \
    mkdir -p ${GOPATH}/{src,bin} && \ 
		chmod -R 0755 ${GOPATH} && \
		git clone --depth 1 --branch ${GIT_BRANCH} https://github.com/angezanetti/trumail.git ${GOPATH}/trumail && \
		cd ${GOPATH}/trumail && \
		rm ${GOPATH}/trumail/{glide.lock,glide.yaml} && \
    glide cache-clear && \
		glide init --non-interactive && \
		glide install && \
		cp -R vendor/* /usr/lib/golang/src && \
    yum history -y undo last && \
    yum clean all && \
    rm -rf /tmp/* \
           /var/cache/yum/* \
           /var/tmp/*

# Expose volumes
#VOLUME [""]

# Expose ports
EXPOSE 8000

### Running User: not used, managed by docker-entrypoint.sh
USER root

### Start postgres
COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["trumail"]
