# Tunnel Setup

Do this once before presenting. It publishes the MCP server, running inside the
team-docs tenant cluster, at a fixed public URL via cloudflared, with no
kubectl port-forward. Same mechanism as the kai talk's haiku tunnel.

## 1. Reuse (or create) the named tunnel

Easiest path: reuse the existing named tunnel from the kai demo (the one that
serves haiku.cloudrumble.net). A single tunnel can carry many public hostnames,
so nothing new is needed except one more routing rule (step 2). Its token is
already stored, so step 3 is only for a fresh tunnel.

To start clean instead: in Cloudflare Zero Trust, open Networks > Tunnels,
create a named tunnel, and copy its token.

## 2. Add the public hostname

On that tunnel, add a Public Hostname rule:

- Hostname: `mcp.cloudrumble.net`
- Service type: `HTTP`
- URL: `http://localhost:8088`

This routing lives in the Zero Trust dashboard, not in a local cloudflared
config file.

## 3. Store the token locally

publish.sh reads the token from `CF_TOKEN_FILE`, defaulting to
`~/.config/haiku-tunnel/token` (the same file the kai demo uses). If reusing the
haiku tunnel, the token is already there and this step is done.

For a new tunnel, save the token in Bitwarden, then write it to a local file
with mode 600:

```sh
export CF_TOKEN_FILE="$HOME/.config/haiku-tunnel/token"
mkdir -p "$(dirname "$CF_TOKEN_FILE")"
umask 077
printf '%s\n' 'PASTE_TUNNEL_TOKEN_HERE' > "$CF_TOKEN_FILE"
chmod 600 "$CF_TOKEN_FILE"
```

Never commit this file or put the token in slides.

## 4. Configure kind and ingress-nginx

`setup.sh` creates the kind cluster and installs ingress-nginx using the kind
ingress-nginx manifest. The controller binds node ports 80 and 443.

`kind-config.yaml` labels the control-plane node `ingress-ready=true` and maps
host port 8088 to node port 80, and host port 8443 to node port 443:

```yaml
nodes:
  - role: control-plane
    kubeadmConfigPatches:
      - |
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "ingress-ready=true"
    extraPortMappings:
      - containerPort: 80
        hostPort: 8088
        protocol: TCP
      - containerPort: 443
        hostPort: 8443
        protocol: TCP
```

`extraPortMappings` can only be set when the kind cluster is created.

## 5. Route to the tenant service

`ship.sh` deploys the server, a ClusterIP Service, and an Ingress inside the
`team-docs` tenant. The Service exposes container port 3000. The host-less
Ingress uses class `nginx` and routes every path to that Service:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: vcluster-yaml-mcp-server
spec:
  type: ClusterIP
  selector:
    app: vcluster-yaml-mcp-server
  ports:
    - port: 3000
      targetPort: 3000
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: vcluster-yaml-mcp-server
spec:
  ingressClassName: nginx
  rules:
    - http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: vcluster-yaml-mcp-server
                port:
                  number: 3000
```

The governed vCluster configuration enables `sync.toHost.ingresses`. vCluster
syncs the Ingress and Service to the host namespace, where ingress-nginx routes
requests from `localhost:8088` to the tenant workload. No NodePort or kubectl
port-forward is used for the tenant service.

## 6. Run and verify

```sh
./setup.sh     # kind, ingress-nginx, and governed team-docs
./ship.sh      # server, Service, and Ingress inside team-docs
./publish.sh   # read CF_TOKEN_FILE and start cloudflared
```

Verify the public endpoint:

```sh
curl -s https://mcp.cloudrumble.net/mcp
curl -s https://mcp.cloudrumble.net/health
```

## Troubleshooting

- Tunnel connected but the public URL returns 502: confirm the tenant Ingress
  and Service synced to the host namespace, and confirm ingress-nginx is ready.
- Tunnel connected but localhost fails: check the kind mapping, host port 8088
  must map to node port 80.
- `extraPortMappings` missing: recreate the kind cluster. The mappings cannot be
  added to a running cluster.
