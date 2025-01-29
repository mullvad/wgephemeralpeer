FROM ubuntu:22.04 AS build

ENV GO_FILENAME=go1.23.5.linux-amd64.tar.gz
ENV GO_FILEHASH=cbcad4a6482107c7c7926df1608106c189417163428200ce357695cc7e01d091
ENV PATH="$PATH:/usr/local/go/bin:/root/go/bin"

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl make git zip \
  && curl -L https://go.dev/dl/${GO_FILENAME} >/tmp/${GO_FILENAME} \
  && echo ${GO_FILEHASH} /tmp/${GO_FILENAME} | sha256sum --check \
  && tar -C /usr/local -xzf /tmp/${GO_FILENAME}

FROM build AS test

RUN go install golang.org/x/vuln/cmd/govulncheck@latest \
 && go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
