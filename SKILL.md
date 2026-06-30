---
name: codex-reset-credits
description: Check Codex or ChatGPT rate-limit reset-credit grants using the local Codex ChatGPT auth token. Use when the user asks to check available reset credits, rate-limit reset credits, reset-credit grants, available_count, or credit status/title/granted_at/expires_at. This skill must never print tokens, cookies, authorization headers, account IDs, or full internal IDs.
---

# Codex Reset Credits

## Quick Path

Run the bundled script first:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.codex\skills\codex-reset-credits\scripts\get-reset-credits.ps1"
```

The script reads local Codex auth from `$CODEX_HOME\auth.json` or `%USERPROFILE%\.codex\auth.json`, calls:

```text
https://chatgpt.com/backend-api/wham/rate-limit-reset-credits
```

Then prints only:

- `available_count`
- each credit's `status`
- each credit's `title`
- each credit's `granted_at` in local time
- each credit's `expires_at` in local time

## Safety Rules

- Never print access tokens, refresh tokens, ID tokens, cookies, `Authorization`, `ChatGPT-Account-ID`, or full internal IDs.
- Do not inspect logs or binary strings before trying the script.
- If the request returns HTTP `401`, say exactly: `auth is invalid or Authorization is missing`.
- If auth data is absent or malformed, say exactly: `auth is invalid or Authorization is missing`.
- Keep output minimal. Prefer JSON unless the user asks for another format.

## Manual Fallback

Use this only if the script is missing or broken:

1. Read local Codex auth from `$CODEX_HOME\auth.json`; when `CODEX_HOME` is unset, use `%USERPROFILE%\.codex\auth.json`.
2. Extract `tokens.access_token`; optionally pass `tokens.account_id` as `ChatGPT-Account-ID`, but never print it.
3. Send `GET https://chatgpt.com/backend-api/wham/rate-limit-reset-credits`.
4. Include headers:
   - `Authorization: Bearer <access_token>`
   - `Accept: application/json`
   - `OpenAI-Beta: codex-1`
   - `originator: Codex Desktop`
5. Convert `granted_at` and `expires_at` to local time before showing them.
6. Emit only the allowlisted fields.
