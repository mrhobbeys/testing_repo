<#
.SYNOPSIS
    Sends the Star Spangled Banner lyrics to a Discord channel via webhook.

.DESCRIPTION
    This PowerShell script posts the complete lyrics of "The Star-Spangled Banner" 
    to a Discord channel using a webhook URL. It includes error handling, input validation,
    and proper formatting for Discord messages.

.PARAMETER WebhookUrl
    The Discord webhook URL to send the message to. Must be a valid HTTPS URL.

.EXAMPLE
    .\Discord-Webhook.ps1 -WebhookUrl "https://discord.com/api/webhooks/your-webhook-url"

.NOTES
    Author: Created for Discord webhook integration
    Requires: PowerShell 5.1 or later
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, HelpMessage = "Enter the Discord webhook URL")]
    [ValidateNotNullOrEmpty()]
    [ValidatePattern('^https://discord(app)?\.com/api/webhooks/\d+/[A-Za-z0-9_-]+$', ErrorMessage = "Invalid Discord webhook URL format")]
    [string]$WebhookUrl
)

# Configuration Variables
$WEBHOOK_URL = $WebhookUrl
$MAX_RETRIES = 3
$RETRY_DELAY = 2  # seconds

# Star Spangled Banner Lyrics
$STAR_SPANGLED_BANNER = @"
🇺🇸 **The Star-Spangled Banner** 🇺🇸

O say can you see, by the dawn's early light,
What so proudly we hailed at the twilight's last gleaming,
Whose broad stripes and bright stars through the perilous fight,
O'er the ramparts we watched, were so gallantly streaming?
And the rocket's red glare, the bombs bursting in air,
Gave proof through the night that our flag was still there;
O say does that star-spangled banner yet wave
O'er the land of the free and the home of the brave?

On the shore dimly seen through the mists of the deep,
Where the foe's haughty host in dread silence reposes,
What is that which the breeze, o'er the towering steep,
As it fitfully blows, half conceals, half discloses?
Now it catches the gleam of the morning's first beam,
In full glory reflected now shines in the stream:
'Tis the star-spangled banner, O long may it wave
O'er the land of the free and the home of the brave.

And where is that band who so vauntingly swore
That the havoc of war and the battle's confusion,
A home and a country, should leave us no more?
Their blood has washed out their foul footsteps' pollution.
No refuge could save the hireling and slave
From the terror of flight, or the gloom of the grave:
And the star-spangled banner in triumph doth wave,
O'er the land of the free and the home of the brave.

O thus be it ever, when freemen shall stand
Between their loved homes and the war's desolation.
Blest with vict'ry and peace, may the Heav'n rescued land
Praise the Power that hath made and preserved us a nation!
Then conquer we must, when our cause it is just,
And this be our motto: 'In God is our trust.'
And the star-spangled banner in triumph shall wave
O'er the land of the free and the home of the brave!
"@

# Function to send message with retry logic
function Send-DiscordMessage {
    param(
        [string]$Message,
        [string]$WebhookUrl,
        [int]$MaxRetries = 3
    )
    
    $retryCount = 0
    $success = $false
    
    while ($retryCount -lt $MaxRetries -and -not $success) {
        try {
            Write-Host "Attempting to send message to Discord (Attempt $($retryCount + 1)/$MaxRetries)..." -ForegroundColor Yellow
            
            # Prepare the payload for Discord webhook
            $payload = @{
                content = $Message
                username = "PowerShell Bot"
                avatar_url = "https://raw.githubusercontent.com/PowerShell/PowerShell/master/assets/ps_black_64.svg"
            } | ConvertTo-Json -Depth 10
            
            # Send the message to Discord
            $response = Invoke-RestMethod -Uri $WebhookUrl -Method POST -Body $payload -ContentType "application/json" -ErrorAction Stop
            
            Write-Host "✅ Message sent successfully to Discord!" -ForegroundColor Green
            $success = $true
            return $true
            
        }
        catch {
            $retryCount++
            $errorMessage = $_.Exception.Message
            
            Write-Warning "❌ Failed to send message (Attempt $retryCount/$MaxRetries): $errorMessage"
            
            # Check for specific Discord API errors
            if ($_.Exception.Response) {
                $statusCode = $_.Exception.Response.StatusCode.Value__
                switch ($statusCode) {
                    400 { Write-Warning "Bad Request - Check webhook URL and message format" }
                    401 { Write-Warning "Unauthorized - Invalid webhook URL" }
                    403 { Write-Warning "Forbidden - Webhook may be disabled or invalid" }
                    404 { Write-Warning "Not Found - Webhook URL not found" }
                    429 { Write-Warning "Rate Limited - Too many requests, waiting longer..." }
                    default { Write-Warning "HTTP Status Code: $statusCode" }
                }
            }
            
            # Wait before retrying (except on last attempt)
            if ($retryCount -lt $MaxRetries) {
                Write-Host "Waiting $RETRY_DELAY seconds before retry..." -ForegroundColor Yellow
                Start-Sleep -Seconds $RETRY_DELAY
                $RETRY_DELAY = $RETRY_DELAY * 2  # Exponential backoff
            }
        }
    }
    
    if (-not $success) {
        Write-Error "Failed to send message after $MaxRetries attempts"
        return $false
    }
}

# Main script execution
try {
    Write-Host "🚀 Starting Discord Webhook Script..." -ForegroundColor Cyan
    Write-Host "Webhook URL: $($WEBHOOK_URL.Substring(0, 50))..." -ForegroundColor Cyan
    
    # Validate webhook URL format (additional validation beyond parameter validation)
    if (-not ($WEBHOOK_URL -match '^https://discord(app)?\.com/api/webhooks/\d+/[A-Za-z0-9_-]+$')) {
        throw "Invalid Discord webhook URL format. Please provide a valid Discord webhook URL."
    }
    
    # Send the Star Spangled Banner lyrics
    $result = Send-DiscordMessage -Message $STAR_SPANGLED_BANNER -WebhookUrl $WEBHOOK_URL -MaxRetries $MAX_RETRIES
    
    if ($result) {
        Write-Host "🎉 The Star-Spangled Banner has been successfully posted to Discord!" -ForegroundColor Green
        exit 0
    }
    else {
        Write-Error "Failed to post the message to Discord"
        exit 1
    }
}
catch {
    Write-Error "❌ Script execution failed: $($_.Exception.Message)"
    Write-Host "Please check your webhook URL and try again." -ForegroundColor Red
    exit 1
}
finally {
    Write-Host "Script execution completed." -ForegroundColor Cyan
}