FROM debian:stable
ARG TUBEREPAIR_USER_UID="2000"
ARG TUBEREPAIR_USER_GID="2000"
EXPOSE 80
EXPOSE 443
LABEL NAME="TubeRepair tuberepair.uptimetrackers.com blueprint"
LABEL VERSION="0.1 Beta"

COPY --chown=${TUBEREPAIR_USER_UID}:${TUBEREPAIR_USER_GID} ./tuberepair /tuberepair-python

RUN /bin/bash | \
    groupadd -g ${TUBEREPAIR_USER_GID} tuberepair && \
    useradd tuberepair -u ${TUBEREPAIR_USER_UID} -g ${TUBEREPAIR_USER_GID} && \
    apt-get update && \
    apt-get install python3 python3-pip --no-install-recommends -y && \
    cd /tuberepair-python && \
    pip3 install -r requirements.txt --break-system-packages && \
    apt-get clean

WORKDIR /tuberepair-python

USER tuberepair

CMD ["python3", "main.py"]