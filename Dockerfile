ARG BASE_IMAGE

FROM ubuntu AS downloader
RUN apt-get update && apt-get install wget -y
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ARG BASE_IMAGE
ARG PGVECTORS_VERSION
RUN <<EOF
    set -e
    if [ -z "${VECTORS_ARCH:-}" ] && [ $(dpkg --print-architecture) = "amd64" ]; then
        VECTORS_ARCH=x86_64
    elif [ -z "${VECTORS_ARCH:-}" ] && [ $(dpkg --print-architecture) = "arm64" ]; then
        VECTORS_ARCH=aarch64
    else
        >&2 echo "Unsupported architecture: $(dpkg --print-architecture)"
        exit 1
    fi
    wget -nv -O vectors.deb https://github.com/tensorchord/pgvecto.rs/releases/download/v${PGVECTORS_VERSION}/vectors-pg${BASE_IMAGE%%[^0-9]*}_${PGVECTORS_VERSION}_$(dpkg --print-architecture).deb
EOF

# See https://github.com/cloudnative-pg/postgres-containers/pkgs/container/postgresql
FROM ghcr.io/cloudnative-pg/postgresql:${BASE_IMAGE}

USER root
RUN --mount=type=bind,from=downloader,source=/vectors.deb,target=/vectors.deb dpkg -i /vectors.deb
USER postgres
