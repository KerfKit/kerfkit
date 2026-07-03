// L-3: rehber sayfası UI iskeleti sözlüğü (şerit/CTA/altbilgi) — 6 dil.
import type { LiteLang } from './lite';

export const siteDict: Record<LiteLang, Record<string, string>> = {
  en: { calcCta: 'Free cut calculator', stripA: 'kerfkit app: unlimited projects, offline, one-time price —',
        stripCalc: 'try the free calculator', stripFound: 'get launch access',
        footHome: 'home', footCalc: 'free calculator' },
  tr: { calcCta: 'Ücretsiz kesim hesaplayıcı', stripA: 'kerfkit uygulaması: sınırsız proje, çevrimdışı, tek seferlik ödeme —',
        stripCalc: 'ücretsiz hesaplayıcıyı dene', stripFound: 'çıkışta haberdar ol',
        footHome: 'ana sayfa', footCalc: 'ücretsiz hesaplayıcı' },
  de: { calcCta: 'Kostenloser Zuschnitt-Rechner', stripA: 'kerfkit-App: unbegrenzte Projekte, offline, einmal zahlen —',
        stripCalc: 'probier den kostenlosen Rechner', stripFound: 'zum Start dabei sein',
        footHome: 'Start', footCalc: 'kostenloser Rechner' },
  fr: { calcCta: 'Calculateur de coupe gratuit', stripA: 'App kerfkit : projets illimités, hors ligne, achat unique —',
        stripCalc: 'essaie le calculateur gratuit', stripFound: 'être prévenu au lancement',
        footHome: 'accueil', footCalc: 'calculateur gratuit' },
  es: { calcCta: 'Calculadora de corte gratis', stripA: 'App kerfkit: proyectos ilimitados, sin conexión, pago único —',
        stripCalc: 'prueba la calculadora gratis', stripFound: 'entérate del lanzamiento',
        footHome: 'inicio', footCalc: 'calculadora gratis' },
  it: { calcCta: 'Calcolatore di taglio gratis', stripA: 'App kerfkit: progetti illimitati, offline, si paga una volta —',
        stripCalc: 'prova il calcolatore gratis', stripFound: 'avvisami al lancio',
        footHome: 'home', footCalc: 'calcolatore gratis' },
};

// hreflang yardımcıları: rehberler `key` frontmatter'ıyla eşleşir (slug'lar dil başına farklı).
export function guideUrl(lang: string, slug: string): string {
  return lang === 'en' ? `/guides/${slug}` : `/${lang}/guides/${slug}`;
}
export function liteUrl(lang: string): string {
  return lang === 'en' ? '/lite' : `/${lang}/lite`;
}
