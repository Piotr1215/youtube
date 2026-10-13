---
options:
  implicit_slide_ends: false
---

# PAM Access

> Slack, reviewed access policies and native SSH.

<!-- new_lines: 2 -->

```bash +exec_replace
printf '%s\n' 'PAM Access' | figlet -f small -w 90 | while IFS= read -r line; do
    paint 'bold cyan' "$line"
done
paint
paint yellow '  Live demo: the bot, PAM configuration, then SSH.'
```

<!-- end_slide -->

## Bot and PAM

> What works in the POC today?

```bash +exec_replace
./journey.sh 1
```

<!-- end_slide -->

## Live: The Bot Home

> Open vCluster Infra Access and show Home.

```bash +exec_replace
paint 'bold cyan' '  HOME'
paint cyan '    targets       ' plain 'customer systems available to the signed-in user'
paint cyan '    access        ' plain 'granted or eligible to request'
paint cyan '    connection    ' plain 'copy the native SSH command'
paint cyan '    policy        ' plain 'applied policy reference'
paint
paint yellow '  Show the original OVH SSH target and the approval-demo target.'
```

[Open the bot conversation](https://app.slack.com/client/T024313FSQZ/D0C80S3CXNJ)

<!-- end_slide -->

## Live: The Access Form

> Switch to Messages, send `access`, then open the form.

```bash +exec_replace
paint cyan '  target   ' plain 'OVH access approval demo'
paint cyan '  change   ' plain 'Request access for myself'
paint cyan '  reason   ' plain 'test'
paint
paint green '  The short reason is accepted; the form proposes a scoped change.'
paint yellow '  Show the existing receipt and PR instead of another submission.'
```

The POC form changes Tailscale policy membership. It does not change Google Workspace membership.

<!-- end_slide -->

## Live: The Test Access PR

> Open the existing request and show its policy diff.

```bash +exec_replace
just boxart pam-policy
paint
paint cyan '  diff       ' plain 'one member added to the approval-demo group'
paint yellow '  review     ' plain 'human review before merge and policy deployment'
```

[Open test PR #29](https://github.com/loft-sh/tailscale-acls/pull/29)

This proves scoped PR creation. Merging this particular test PR is not a delivery requirement.

<!-- end_slide -->

## Approval in the Service

> Planned workflow: approve in Slack; the policy PR stays behind the scenes.

```bash +exec_replace
paint cyan '  request     ' plain 'person, customer target and reason'
paint cyan '  approve     ' plain 'Jonathan or Fabian, in Slack'
paint cyan '  policy      ' plain 'automated checks and PR approval after the Slack decision'
paint cyan '  activate    ' plain 'policy deployment, then ongoing access'
paint cyan '  revoke      ' plain 'remove the assignment when access is no longer needed'
paint
paint yellow '  The current POC still requires human GitHub review.'
```

<!-- end_slide -->

## Live: PAM Configuration

> Open the Tailscale admin console and select the OVH PAM service.

```bash +exec_replace
paint cyan '  service     ' plain 'SSH target and upstream host / port'
paint cyan '  connector   ' plain 'private gateway that reaches the customer'
paint cyan '  identity    ' plain 'PAM grant, permitted service and SSH username'
paint cyan '  recording   ' plain 'session attribution, playback and recordings on request'
paint
paint yellow '  Show how the target configuration and access policy fit together.'
```

[Open Tailscale admin](https://login.tailscale.com/admin) · [Open the policy source](https://github.com/loft-sh/tailscale-acls/blob/main/policy.hujson)

<!-- end_slide -->

## Live: Native SSH

> Ctrl+E connects to the original demo target; `exit` returns here.

```bash +exec_replace
paint cyan '  inside SSH   ' plain 'whoami, hostname, echo "$SSH_CONNECTION"'
paint yellow '  after SSH    ' plain 'show the matching PAM session and playback'
```

```bash +exec +acquire_terminal
ssh -l boundary-poc ovh-demo.robin-cobia.ts.net
```

Use the original target; the approval-demo target needs its reviewed policy deployed first.

<!-- end_slide -->

## Access Path

> Where do authorization, credentials and egress happen?

```bash +exec_replace
./journey.sh 2
```

<!-- end_slide -->

## The SSH Path

> A private connector brokers the customer connection.

```bash +exec_replace
just boxart pam-ssh
paint
paint cyan '  connector    ' plain 'no public IP or inbound security-group rules'
paint cyan '  customer     ' plain 'approved Linux account and certificate trust'
paint yellow '  remaining    ' plain 'clean-target proof and isolation denial tests'
```

<!-- end_slide -->

## Static Customer Egress

> All customer-bound traffic uses known static public IPs.

```bash +exec_replace
paint cyan '  engineer' gray ' ──▶ ' cyan 'PAM connector' gray ' ──▶ ' 'bold yellow' 'static NAT IP' gray ' ──▶ ' cyan 'customer'
paint
paint plain '  63.183.170.86     18.196.66.114'
paint plain '  3.19.214.126      18.227.187.66'
paint
paint green '  Send the published allowlist to customers for firewall setup.'
```

[Customer IP allowlist](https://www.vcluster.com/docs/ips)

<!-- end_slide -->

## Customer Administration

> Give the customer admin controls over their own domain.

```bash +exec_replace
paint 'bold cyan' '  CUSTOMER ADMIN'
paint cyan '    setup        ' plain 'register customer targets and maintain access rules'
paint cyan '    assignment   ' plain 'assign individual company users to customer targets'
paint cyan '    mapping      ' plain 'map existing SSO groups to Tailscale access rules'
paint
paint 'bold yellow' '  OPS'
paint yellow '    platform     ' plain 'technical design, integrations and security controls'
paint yellow '    SSO          ' plain 'Google Workspace membership remains Ops-only'
```

Target onboarding and full delegated administration remain implementation work.

<!-- end_slide -->

## Tradeoffs and Feedback

> What did the POCs show, and what workflow should we support?

```bash +exec_replace
./journey.sh 3
```

<!-- end_slide -->

## PAM and Boundary

> Compare our tested configurations.

```bash +exec_replace
paint 'bold cyan' '  TAILSCALE PAM                 ' 'bold yellow' 'BOUNDARY POC'
paint plain '  connector + NAT               ' gray 'HCP + worker + Vault + S3'
paint plain '  native SSH                    ' gray 'Boundary client / proxy'
paint plain '  PAM-issued certificate        ' gray 'Vault credential injection'
paint plain '  managed playback              ' gray 'S3 recordings and playback'
paint
paint green '  Fixed egress was proved in both POCs.'
paint yellow '  Neither POC has passed full production acceptance.'
```

<!-- end_slide -->

## PAM Tradeoffs

```bash +exec_replace
paint green '  + ' cyan 'operated stack   ' plain 'fewer components in this POC'
paint green '  + ' cyan 'engineer flow    ' plain 'native SSH and managed playback'
paint yellow '  - ' cyan 'trust boundary   ' plain 'more session and recording handling at the vendor'
paint yellow '  ? ' cyan 'validate         ' plain 'entitlement, retention, failure handling and recovery'
```

The smaller footprint is an inference from these POC stacks, not a cost benchmark.

<!-- end_slide -->

## Agreed Customer Access Model

> Jonathan confirmed the workflow: approve assignments, then connect.

```bash +exec_replace
paint cyan '  assignments   ' plain 'individual people, scoped to customer targets'
paint cyan '  approval      ' plain 'Jonathan or Fabian approves in Slack'
paint cyan '  normal use    ' plain 'ongoing access until the assignment is revoked'
paint cyan '  exceptions    ' plain 'grant temporarily, then revoke when needed'
paint cyan '  people        ' plain 'named company users; the recipient team does not matter'
paint
paint green '  Standing assignments; native Tailscale JIT is not needed.'
```

The admin tools manage grants and revocation. Google Workspace membership stays Ops-only.

<!-- end_slide -->

## Verification Still Needed

```bash +exec_replace
paint green '  proved earlier  ' plain 'native SSH, fixed egress and playback'
paint green '  working now     ' plain 'bot Home, modal submission and a scoped policy PR'
paint yellow '  verify          ' plain 'clean target; customer/internal isolation; SSO/MFA'
paint yellow '  verify          ' plain 'offboarding, active sessions, recording retention/failures'
paint yellow '  verify          ' plain 'Slack approvals, automatic PR handling and delegated admin'
paint yellow '  verify          ' plain 'recovery, redundancy, entitlement and recording viewers'
```

The demo is POC evidence; production acceptance remains open.

<!-- end_slide -->

## Takeaways

```bash +exec_replace
paint green '  ✓ ' cyan 'so what    ' plain 'PAM supports the native SSH path with a smaller POC stack'
paint green '  ✓ ' cyan 'now what   ' plain 'the bot creates reviewed policy changes and shows access'
paint yellow '  ▶ ' cyan 'then what  ' plain 'build individual grant / revoke controls with named approvers'
```

<!-- end_slide -->

## Demo Tabs and Sources

[Slack bot](https://app.slack.com/client/T024313FSQZ/D0C80S3CXNJ) · [Tailscale admin](https://login.tailscale.com/admin)

[Policy source](https://github.com/loft-sh/tailscale-acls/blob/main/policy.hujson) · [Access PR #29](https://github.com/loft-sh/tailscale-acls/pull/29)

[Customer IP allowlist](https://www.vcluster.com/docs/ips)

Evidence, demo notes and comparison sources: `README.md`.

<!-- end_slide -->

# That's All Folks!

```bash +exec_replace
printf '%s\n' "That's all folks!" | figlet -f small -w 90 | while IFS= read -r line; do
    paint 'bold cyan' "$line"
done
```
