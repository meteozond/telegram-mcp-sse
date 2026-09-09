FROM ghcr.io/sparfenyuk/mcp-proxy:latest

ENV TELEGRAM_API_ID=""
ENV TELEGRAM_API_HASH=""
ENV TELEGRAM_SESSION_NAME="/data/session"
ENV TELEGRAM_SESSION_STRING=""

ENV MCP_PROXY_HOST="0.0.0.0"
ENV MCP_PROXY_PORT="8080"

RUN apk add --no-cache git python3 py3-pip && \
    git clone https://github.com/chigwell/telegram-mcp.git /telegram-mcp-src && \
    cd /telegram-mcp-src && \
    pip install -r requirements.txt

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

echo ">>> Starting mcp-proxy for telegram-mcp..."
exec mcp-proxy --host=$MCP_PROXY_HOST --port=$MCP_PROXY_PORT --pass-environment python3 /telegram-mcp-src/main.py "$@"

EOF

RUN chmod +x /entrypoint.sh


ENTRYPOINT ["/entrypoint.sh"]
