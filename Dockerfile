FROM ubuntu:22.04

ENV GO_FILENAME=go1.22.4.linux-amd64.tar.gz
ENV GO_FILEHASH=ba79d4526102575196273416239cca418a651e049c2b099f3159db85e7bade7d
ENV PATH="$PATH:/usr/local/go/bin"

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl make git zip \
  && curl -L https://go.dev/dl/${GO_FILENAME} >/tmp/${GO_FILENAME} \
  && echo ${GO_FILEHASH} /tmp/${GO_FILENAME} | sha256sum --check \
  && tar -C /usr/local -xzf /tmp/${GO_FILENAME}
