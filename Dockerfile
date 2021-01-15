FROM **TODO** as game-install

RUN /opt/steam/steamcmd.sh +login anonymous +force_install_dir /opt/game +app_update 232330 validate +quit

FROM ubuntu:focal

RUN apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests \
        lib32gcc1 \
    && apt-get clean autoclean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

COPY --chown=nobody:root --from=game-install /opt/game /opt/game

USER nobody
ENTRYPOINT ["/opt/game/srcds_run", "-game cstrike", "+map de_dust2", "-strictbindport"]
