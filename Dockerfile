# See https://github.com/cloudnative-pg/postgres-containers/pkgs/container/postgresql
ARG BASE_IMAGE
FROM ghcr.io/cloudnative-pg/postgresql:${BASE_IMAGE}

USER root
ARG PGVECTORS_VERSION
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
    wget -nv -O vectors.deb https://github.com/tensorchord/pgvecto.rs/releases/download/v${BASE_IMAGE%%[^0-9]*}/vectors-pg${PG_MAJOR}_${PGVECTORS_VERSION}_$(dpkg --print-architecture).deb
    dpkg -i vectors.deb
    rm vectors.deb
    apt remove -y wget
EOF

USER postgres
