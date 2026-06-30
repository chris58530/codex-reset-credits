# Codex Reset Credits

A public Codex skill for checking local Codex rate-limit reset-credit availability without printing tokens, cookies, account IDs, or internal IDs.

## Copy-Paste Prompt

Paste this into Codex:

```text
Use https://github.com/chris58530/codex-reset-credits to check my local Codex rate-limit reset credits. Install it as a skill if needed, then show only available_count and each credit's status/title/granted_at/expires_at in local time. Never print tokens, cookies, Authorization headers, account IDs, or full internal IDs. If the request returns 401, say: auth is invalid or Authorization is missing.
```

## Install as a Codex Skill

Windows PowerShell:

```powershell
git clone https://github.com/chris58530/codex-reset-credits.git "$env:USERPROFILE\.codex\skills\codex-reset-credits"
```

Then ask Codex:

```text
Use $codex-reset-credits to check my reset credits.
```

## Run Directly

Windows PowerShell:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.codex\skills\codex-reset-credits\scripts\get-reset-credits.ps1"
```

Expected output shape:

```json
{
  "available_count": 2,
  "credits": [
    {
      "status": "available",
      "title": "Full reset (Weekly + 5 hr)",
      "granted_at": "2026-06-27 07:44:36 +08:00",
      "expires_at": "2026-07-27 07:44:36 +08:00"
    }
  ]
}
```

## What It Does

The script reads local Codex auth from:

```text
$CODEX_HOME\auth.json
```

or, when `CODEX_HOME` is unset:

```text
%USERPROFILE%\.codex\auth.json
```

It calls:

```text
https://chatgpt.com/backend-api/wham/rate-limit-reset-credits
```

It prints only:

- `available_count`
- each credit's `status`
- each credit's `title`
- each credit's `granted_at` in local time
- each credit's `expires_at` in local time

## Safety

- Never share your `auth.json`.
- Never paste tokens, cookies, or authorization headers into chat.
- This tool intentionally does not print tokens, cookies, account IDs, or full internal IDs.
- If auth is missing, expired, or rejected with HTTP 401, it prints:

```text
auth is invalid or Authorization is missing
```

## Notes

- This checks Codex reset credits, not OpenAI API billing credits.
- This uses a ChatGPT backend endpoint, not a stable public OpenAI API.
- The included script is PowerShell-first and works best on Windows.
