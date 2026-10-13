The Slack bot is now working in the PAM POC: it shows available targets and connection commands, and can open a PR for an access change. The access rules stay in the private Git repo with review; the bot provides a thin interface over them.

Next is the admin workflow, so you can register customer targets and manage access within your team. Before I finish that, I want to confirm how you want to manage it:

- Do you manage customer access through account teams, individual assignments, a shared CE pool, or a mix?
- Should an assignment give someone ongoing access, or should each use require approval? Are there customer-specific exceptions?
- When someone needs access to another customer, how should that request be handled within your team?

This will shape the controls we give your admin and the experience for engineers. If each use needs approval, that changes the authorization workflow we need to build.
