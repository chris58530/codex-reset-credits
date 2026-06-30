$ErrorActionPreference = 'Stop'

function Get-CodexHome {
    if (-not [string]::IsNullOrWhiteSpace($env:CODEX_HOME)) {
        return $env:CODEX_HOME
    }
    return (Join-Path $env:USERPROFILE '.codex')
}

function Fail-Auth {
    Write-Output 'auth is invalid or Authorization is missing'
    exit 0
}

function Convert-ToLocalString {
    param([AllowNull()] $Value)

    if ($null -eq $Value -or [string]::IsNullOrWhiteSpace([string]$Value)) {
        return $null
    }

    $dto = [DateTimeOffset]::Parse(
        [string]$Value,
        [Globalization.CultureInfo]::InvariantCulture,
        [Globalization.DateTimeStyles]::AssumeUniversal
    )
    return $dto.ToLocalTime().ToString('yyyy-MM-dd HH:mm:ss zzz')
}

$authPath = Join-Path (Get-CodexHome) 'auth.json'
if (-not (Test-Path -LiteralPath $authPath)) {
    Fail-Auth
}

try {
    $auth = Get-Content -Raw -LiteralPath $authPath | ConvertFrom-Json
    $accessToken = $auth.tokens.access_token
    $accountId = $auth.tokens.account_id
} catch {
    Fail-Auth
}

if ([string]::IsNullOrWhiteSpace($accessToken)) {
    Fail-Auth
}

$headers = @{
    Authorization = "Bearer $accessToken"
    Accept = 'application/json'
    'OpenAI-Beta' = 'codex-1'
    originator = 'Codex Desktop'
}

if (-not [string]::IsNullOrWhiteSpace($accountId)) {
    $headers['ChatGPT-Account-ID'] = $accountId
}

try {
    $response = Invoke-WebRequest `
        -Method GET `
        -Uri 'https://chatgpt.com/backend-api/wham/rate-limit-reset-credits' `
        -Headers $headers `
        -UseBasicParsing
    $data = $response.Content | ConvertFrom-Json
} catch {
    $statusCode = $null
    if ($_.Exception.Response -and $_.Exception.Response.StatusCode) {
        $statusCode = [int]$_.Exception.Response.StatusCode
    }
    if ($statusCode -eq 401) {
        Fail-Auth
    }
    throw
}

$credits = @()
foreach ($credit in @($data.credits)) {
    $credits += [pscustomobject]@{
        status = $credit.status
        title = $credit.title
        granted_at = Convert-ToLocalString $credit.granted_at
        expires_at = Convert-ToLocalString $credit.expires_at
    }
}

[pscustomobject]@{
    available_count = $data.available_count
    credits = $credits
} | ConvertTo-Json -Depth 5
