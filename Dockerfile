FROM centos:latest
ENV GIT_BRANCH master

RUN	yum update -y && \
	yum -y install golang git make && \
	go version

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"


RUN curl https://glide.sh/get | sh
RUN	git clone --depth 1 --branch ${GIT_BRANCH} https://github.com/angezanetti/trumail.git $GOPATH/trumail

WORKDIR $GOPATH

RUN glide cache-clear
RUN	glide init --non-interactive
RUN	glide install
RUN	ls -all "$GOPATH/vendor"

EXPOSE 8888
CMD go run "$GOPATH/trumail/main.go"
