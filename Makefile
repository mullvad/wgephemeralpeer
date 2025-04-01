export CGO_ENABLED = 0
export VERSION     = ${shell git describe --tags 2>/dev/null}
export SOURCE_DATE_EPOCH = ${shell git log ${VERSION} -1 --pretty=%ct}
export SOURCE_DATE_ISO = ${shell TZ=UTC git log ${VERSION} -1 --date=iso-local --pretty=%cd}


BIN        = mullvad-upgrade-tunnel
GO_LDFLAGS = -buildid= -s -w -X main.VERSION=${VERSION} -X main.buildTimestamp=${SOURCE_DATE_EPOCH}

.PHONY: all
all: ${BIN}

.PHONY: ${BIN}
${BIN}:
	go build -a -trimpath -buildvcs=true -ldflags "${GO_LDFLAGS}" \
		-o ${BIN} ./cmd/mullvad-upgrade-tunnel

.PHONY: install
install:
	go install

.PHONY: upgrade
upgrade:
	go get -u
	go mod tidy
	go mod vendor

.PHONY: clean
clean:
	rm -f ${BIN}*

.PHONY: fmt
fmt:
	go fmt ./...

.PHONY: vet
vet:
	golangci-lint run ./...

.PHONY: vuln
vuln:
	govulncheck ./...

.PHONY: test
test:
	go test -v ./...

.PHONY: ci
ci:
	podman build --quiet --target test \
		-t wgephemeralpeer-tester .
	podman run --rm -v .:/build:Z -w /build \
		-it wgephemeralpeer-tester make all vuln test vet

.PHONY: build-container
build-container:
	podman build --target build -t wgephemeralpeer .

.PHONY: build
build: build-container
	podman run --rm -v .:/build:Z -w /build \
		-e GOOS=${GOOS} -e GOARCH=${GOARCH} -e GOARM=${GOARM} -e TZ=UTC \
		wgephemeralpeer \
		sh -c '\
			ARMV=$${GOARM:+v$$GOARM};make BIN=${BIN}${EXT} && \
			touch -d "${SOURCE_DATE_ISO}" ${BIN}${EXT} && \
			zip -X ${BIN}_${VERSION}_${GOOS}_${GOARCH}$$ARMV.zip ${BIN}${EXT}'


.PHONY: release-darwin-amd64
release-darwin-amd64:
	$(MAKE) GOOS=darwin GOARCH=amd64 build

.PHONY: release-darwin-arm64
release-darwin-arm64:
	$(MAKE) GOOS=darwin GOARCH=arm64 build

.PHONY: release-linux-amd64
release-linux-amd64:
	$(MAKE) GOOS=linux GOARCH=amd64 build

.PHONY: release-linux-arm64
release-linux-arm64:
	$(MAKE) GOOS=linux GOARCH=arm64 build

.PHONY: release-linux-armv5
release-linux-armv5:
	$(MAKE) GOOS=linux GOARCH=arm GOARM=5 build

.PHONY: release-linux-armv6
release-linux-armv6:
	$(MAKE) GOOS=linux GOARCH=arm GOARM=6 build

.PHONY: release-linux-armv7
release-linux-armv7:
	$(MAKE) GOOS=linux GOARCH=arm GOARM=7 build

.PHONY: release-windows-amd64
release-windows-amd64:
	$(MAKE) GOOS=windows GOARCH=amd64 EXT=.exe build

.PHONY: release-windows-arm64
release-windows-arm64:
	$(MAKE) GOOS=windows GOARCH=arm64 EXT=.exe build

.PHONY: release
release: \
	clean \
	release-darwin-amd64 \
	release-darwin-arm64 \
	release-linux-amd64 \
	release-linux-arm64 \
	release-linux-armv5 \
	release-linux-armv6 \
	release-linux-armv7 \
	release-windows-amd64 \
	release-windows-arm64
