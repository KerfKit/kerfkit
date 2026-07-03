// P-2 (E7-S3): SEO rehber sayfaları — Astro content collection (docs/09 §3).
import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

const guides = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/guides' }),
  schema: z.object({
    title: z.string(),
    description: z.string(),
    date: z.string(),
  }),
});

export const collections = { guides };
