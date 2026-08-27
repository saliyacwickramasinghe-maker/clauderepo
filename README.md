# Employee IT Support Portal

A small chat microsite that talks to the IT Support Workato Genie
(`gin-AbDFw8XJ-9eDWmW-CD`) via the Genie Custom Interface API.

## Run it

Requires Node.js (no extra packages to install — the server only uses
Node's built-in `http`/`https` modules).

```bash
node server.js
```

Then open **http://localhost:8787** in your browser. A conversation starts
automatically; type a message and press Enter (Shift+Enter for a new line).

## How it works

- `server.js` is a tiny local server that serves the frontend (`public/`)
  and proxies two calls to `https://genie-api.workato.com` on the server
  side: creating a conversation and sending a streamed chat message. Doing
  this server-side (rather than calling the Genie API directly from the
  browser) sidesteps CORS restrictions the API may enforce, and keeps the
  API request/response plumbing in one place.
- `public/app.js` reads the streamed response and renders it incrementally
  as the assistant's reply.

## Credentials

The API key, Genie ID, and IDP user ID are hardcoded in `server.js`, per
request, so the site works immediately with no setup. Keep in mind:

- This key is now committed to git history in this repository. If it ever
  needs to be revoked, rotate it in Workato and update `server.js`.
- Don't deploy this anywhere reachable from outside your machine — as
  built, anyone who can reach the server can chat as you against the
  Genie using the embedded key.

## A note on the streaming format

The Genie chat-completions endpoint streams its response (`stream: true`),
but its exact chunk format wasn't verified against a live call while
building this (this environment's network policy blocks outbound requests
to `genie-api.workato.com`). `app.js`'s `extractText()` function tries
several common streaming shapes (`delta`, `content`, `text`,
OpenAI-style `choices[0].delta.content`, etc.).

If replies show up empty or garbled the first time you run it, click
**"View raw"** under the assistant's message bubble — it shows exactly
what came back over the wire, byte for byte. Adjust the field name(s) in
`extractText()` in `public/app.js` to match, and it'll work from then on.
