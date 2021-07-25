FROM debian:buster-slim


ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-utils debconf locales locales-all && dpkg-reconfigure locales && \
    apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
        inotify-tools \
        x264 \
        ffmpeg

RUN pip3 install ffmpeg-normalize
        #libav-tools \

COPY auto_transcode/monitor.sh /opt/auto_transcode/
ENV PATH="/opt/auto_transcode:${PATH}"

RUN apt-get -y update && \
    apt-get -y --no-install-recommends install \
        procps \
        less && \
    rm -rf /var/cache/apt/* && \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["monitor.sh"]

