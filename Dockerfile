FROM 0x416e746f6e0a/alpine-base:3.9

# set maintainer label
LABEL MAINTAINER="Anton Chen <contact@antonchen.com>"

RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache --virtual=build-dependencies \
    unzip \
    jq && \
 echo "**** install packages ****" && \
 apk add --no-cache \
    openssl \
    curl \
    darkhttpd \
    aria2 && \
 ANVERSION=$(curl -sX GET "https://api.github.com/repos/mayswind/AriaNg/releases/latest" \
    | jq -r .tag_name ) && \
 curl -o \
    /tmp/AriaNg.zip -L \
    "https://github.com/mayswind/AriaNg/releases/download/${ANVERSION}/AriaNg-${ANVERSION}.zip" && \
 unzip /tmp/AriaNg.zip -d /ariang && \
 echo "**** cleanup ****" && \
 apk del --purge \
    build-dependencies && \
 rm -rf \
    /tmp/*


# copy local files
COPY root/ /

# ports and volumes
EXPOSE 8000 6800 51467 51467/udp
VOLUME /config /downloads
