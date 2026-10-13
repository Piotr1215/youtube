# PAM team meeting, 2026-10-13

Architecture, demos and a Boundary comparison for the team meeting. Terminal diagrams render from local text files through presenterm snippets. PlantUML sequence sources are also included.

## Presentation

From this directory:

```sh
just present
```

The local diagram text is used directly, so presentation rendering does not depend on PlantUML being installed. The matching `.puml` files are available for editing or regeneration with the repository recipes.

Space or Enter advances. Left returns. Ctrl+E runs the command on a demo slide. The SSH slide uses `+acquire_terminal`, so the shell gets the terminal and `exit` returns to the presentation. See the [presenterm execution guide](https://github.com/mfontanini/presenterm/blob/master/docs/src/features/code/execution.md).

Executable slides show a read-only PR diff and connect interactively to the existing POC SSH target. Keep host-key verification enabled.

## Demo

1. Open vCluster Infra Access in Slack. Show Home's original OVH demo SSH entry and its applied-policy status.
2. In Messages, send `access` and open a fresh form. Select OVH access approval demo, Request access for myself and a short reason. If PR #29 is pending, cancel the form after showing it.
3. Show the existing private receipt and [access PR #29](https://github.com/loft-sh/tailscale-acls/pull/29). At verification, it was OPEN at `5714b8859c542a3bff0521bc8340a9f1cb5b9f4b`, with only one added member in `group:pam-ovh-demo-access`. `tests` and `acls` passed; legacy auto-approval skipped. Human code-owner review was still required.
4. Run the Terminal demo slide. In SSH, run `whoami`, `hostname` and `echo "$SSH_CONNECTION"`, then `exit`. The October 8 evidence recorded source NAT IP `3.19.214.126`; compare the current connection separately.
5. Open the PAM session view and show attribution/playback if your current permissions allow it. Playback and attribution were verified on October 8 and have not been reverified for this deck.

The approval-demo target requires human review, merge and successful deployment at the exact main SHA before access can be tested. The original target is the existing regression/demo path. The presentation SSH command has not been run during deck preparation.

## Evidence and comparison

| Claim | Source and limit |
| --- | --- |
| Slack modal and ordinary PR creation | Flows #69 deployed at `4b02ead`; private receipt and PR #29 verified on October 13. Current catalog/email-membership flow, not the future Google-group integration. |
| PAM native SSH, fixed egress, certificate authentication | [PAM evidence](https://github.com/loft-sh/architecture/blob/af75f649ecb1df6bec3e767c70d613aebccdf683/platform/evidence/tailscale-pam-poc-2026-10-08.md). Dated proof on an existing target that still has Tailscale installed. |
| Recording and attribution | Same PAM evidence. Playback observed by Piotr; recording retention and failure handling remain open. |
| Boundary stack and SSH path | [Boundary design](https://github.com/loft-sh/architecture/blob/af75f649ecb1df6bec3e767c70d613aebccdf683/platform/designs/boundary-poc.md) and [coverage matrix](https://github.com/loft-sh/architecture/blob/af75f649ecb1df6bec3e767c70d613aebccdf683/platform/evidence/customer-access-coverage.md). HCP, worker, Vault, NAT and S3 in this POC. |
| Smaller PAM footprint | Inference from the two operated POC stacks, not a benchmark or cost estimate. |
| SSO baseline and administration split | Piotr's October 13 clarification: CE baseline access is already automatic through company SSO. Only Infra/Ops changes Google Workspace group membership. CE owns customer setup and Tailscale-side changes, including mapping existing SSO groups to targets. End-to-end PAM group mapping and delegated administration remain acceptance work. |

PAM uses a connector to proxy application sessions. See [PAM architecture](https://tailscale.com/docs/privileged-access-management/architecture-and-concepts) and [PAM SSH](https://tailscale.com/docs/privileged-access-management/how-to/access-ssh). Boundary distinguishes credential injection from brokering: see [credential management](https://developer.hashicorp.com/boundary/docs/concepts/credential-management). Its recording behavior and availability are described in [session recording](https://developer.hashicorp.com/boundary/docs/session-recording). The vendor docs describe capabilities; the POC evidence records our tested results.

## Requirements

AZ-3 specifies PR-reviewed access grants and AZ-5 specifies approved JIT with automatic expiry, both priority 3. The matrix leaves normal session duration and the main access model open. Automatic SSO baseline access is already established. We are building a platform service for CE to manage its own customer domain. CE defines its access-management workflow: account teams, individual assignments or shared access; ongoing access while assigned or approval for each use; and the changes its admin must handle. Ops designs the authorization mechanism and user experience. CE maintains actual assignments through those tools. Approval for every use changes the authorization workflow. No fixed access durations are proposed.

CE owns customer rollout, PAM target registration, assignments and customer-side configuration in tailscale-acls, including mapping existing SSO groups to access rules. Ops/IT/Platform owns the technical decisions, integrations, plumbing and shared security controls. Infra/Ops alone manages Google Workspace group membership. The proposed bot does not administer Google Workspace membership.

Lifecycle requirements include offboarding within one business day, quarterly access review and unused-access alerts after 90 days. These deadlines govern the access lifecycle. They do not set normal session timeouts.

Customer and internal access must remain isolated. A clean customer target, denial tests, SSO/MFA/group sync, CE administration, offboarding/open sessions, retention/failure handling, recovery and commercial acceptance remain open. Production acceptance remains incomplete.

## Documents

- [SSH design](https://github.com/loft-sh/architecture/blob/af75f649ecb1df6bec3e767c70d613aebccdf683/platform/designs/customer-access.md)
- [PAM decision](https://github.com/loft-sh/architecture/blob/af75f649ecb1df6bec3e767c70d613aebccdf683/platform/adrs/009-tailscale-pam.md)
- [SSH runbook](https://github.com/loft-sh/architecture/blob/af75f649ecb1df6bec3e767c70d613aebccdf683/platform/runbooks/tailscale-pam-poc.md)
- [UX Slack proposal](slack-message.md)

Older design and coverage snapshots contain the legacy Slack auto-approval path and central Ops ownership. This meeting checkpoint and DEVOPS-1628's latest comments describe the October 13 bot behavior and proposed CE operating model.
