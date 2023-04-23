FROM alpine:3.17 AS Builder
ARG MIRROR_DOMAIN="mirrors.tuna.tsinghua.edu.cn"

RUN \
  sed -i "s/dl-cdn.alpinelinux.org/${MIRROR_DOMAIN}/g" /etc/apk/repositories && \
  apk add --no-cache --update \
    curl \
    jq \
    unzip && \
  mkdir /build-out && rm -rf /build-out/* && \
  mkdir -p /build-out/app /build-out/downloads && \
  AN_VER=$(curl -sX GET "https://api.github.com/repos/mayswind/AriaNg/releases/latest" \
  | jq -r .tag_name ) && \
  curl -L "https://github.com/mayswind/AriaNg/releases/download/${AN_VER}/AriaNg-${AN_VER}.zip" \
  -o /tmp/AriaNg.zip && \
  unzip /tmp/AriaNg.zip -d /build-out/app/ariang

# copy local files
COPY root/ /build-out/
RUN find /build-out/etc/s6-overlay -name run|xargs chmod 755

FROM antonhub/alpine:3.17
# set maintainer label
LABEL MAINTAINER="Anton Chen <contact@antonchen.com>"

ARG MIRROR_DOMAIN="mirrors.tuna.tsinghua.edu.cn"
ENV FIRST_PARTY="true"

COPY --from=Builder /build-out/ /

RUN \
  echo "**** install packages ****" && \
  sed -i "s/dl-cdn.alpinelinux.org/${MIRROR_DOMAIN}/g" /etc/apk/repositories && \
  apk add --no-cache --update \
    openssl \
    cronie \
    aria2 \
    darkhttpd && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/*

# ports and volumes
EXPOSE 8000 6800 51467 51467/udp
VOLUME /config /downloads
