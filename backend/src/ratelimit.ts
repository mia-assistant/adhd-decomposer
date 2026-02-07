import { Env, RateLimitEntry } from './types';

const RATE_LIMIT_PREFIX = 'rate:';

function getTodayKey(deviceId: string): string {
  const today = new Date().toISOString().split('T')[0];
  return `${RATE_LIMIT_PREFIX}${deviceId}:${today}`;
}

function getTomorrowReset(): string {
  const tomorrow = new Date();
  tomorrow.setUTCDate(tomorrow.getUTCDate() + 1);
  tomorrow.setUTCHours(0, 0, 0, 0);
  return tomorrow.toISOString();
}

export async function checkRateLimit(
  env: Env,
  deviceId: string,
  isPremium: boolean
): Promise<{ allowed: boolean; used: number; limit: number; resetsAt: string }> {
  // Premium users have unlimited
  if (isPremium) {
    return {
      allowed: true,
      used: 0,
      limit: -1, // Unlimited
      resetsAt: '',
    };
  }

  const limit = parseInt(env.FREE_DAILY_LIMIT) || 3;
  const key = getTodayKey(deviceId);
  
  const entry = await env.RATE_LIMITS.get<RateLimitEntry>(key, 'json');
  const used = entry?.count || 0;
  
  return {
    allowed: used < limit,
    used,
    limit,
    resetsAt: getTomorrowReset(),
  };
}

export async function incrementUsage(env: Env, deviceId: string): Promise<void> {
  const key = getTodayKey(deviceId);
  const entry = await env.RATE_LIMITS.get<RateLimitEntry>(key, 'json');
  
  const newEntry: RateLimitEntry = {
    count: (entry?.count || 0) + 1,
    date: new Date().toISOString().split('T')[0],
  };
  
  // Expire at end of day (86400 seconds = 24 hours, but we'll set it to expire at midnight UTC + buffer)
  const ttl = 86400 + 3600; // 25 hours to be safe
  await env.RATE_LIMITS.put(key, JSON.stringify(newEntry), { expirationTtl: ttl });
}

export async function getUsageStats(
  env: Env,
  deviceId: string,
  isPremium: boolean
): Promise<{ used: number; limit: number; resetsAt: string; isPremium: boolean }> {
  const { used, limit, resetsAt } = await checkRateLimit(env, deviceId, isPremium);
  return { used, limit, resetsAt, isPremium };
}
