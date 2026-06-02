import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import mdx from '@astrojs/mdx';

// https://astro.build/config
export default defineConfig({
  site: 'https://devilbox.nntoan.com',
  base: '/',
  trailingSlash: 'always',
  integrations: [
    starlight({
      title: 'Devilbox',
      description: 'A modern dockerized PHP development stack for any platform.',
      // logo wired in D4.4 after D1.5 asset relocation to docs/public/img/
      social: [
        { icon: 'github', label: 'GitHub', href: 'https://github.com/devilbox-community/devilbox' },
      ],
      customCss: ['./src/styles/devilbox.css'],
      editLink: {
        baseUrl: 'https://github.com/devilbox-community/devilbox/edit/mainline/docs/',
      },
      lastUpdated: true,
      defaultLocale: { lang: 'en' },
      sidebar: [],
    }),
    mdx(),
  ],
});
