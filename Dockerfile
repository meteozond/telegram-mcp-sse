FROM ghcr.io/sparfenyuk/mcp-proxy:latest

ENV TELEGRAM_API_ID=""
ENV TELEGRAM_API_HASH=""
ENV TELEGRAM_SESSION_NAME="session"
ENV TELEGRAM_SESSION_STRING=""

ENV MCP_PROXY_HOST="0.0.0.0"
ENV MCP_PROXY_PORT="8080"

RUN apk add --no-cache git python3 py3-pip && \
    git clone https://github.com/chigwell/telegram-mcp.git /telegram-mcp-src && \
    cd /telegram-mcp-src && \
    pip install -r requirements.txt

ENV PATH="/usr/local/bin:${PATH}"

WORKDIR /

RUN cat > /entrypoint.sh <<'EOF'
#!/bin/sh
SESSION_FILE="/telegram-mcp-src/${TELEGRAM_SESSION_NAME}.session"

if [ ! -f "/$TELEGRAM_SESSION_NAME.session" ]; then
    echo "Session file not found: $SESSION_FILE"
    echo "Running telegram-mcp directly for session setup..."
    exec python3 /telegram-mcp-src/main.py "$@"
else
    echo "Session file found: $SESSION_FILE"
    echo "Starting mcp-proxy for telegram-mcp..."
    exec mcp-proxy --host=$MCP_PROXY_HOST --port=$MCP_PROXY_PORT --pass-environment python3 /telegram-mcp-src/main.py "$@"
fi
EOF

RUN chmod +x /entrypoint.sh


ENTRYPOINT ["/entrypoint.sh"]
