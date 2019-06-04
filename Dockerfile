# FROM golang:1.9.2
# RUN go get github.com/hashicorp/packer
# RUN cd /go/src/github.com/hashicorp/packer && git checkout 39fc8593deae0999d211c482cd756cd4fdc55832
# RUN cd $GOPATH/src/github.com/hashicorp/packer && PACKER_DEV=1 make bin

FROM centos:7

ARG PACKER_VER=1.4.1
ARG DOCKER_VER=18.09.6
ARG DOCKER_COMPOSE_VER=1.24.0
ARG YUM_PROXY

# COPY --from=0 /go/src/github.com/hashicorp/packer/pkg/linux_amd64/packer /usr/bin/packer
RUN if [ -n "${YUM_PROXY}" ]; then echo "proxy=${YUM_PROXY}" >> /etc/yum.conf; fi &&\
    yum -y update && yum install -y epel-release &&\
    yum install -y git unzip openssh-clients jq &&\
    sed -i '/^proxy=/d' /etc/yum.conf &&\
    curl ${YUM_PROXY:+--proxy ${YUM_PROXY}} -sL --fail -o /tmp/packer.zip https://releases.hashicorp.com/packer/${PACKER_VER}/packer_${PACKER_VER}_linux_amd64.zip &&\
    cd /usr/bin && unzip /tmp/packer.zip && chmod +x /usr/bin/packer &&\
    rm /tmp/packer.zip &&\
    curl ${YUM_PROXY:+--proxy ${YUM_PROXY}} -sL https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VER}.tgz | tar -xz -C /tmp && mv /tmp/docker/* /usr/bin && rm -rf /tmp/docker &&\
    curl ${YUM_PROXY:+--proxy ${YUM_PROXY}} -sL https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VER}/docker-compose-`uname -s`-`uname -m` -o /usr/bin/docker-compose && chmod +x /usr/bin/docker-compose

LABEL maintainer="Patrick Double <pat@patdouble.com>" \
    org.label-schema.docker.dockerfile="$DOCKERFILE_PATH/Dockerfile" \
    org.label-schema.license="Apache2.0" \
    org.label-schema.name="Image for use by CI environments to build a docker image using packer. Packer ${PACKER_VER}, Docker ${DOCKER_VER}, Docker Compose ${DOCKER_COMPOSE_VER}." \
    org.label-schema.url="https://bitbucket.org/double16/packer-build-base" \
    org.label-schema.vcs-ref="$SOURCE_COMMIT" \
    org.label-schema.vcs-type="$SOURCE_TYPE" \
    org.label-schema.vcs-url="https://bitbucket.org/double16/packer-build-base.git"
