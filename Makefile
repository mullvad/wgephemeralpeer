BIN                = mullvad-upgrade-tunnel
GO_LDFLAGS         = -buildid= -s -w -X main.VERSION=${VERSION}
export CGO_ENABLED = 0
export VERSION     = ${shell git describe --tags 2>/dev/null}

.PHONY: mullvad-upgrade-tunnel
mullvad-upgrade-tunnel:
	go build -a -trimpath -buildvcs=false -ldflags "${GO_LDFLAGS}" \
		-o ${BIN} ./cmd/mullvad-upgrade-tunnel

.PHONY: install
install:
	go install

.PHONY: grpc
grpc:
	protoc --go_out=. --go_opt=paths=source_relative \
		--go-grpc_out=. --go-grpc_opt=paths=source_relative internal/grpc/ephemeralpeer.proto

.PHONY: clean
clean:
	rm -f ${BIN}*

.PHONY: build-container
build-container:
	podman build -t wgephemeralpeer .

.PHONY: build
build: build-container
	podman run --rm -v .:/build:Z -w /build \
		-e GOOS=${GOOS} -e GOARCH=${GOARCH} \
		-it wgephemeralpeer \
		make BIN=${BIN}${EXT} ${BIN} && zip ${BIN}_${VERSION}_${GOOS}_${GOARCH}.zip ${BIN}${EXT}

.PHONY: release-darwin-amd64
release-darwin-amd64:
	$(MAKE) GOOS=darwin GOARCH=amd64 build

.PHONY: release-darwin-arm64
release-darwin-arm64:
	$(MAKE) GOOS=darwin GOARCH=arm64 build

.PHONY: release-linux-amd64
release-linux-amd64:
	$(MAKE) GOOS=linux GOARCH=amd64 build

.PHONY: release-windows-amd64
release-windows-amd64:
	$(MAKE) GOOS=windows GOARCH=amd64 EXT=.exe build

.PHONY: release
release: \
	clean \
	release-darwin-amd64 \
	release-darwin-arm64 \
	release-linux-amd64 \
	release-windows-amd64
