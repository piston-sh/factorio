FROM frolvlad/alpine-glibc:alpine-3.7
LABEL maintainer="admin@deniscraig.com"

ARG user=factorio
ARG group=factorio
ARG puid=845
ARG pgid=845
ARG gamedir=/opt/factorio
ARG volumedir=/factorio

ENV PORT=34197 \
    RCON_PORT=27015 \
    VERSION=0.16.51 \
    SHA1=127e7ff484ab263b13615d6114013ce0a66ac929 \
    SAVES=/factorio/saves \
    CONFIG=/factorio/config \
    MODS=/factorio/mods \
    SCENARIOS=/factorio/scenarios \
    SCRIPTOUTPUT=/factorio/script-output

# Install dependencies & factorio headless
RUN mkdir -p /opt /factorio && \
    apk add --update --no-cache pwgen && \
    apk add --update --no-cache --virtual .build-deps curl && \
    curl -sSL https://www.factorio.com/get-download/$VERSION/headless/linux64 \
        -o /tmp/factorio_headless_x64_$VERSION.tar.xz && \
    echo "$SHA1  /tmp/factorio_headless_x64_$VERSION.tar.xz" | sha1sum -c && \
    tar xf /tmp/factorio_headless_x64_$VERSION.tar.xz --directory /opt && \
    chmod ugo=rwx /opt/factorio && \
    rm /tmp/factorio_headless_x64_$VERSION.tar.xz

# Symlink folders
RUN ln -s $SAVES /opt/factorio/saves && \
    ln -s $MODS /opt/factorio/mods && \
    ln -s $SCENARIOS /opt/factorio/scenarios && \
    ln -s $SCRIPTOUTPUT /opt/factorio/script-output

# Cleanup and add users
RUN apk del .build-deps && \
    addgroup -g $pgid -S $group && \
    adduser -u $puid -G $group -s /bin/sh -SDH $user && \
    chown -R $user:$group /opt/factorio /factorio

EXPOSE $PORT/udp 
EXPOSE $RCON_PORT/tcp

USER $user

VOLUME $volumedir

COPY --chown=$user:$group start.sh start.sh
ENTRYPOINT ["./start.sh"]
