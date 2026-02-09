// Cloudflare Worker Types
export interface Env {
  // KV Namespaces
  RATE_LIMITS: KVNamespace;
  CACHE: KVNamespace;
  USERS: KVNamespace;
  
  // Secrets
  OPENAI_API_KEY: string;
  JWT_SECRET: string;
  
  // Config
  ENVIRONMENT: string;
  FREE_DAILY_LIMIT: string;
  CACHE_TTL_SECONDS: string;
}

// API Types
export interface DecomposeRequest {
  task: string;
  style?: 'standard' | 'quick' | 'gentle';
  context?: {
    timeOfDay?: 'morning' | 'afternoon' | 'evening' | 'night';
    energy?: 'low' | 'medium' | 'high';
  };
}

export interface StepDetail {
  action: string;
  estimatedMinutes: number;
}

export interface DecomposeResponse {
  success: boolean;
  task?: {
    title: string;
    steps: StepDetail[];
    totalEstimatedMinutes: number;
    encouragement: string;
  };
  cached?: boolean;
  error?: string;
}

export interface UsageResponse {
  used: number;
  limit: number;
  resetsAt: string;
  isPremium: boolean;
}

export interface TokenPayload {
  deviceId: string;
  isPremium: boolean;
  userId?: string;
  iat: number;
  exp: number;
}

export interface RateLimitEntry {
  count: number;
  date: string;
}

export interface UserRecord {
  deviceId: string;
  isPremium: boolean;
  premiumUntil?: string;
  revenueCatId?: string;
  createdAt: string;
  lastSeen: string;
}
