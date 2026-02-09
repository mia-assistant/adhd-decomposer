var __defProp = Object.defineProperty;
var __name = (target, value) => __defProp(target, "name", { value, configurable: true });

// src/auth.ts
var encoder = new TextEncoder();
function base64UrlEncode(data) {
  const base64 = btoa(String.fromCharCode(...data));
  return base64.replace(/\+/g, "-").replace(/\//g, "_").replace(/=/g, "");
}
__name(base64UrlEncode, "base64UrlEncode");
function base64UrlDecode(str) {
  const base64 = str.replace(/-/g, "+").replace(/_/g, "/");
  const padding = "=".repeat((4 - base64.length % 4) % 4);
  const binary = atob(base64 + padding);
  return Uint8Array.from(binary, (c) => c.charCodeAt(0));
}
__name(base64UrlDecode, "base64UrlDecode");
async function getKey(secret) {
  return crypto.subtle.importKey(
    "raw",
    encoder.encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign", "verify"]
  );
}
__name(getKey, "getKey");
async function createToken(payload, secret, expiresInDays = 365) {
  const now = Math.floor(Date.now() / 1e3);
  const fullPayload = {
    ...payload,
    iat: now,
    exp: now + expiresInDays * 24 * 60 * 60
  };
  const header = { alg: "HS256", typ: "JWT" };
  const headerB64 = base64UrlEncode(encoder.encode(JSON.stringify(header)));
  const payloadB64 = base64UrlEncode(encoder.encode(JSON.stringify(fullPayload)));
  const key = await getKey(secret);
  const signature = await crypto.subtle.sign(
    "HMAC",
    key,
    encoder.encode(`${headerB64}.${payloadB64}`)
  );
  const signatureB64 = base64UrlEncode(new Uint8Array(signature));
  return `${headerB64}.${payloadB64}.${signatureB64}`;
}
__name(createToken, "createToken");
async function verifyToken(token, secret) {
  try {
    const parts = token.split(".");
    if (parts.length !== 3) return null;
    const [headerB64, payloadB64, signatureB64] = parts;
    const key = await getKey(secret);
    const signature = base64UrlDecode(signatureB64);
    const valid = await crypto.subtle.verify(
      "HMAC",
      key,
      signature,
      encoder.encode(`${headerB64}.${payloadB64}`)
    );
    if (!valid) return null;
    const payload = JSON.parse(
      new TextDecoder().decode(base64UrlDecode(payloadB64))
    );
    if (payload.exp < Math.floor(Date.now() / 1e3)) {
      return null;
    }
    return payload;
  } catch {
    return null;
  }
}
__name(verifyToken, "verifyToken");
function generateDeviceId() {
  const bytes = new Uint8Array(16);
  crypto.getRandomValues(bytes);
  return Array.from(bytes, (b) => b.toString(16).padStart(2, "0")).join("");
}
__name(generateDeviceId, "generateDeviceId");

// src/ratelimit.ts
var RATE_LIMIT_PREFIX = "rate:";
function getTodayKey(deviceId) {
  const today = (/* @__PURE__ */ new Date()).toISOString().split("T")[0];
  return `${RATE_LIMIT_PREFIX}${deviceId}:${today}`;
}
__name(getTodayKey, "getTodayKey");
function getTomorrowReset() {
  const tomorrow = /* @__PURE__ */ new Date();
  tomorrow.setUTCDate(tomorrow.getUTCDate() + 1);
  tomorrow.setUTCHours(0, 0, 0, 0);
  return tomorrow.toISOString();
}
__name(getTomorrowReset, "getTomorrowReset");
async function checkRateLimit(env, deviceId, isPremium) {
  if (isPremium) {
    return {
      allowed: true,
      used: 0,
      limit: -1,
      // Unlimited
      resetsAt: ""
    };
  }
  const limit = parseInt(env.FREE_DAILY_LIMIT) || 3;
  const key = getTodayKey(deviceId);
  const entry = await env.RATE_LIMITS.get(key, "json");
  const used = entry?.count || 0;
  return {
    allowed: used < limit,
    used,
    limit,
    resetsAt: getTomorrowReset()
  };
}
__name(checkRateLimit, "checkRateLimit");
async function incrementUsage(env, deviceId) {
  const key = getTodayKey(deviceId);
  const entry = await env.RATE_LIMITS.get(key, "json");
  const newEntry = {
    count: (entry?.count || 0) + 1,
    date: (/* @__PURE__ */ new Date()).toISOString().split("T")[0]
  };
  const ttl = 86400 + 3600;
  await env.RATE_LIMITS.put(key, JSON.stringify(newEntry), { expirationTtl: ttl });
}
__name(incrementUsage, "incrementUsage");
async function getUsageStats(env, deviceId, isPremium) {
  const { used, limit, resetsAt } = await checkRateLimit(env, deviceId, isPremium);
  return { used, limit, resetsAt, isPremium };
}
__name(getUsageStats, "getUsageStats");

// src/openai.ts
var CACHE_PREFIX = "decompose:";
function normalizeTask(task) {
  return task.toLowerCase().trim().replace(/[^\w\s]/g, "").replace(/\s+/g, " ").substring(0, 100);
}
__name(normalizeTask, "normalizeTask");
function getCacheKey(task, style) {
  return `${CACHE_PREFIX}${style}:${normalizeTask(task)}`;
}
__name(getCacheKey, "getCacheKey");
async function getCachedResponse(env, task, style) {
  const key = getCacheKey(task, style);
  const cached = await env.CACHE.get(key, "json");
  if (cached) {
    return { ...cached, cached: true };
  }
  return null;
}
__name(getCachedResponse, "getCachedResponse");
async function cacheResponse(env, task, style, response) {
  const key = getCacheKey(task, style);
  const ttl = parseInt(env.CACHE_TTL_SECONDS) || 86400;
  await env.CACHE.put(key, JSON.stringify(response), { expirationTtl: ttl });
}
__name(cacheResponse, "cacheResponse");
var JSON_FORMAT = `
Respond with JSON only:
{
  "title": "<short descriptive title for the task>",
  "steps": [
    { "action": "<clear action description>", "estimatedMinutes": <minutes for this step> }
  ],
  "encouragement": "<brief motivating message>"
}`;
var STYLE_PROMPTS = {
  standard: `You are an ADHD task coach. Break down the given task into small, actionable steps.

Rules:
- Each step should take 2-10 minutes max
- Use clear, specific action verbs (grab, open, write, move)
- Include micro-steps that might seem obvious (ADHD brains need explicit steps)
- Add brief context/location when helpful
- 5-8 steps is ideal
- End with a small reward or acknowledgment step
- Each step must include a realistic time estimate in minutes
${JSON_FORMAT}`,
  quick: `You are an ADHD task coach. Break down the given task into exactly 5 quick steps.

Rules:
- Maximum 5 steps, no more
- Each step ultra-concise (under 10 words)
- Action verbs only
- No fluff, just essentials
- Each step must include a realistic time estimate in minutes
${JSON_FORMAT}`,
  gentle: `You are a supportive ADHD coach. Break down the given task with extra care and gentleness.

Rules:
- Smaller steps than usual (1-5 minutes each)
- Include permission to pause between steps
- Add sensory grounding cues (take a breath, notice your feet)
- Acknowledge difficulty without judgment
- Include self-compassion reminders
- 6-10 steps is fine
- Each step must include a realistic time estimate in minutes
${JSON_FORMAT}`
};
function getContextAddition(context) {
  if (!context) return "";
  const additions = [];
  if (context.timeOfDay) {
    const timeHints = {
      morning: "Consider morning energy levels and routines.",
      afternoon: "Account for post-lunch energy dip.",
      evening: "Keep steps simple, energy may be low.",
      night: "Ultra-simple steps only, minimal cognitive load."
    };
    additions.push(timeHints[context.timeOfDay]);
  }
  if (context.energy) {
    const energyHints = {
      low: "User has low energy - make steps extra small and gentle.",
      medium: "Normal energy level.",
      high: "User has good energy - can handle slightly bigger steps."
    };
    additions.push(energyHints[context.energy]);
  }
  return additions.length > 0 ? `

Context: ${additions.join(" ")}` : "";
}
__name(getContextAddition, "getContextAddition");
async function decomposeTask(env, request) {
  const style = request.style || "standard";
  const systemPrompt = STYLE_PROMPTS[style] + getContextAddition(request.context);
  try {
    const response = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${env.OPENAI_API_KEY}`
      },
      body: JSON.stringify({
        model: "gpt-4o-mini",
        messages: [
          { role: "system", content: systemPrompt },
          { role: "user", content: `Break down this task: ${request.task}` }
        ],
        temperature: 0.7,
        max_tokens: 1e3,
        response_format: { type: "json_object" }
      })
    });
    if (!response.ok) {
      const error = await response.text();
      console.error("OpenAI API error:", error);
      return {
        success: false,
        error: "AI service temporarily unavailable"
      };
    }
    const data = await response.json();
    const content = data.choices[0]?.message?.content;
    if (!content) {
      return {
        success: false,
        error: "Empty response from AI"
      };
    }
    const parsed = JSON.parse(content);
    const steps = (parsed.steps || []).map((s) => {
      if (typeof s === "string") {
        return { action: s, estimatedMinutes: 5 };
      }
      return { action: s.action, estimatedMinutes: s.estimatedMinutes ?? 5 };
    });
    const totalEstimatedMinutes = steps.reduce((sum, s) => sum + s.estimatedMinutes, 0);
    return {
      success: true,
      task: {
        title: parsed.title || request.task,
        steps,
        totalEstimatedMinutes,
        encouragement: parsed.encouragement || "You've got this!"
      },
      cached: false
    };
  } catch (error) {
    console.error("Decompose error:", error);
    return {
      success: false,
      error: "Failed to process task"
    };
  }
}
__name(decomposeTask, "decomposeTask");
var SUBSTEPS_PROMPT = `You are an ADHD task coach helping someone who is stuck on a step.

Break this step into 3-5 MICRO-steps that are:
- Extremely small (1-3 minutes each)
- Physical and concrete (stand up, open app, move hand)
- Include the very first tiny action to start
- No thinking or decision-making required

The goal is to make starting feel effortless.

Respond with JSON only:
{
  "substeps": ["micro-step 1", "micro-step 2", ...],
  "encouragement": "<brief, warm encouragement>"
}`;
async function getSubSteps(env, step, taskContext) {
  const userMessage = taskContext ? `Task context: ${taskContext}

Step I'm stuck on: ${step}` : `Step I'm stuck on: ${step}`;
  try {
    const response = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${env.OPENAI_API_KEY}`
      },
      body: JSON.stringify({
        model: "gpt-4o-mini",
        messages: [
          { role: "system", content: SUBSTEPS_PROMPT },
          { role: "user", content: userMessage }
        ],
        temperature: 0.7,
        max_tokens: 500,
        response_format: { type: "json_object" }
      })
    });
    if (!response.ok) {
      const error = await response.text();
      console.error("OpenAI API error:", error);
      return {
        success: false,
        error: "AI service temporarily unavailable"
      };
    }
    const data = await response.json();
    const content = data.choices[0]?.message?.content;
    if (!content) {
      return {
        success: false,
        error: "Empty response from AI"
      };
    }
    const parsed = JSON.parse(content);
    return {
      success: true,
      substeps: parsed.substeps,
      encouragement: parsed.encouragement
    };
  } catch (error) {
    console.error("SubSteps error:", error);
    return {
      success: false,
      error: "Failed to break down step"
    };
  }
}
__name(getSubSteps, "getSubSteps");

