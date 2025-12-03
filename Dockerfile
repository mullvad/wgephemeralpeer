FROM ubuntu:24.04 AS build

ENV PATH="$PATH:/usr/local/go/bin:/root/go/bin"

# The SHA256 checksum used to verify the go archive can be found at https://go.dev/dl/

ENV GO_FILENAME=go1.24.11.linux-amd64.tar.gz
ENV GO_FILEHASH=bceca00afaac856bc48b4cc33db7cd9eb383c81811379faed3bdbc80edb0af65

ENV GOCI_URL=https://github.com/golangci/golangci-lint/releases/download/v1.64.8/golangci-lint-1.64.8-linux-amd64.deb
ENV GOCI_FILEHASH=3d662a0aaa8fc64babef2bbc4f3f24fd1a073c82c6b8ea2f21c7e40492ea13ca

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    make \
    zip \
  && curl -s -L https://go.dev/dl/${GO_FILENAME} >/tmp/${GO_FILENAME} \
  && echo ${GO_FILEHASH} /tmp/${GO_FILENAME} | sha256sum --check \
  && tar -C /usr/local -xzf /tmp/${GO_FILENAME}

FROM build AS test

RUN go install golang.org/x/vuln/cmd/govulncheck@latest \
  && curl -s -L ${GOCI_URL} >/tmp/goci.deb \
  && echo ${GOCI_FILEHASH} /tmp/goci.deb | sha256sum --check \
  && dpkg -i /tmp/goci.deb
