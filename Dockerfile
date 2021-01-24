FROM ghcr.io/lanofdoom/steamcmd/steamcmd:latest as install

RUN /opt/steam/steamcmd.sh +login anonymous +force_install_dir /opt/game +app_update 232330 validate +quit
RUN rm -rf /opt/game/steamapps

FROM ubuntu:focal

RUN apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests \
        lib32gcc1 \
    && apt-get clean autoclean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

COPY --chown=nobody:root --from=install /opt/game /opt/game

ENTRYPOINT ["su", "-s", "/bin/bash", "nobody", "--", "/opt/game/srcds_run", "-game cstrike", "+map de_dust2", "-strictbindport"]
