# OpenMausBot on Railway: the official server image plus the Caddy edge that upstream runs as a
# separate container in the same network namespace (deploy/docker-compose.yml). Railway services
# don't share loopback, and the server only listens on 127.0.0.1 (loopback is its owner trust), so
# Caddy moves into this container and is the only thing on $PORT.
FROM caddy:2.11.7 AS caddy

FROM ghcr.io/milind-soni/openmausbot:v0.1.134
USER root
# tini reaps the exited Chrome helpers the bots' browsers leave behind (upstream's `init: true`);
# On Railway tini is not PID 1, so it runs as a child subreaper (-s) to still collect them.
RUN apt-get update \
  && apt-get install -y --no-install-recommends tini \
  && rm -rf /var/lib/apt/lists/* \
  && setpriv --version
COPY --from=caddy /usr/bin/caddy /usr/local/bin/caddy
# Engines baked in, so Settings -> Engines can sign them in straight away. Settings can also install
# newer copies into the volume (<data dir>/tools/npm), which win on the bots' PATH.
# upgrade: npm @anthropic-ai/claude-code
ARG CLAUDE_CODE_VERSION=2.1.316
# upgrade: npm @openai/codex
ARG CODEX_VERSION=0.166.0
RUN HOME=/tmp/omb-build-home npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION} @openai/codex@${CODEX_VERSION} \
  && rm -rf /tmp/omb-build-home /tmp/node-compile-cache
# Railway doesn't create /.dockerenv. Without it agent-browser and OpenMausBot's Chrome launcher
# don't know they are in a container, skip --disable-dev-shm-usage, and Chrome crashes on Railway's
# small /dev/shm (upstream compose sets shm_size: 512m instead).
RUN touch /.dockerenv
COPY Caddyfile /etc/caddy/Caddyfile
COPY railway-entrypoint.sh /usr/local/bin/railway-entrypoint.sh
RUN chmod 0755 /usr/local/bin/railway-entrypoint.sh \
  && caddy validate --config /etc/caddy/Caddyfile --adapter caddyfile
# Starts as root only to hand Railway's root-owned volume to `maus`, then drops to it.
ENTRYPOINT ["/usr/bin/tini", "-s", "--", "/usr/local/bin/railway-entrypoint.sh"]
CMD []
