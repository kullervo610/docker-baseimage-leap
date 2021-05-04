FROM registry.opensuse.org/opensuse/leap:15.3

#
# Add s6 overlay
#
ARG S6_OVERLAY_VERSION=v2.2.0.3
ARG S6_OVERLAY_ARCH=amd64
ARG S6_OVERLAY_URL=https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-${S6_OVERLAY_ARCH}-installer

RUN set -ex && \
  zypper -n install curl && \
  curl -# -L -o /tmp/s6-overlay-${OVERLAY_ARCH}-installer ${S6_OVERLAY_URL} && \
  chmod +x /tmp/s6-overlay-${OVERLAY_ARCH}-installer && \
  /tmp/s6-overlay-${OVERLAY_ARCH}-installer / && \
  rm /tmp/s6-overlay-${OVERLAY_ARCH}-installer && \
  zypper -n remove --clean-deps curl && \
  zypper clean

#
# Add timezone data (tzdata) and set default timezone as UTC offset 00:00
#
RUN set -ex && \
  zypper -n install timezone && \
  zypper clean
ENV TZ Factory

#
# Add a default user and group for a container
# as well as working directory for an app
#
ARG APPHOME=/app
WORKDIR ${APPHOME}
RUN set -ex && \
  useradd -r -U -d ${APPHOME} -s /bin/false container && \
  usermod -G users container && \
  chown -R container:container ${APPHOME}
USER container

#
# Use s6 overlay for process supervision (as PID 1)
#
ENTRYPOINT ["/init"]
