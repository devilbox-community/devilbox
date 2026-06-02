import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import mdx from '@astrojs/mdx';
import rehypeMermaid from 'rehype-mermaid';

// https://astro.build/config
export default defineConfig({
  site: 'https://devilbox.nntoan.com',
  base: '/',
  trailingSlash: 'always',
  markdown: {
    rehypePlugins: [
      [rehypeMermaid, { strategy: 'inline-svg', dark: true }]
    ]
  },
  integrations: [
    starlight({
      title: 'Devilbox',
      description: 'A modern dockerized PHP development stack for any platform.',
      logo: { src: './src/assets/logo.svg', replacesTitle: false },
      favicon: '/img/logo.png',
      social: {
        github: 'https://github.com/devilbox-community/devilbox',
      },
      customCss: ['./src/styles/custom.css'],
      editLink: {
        baseUrl: 'https://github.com/devilbox-community/devilbox/edit/mainline/docs/',
      },
      lastUpdated: true,
      defaultLocale: 'en',
      sidebar: [
        { slug: 'read-first' },
        { slug: 'features' },
        { slug: 'devilbox-purpose' },
        {
          label: "Getting started",
          items: [
            { slug: 'getting-started/prerequisites' },
            { slug: 'getting-started/install-script' },
            { slug: 'getting-started/install-the-devilbox' },
            { slug: 'getting-started/start-the-devilbox' },
            { slug: 'getting-started/devilbox-intranet' },
            { slug: 'getting-started/directory-overview' },
            { slug: 'getting-started/create-your-first-project' },
            { slug: 'getting-started/enter-the-php-container' },
            { slug: 'getting-started/change-container-versions' },
            { slug: 'getting-started/important' },
            { slug: 'getting-started/agentic' },
            { slug: 'getting-started/agentic-auth' },
            { slug: 'getting-started/agentic-tools-toggle' },
          ],
        },
        {
          label: "CLI reference",
          items: [
            { slug: 'intermediate/dvl-cli' },
            { slug: 'intermediate/dvl-agent' },
          ],
        },
        {
          label: "Workspaces",
          items: [
            { slug: 'intermediate/hermes-workspace' },
            { slug: 'intermediate/multica' },
          ],
        },
        {
          label: "Configuration",
          autogenerate: { directory: 'configuration-files' },
        },
        {
          label: "Custom containers",
          autogenerate: { directory: 'custom-container' },
        },
        {
          label: "Examples",
          autogenerate: { directory: 'examples' },
        },
        {
          label: "Intermediate",
          items: [
            { slug: 'intermediate/setup-auto-dns' },
            { slug: 'intermediate/setup-valid-https' },
            { slug: 'intermediate/configure-php-xdebug' },
            { slug: 'intermediate/enable-disable-php-modules' },
            { slug: 'intermediate/read-log-files' },
            { slug: 'intermediate/email-catch-all' },
            { slug: 'intermediate/add-custom-environment-variables' },
            { slug: 'intermediate/work-inside-the-php-container' },
            { slug: 'intermediate/source-code-analysis' },
            { slug: 'intermediate/best-practice' },
          ],
        },
        {
          label: "Advanced",
          autogenerate: { directory: 'advanced' },
        },
        {
          label: "Howto",
          autogenerate: { directory: 'howto' },
        },
        {
          label: "Maintenance",
          autogenerate: { directory: 'maintenance' },
        },
        {
          label: "Support",
          autogenerate: { directory: 'support' },
        },
        {
          label: "Autostart commands",
          autogenerate: { directory: 'autostart' },
        },
        {
          label: "vhost-gen",
          autogenerate: { directory: 'vhost-gen' },
        },
        {
          label: "reverse-proxy",
          autogenerate: { directory: 'reverse-proxy' },
        },
        {
          label: "Corporate Usage",
          autogenerate: { directory: 'corporate-usage' },
        },
        {
          label: "Readings",
          autogenerate: { directory: 'readings' },
        },
        {
          label: "3rd party projects",
          autogenerate: { directory: 'third-party' },
        },
      ],
    }),
    mdx(),
  ],
});
