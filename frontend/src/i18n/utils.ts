import { translations, type Lang } from './translations';

export function useTranslations(lang: Lang) {
  return translations[lang];
}

export function getLangFromUrl(url: URL): Lang {
  return url.pathname.startsWith('/en/') || url.pathname === '/en' ? 'en' : 'es';
}
