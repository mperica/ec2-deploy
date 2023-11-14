FROM alpine:latest

ENV DEPLOY_DIR=/app
ENV SSH_PORT=22
ENV SSH_KEY_PATH=/tmp/sshkey.pem

RUN apk add --update --no-cache bash curl openssh-client
WORKDIR /app

COPY ec2.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/ec2.sh

ENTRYPOINT /usr/local/bin/ec2.sh "$@"
