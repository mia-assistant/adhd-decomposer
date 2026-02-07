# Tiny Steps API

Backend API for the Tiny Steps ADHD task decomposition app.

## Setup

### 1. Install dependencies

```bash
npm install
```

### 2. Login to Cloudflare

```bash
npx wrangler login
```

### 3. Create KV namespaces

```bash
# Create the namespaces
npx wrangler kv:namespace create "RATE_LIMITS"
npx wrangler kv:namespace create "CACHE"
npx wrangler kv:namespace create "USERS"

# Copy the IDs and update wrangler.toml
```

### 4. Set secrets

```bash
# OpenAI API key
npx wrangler secret put OPENAI_API_KEY
# (paste your key when prompted)

# JWT secret (generate a random 64-char string)
npx wrangler secret put JWT_SECRET
# (paste a random secret like: openssl rand -hex 32)
```

### 5. Update wrangler.toml

Replace the placeholder KV namespace IDs with the real ones from step 3.

### 6. Deploy

```bash
npm run deploy
```

## Local Development

```bash
npm run dev
```

This starts a local server at http://localhost:8787

## API Endpoints

### `POST /v1/register`

Register a new device and get an auth token.

**Response:**
```json
{
  "success": true,
  "token": "eyJ...",
  "deviceId": "abc123..."
}
```

### `POST /v1/decompose`

Break down a task into steps.

**Headers:**
- `Authorization: Bearer <token>`

**Body:**
```json
{
  "task": "Clean my room",
  "style": "standard|quick|gentle",
  "context": {
    "timeOfDay": "morning|afternoon|evening|night",
    "energy": "low|medium|high"
  }
}
```

**Response:**
```json
{
  "success": true,
  "steps": [
    "Grab a trash bag from under the sink",
    "Walk around the room and pick up obvious trash",
    "..."
  ],
  "estimatedMinutes": 25,
  "encouragement": "You've got this! One step at a time.",
  "cached": false
}
```

### `GET /v1/usage`

Get current usage stats.

**Headers:**
- `Authorization: Bearer <token>`

**Response:**
```json
{
  "used": 2,
  "limit": 3,
  "resetsAt": "2024-01-02T00:00:00.000Z",
  "isPremium": false
}
```

### `POST /v1/verify-subscription`

Verify premium subscription status (for RevenueCat integration).

**Headers:**
- `Authorization: Bearer <token>`

**Body:**
```json
{
  "revenueCatUserId": "rc_user_123"
}
```

## Rate Limits

- **Free users:** 3 decompositions per day
- **Premium users:** Unlimited

Rate limits reset at midnight UTC.

## Caching

Common task decompositions are cached for 24 hours to:
- Reduce API costs
- Improve response times
- Provide consistent results

Cache keys are normalized (lowercase, trimmed, punctuation removed) so slight variations still hit the cache.

## Security

- All requests require a valid JWT (except `/v1/register`)
- Tokens are tied to device IDs
- Rate limiting prevents abuse
- Request validation prevents injection
- CORS headers configured for mobile app access

## RevenueCat Webhook

Set up a webhook in RevenueCat dashboard pointing to:
```
POST https://your-worker.workers.dev/v1/webhook/revenuecat
```

This will upgrade users to premium when they subscribe.

## Environment Variables

| Variable | Description |
|----------|-------------|
| `OPENAI_API_KEY` | OpenAI API key (secret) |
| `JWT_SECRET` | Secret for signing JWTs (secret) |
| `FREE_DAILY_LIMIT` | Decompositions per day for free users |
| `CACHE_TTL_SECONDS` | How long to cache responses |

## Cost Estimation

Using GPT-4o-mini:
- ~$0.15 per 1M input tokens
- ~$0.60 per 1M output tokens

Average request: ~500 input + 500 output tokens = ~$0.0004/request

| Users | Requests/day | Monthly cost (no cache) | With 50% cache |
|-------|--------------|-------------------------|----------------|
| 100 | 300 | $3.60 | $1.80 |
| 1,000 | 3,000 | $36 | $18 |
| 10,000 | 30,000 | $360 | $180 |

Cloudflare Workers free tier: 100,000 requests/day
