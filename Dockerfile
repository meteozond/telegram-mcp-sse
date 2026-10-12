FROM ghcr.io/sparfenyuk/mcp-proxy:latest

ENV TELEGRAM_API_ID=""
ENV TELEGRAM_API_HASH=""
ENV TELEGRAM_SESSION_NAME="/data/session"
ENV TELEGRAM_SESSION_STRING=""

ENV MCP_PROXY_HOST="0.0.0.0"
ENV MCP_PROXY_PORT="8080"

ARG TELEGRAM_MCP_REPO=https://github.com/chigwell/telegram-mcp.git
ARG TELEGRAM_MCP_REF=main

RUN apk add --no-cache git python3 py3-pip && \
    git clone --depth 1 --branch "$TELEGRAM_MCP_REF" "$TELEGRAM_MCP_REPO" /telegram-mcp-src && \
    pip install --no-cache-dir -r /telegram-mcp-src/requirements.txt && \
    rm -rf /telegram-mcp-src/.git

ENV PATH="/usr/local/bin:${PATH}"

WORKDIR /data

RUN cat > /entrypoint.sh <<'EOF'
#!/bin/sh
set -e

SESSION_FILE="${TELEGRAM_SESSION_NAME}.session"

if [ -t 0 ] && [ -n "$TELEGRAM_API_ID" ] && [ -n "$TELEGRAM_API_HASH" ] && \
   [ -z "$TELEGRAM_SESSION_STRING" ] && [ ! -f "$SESSION_FILE" ]; then
    echo ">>> Starting interactive login..."
    python3 -c 'import os;from telethon.sync import TelegramClient;TelegramClient(os.environ["TELEGRAM_SESSION_NAME"],int(os.environ["TELEGRAM_API_ID"]),os.environ["TELEGRAM_API_HASH"]).start().disconnect()'
    echo ">>> Login done. Session saved to $SESSION_FILE. Re-run to start the server."
    exit 0
fi

echo ">>> Starting mcp-proxy (/sse and /mcp) on $MCP_PROXY_HOST:$MCP_PROXY_PORT..."
exec mcp-proxy --host=$MCP_PROXY_HOST --port=$MCP_PROXY_PORT --pass-environment python3 /telegram-mcp-src/main.py "$@"

EOF

RUN chmod +x /entrypoint.sh


ENTRYPOINT ["/entrypoint.sh"]
