# Deploy and Host OpenMausBot on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/openmausbot?referralCode=sLjDXb&utm_medium=integration&utm_source=button&utm_campaign=openmausbot)

[OpenMausBot](https://github.com/milind-soni/OpenMausBot) is an open-source alternative to Grok Bot: a chat app where you build a team of AI bots. Each bot runs on a real agent CLI (Claude Code or Codex) with your own subscription, and gets its own model, memory, skills, connected apps and a browser it can drive. Bots talk to each other in rooms, run routines on a schedule and answer webhooks. This template runs the official server image always-on, so your bots keep working with every laptop closed.

## About Hosting OpenMausBot

One service and one volume, no database. The official `ghcr.io/milind-soni/openmausbot` image (pinned to a release) runs the server, the web app and a bundled Chrome for the bots' browser. The server only listens on loopback, which is its owner trust, so this template puts a Caddy edge in the same container on Railway's port, as upstream's Docker stack does in a sidecar. Caddy forwards the real client address and streams events unbuffered; it adds no password of its own.

Sign-in is OpenMausBot's own. The emails you set in `OMB_SIGNIN_EMAILS` sign in at `/pair` with a one-time code from OpenMausBot's account service, so no mail server is needed. Everything else answers only to a signed-in session.

Everything lives on the volume at `/data`: bots, chats, memory, engine logins and settings survive redeploys.

## Common Use Cases

- An always-on team of coding and research bots on your Claude Pro/Max or ChatGPT plan
- Bots that browse the web, fill forms and collect data in their own browser sessions
- Scheduled routines, such as a morning digest or a weekly report, that run with your computer off
- Webhook-driven bots that react to GitHub, Stripe or form events
- One workspace for a small team, with chat-only members next to admins

## Dependencies for OpenMausBot Hosting

- A Claude (Pro/Max) or ChatGPT account for the engines, or an Anthropic or OpenAI-compatible API key
- An email address to sign in with

### Deployment Dependencies

- [OpenMausBot on GitHub](https://github.com/milind-soni/OpenMausBot)
- [Self-hosting guide](https://github.com/milind-soni/OpenMausBot/blob/main/docs/self-hosting.md)
- [Template source](https://github.com/two-workspaces/openmausbot)

### Implementation Details

**First use:**

1. Enter your email as `OMB_SIGNIN_EMAILS` when you deploy.
2. Open the service's Railway domain. It shows the sign-in page: choose **Sign in with email**, enter the code you receive, and the browser stays signed in.
3. Go to **Settings → Engines**. **Claude Code**: "Sign in to Claude" opens Anthropic's sign-in and gives you a code to paste back. **Codex**: "Connect ChatGPT" shows a device code for OpenAI's page. Both CLIs are already installed.
4. Create a bot and start chatting.

Prefer a pairing code? Open a shell with `railway ssh` and run:

```
setpriv --reuid=maus --regid=maus --init-groups env HOME=/data node /app/dist-server/openmausbot.js pair --label "My browser"
```

It prints a single-use code (valid ten minutes) and a link to your domain. Add `--client` for a chat-only device.

**Settings:**

- `OMB_SIGNIN_EMAILS`: admins, comma-separated addresses or `@domain`. `OMB_SIGNIN_MEMBER_EMAILS`: people who may only chat and approve. These variables win over the list in Settings while they are set.
- `OMB_PUBLIC_URL`: change to `https://your-domain` after adding a custom domain, so pairing links use it. Webhook URLs follow it.
- Pay per token instead of a subscription: add an Anthropic or OpenAI-compatible key under **Settings → Connections → Model providers**.

Notes and limits:

- Bots' shells and browsers run inside this container as the same user as the server. Only give admin access to people you trust with that.
- The bots' browser is a full Chrome, started per bot when it browses. Browsing bots need more RAM than chat alone, so the Free plan's 0.5 GB is too small for them.
- A redeploy waits up to `RAILWAY_DEPLOYMENT_DRAINING_SECONDS` (30) for running bot turns to stop cleanly.
- Grok Build and voice features are desktop-app or extra-key features and are not set up here.

## Why Deploy OpenMausBot on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying OpenMausBot on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
