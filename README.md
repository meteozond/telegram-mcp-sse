# Telegram MCP SSE Docker Image

## Description

Docker image for running MCP-proxy with Telegram integration. Based on 
`ghcr.io/sparfenyuk/mcp-proxy:latest` and includes 
[telegram-mcp](https://github.com/chigwell/telegram-mcp) for multiple agents
working with Telegram API.

## Features

- 🚀 Quick start MCP server with Telegram support
- 🔄 Automatic session initialization on first run
- 📦 Ready-to-use image with pre-installed dependencies
- 🤖 Multi-agent support - can serve multiple AI agents simultaneously

## Quick Start

### 1. Obtain Telegram API Credentials

Before starting, you need to get your API credentials:

1. Go to [my.telegram.org](https://my.telegram.org)
2. Log in with your phone number
3. Navigate to "API Development Tools"
4. Create a new application (if you haven't already)
5. Copy your `api_id` and `api_hash`

### 2. Initialize Telegram session (first time only)

Run the container in interactive mode to create your Telegram session:

```bash
docker run --rm -it \
  -e TELEGRAM_API_ID=your_api_id \
  -e TELEGRAM_API_HASH=your_api_hash \
  -v ./session.session:/session.session \
  meteozond/telegram-mcp-sse:latest
```

You will be prompted to:
1. Enter your phone number (with country code, e.g., +1234567890)
2. Enter the confirmation code sent to your Telegram
3. Enter your 2FA password (if enabled)
4. Exit the container after successful authentication

After successful authentication, the session will be saved to `session.session` file.

### 3. Run the container with MCP proxy

When session is created, run with port mapping:

```bash
docker run \
  -e TELEGRAM_API_ID=your_api_id \
  -e TELEGRAM_API_HASH=your_api_hash \
  -v ./session.session:/session.session \
  -p 8080:8080 \
  meteozond/telegram-mcp-sse:latest
```

After starting, if `session.session` exists the server will be available at 
`http://localhost:8080` and ready to serve multiple AI agents.

## Environment Variables

| Variable                  | Default Value | Description                          |
|---------------------------|---------------|--------------------------------------|
| `TELEGRAM_API_ID`         | -             | Telegram API ID (required)           |
| `TELEGRAM_API_HASH`       | -             | Telegram API Hash (required)         |
| `TELEGRAM_SESSION_NAME`   | `session`     | Session file name                    |
| `TELEGRAM_SESSION_STRING` | -             | Session string (alternative to file) |
| `MCP_PROXY_HOST`          | `0.0.0.0`     | MCP proxy host                       |
| `MCP_PROXY_PORT`          | `8080`        | MCP proxy port                       |


## Connecting to MCP Proxy

After startup, server is available at: `http://localhost:8080/sse`

## mcp.json Configuration

```json
{
  "servers": {
    "telegram": {
      "url": "http://127.0.0.1:8080/sse"
    }
  }
}
```

## Available Methods

MCP proxy provides access to all telegram-mcp methods:

- **Chats and Messages**: `list_chats`, `get_messages`, `send_message`, 
  `edit_message`, `delete_message`
- **Contacts**: `list_contacts`, `search_contacts`, `add_contact`, 
  `delete_contact`
- **Groups and Channels**: `create_group`, `create_channel`, `invite_to_group`,
  `get_participants`
- **Media**: `send_file`, `download_media`, `send_voice`, `send_sticker`, 
  `send_gif`
- **Administration**: `promote_admin`, `ban_user`, `unban_user`, `get_admins`
- **Profile**: `get_me`, `update_profile`, `set_profile_photo`, 
  `get_privacy_settings`
- **And much more...**

For complete method list, see [telegram-mcp documentation](https://github.com/chigwell/telegram-mcp).

## Troubleshooting

### Authentication Error

If you have session issues:

1. Delete `session.session` file
2. Restart in interactive mode to create new session

## Links

- [telegram-mcp](https://github.com/chigwell/telegram-mcp) - MCP server for 
  Telegram
- [mcp-proxy](https://github.com/sparfenyuk/mcp-proxy) - HTTP proxy for MCP
- [Telegram API](https://core.telegram.org/api) - Telegram API documentation
- [My Telegram](https://my.telegram.org) - Get API credentials

## License

MIT License

See [LICENSE](LICENSE) in the project root.
