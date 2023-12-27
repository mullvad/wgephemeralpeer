FROM ubuntu:22.04

ENV GOVERSION="go1.19.13.linux-amd64.tar.gz"
ENV GOVERSIONCSUM="4643d4c29c55f53fa0349367d7f1bb5ca554ea6ef528c146825b0f8464e2e668"
ENV PATH="$PATH:/usr/local/go/bin"

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    make \
  && curl -L https://go.dev/dl/$GOVERSION >/tmp/$GOVERSION \
  && echo $GOVERSIONCSUM /tmp/$GOVERSION | sha256sum --check \
  && tar -C /usr/local -xzf /tmp/$GOVERSION
