# Getting started with OCI CAAS
Getting started...


Create a stripe account:
https://dashboard.stripe.com/register?redirect=%2Ftest%2Fdashboard

Get your test API keys (you'll need access to both during the setup)
Publishable Key
Secret Key

Download SQL Developer:
https://www.oracle.com/tools/downloads/sqldev-downloads.html

You'll need SSH keys on your workstation (ssh-keygen to create them, if they don't exist or if you want to use new ones).

# Setting up WAF / WAAS rules
By default, no rules are enabled on the WAF, and you'll need to run a script to update them in bulk.

```
admin-scripts/activate-waf_rules.sh <WAF OCID>
```