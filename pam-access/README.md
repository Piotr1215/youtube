# PAM team meeting, 2026-10-13

Architecture, demos and a Boundary comparison for the team meeting. The deck follows `ai-dev-loop`: a figlet title, `paint` color rows, `boxart` diagrams and chapter maps. The bot and PAM configuration are the main live demos.

## Presentation

From this directory:

```sh
env -u NO_COLOR just present
```

Run `just boxart pam-ssh` or `just boxart pam-policy` to render the colored diagrams. Their sources are `diagrams/*.json`; text and PlantUML versions are retained as reference material. Unsetting `NO_COLOR` preserves the slide colors if that variable is present in the shell.

Space or Enter advances. Left returns. Ctrl+E runs the command on a demo slide. The SSH slide uses `+acquire_terminal`, so the shell gets the terminal and `exit` returns to the presentation. See the [presenterm execution guide](https://github.com/mfontanini/presenterm/blob/master/docs/src/features/code/execution.md).

Open the demo URLs yourself; the slides do not launch a browser. The only interactive command is SSH to the existing POC target. Keep host-key verification enabled.

### Browser tabs

- [Bot conversation](https://app.slack.com/client/T024313FSQZ/D0C80S3CXNJ): show Home, then Messages and the access form. This is Piotr's existing conversation; use the bot's Home tab in the same workspace.
- [Test PR #29](https://github.com/loft-sh/tailscale-acls/pull/29): evidence that the bot creates a scoped policy diff. It is a test artifact, not a delivery blocker or a PR that must be merged.
- [Tailscale admin](https://login.tailscale.com/admin): open Services and the OVH SSH PAM service. Show the connector, upstream address/port, and how its access grant selects the service and SSH username. Open session attribution/playback after the SSH demo if available.
- [Policy source](https://github.com/loft-sh/tailscale-acls/blob/main/policy.hujson): show the matching PAM grant. PAM service setup and access controls are described in the official [services guide](https://tailscale.com/docs/privileged-access-management/services) and [control-access guide](https://tailscale.com/docs/privileged-access-management/how-to/control-access).

## Demo

1. Open vCluster Infra Access in Slack. Show Home's original OVH demo SSH entry and its applied-policy status.
2. In Messages, send `access` and open a fresh form. Select OVH access approval demo, Request access for myself and a short reason. If PR #29 is pending, cancel the form after showing it.
3. Show the existing private receipt and [access PR #29](https://github.com/loft-sh/tailscale-acls/pull/29). At verification, it was OPEN at `5714b8859c542a3bff0521bc8340a9f1cb5b9f4b`, with only one added member in `group:pam-ovh-demo-access`. `tests` and `acls` passed; legacy auto-approval skipped. Human code-owner review was still required.
4. At Live: PAM Configuration, switch to the admin tab and show the configured service, connector, upstream endpoint and PAM access grant.
5. Run the Live: Native SSH slide. In SSH, run `whoami`, `hostname` and `echo "$SSH_CONNECTION"`, then `exit`. The October 8 evidence recorded source NAT IP `3.19.214.126`; compare the current connection separately.
6. Open the PAM session view and show attribution/playback if your current permissions allow it. Playback and attribution were verified on October 8 and have not been reverified for this deck.

If a test policy change is deliberately used to grant approval-demo access, it must be reviewed and deployed before testing that grant. PR #29 itself need not be merged; it already proves PR creation and can stay as the demo artifact. The original target is the existing regression/demo path. The presentation SSH command has not been run during deck preparation.

## Evidence and comparison

| Claim | Source and limit |
| --- | --- |
| Slack modal and ordinary PR creation | Flows #69 deployed at `4b02ead`; private receipt and test PR #29 verified on October 13. Current catalog/email-membership flow; automatic approval remains planned. |
| PAM native SSH, fixed egress, certificate authentication | [PAM evidence](https://github.com/loft-sh/architecture/blob/af75f649ecb1df6bec3e767c70d613aebccdf683/platform/evidence/tailscale-pam-poc-2026-10-08.md). Dated proof on an existing target that still has Tailscale installed. |
| Recording and attribution | Same PAM evidence. Playback observed by Piotr; recording retention and failure handling remain open. |
| Boundary stack and SSH path | [Boundary design](https://github.com/loft-sh/architecture/blob/af75f649ecb1df6bec3e767c70d613aebccdf683/platform/designs/boundary-poc.md) and [coverage matrix](https://github.com/loft-sh/architecture/blob/af75f649ecb1df6bec3e767c70d613aebccdf683/platform/evidence/customer-access-coverage.md). HCP, worker, Vault, NAT and S3 in this POC. |
| Smaller PAM footprint | Inference from the two operated POC stacks, not a benchmark or cost estimate. |
| SSO baseline and administration split | Piotr's October 13 clarification: company SSO provides baseline access. Only Infra/Ops changes Google Workspace membership. Customer access is assigned to individual company identities by Jonathan or Fabian, independent of the recipient's team. Delegated administration remains acceptance work. |

PAM uses a connector to proxy application sessions. See [PAM architecture](https://tailscale.com/docs/privileged-access-management/architecture-and-concepts) and [PAM SSH](https://tailscale.com/docs/privileged-access-management/how-to/access-ssh). Boundary distinguishes credential injection from brokering: see [credential management](https://developer.hashicorp.com/boundary/docs/concepts/credential-management). Its recording behavior and availability are described in [session recording](https://developer.hashicorp.com/boundary/docs/session-recording). The vendor docs describe capabilities; the POC evidence records our tested results.

## Requirements

### CE decision, October 13

Jonathan confirmed individual assignments, including access for non-CE users such as the CTO team. An assignment provides ongoing access. Temporary exceptions may be granted and manually revoked; no customer requiring approval for every use was identified. Customer-access approval can go through Jonathan or Fabian.

The service should provide person/customer grant and revoke controls, an approval record tied to the policy change, and access status reflecting deployed policy. Jonathan or Fabian selects the individual company identity; recipient team membership is not an authorization gate. Customer-specific Tailscale policy groups may remain as permission sets containing named individuals. These are separate from Google Workspace groups, whose membership remains Ops-only. Jonathan/Fabian approval happens in Slack; policy PRs are handled automatically after approval. Automated scope/provenance checks and CI must bind the approved person, customer and action to the resulting change. The current POC still requires human GitHub review; the complete Slack approval, automatic PR handling and delegated revocation path remain implementation work.

Revocation must be tested after policy deployment, including alternative grants and already-open sessions. An assignment lifetime is separate from the lifetime of an SSH session or its credentials.

AZ-3 specifies PR-reviewed access grants and AZ-5 specifies approved JIT with automatic expiry, both priority 3. Jonathan's answer establishes individual standing assignments and manual revocation as the normal CE workflow. Native Tailscale JIT is not needed for that workflow. AZ-5's automatic-expiry capability remains a separate lower-priority requirement, not evidence that all access must expire. No fixed access durations are proposed.

### Static egress and recordings

All customer-bound traffic must use the service's protected static public IPs. The native SSH POC verified this path. The customer-facing [IP allowlist](https://www.vcluster.com/docs/ips) was fetched successfully on October 13 and publishes four IPv4 addresses, including the POC NAT address `3.19.214.126`. CE can send that page to customers. EG-2 requires at least eight published addresses, so the current four-address page does not complete that acceptance criterion.

Relevant session recordings can be provided on request. This is distinct from granting CE access to the whole recording library; retention, viewer permissions and the Legal decision remain acceptance work. Current playback evidence is dated, as recorded above.

CE owns customer rollout, PAM target registration, assignments and customer-side configuration in tailscale-acls, including mapping existing SSO groups to access rules. Ops/IT/Platform owns the technical decisions, integrations, plumbing and shared security controls. Infra/Ops alone manages Google Workspace group membership. The proposed bot does not administer Google Workspace membership.

Lifecycle requirements include offboarding within one business day, quarterly access review and unused-access alerts after 90 days. These deadlines govern the access lifecycle. They do not set normal session timeouts.

Customer and internal access must remain isolated. A clean customer target, denial tests, SSO/MFA/group sync, CE administration, offboarding/open sessions, retention/failure handling, recovery and commercial acceptance remain open. Production acceptance remains incomplete.

## Documents

- [SSH design](https://github.com/loft-sh/architecture/blob/af75f649ecb1df6bec3e767c70d613aebccdf683/platform/designs/customer-access.md)
- [PAM decision](https://github.com/loft-sh/architecture/blob/af75f649ecb1df6bec3e767c70d613aebccdf683/platform/adrs/009-tailscale-pam.md)
- [SSH runbook](https://github.com/loft-sh/architecture/blob/af75f649ecb1df6bec3e767c70d613aebccdf683/platform/runbooks/tailscale-pam-poc.md)
- [UX Slack proposal](slack-message.md)
- [Reply to Jonathan's access-model confirmation](jonathan-reply.md)

Older design and coverage snapshots contain the legacy Slack auto-approval path and central Ops ownership. This meeting checkpoint and DEVOPS-1628's latest comments describe the October 13 bot behavior and proposed CE operating model.
