---
title: "Add custom environment variables"
---

# Add custom environment variables

If your application requires a variable to determine if it is run under
development or production, you can easily add it and make PHP aware of
it.


## Add custom environment variables

This is fairly simple. Any variable inside the `.env` file is considered
an environment variable and automatically known to PHP.

If you for example require a variable `APPLICATION_ENV`, with a value of
`production`, you would add the following to the `.env` file:

``` bash
APPLICATION_ENV=production
```

You need to restart the Devilbox for the changes to take effect.

> [!NOTE]
> There is already a proposed section inside the `.env` file at the very
> bottom to add you custom variables to differentiate them from the
> Devilbox required variables.

## Use custom environment variables

Accessing the above defined environment variable on the PHP side is also
fairly simple. You can use the PHP's built-in function `getenv` to
obtain the value:

``` php
<?php
// Example use of getenv()
echo getenv('APPLICATION_ENV');
?>
```
