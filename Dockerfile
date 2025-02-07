FROM ubuntu:22.04 AS build

ENV GO_FILENAME=go1.23.6.linux-amd64.tar.gz
ENV GO_FILEHASH=9379441ea310de000f33a4dc767bd966e72ab2826270e038e78b2c53c2e7802d
ENV PATH="$PATH:/usr/local/go/bin:/root/go/bin"

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl make git zip \
  && curl -L https://go.dev/dl/${GO_FILENAME} >/tmp/${GO_FILENAME} \
  && echo ${GO_FILEHASH} /tmp/${GO_FILENAME} | sha256sum --check \
  && tar -C /usr/local -xzf /tmp/${GO_FILENAME}

FROM build AS test

RUN go install golang.org/x/vuln/cmd/govulncheck@latest \
 && go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
