#!/bin/bash
# Runs OpenMausBot and its Caddy edge in one Railway service. Either one exiting stops the
# container, so Railway restarts both together.
set -euo pipefail

# Railway mounts the volume owned by root; the server and the bots run as `maus` with HOME=/data.
if [ "$(stat -c %U /data)" != maus ]; then
  echo "railway: handing /data to maus"
  chown -R maus:maus /data
fi

as_maus() { setpriv --reuid=maus --regid=maus --init-groups --reset-env -- env \
  HOME=/data PATH="$PATH" "${keep[@]}" "$@"; }
# --reset-env drops the environment; pass on everything but Railway's root-only bits.
keep=()
while IFS= read -r -d '' kv; do
  case "${kv%%=*}" in HOME|PATH|USER|LOGNAME|SHELL) ;; *) keep+=("$kv") ;; esac
done < <(env -0)

cd /app
as_maus node dist-server/server-launcher.js &
server=$!
as_maus caddy run --config /etc/caddy/Caddyfile --adapter caddyfile &
edge=$!

stop() { kill -TERM "$server" "$edge" 2>/dev/null || true; }
trap stop TERM INT
set +e
wait -n "$server" "$edge"
status=$?
stop
wait
exit "$status"
