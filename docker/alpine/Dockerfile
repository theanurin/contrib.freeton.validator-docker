ARG ALPINE_VERSION=3.11.6
ARG TON_GITHUB_REPO="https://github.com/ton-blockchain/ton.git"
ARG TON_GITHUB_REF="eecf05ca5934c8c65c8113237fa4a00adcfea697"


FROM alpine:${ALPINE_VERSION} AS builder

# Install dependencies and tools
RUN apk add --no-cache \
	cmake=3.15.5-r0 \
	g++=9.2.0-r4 \
	gcc=9.2.0-r4 \
	git=2.24.3-r0 \
	linux-headers=4.19.36-r0 \
	ninja=1.9.0-r3 \
	openssl-dev=1.1.1g-r0 \
	zlib-dev=1.2.11-r3

# Declare build time arguments
#
ARG TON_GITHUB_REPO
#
ARG TON_GITHUB_REF
#
# https://gcc.gnu.org/onlinedocs/gcc-9.2.0/gcc/x86-Options.html#x86-Options
ARG TON_ARCH=x86-64
#ARG TON_ARCH=native
#ARG TON_ARCH=corei7-avx
#
# Ninja -j
ARG BUILD_THREADS=2
#
# CMake CMAKE_BUILD_TYPE
ARG BUILD_TYPE=Release
#ARG BUILD_TYPE=RelWithDebInfo

WORKDIR /builder

RUN git clone --recursive "${TON_GITHUB_REPO}" src
RUN cd src && git checkout "${TON_GITHUB_REF}"

COPY patches/ patches/
RUN cd src && find ../patches -name '*.patch' -exec git apply {} \;

RUN mkdir build
RUN cd build && cmake ../src -G "Ninja" -DCMAKE_BUILD_TYPE="${BUILD_TYPE}" -DPORTABLE=ON -DTON_ARCH="${TON_ARCH}"
RUN cd build && ninja -j "${BUILD_THREADS}"

RUN mkdir -p root/usr/local/bin/

COPY support/share/                  root/usr/local/share/ton/
COPY support/BANNER                  root/
COPY support/docker-entrypoint.sh    root/usr/local/bin/

RUN echo >> root/BANNER
RUN echo "--------------- TON Blockchain Build ---------------" >> root/BANNER
RUN echo "  Git: ${TON_GITHUB_REPO}" >> root/BANNER
RUN echo "  Ref: ${TON_GITHUB_REF}" >> root/BANNER
RUN echo "----------------------------------------------------" >> root/BANNER
RUN echo >> root/BANNER

RUN cp build/validator-engine/validator-engine                 root/usr/local/bin/
RUN cp build/validator-engine-console/validator-engine-console root/usr/local/bin/
RUN cp build/utils/generate-random-id                          root/usr/local/bin/

#RUN apk add tree && tree root/


FROM alpine:${ALPINE_VERSION}
ARG TON_GITHUB_REPO
ARG TON_GITHUB_REF
LABEL org.label-schema.vcs-ref="${TON_GITHUB_REF}" org.label-schema.vcs-url="${TON_GITHUB_REPO}"
VOLUME [ "/etc/ton", "/var/ton" ]
RUN apk add --no-cache curl libstdc++ && adduser -D -h /var/ton ton
WORKDIR /var/ton
COPY --from=builder /builder/root/ /
ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]
CMD ["validator-engine"]
