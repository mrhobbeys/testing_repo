# Discord Webhook PowerShell Script

A PowerShell script that sends the Star Spangled Banner lyrics to a Discord channel via webhook integration.

## Features

- ✅ **Parameter Validation**: Validates Discord webhook URL format
- ✅ **Error Handling**: Comprehensive try-catch blocks with retry logic
- ✅ **Retry Mechanism**: Configurable retry attempts with exponential backoff
- ✅ **Detailed Logging**: Colored console output for better user experience
- ✅ **Help Documentation**: Full PowerShell help with examples

## Usage

```powershell
.\Discord-Webhook.ps1 -WebhookUrl "https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN"
```

### Getting a Discord Webhook URL

1. Go to your Discord server
2. Right-click on the channel where you want to post messages
3. Select "Edit Channel" → "Integrations" → "Webhooks"
4. Click "New Webhook" or "Create Webhook"
5. Copy the webhook URL

## Parameters

- **WebhookUrl** (Required): The Discord webhook URL to send the message to
  - Must be a valid HTTPS Discord webhook URL
  - Format: `https://discord.com/api/webhooks/{id}/{token}`

## Error Handling

The script includes comprehensive error handling for:

- Invalid webhook URL format
- Network connectivity issues
- Discord API errors (400, 401, 403, 404, 429)
- Rate limiting with exponential backoff

## Configuration

You can modify these variables at the top of the script:

- `$MAX_RETRIES`: Number of retry attempts (default: 3)
- `$RETRY_DELAY`: Initial retry delay in seconds (default: 2)

## Requirements

- PowerShell 5.1 or later
- Internet connectivity
- Valid Discord webhook URL

## Help

For detailed help, run:

```powershell
Get-Help .\Discord-Webhook.ps1 -Full
```

## Examples

```powershell
# Basic usage
.\Discord-Webhook.ps1 -WebhookUrl "https://discord.com/api/webhooks/123456789/abcdef123456"

# View help
Get-Help .\Discord-Webhook.ps1 -Examples
```