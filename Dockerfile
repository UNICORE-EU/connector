FROM ubuntu:24.04

RUN apt-get update -q

RUN DEBIAN_FRONTEND="noninteractive" apt-get install -q -m -y \
    sudo nano less \
    openssl \
    hostname wget curl \
    python3-minimal \
    python3-requests \
    openjdk-21-jre-headless

RUN /usr/sbin/groupadd -r unicore 2>/dev/null
RUN /usr/sbin/useradd -c "UNICORE" -g unicore -s /bin/false -r -d /tmp unicore 2>/dev/null
RUN mkdir -p /opt/unicore/unicorex/lib /opt/unicore/unicorex/bin /opt/unicore/unicorex/conf \
            /opt/unicore/gateway/lib /opt/unicore/gateway/bin /opt/unicore/gateway/conf \ 
            /opt/unicore/certs
COPY ./unicore/gateway/lib/* /opt/unicore/gateway/lib/
COPY ./unicore/gateway/bin/* /opt/unicore/gateway/bin/
COPY ./config/gateway/* /opt/unicore/gateway/conf/
COPY ./unicore/unicorex/lib/* /opt/unicore/unicorex/lib/
COPY ./unicore/unicorex/bin/* /opt/unicore/unicorex/bin/
COPY ./config/unicorex/* /opt/unicore/unicorex/conf/
COPY ./unicore/*.sh /opt/unicore/
RUN chown -R unicore:unicore /opt/unicore

COPY docker-entrypoint.sh /usr/local/bin/
COPY health-check.py /usr/local/bin/

EXPOSE 8080

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["bash"]

HEALTHCHECK --interval=30s --timeout=10s --retries=10 \
 CMD python3 /usr/local/bin/health-check.py
