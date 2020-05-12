FROM alpine:3.11.6
ARG TON_GITHUB_REPO="https://github.com/ton-blockchain/ton.git"
ARG TON_GITHUB_REF="eecf05ca5934c8c65c8113237fa4a00adcfea697"
WORKDIR /build
RUN apk add --no-cache git
RUN git clone --recursive "${TON_GITHUB_REPO}" ton-blockchain && cd ton-blockchain && git checkout "${TON_GITHUB_REF}"
COPY patches ./patches/
RUN cd ton-blockchain && find /build/patches -name '*.patch' -exec git apply {} \;
RUN apk add --no-cache cmake g++ gcc git linux-headers ninja openssl-dev zlib-dev

# https://gcc.gnu.org/onlinedocs/gcc-9.2.0/gcc/x86-Options.html#x86-Options
ARG TON_ARCH=native
#ARG TON_ARCH=corei7-avx

RUN mkdir ton-blockchain/build && cd ton-blockchain/build \
&& cmake .. -G "Ninja" -DCMAKE_BUILD_TYPE=RelWithDebInfo -DPORTABLE=ON -DTON_ARCH="${TON_ARCH}"
RUN cd ton-blockchain/build && ninja -j 1

COPY support/mainnet                 /etc/ton.mainnet.example
COPY support/testnet                 /etc/ton.testnet.example
COPY support/BANNER                  /
COPY support/docker-entrypoint.sh    /usr/local/bin/

VOLUME [ "/etc/ton", "/var/ton" ]
ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]