// src/index.ts
var corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
  "Access-Control-Max-Age": "86400"
};
function jsonResponse(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      "Content-Type": "application/json",
      ...corsHeaders
    }
  });
}
__name(jsonResponse, "jsonResponse");
function errorResponse(message, status = 400) {
  return jsonResponse({ success: false, error: message }, status);
}
__name(errorResponse, "errorResponse");
async function authenticate(request, env) {
  const authHeader = request.headers.get("Authorization");
  if (!authHeader?.startsWith("Bearer ")) {
    return null;
  }
  const token = authHeader.slice(7);
  return verifyToken(token, env.JWT_SECRET);
}
__name(authenticate, "authenticate");
function validateDecomposeRequest(body) {
  if (!body || typeof body !== "object") return null;
  const req = body;
  if (typeof req.task !== "string" || req.task.trim().length === 0) {
    return null;
  }
  if (req.task.length > 500) {
    return null;
  }
  const style = req.style;
  if (style && !["standard", "quick", "gentle"].includes(style)) {
    return null;
  }
  return {
    task: req.task.trim(),
    style: style || "standard",
    context: req.context
  };
}
__name(validateDecomposeRequest, "validateDecomposeRequest");
async function handleRegister(env) {
  const deviceId = generateDeviceId();
  const token = await createToken({ deviceId, isPremium: false }, env.JWT_SECRET);
  return jsonResponse({
    success: true,
    token,
    deviceId
  });
}
__name(handleRegister, "handleRegister");
async function handleDecompose(request, env) {
  const auth = await authenticate(request, env);
  if (!auth) {
    return errorResponse("Unauthorized", 401);
  }
  let body;
  try {
    body = await request.json();
  } catch {
    return errorResponse("Invalid JSON body");
  }
  const decomposeReq = validateDecomposeRequest(body);
  if (!decomposeReq) {
    return errorResponse("Invalid request: task is required (max 500 chars)");
  }
  const rateLimit = await checkRateLimit(env, auth.deviceId, auth.isPremium);
  if (!rateLimit.allowed) {
    return jsonResponse({
      success: false,
      error: "Daily limit reached",
      usage: {
        used: rateLimit.used,
        limit: rateLimit.limit,
        resetsAt: rateLimit.resetsAt
      }
    }, 429);
  }
  const cached = await getCachedResponse(env, decomposeReq.task, decomposeReq.style || "standard");
  if (cached) {
    if (!auth.isPremium) {
      await incrementUsage(env, auth.deviceId);
    }
    return jsonResponse(cached);
  }
  const result = await decomposeTask(env, decomposeReq);
  if (result.success) {
    await cacheResponse(env, decomposeReq.task, decomposeReq.style || "standard", result);
    if (!auth.isPremium) {
      await incrementUsage(env, auth.deviceId);
    }
  }
  return jsonResponse(result);
}
__name(handleDecompose, "handleDecompose");
async function handleUsage(request, env) {
  const auth = await authenticate(request, env);
  if (!auth) {
    return errorResponse("Unauthorized", 401);
  }
  const stats = await getUsageStats(env, auth.deviceId, auth.isPremium);
  return jsonResponse(stats);
}
__name(handleUsage, "handleUsage");
async function handleVerifySubscription(request, env) {
  const auth = await authenticate(request, env);
  if (!auth) {
    return errorResponse("Unauthorized", 401);
  }
  let body;
  try {
    body = await request.json();
  } catch {
    return errorResponse("Invalid JSON body");
  }
  return jsonResponse({
    success: true,
    isPremium: auth.isPremium,
    message: "RevenueCat verification not yet implemented"
  });
}
__name(handleVerifySubscription, "handleVerifySubscription");
async function handleUpgradeToPremium(request, env) {
  const auth = await authenticate(request, env);
  if (!auth) {
    return errorResponse("Unauthorized", 401);
  }
  const newToken = await createToken(
    { deviceId: auth.deviceId, isPremium: true, userId: auth.userId },
    env.JWT_SECRET
  );
  return jsonResponse({
    success: true,
    token: newToken,
    isPremium: true
  });
}
__name(handleUpgradeToPremium, "handleUpgradeToPremium");
async function handleSubSteps(request, env) {
  const auth = await authenticate(request, env);
  if (!auth) {
    return errorResponse("Unauthorized", 401);
  }
  let body;
  try {
    body = await request.json();
  } catch {
    return errorResponse("Invalid JSON body");
  }
  if (!body.step || typeof body.step !== "string" || body.step.trim().length === 0) {
    return errorResponse("Invalid request: step is required");
  }
  if (body.step.length > 300) {
    return errorResponse("Step text too long (max 300 chars)");
  }
  const result = await getSubSteps(env, body.step.trim(), body.taskContext);
  return jsonResponse(result);
}
__name(handleSubSteps, "handleSubSteps");
async function handleHealth() {
  return jsonResponse({
    status: "healthy",
    timestamp: (/* @__PURE__ */ new Date()).toISOString()
  });
}
__name(handleHealth, "handleHealth");
var index_default = {
  async fetch(request, env) {
    if (request.method === "OPTIONS") {
      return new Response(null, { headers: corsHeaders });
    }
    const url = new URL(request.url);
    const path = url.pathname;
    try {
      if (path === "/health" && request.method === "GET") {
        return handleHealth();
      }
      if (path === "/v1/register" && request.method === "POST") {
        return handleRegister(env);
      }
      if (path === "/v1/decompose" && request.method === "POST") {
        return handleDecompose(request, env);
      }
      if (path === "/v1/usage" && request.method === "GET") {
        return handleUsage(request, env);
      }
      if (path === "/v1/verify-subscription" && request.method === "POST") {
        return handleVerifySubscription(request, env);
      }
      if (path === "/v1/substeps" && request.method === "POST") {
        return handleSubSteps(request, env);
      }
      if (path === "/v1/webhook/revenuecat" && request.method === "POST") {
        return handleUpgradeToPremium(request, env);
      }
      return errorResponse("Not found", 404);
    } catch (error) {
      console.error("Unhandled error:", error);
      return errorResponse("Internal server error", 500);
    }
  }
};
export {
  index_default as default
};
//# sourceMappingURL=index.js.map
