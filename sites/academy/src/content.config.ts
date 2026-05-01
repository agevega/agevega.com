import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

const courses = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/courses' }),
  schema: z.object({
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
  }),
});

export const collections = { courses };
