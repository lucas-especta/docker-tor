FROM debian:bookworm

EXPOSE 9001
ENV DEBIAN_FRONTEND=noninteractive

ADD apt-pinning /etc/apt/preferences.d/pinning

RUN apt-get update && apt-get install -y \
    gpg \
    dirmngr \
    gpg-agent \
    curl

RUN echo 'deb http://deb.torproject.org/torproject.org bookworm main' > /etc/apt/sources.list.d/tor.list && \
    curl -sSl https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --import - && \
    gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -

RUN apt-get update && apt-get install -y \
    deb.torproject.org-keyring \
    obfs4proxy \
    openssl \
    tor

# tor-arm does not work in Docker container:
# _curses.error: setupterm: could not find terminal
# Install outside of the Docker container if required.

WORKDIR /var/lib/tor

ADD ./torrc /etc/torrc
# Allow you to upgrade your relay without having to regenerate keys
# VOLUME /var/lib/tor

VOLUME /.tor

# Generate a random nickname for the relay
RUN echo "Nickname docker$(head -c 16 /dev/urandom  | sha1sum | cut -c1-10)" >> /etc/torrc

CMD ["/usr/bin/tor", "-f", "/etc/torrc"]
