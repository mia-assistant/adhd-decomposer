import { Env, TokenPayload, DecomposeRequest, DecomposeResponse, UsageResponse } from './types';
import { createToken, verifyToken, generateDeviceId } from './auth';
import { checkRateLimit, incrementUsage, getUsageStats } from './ratelimit';
import { getCachedResponse, cacheResponse, decomposeTask, getSubSteps } from './openai';

// CORS headers
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  'Access-Control-Max-Age': '86400',
};

function jsonResponse(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      'Content-Type': 'application/json',
      ...corsHeaders,
    },
  });
}

function errorResponse(message: string, status = 400): Response {
  return jsonResponse({ success: false, error: message }, status);
}

// Extract and verify auth token
async function authenticate(request: Request, env: Env): Promise<TokenPayload | null> {
  const authHeader = request.headers.get('Authorization');
  if (!authHeader?.startsWith('Bearer ')) {
    return null;
  }

  const token = authHeader.slice(7);
  return verifyToken(token, env.JWT_SECRET);
}

// Validate decompose request
function validateDecomposeRequest(body: unknown): DecomposeRequest | null {
  if (!body || typeof body !== 'object') return null;
  
  const req = body as Record<string, unknown>;
  
  if (typeof req.task !== 'string' || req.task.trim().length === 0) {
    return null;
  }
  
  if (req.task.length > 500) {
    return null;
  }
  
  const style = req.style as string | undefined;
  if (style && !['standard', 'quick', 'gentle'].includes(style)) {
    return null;
  }
  
  return {
    task: req.task.trim(),
    style: (style as DecomposeRequest['style']) || 'standard',
    context: req.context as DecomposeRequest['context'],
  };
}

// Route handlers
async function handleRegister(env: Env): Promise<Response> {
  const deviceId = generateDeviceId();
  const token = await createToken({ deviceId, isPremium: false }, env.JWT_SECRET);
  
  return jsonResponse({
    success: true,
    token,
    deviceId,
  });
}

async function handleDecompose(request: Request, env: Env): Promise<Response> {
  // Authenticate
  const auth = await authenticate(request, env);
  if (!auth) {
    return errorResponse('Unauthorized', 401);
  }

  // Parse request body
  let body: unknown;
  try {
    body = await request.json();
  } catch {
    return errorResponse('Invalid JSON body');
  }

  // Validate request
  const decomposeReq = validateDecomposeRequest(body);
  if (!decomposeReq) {
    return errorResponse('Invalid request: task is required (max 500 chars)');
  }

  // Check rate limit
  const rateLimit = await checkRateLimit(env, auth.deviceId, auth.isPremium);
  if (!rateLimit.allowed) {
    return jsonResponse({
      success: false,
      error: 'Daily limit reached',
      usage: {
        used: rateLimit.used,
        limit: rateLimit.limit,
        resetsAt: rateLimit.resetsAt,
      },
    }, 429);
  }

  // Check cache first
  const cached = await getCachedResponse(env, decomposeReq.task, decomposeReq.style || 'standard');
  if (cached) {
    // Still count against rate limit for free users (prevents cache farming)
    if (!auth.isPremium) {
      await incrementUsage(env, auth.deviceId);
    }
    return jsonResponse(cached);
  }

  // Call OpenAI
  const result = await decomposeTask(env, decomposeReq);
  
  if (result.success) {
    // Cache successful response
    await cacheResponse(env, decomposeReq.task, decomposeReq.style || 'standard', result);
    
    // Increment usage
    if (!auth.isPremium) {
      await incrementUsage(env, auth.deviceId);
    }
  }

  return jsonResponse(result);
}

async function handleUsage(request: Request, env: Env): Promise<Response> {
  const auth = await authenticate(request, env);
  if (!auth) {
    return errorResponse('Unauthorized', 401);
  }

  const stats = await getUsageStats(env, auth.deviceId, auth.isPremium);
  return jsonResponse(stats);
}

async function handleVerifySubscription(request: Request, env: Env): Promise<Response> {
  const auth = await authenticate(request, env);
  if (!auth) {
    return errorResponse('Unauthorized', 401);
  }

  // Parse RevenueCat user ID from body
  let body: { revenueCatUserId?: string };
  try {
    body = await request.json();
  } catch {
    return errorResponse('Invalid JSON body');
  }

  // TODO: Verify with RevenueCat API
  // For now, just return current status
  // In production, you'd call RevenueCat to verify subscription
  
  return jsonResponse({
    success: true,
    isPremium: auth.isPremium,
    message: 'RevenueCat verification not yet implemented',
  });
}

async function handleUpgradeToPremium(request: Request, env: Env): Promise<Response> {
  const auth = await authenticate(request, env);
  if (!auth) {
    return errorResponse('Unauthorized', 401);
  }

  // Generate new token with premium status
  // In production, only do this after RevenueCat webhook confirms purchase
  const newToken = await createToken(
    { deviceId: auth.deviceId, isPremium: true, userId: auth.userId },
    env.JWT_SECRET
  );

  return jsonResponse({
    success: true,
    token: newToken,
    isPremium: true,
  });
}

async function handleSubSteps(request: Request, env: Env): Promise<Response> {
  // Authenticate
  const auth = await authenticate(request, env);
  if (!auth) {
    return errorResponse('Unauthorized', 401);
  }

  // Parse request body
  let body: { step: string; taskContext?: string };
  try {
    body = await request.json();
  } catch {
    return errorResponse('Invalid JSON body');
  }

  if (!body.step || typeof body.step !== 'string' || body.step.trim().length === 0) {
    return errorResponse('Invalid request: step is required');
  }

  if (body.step.length > 300) {
    return errorResponse('Step text too long (max 300 chars)');
  }

  // Call OpenAI for sub-steps
  const result = await getSubSteps(env, body.step.trim(), body.taskContext);
  
  return jsonResponse(result);
}

async function handleHealth(): Promise<Response> {
  return jsonResponse({
    status: 'healthy',
    timestamp: new Date().toISOString(),
  });
}

// Main router
export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    // Handle CORS preflight
    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: corsHeaders });
    }

    const url = new URL(request.url);
    const path = url.pathname;

    try {
      // Health check
      if (path === '/health' && request.method === 'GET') {
        return handleHealth();
      }

      // Register new device (get token)
      if (path === '/v1/register' && request.method === 'POST') {
        return handleRegister(env);
      }

      // Decompose task
      if (path === '/v1/decompose' && request.method === 'POST') {
        return handleDecompose(request, env);
      }

      // Get usage stats
      if (path === '/v1/usage' && request.method === 'GET') {
        return handleUsage(request, env);
      }

      // Verify subscription status
      if (path === '/v1/verify-subscription' && request.method === 'POST') {
        return handleVerifySubscription(request, env);
      }

      // Get sub-steps for a stuck step
      if (path === '/v1/substeps' && request.method === 'POST') {
        return handleSubSteps(request, env);
      }

      // Webhook for RevenueCat (premium upgrade)
      if (path === '/v1/webhook/revenuecat' && request.method === 'POST') {
        return handleUpgradeToPremium(request, env);
      }

      // Not found
      return errorResponse('Not found', 404);
    } catch (error) {
      console.error('Unhandled error:', error);
      return errorResponse('Internal server error', 500);
    }
  },
};
