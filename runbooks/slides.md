---
theme: theme.json
author: Cloud-Native Corner 
date: MMMM dd, YYYY
paging: Slide %d / %d
---

```bash
~~~figlet
Automated Runbooks
~~~
```

---

## Runbooks

Runbooks are useful codifying repeatable troubleshooting steps

> A runbook is a detailed “how-to” guide for completing a commonly repeated task
> or procedure within a company’s IT operations process. Runbooks are created to
> provide everyone on the team—new or experienced—the knowledge and steps to
> quickly and accurately resolve a given issue. For example, a runbook may
> outline routine operations tasks such as patching a server or renewing a
> website’s SSL certificate.

---

## Automating Runbooks: Goals

- Ability to execute runbook steps in a repeatable manner
- Leaving audit trail in the form of incident handling document
- Everyone with access should be able to execute a runbook

---

```
~~~xargs -I _ java -jar /usr/local/bin/plantuml.jar _ -utxt
simple.puml
~~~
```

```
~~~xargs cat
simple.utxt
~~~
```

---

## Useful tools

- shell: bash
- kubectl
- terminal multiplexer: e.g. **tmux**
- terminal multiplexer session manager: e.g. tmux-ressurect or **tmuxinator**
- tooling integration: **nvim** with a runner plugin, but it's possible to run
  without it

---

## An example

### Super important-web page site is `down`

This alert looks like:

> An uptime check on k8s-prod-cluster Uptime Check URL labels
> {project_id=prod-hosting, host=example.com} is failing.

This indicates that `example.com` is not responding to it's health check and
will not automatically recover. In the scenario we assume that pods of the
`important-webpage` deployment did not recover after a MongoDB cluster
auto-upgrade.

To recover from the alert, follow these steps:

1. Connect to the `k8s-prod-cluster` cluster in the `prod-hosting` account. 
2. One by one, delete all of the pods within the current important-webpage
   deployment. 
3. The new pods will reconnect to the upgraded MongoDB cluster and the alert should
   automatically clear.

---

```bash
~~~figlet
Demo Time
~~~
```
