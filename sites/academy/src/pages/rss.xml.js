import rss from '@astrojs/rss';
import { getCollection } from 'astro:content';

export async function GET(context) {
  const courses = await getCollection('courses');
  const sorted = [...courses].sort(
    (a, b) => b.data.publishedAt.getTime() - a.data.publishedAt.getTime()
  );

  return rss({
    title: 'AgeVega Academy',
    description:
      'Cursos de DevSecOps, Cloud y Automatización. Recursos prácticos del canal AgeVega Master.',
    site: context.site,
    items: sorted.map((course) => ({
      title: course.data.title,
      description: course.data.description,
      pubDate: course.data.publishedAt,
      link: `/cursos/${course.id.replace(/\.mdx?$/, '')}/`,
    })),
  });
}
