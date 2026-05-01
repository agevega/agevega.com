import { describe, it, expect } from 'vitest';
import { z } from 'zod';

// Mirror of the schema in src/content.config.ts
const courseSchema = z.object({
  title: z.string(),
  description: z.string(),
  youtubeId: z.string(),
  category: z.enum(['devops', 'cloud', 'security', 'automation', 'other']),
  tags: z.array(z.string()),
  order: z.number().optional(),
  publishedAt: z.coerce.date(),
  difficulty: z.enum(['beginner', 'intermediate', 'advanced']).default('beginner'),
  resources: z.array(z.object({
    label: z.string(),
    url: z.string().url().refine(u => u.startsWith('https://'), { message: 'Resource URL must use HTTPS' }),
  })).optional(),
});

const validCourse = {
  title: 'Intro to DevOps',
  description: 'Learn DevOps fundamentals',
  youtubeId: 'abc123',
  category: 'devops' as const,
  tags: ['devops', 'cicd'],
  publishedAt: new Date('2024-01-15'),
  difficulty: 'beginner' as const,
};

describe('Course content schema', () => {
  it('accepts a valid course with required fields', () => {
    expect(courseSchema.safeParse(validCourse).success).toBe(true);
  });

  it('accepts optional fields: order and resources', () => {
    const result = courseSchema.safeParse({
      ...validCourse,
      order: 1,
      resources: [{ label: 'GitHub', url: 'https://github.com/example' }],
    });
    expect(result.success).toBe(true);
  });

  it('rejects an invalid category', () => {
    expect(courseSchema.safeParse({ ...validCourse, category: 'blockchain' }).success).toBe(false);
  });

  it('rejects a missing required field (title)', () => {
    const { title: _, ...withoutTitle } = validCourse;
    expect(courseSchema.safeParse(withoutTitle).success).toBe(false);
  });

  it('coerces string dates to Date objects', () => {
    const result = courseSchema.safeParse({ ...validCourse, publishedAt: '2024-01-15' });
    expect(result.success).toBe(true);
    if (result.success) {
      expect(result.data.publishedAt).toBeInstanceOf(Date);
    }
  });

  it('rejects a resource with non-URL string', () => {
    const result = courseSchema.safeParse({
      ...validCourse,
      resources: [{ label: 'Bad', url: 'not-a-url' }],
    });
    expect(result.success).toBe(false);
  });

  it('rejects a resource with HTTP (non-HTTPS) URL', () => {
    const result = courseSchema.safeParse({
      ...validCourse,
      resources: [{ label: 'Insecure', url: 'http://example.com' }],
    });
    expect(result.success).toBe(false);
  });

  it('rejects an invalid difficulty value', () => {
    expect(courseSchema.safeParse({ ...validCourse, difficulty: 'expert' }).success).toBe(false);
  });

  it('defaults difficulty to beginner when omitted', () => {
    const { difficulty: _, ...withoutDifficulty } = validCourse;
    const result = courseSchema.safeParse(withoutDifficulty);
    expect(result.success).toBe(true);
    if (result.success) {
      expect(result.data.difficulty).toBe('beginner');
    }
  });
});
