# Homepage Dashboard

> Your Homelab, As Code

```bash +exec_replace
echo "Homepage" | figlet -f small -w 90
```

<!-- end_slide -->

## Problem: Dashboard Sprawl

> Too many services, too many bookmarks

```bash +exec_replace
cat << 'EOF' | ccze -A
- Lots of services       <- each with its own URL
- Use Bookmarks?         <- don't show what's actually running
- Static links?          <- no health or status info
EOF
```

<!-- end_slide -->

## Dashboard Options

> Why Homepage over alternatives?

| Feature | Homepage | Dashy | Homer | Heimdall |
|---------|----------|-------|-------|----------|
| Config as Code | YAML | YAML | YAML | SQLite/UI |
| K8s Widgets | Native | API-based | None | None |
| Service Discovery | Ingress/CRD | No | No | No |
| GitHub Stars | 26k+ | 22k+ | 10.5k | 8.5k+ |

<!-- end_slide -->

## Configuration as Code

> **Homepage** = YAML config + GitOps deployment

```bash +exec_replace
cat << 'EOF' | ccze -A
- Config in Git           <- ArgoCD syncs on push
- Infra integration       <- shows live statuses
- Secrets references      <- via variables and secrets mounts
EOF
```
<!-- end_slide -->

## How It Works

```bash +exec_replace
just plantuml architecture
```

<!-- end_slide -->

## Configuration Structure

> ConfigMap keys mounted as separate files

```bash +exec_replace
cat << 'EOF' | ccze -A
ConfigMap keys → mounted as separate files:
  services.yaml    → Service definitions + widgets
  settings.yaml    → Layout and theme
  widgets.yaml     → Header widgets (K8s stats)
  kubernetes.yaml  → Cluster mode config
  bookmarks.yaml   → Quick links
EOF
```

<!-- end_slide -->

## Service Definition

> Two patterns: K8s status + Widget

```yaml
- GitOps:
  - ArgoCD:
      description: GitOps Continuous Delivery
      href: https://argocd.homelab.local
      icon: git.svg
      showStats: true            # Pod status indicator
      widget:                    # API-based widget
        type: argocd
        url: https://argocd-server.argocd.svc.cluster.local
        key: {{HOMEPAGE_VAR_ARGOCD_TOKEN}}
```

<!-- end_slide -->

## Widget Types

> Two integration patterns: Status dots + API widgets

```bash +exec_replace
cat << 'EOF' | ccze -A
Pod Status (showStats):     <- green/red dot via K8s API
  - namespace + podSelector <- tells Homepage which pods to check
  - No auth needed          <- uses ServiceAccount RBAC

API Widgets:                <- rich data from service APIs
  - type: argocd/grafana    <- built-in widget types
  - url + key               <- endpoint + auth token
EOF
```

<!-- end_slide -->


## Gotcha: Allowed Hosts

> Security feature that trips people up

```bash +exec_replace
cat << 'EOF' | ccze -A
Without HOMEPAGE_ALLOWED_HOSTS:
  -> 403 Forbidden on every request

Fix: Add your hostname to allowed list
  HOMEPAGE_ALLOWED_HOSTS=homepage.homelab.local

Check logs first when Homepage won't load!
EOF
```

<!-- end_slide -->

## Resources

| Resource |
|----------|
| Homepage: https://gethomepage.dev/ |
| Widgets: https://gethomepage.dev/widgets/ |
| My Config: https://github.com/Piotr1215/homelab |

<!-- end_slide -->

# That's All Folks!

```bash +exec_replace
just intro_toilet That\'s all folks!
```
