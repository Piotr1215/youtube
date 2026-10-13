Thank you, this is very helpful. We'll use individual assignments with ongoing access and manual revocation, including access for CTO-team members. We don't need Tailscale's JIT feature for this workflow.

You and Fabian would manage access from the bot's Home page and approve requests in Slack. The policy PRs would be automatically checked and approved behind the scenes after your Slack approval.

Each person would have a personalized Home page showing their available targets and copyable SSH commands. We can also provide relevant session recordings on request.

All customer traffic through the service uses our static egress IPs. You can pass [the IP allowlist](https://www.vcluster.com/docs/ips) to customers for their firewall configuration.
