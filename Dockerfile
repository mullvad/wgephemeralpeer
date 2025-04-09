FROM ubuntu:22.04 AS build

ENV GO_FILENAME=go1.24.2.linux-amd64.tar.gz
ENV GO_FILEHASH=68097bd680839cbc9d464a0edce4f7c333975e27a90246890e9f1078c7e702ad
ENV PATH="$PATH:/usr/local/go/bin:/root/go/bin"

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl make git zip \
  && curl -L https://go.dev/dl/${GO_FILENAME} >/tmp/${GO_FILENAME} \
  && echo ${GO_FILEHASH} /tmp/${GO_FILENAME} | sha256sum --check \
  && tar -C /usr/local -xzf /tmp/${GO_FILENAME}

FROM build AS test

RUN go install golang.org/x/vuln/cmd/govulncheck@latest \
 && go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
