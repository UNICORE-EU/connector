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
RUN mkdir -p /unicore/unicorex/lib /unicore/unicorex/bin /unicore/unicorex/conf \
            /unicore/gateway/lib /unicore/gateway/bin /unicore/gateway/conf \ 
            /unicore/certs
COPY ./unicore/gateway/lib/* /unicore/gateway/lib/
COPY ./unicore/gateway/bin/* /unicore/gateway/bin/
COPY ./config/gateway/* /unicore/gateway/conf/
COPY ./unicore/unicorex/lib/* /unicore/unicorex/lib/
COPY ./unicore/unicorex/bin/* /unicore/unicorex/bin/
COPY ./config/unicorex/* /unicore/unicorex/conf/
COPY ./unicore/*.sh /unicore/
RUN chown -R unicore:unicore /unicore

COPY docker-entrypoint.sh /usr/local/bin/
COPY health-check.py /usr/local/bin/

EXPOSE 8080

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["bash"]

HEALTHCHECK --interval=30s --timeout=10s --retries=10 \
 CMD python3 /usr/local/bin/health-check.py
