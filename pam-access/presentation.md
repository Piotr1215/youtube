---
title: PAM infrastructure access
author: Piotr Zaniewski
date: 2026-10-13
options:
  implicit_slide_ends: false
---

## The service

```bash +exec_replace
./journey.sh 1
```

<!-- end_slide -->

# Platform service for CE

- Company SSO already provides automatic baseline access for everyone in CE.
- Infra/Ops alone manages Google Workspace group membership and the shared platform.
- CE administers customer targets, access rules, assignments and rollout through the service.
- Ops owns the technical design, plumbing and security controls.
- PRs and a thin self-service interface use the same reviewed access policies.

CE defines its access-management workflow and maintains customer assignments. Ops designs the controls.

<!-- end_slide -->

# Slack demo

- Open vCluster Infra Access: Home, then Messages.
- Open a fresh access form and select OVH access approval demo.
- Show Request access for myself and the short reason `test`.
- Show the existing bot receipt and PR #29: one policy group, one added member.
- Show green tests and the required human review.

Use the existing PR for the meeting.

```bash +exec
gh pr diff 29 --repo loft-sh/tailscale-acls
```

<!-- end_slide -->

## Architecture and demo

```bash +exec_replace
./journey.sh 2
```

<!-- end_slide -->

# SSH architecture

```bash +exec_replace
cat diagrams/pam-ssh.txt
```

- The connector has no public IP or inbound security-group rules.
- The target sees gateway egress, and PAM records engineer identity.
- Customer setup still needs an approved account and certificate trust.

The demo proves the SSH path on the existing target. Clean-target isolation and broader internal-infrastructure coverage remain open.

<!-- end_slide -->

# Slack and Git

```bash +exec_replace
cat diagrams/pam-policy.txt
```

- Home shows applied access and a terminal connection command.
- The form checks identity and role, then proposes a scoped change.
- PR creation alone does not grant access.

The POC uses catalog roles and explicit email membership. The bot does not change Google Workspace membership.

<!-- end_slide -->

# Terminal demo

Press Ctrl+E to connect to the existing demo SSH target. Type `exit` to return to the slides.

```bash +exec +acquire_terminal
ssh -l boundary-poc ovh-demo.robin-cobia.ts.net
```

Inside the session, show `whoami`, `hostname` and `echo "$SSH_CONNECTION"`.

Show the corresponding PAM session and playback if your account has access.

This uses the original SSH target. The approval-demo target requires its reviewed policy change to be deployed first.

<!-- end_slide -->

## Tradeoffs and feedback

```bash +exec_replace
./journey.sh 3
```

<!-- end_slide -->

# PAM and Boundary

| Area | Tailscale PAM POC | Boundary POC |
| --- | --- | --- |
| Operated components | Connector and gateway/NAT | HCP, worker, Vault and recording S3 |
| Engineer entry point | Native SSH | Boundary client/proxy |
| Upstream authentication | PAM-issued certificate | Vault certificate / credential injection |
| Recording | Managed playback | S3 recordings and playback |
| Fixed egress | Proved from target | Proved from target |
| Group SSO and full delegation | Not verified end to end | Not verified end to end |

The comparison covers the two recorded POC configurations.

<!-- end_slide -->

# PAM tradeoffs

- Smaller operated stack in this POC: no Vault or recording S3 dependency in the PAM path.
- Native SSH fits the existing terminal workflow.
- Managed attribution and playback were observed in earlier tests.
- Vendor owns more of the session and recording trust boundary.
- Entitlement, retention controls, failure behavior and delegated administration need validation.

Boundary gives us a Vault/storage-based design with more components to operate. Neither POC has passed full production acceptance.

<!-- end_slide -->

# Customer administration

```text
  CE admin
     |
     +--> Customer/system setup and rollout
     +--> PAM target registration and maintenance
     +--> Map existing SSO groups to customer access rules
     +--> Customer-scoped policy changes and review

  Infra/Ops --> Google Workspace membership, SSO and shared platform
```

CE manages customer assignments and Tailscale access rules through our tools. Ops owns the technical design and Google Workspace membership.

The bot has POC policy-membership and eligibility forms. Full target onboarding and SSO-group policy mapping remain acceptance work.

<!-- end_slide -->

# Acceptance work

- Clean customer target without Tailscale and verified cross-customer/internal isolation.
- Google-group SSO, MFA and independent CE-admin workflows.
- Verify offboarding, access removal and behavior of existing sessions.
- Validate recording retention, shell/exec coverage and failure handling.
- Connector recovery, redundancy and commercial readiness.

Working now: Home, modal submission and an ordinary scoped access PR with passing checks.

Earlier POC tests proved native SSH, fixed egress and recording playback.

<!-- end_slide -->

# CE access workflow

- Assignments: account teams, individual assignments, a shared CE pool, or a mix?
- Access: ongoing access while assigned, or approval for each use? Customer-specific exceptions?
- Admin workflow: which changes should the CE admin handle, and how should engineers request extra customer access?

CE describes the workflow. Ops designs the mechanism; CE uses it to maintain access. Approval for every use changes the authorization workflow.

<!-- end_slide -->

# Takeaways

- PAM reduced the operated stack in our POC and supports the native SSH demo.
- The Slack prototype now creates a scoped PR for human review.
- CE manages its customer domain; Ops owns Google membership, the platform and technical decisions.
- Use CE's workflow to build controls for managing customer assignments.

Meeting notes and sources: `README.md` in this directory.
