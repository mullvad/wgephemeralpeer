FROM ubuntu:noble-20260113 AS build

ENV PATH="$PATH:/usr/local/go/bin:/root/go/bin"

# The SHA256 checksum used to verify the go archive can be found at https://go.dev/dl/

ENV GO_FILENAME=go1.25.9.linux-amd64.tar.gz
ENV GO_FILEHASH=00859d7bd6defe8bf84d9db9e57b9a4467b2887c18cd93ae7460e713db774bc1

ENV GOCI_URL=https://github.com/golangci/golangci-lint/releases/download/v2.10.1/golangci-lint-2.10.1-linux-amd64.deb
ENV GOCI_FILEHASH=8aa9b3aa14f39745eeb7fc7ff50bcac683e785397d1e4bc9afd2184b12c4ce86

ENV APT_SNAPSHOT=20260205T000000Z

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
  && echo "APT::Snapshot ${APT_SNAPSHOT};" | tee /etc/apt/apt.conf.d/50snapshot \
  && apt-get clean \
  && apt-get update && apt-get install -y --no-install-recommends \
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
