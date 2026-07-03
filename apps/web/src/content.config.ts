// P-2/L-3: SEO rehberleri — Astro content collection (docs/09 §3, docs/18 §3).
// `key`: dil sürümlerini hreflang'de eşleştirir (slug'lar dil başına yerel).
// `reviewed`: docs/18 §5.2 yayın bekçisi — false olan sayfa BUILD'E GİRMEZ.
import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

const guides = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/guides' }),
  schema: z.object({
    title: z.string(),
    description: z.string(),
    date: z.string(),
    key: z.string(),
    reviewed: z.boolean().default(false),
  }),
});

export const collections = { guides };
