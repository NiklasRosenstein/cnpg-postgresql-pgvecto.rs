ARG PG_MAJOR=15
ARG PJ_MINOR=5

FROM ghcr.io/cloudnative-pg/postgresql:${PG_MAJOR}.${PJ_MINOR}}-debian
USER root

# https://github.com/tensorchord/pgvecto.rs/releases/tag/v0.2.1
ARG VECTORS_VERSION=0.2.1
RUN <<EOF
    set -e
    if [ -z "${VECTORS_ARCH:-}" ] && [ $(dpkg --print-architecture) = "amd64" ]; then
        VECTORS_ARCH=x86_64
    elif [ -z "${VECTORS_ARCH:-}" ] && [ $(dpkg --print-architecture) = "arm64" ]; then
        VECTORS_ARCH=aarch64
    else
        >&2 echo "Unsupported architectureL: $(dpkg --print-architecture)"
        exit 1
    fi
    apt update && apt install -y wget
    wget -nv -O vectors.deb https://github.com/tensorchord/pgvecto.rs/releases/download/v${VECTORS_VERSION}/vectors-pg${PG_MAJOR}_${VECTORS_VERSION}_$(dpkg --print-architecture).deb
    dpkg -i vectors.deb
    rm vectors.deb
    apt remove -y wget
EOF

USER postgres
