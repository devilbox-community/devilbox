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
      social: {
        github: 'https://github.com/devilbox-community/devilbox',
      },
      customCss: ['./src/styles/devilbox.css'],
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
          ],
        },
        {
          label: "Intermediate",
          items: [
            { slug: 'intermediate/dvl-cli' },
            { slug: 'intermediate/dvl-agent' },
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
          items: [
            { slug: 'advanced/customize-php-globally' },
            { slug: 'advanced/customize-webserver-globally' },
            { slug: 'advanced/connect-to-host-os' },
            { slug: 'advanced/connect-to-other-docker-container' },
            { slug: 'advanced/connect-to-external-hosts' },
            { slug: 'advanced/add-custom-cname-records' },
            { slug: 'advanced/add-your-own-docker-image' },
            { slug: 'advanced/overwrite-existing-docker-image' },
          ],
        },
        {
          label: "Autostart commands",
          items: [
            { slug: 'autostart/custom-scripts-per-php-version' },
            { slug: 'autostart/custom-scripts-globally' },
            { slug: 'autostart/autostarting-nodejs-apps' },
          ],
        },
        {
          label: "vhost-gen",
          items: [
            { slug: 'vhost-gen/virtual-host-templates' },
            { slug: 'vhost-gen/customize-all-virtual-hosts-globally' },
            { slug: 'vhost-gen/customize-specific-virtual-host' },
            { slug: 'vhost-gen/virtual-host-vs-reverse-proxy' },
            { slug: 'vhost-gen/example-add-subdomains' },
          ],
        },
        {
          label: "reverse-proxy",
          items: [
            { slug: 'reverse-proxy/reverse-proxy-with-https' },
            { slug: 'reverse-proxy/reverse-proxy-for-custom-docker' },
          ],
        },
        {
          label: "Enable custom container",
          items: [
            { slug: 'custom-container/enable-all-container' },
            { slug: 'custom-container/enable-php-community' },
            { slug: 'custom-container/enable-blackfire' },
            { slug: 'custom-container/enable-elk-stack' },
            { slug: 'custom-container/enable-mailhog' },
            { slug: 'custom-container/enable-meilisearch' },
            { slug: 'custom-container/enable-ngrok' },
            { slug: 'custom-container/enable-python-flask' },
            { slug: 'custom-container/enable-rabbitmq' },
            { slug: 'custom-container/enable-solr' },
            { slug: 'custom-container/enable-varnish' },
          ],
        },
        {
          label: "Corporate Usage",
          items: [
            { slug: 'corporate-usage/shared-devilbox-server-in-lan' },
            { slug: 'corporate-usage/use-external-databases' },
            { slug: 'corporate-usage/showcase-over-the-internet' },
          ],
        },
        {
          label: "Maintenance",
          items: [
            { slug: 'maintenance/checkout-different-devilbox-release' },
            { slug: 'maintenance/remove-stopped-container' },
            { slug: 'maintenance/update-the-devilbox' },
            { slug: 'maintenance/remove-the-devilbox' },
            { slug: 'maintenance/backup-and-restore-mysql' },
            { slug: 'maintenance/backup-and-restore-pgsql' },
            { slug: 'maintenance/backup-and-restore-mongo' },
          ],
        },
        {
          label: "Configuration files",
          items: [
            { slug: 'configuration-files/env-file' },
            { slug: 'configuration-files/docker-compose-yml' },
            { slug: 'configuration-files/docker-compose-override-yml' },
            { slug: 'configuration-files/apache-conf' },
            { slug: 'configuration-files/nginx-conf' },
            { slug: 'configuration-files/php-ini' },
            { slug: 'configuration-files/php-fpm-conf' },
            { slug: 'configuration-files/my-cnf' },
            { slug: 'configuration-files/bashrc-sh' },
          ],
        },
        {
          label: "Examples",
          items: [
            { slug: 'examples/setup-cakephp' },
            { slug: 'examples/setup-codeigniter' },
            { slug: 'examples/setup-codeigniter4' },
            { slug: 'examples/setup-contao' },
            { slug: 'examples/setup-craftcms' },
            { slug: 'examples/setup-drupal' },
            { slug: 'examples/setup-expressionengine' },
            { slug: 'examples/setup-joomla' },
            { slug: 'examples/setup-laravel' },
            { slug: 'examples/setup-magento2' },
            { slug: 'examples/setup-phalcon' },
            { slug: 'examples/setup-photon-cms' },
            { slug: 'examples/setup-presta-shop' },
            { slug: 'examples/setup-processwire' },
            { slug: 'examples/setup-shopware' },
            { slug: 'examples/setup-symfony' },
            { slug: 'examples/setup-typo3' },
            { slug: 'examples/setup-wordpress' },
            { slug: 'examples/setup-yii' },
            { slug: 'examples/setup-zend' },
            { slug: 'examples/setup-other-frameworks' },
          ],
        },
        {
          label: "Examples - reverse proxy",
          items: [
            { slug: 'examples/setup-reverse-proxy-nodejs' },
            { slug: 'examples/setup-reverse-proxy-sphinx-docs' },
            { slug: 'examples/setup-reverse-proxy-python-flask' },
          ],
        },
        {
          label: "Readings",
          items: [
            { slug: 'readings/syncronize-container-permissions' },
            { slug: 'readings/available-container' },
            { slug: 'readings/available-tools' },
          ],
        },
        {
          label: "Support",
          items: [
            { slug: 'support/troubleshooting' },
            { slug: 'support/faq' },
            { slug: 'support/howto' },
            { slug: 'support/blogs-videos-and-use-cases' },
            { slug: 'support/artwork' },
          ],
        },
        {
          label: "3rd party projects",
          items: [
            { slug: 'third-party/devilbox-cli' },
            { slug: 'third-party/nginx-acme' },
          ],
        },
      ],
    }),
    mdx(),
  ],
});
