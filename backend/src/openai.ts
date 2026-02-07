import { Env, DecomposeRequest, DecomposeResponse } from './types';

const CACHE_PREFIX = 'decompose:';

// Normalize task for cache key
function normalizeTask(task: string): string {
  return task
    .toLowerCase()
    .trim()
    .replace(/[^\w\s]/g, '')
    .replace(/\s+/g, ' ')
    .substring(0, 100);
}

function getCacheKey(task: string, style: string): string {
  return `${CACHE_PREFIX}${style}:${normalizeTask(task)}`;
}

export async function getCachedResponse(
  env: Env,
  task: string,
  style: string
): Promise<DecomposeResponse | null> {
  const key = getCacheKey(task, style);
  const cached = await env.CACHE.get<DecomposeResponse>(key, 'json');
  if (cached) {
    return { ...cached, cached: true };
  }
  return null;
}

export async function cacheResponse(
  env: Env,
  task: string,
  style: string,
  response: DecomposeResponse
): Promise<void> {
  const key = getCacheKey(task, style);
  const ttl = parseInt(env.CACHE_TTL_SECONDS) || 86400;
  await env.CACHE.put(key, JSON.stringify(response), { expirationTtl: ttl });
}

// System prompts for different styles
const STYLE_PROMPTS = {
  standard: `You are an ADHD task coach. Break down the given task into small, actionable steps.

Rules:
- Each step should take 2-10 minutes max
- Use clear, specific action verbs (grab, open, write, move)
- Include micro-steps that might seem obvious (ADHD brains need explicit steps)
- Add brief context/location when helpful
- 5-8 steps is ideal
- End with a small reward or acknowledgment step

Respond with JSON only:
{
  "steps": ["step 1", "step 2", ...],
  "estimatedMinutes": <total minutes>,
  "encouragement": "<brief motivating message>"
}`,

  quick: `You are an ADHD task coach. Break down the given task into exactly 5 quick steps.

Rules:
- Maximum 5 steps, no more
- Each step ultra-concise (under 10 words)
- Action verbs only
- No fluff, just essentials

Respond with JSON only:
{
  "steps": ["step 1", "step 2", "step 3", "step 4", "step 5"],
  "estimatedMinutes": <total minutes>,
  "encouragement": "<5 word max encouragement>"
}`,

  gentle: `You are a supportive ADHD coach. Break down the given task with extra care and gentleness.

Rules:
- Smaller steps than usual (1-5 minutes each)
- Include permission to pause between steps
- Add sensory grounding cues (take a breath, notice your feet)
- Acknowledge difficulty without judgment
- Include self-compassion reminders
- 6-10 steps is fine

Respond with JSON only:
{
  "steps": ["step 1", "step 2", ...],
  "estimatedMinutes": <total minutes>,
  "encouragement": "<warm, gentle encouragement>"
}`,
};

// Context additions
function getContextAddition(context?: DecomposeRequest['context']): string {
  if (!context) return '';
  
  const additions: string[] = [];
  
  if (context.timeOfDay) {
    const timeHints: Record<string, string> = {
      morning: 'Consider morning energy levels and routines.',
      afternoon: 'Account for post-lunch energy dip.',
      evening: 'Keep steps simple, energy may be low.',
      night: 'Ultra-simple steps only, minimal cognitive load.',
    };
    additions.push(timeHints[context.timeOfDay]);
  }
  
  if (context.energy) {
    const energyHints: Record<string, string> = {
      low: 'User has low energy - make steps extra small and gentle.',
      medium: 'Normal energy level.',
      high: 'User has good energy - can handle slightly bigger steps.',
    };
    additions.push(energyHints[context.energy]);
  }
  
  return additions.length > 0 ? `\n\nContext: ${additions.join(' ')}` : '';
}

export async function decomposeTask(
  env: Env,
  request: DecomposeRequest
): Promise<DecomposeResponse> {
  const style = request.style || 'standard';
  const systemPrompt = STYLE_PROMPTS[style] + getContextAddition(request.context);

  try {
    const response = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${env.OPENAI_API_KEY}`,
      },
      body: JSON.stringify({
        model: 'gpt-5-mini',
        messages: [
          { role: 'system', content: systemPrompt },
          { role: 'user', content: `Break down this task: ${request.task}` },
        ],
        temperature: 0.7,
        max_tokens: 1000,
        response_format: { type: 'json_object' },
      }),
    });

    if (!response.ok) {
      const error = await response.text();
      console.error('OpenAI API error:', error);
      return {
        success: false,
        error: 'AI service temporarily unavailable',
      };
    }

    const data = await response.json() as {
      choices: Array<{ message: { content: string } }>;
    };

    const content = data.choices[0]?.message?.content;
    if (!content) {
      return {
        success: false,
        error: 'Empty response from AI',
      };
    }

    const parsed = JSON.parse(content);
    return {
      success: true,
      steps: parsed.steps,
      estimatedMinutes: parsed.estimatedMinutes,
      encouragement: parsed.encouragement,
      cached: false,
    };
  } catch (error) {
    console.error('Decompose error:', error);
    return {
      success: false,
      error: 'Failed to process task',
    };
  }
}
