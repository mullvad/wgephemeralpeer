FROM ubuntu:noble-20260113 AS build

ENV PATH="$PATH:/usr/local/go/bin:/root/go/bin"

# The SHA256 checksum used to verify the go archive can be found at https://go.dev/dl/

ENV GO_FILENAME=go1.24.13.linux-amd64.tar.gz
ENV GO_FILEHASH=1fc94b57134d51669c72173ad5d49fd62afb0f1db9bf3f798fd98ee423f8d730

ENV GOCI_URL=https://github.com/golangci/golangci-lint/releases/download/v1.64.8/golangci-lint-1.64.8-linux-amd64.deb
ENV GOCI_FILEHASH=3d662a0aaa8fc64babef2bbc4f3f24fd1a073c82c6b8ea2f21c7e40492ea13ca

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
