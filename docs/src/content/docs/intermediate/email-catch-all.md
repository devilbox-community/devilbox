---
title: "Email catch-all"
---

# Email catch-all

## Devilbox Intranet

All your projects can send emails to whatever recipient. You do not have
to worry that they will actually being sent. Each PHP container runs a
local postfix mailserver that intercepts all outgoing mails and puts
them into a local mailbox by the user `devilbox`.

In order to view sent emails open up the devilbox intranet
<http://localhost/mail.php>. There you can also test email sending and
verify that they really stay locally.

<figure>
<img src="/_includes/figures/devilbox/devilbox-intranet-emails.png"
alt="Devilbox intranet: email catch-all overview" />
<figcaption aria-hidden="true">Devilbox intranet: email catch-all
overview</figcaption>
</figure>

In the above image from the intranet you can see that all emails sent to
whatever recipient have been caught by the Devilbox and are available to
be read.

## MailHog

Instead of using the very basic Devilbox intranet UI for emails, you can
also enable MailHog and use this to view sent email.s

<div class="seealso">

`custom-container-enable-mailhog`

</div>
