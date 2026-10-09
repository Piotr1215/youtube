# Your Platform Already Has AI Users

> Paved roads for the AI tools and agents teams ship

<!-- new_lines: 3 -->

```bash +exec_replace
echo "AI Users" | figlet -f small -w 90
```

<!-- end_slide -->

## About Me

<!-- skip_slide -->

```bash +exec_replace
echo "Piotr Zaniewski" | figlet -f small -w 90
```

> Head of Engineering Enablement @ vCluster

```bash +exec_replace
m() { printf '  \e[1;36m%s\e[0m\e[37m%s\e[0m\n' "$1" "$2"; }
m 'Expertise   ' 'platform engineering, Kubernetes, GitOps, SRE'
m 'AI work     ' 'agent platforms, MCP servers, RAG'
m 'Speaking    ' 'workshops, conference talks, live demos'
m 'Content     ' 'YouTube, Medium, Killercoda'
```

```bash +exec_replace
qrencode -t UTF8 -m 2 "https://cloudrumble.net"
printf '  \e[37m%s\e[0m\n' 'cloudrumble.net  ·  github.com/Piotr1215  ·  @cloud-native-corner'
```

<!-- end_slide -->

## Converging Components

> Paved roads for AI tools combine three components.

```bash +exec_replace
f() { printf '  \e[1;36m%-23s\e[0m\e[37m%-17s\e[0m\e[35m%s\e[0m\e[1;33m%s\e[0m\n' "$1" "$2" "$3" "$4"; }
f 'Platform engineering' 'the discipline' '──┐'
f 'Kubernetes' 'the runtime' '──┼──▶  ' 'paved roads for AI tools'
f 'MCP' 'the interface' '──┘'
printf '\n'
m() { printf '  \e[1;36m%s\e[0m\e[35m%s\e[0m\e[37m%s\e[0m\n' "$1" '›  ' "$2"; }
m 'Discipline  ' 'self-service, golden paths, guardrails'
m 'Runtime     ' 'where AI tools and agents actually run'
m 'Interface   ' 'how agents discover and call those tools'
```

<!-- end_slide -->

## The Shift

> Why do platforms need to care about AI tools now?

```bash +exec_replace
./journey.sh 1
```

<!-- end_slide -->

## Two Kinds of Platform Users

> Agents call the same APIs your developers do.

```bash +exec_replace
m() { printf '  \e[1;36m%-14s\e[0m\e[37m%-26s\e[0m\e[33m%s\e[0m\n' "$1" "$2" "$3"; }
printf '  \e[1;37m%-14s%-26s%s\e[0m\n\n' 'DIMENSION' 'DEVELOPERS' 'AGENTS'
m 'Interface' 'portal, CLI, docs' 'MCP tools, typed schemas'
m 'Golden path' 'templates, scaffolding' 'skills, workflow definitions'
m 'Guardrails' 'permissions, review gates' 'tool allowlists, approval gates'
m 'Bottleneck' 'cognitive load' 'context window'
m 'Memory' 'experience, wikis' 'none, unless the platform keeps it'
m 'Cost' 'salaries and time' 'tokens and compute'
printf '\n  \e[32m%s\e[0m\n' 'The same platform serves both; the interface layer changes.'
```

<!-- end_slide -->

## AI Tools Across Teams

> MCP servers, RAG services, and agents run like any other workload.

```bash +exec_replace
m() { printf '  \e[1;36m%s\e[0m\e[35m%s\e[0m\e[37m%s\e[0m\n' "$1" '›  ' "$2"; }
printf '  \e[1;33m%s\e[0m\n\n' 'AI TOOL                           WHAT IT NEEDS'
m 'MCP server for internal docs   ' 'a place to run and a web address'
m 'RAG service over company data  ' 'passwords, storage, data access rules'
m 'Agent calling other systems    ' 'its own identity, limits on what it reaches'
m 'Report or analysis agent       ' 'read access to data, a human before results ship'
printf '\n  \e[32m%s\e[0m\n' 'The same guardrails repeat across teams, so they belong in the platform.'
```

<!-- end_slide -->

## Without Shared Guardrails

> Each team solves isolation, access, and data handling on its own.

```bash +exec_replace
x() { printf '  \e[31m✗\e[0m  \e[1;37m%s\e[0m\e[37m%s\e[0m\n' "$1" "$2"; }
x 'Ticket queue    ' 'the platform team becomes the bottleneck'
x 'Weak isolation  ' 'tools share space, so one failure spreads'
x 'Data exposure   ' 'an agent reaches data its team never cleared'
x 'Ad hoc access   ' 'who may call which tool, decided per request'
x 'Policy drift    ' 'rules copied per team, then diverging'
printf '\n  \e[33m%s\e[0m\n' 'Fast delivery needs a boundary teams can rely on.'
```

<!-- end_slide -->

## The Discipline

> How does platform engineering answer this?

```bash +exec_replace
./journey.sh 2
```

<!-- end_slide -->

## What a Paved Road Is

> A team brings its tool; the platform provides the runtime around it.

```bash +exec_replace
m() { printf '  \e[1;36m%s\e[0m\e[35m%s\e[0m\e[37m%s\e[0m\n' "$1" '›  ' "$2"; }
m 'Team brings        ' 'an image and what the tool needs to reach'
m 'Platform provides  ' 'an isolated runtime, created on request'
m 'Guardrails         ' 'in place when the runtime starts'
m 'Changes            ' 'reviewed pull requests to the template'
printf '\n  \e[32m%s\e[0m\n' 'Teams ship without tickets, and the platform keeps the standards.'
```

<!-- end_slide -->

## Roads by Risk Class

> A docs server and an agent with write access carry different risk.

```bash +exec_replace
r() { printf '  \e[1;33m%s\e[0m\e[37m%s\e[0m\n                   \e[36m%s\e[0m\n\n' "$1" "$2" "$3"; }
r 'docs-tool        ' 'read-only tools, docs MCP servers' 'locked-down runtime, spending cap, public address'
r 'data-tool        ' 'RAG and analytics over company data' '+ only its own keys, approved data sources, no public address'
r 'agent-runtime    ' 'agents that act on other systems' '+ own identity, approved destinations, approval for writes'
r 'gpu-runtime      ' 'training and inference' '+ GPU budget, dedicated machines'
printf '  \e[32m%s\e[0m\n' 'Teams pick a road; the platform team decides which roads exist.'
printf '  \e[37m%s\e[0m\n' 'The demo walks the first road, docs-tool.'
```

<!-- end_slide -->

## What Agents Need From the Platform

> Agents bring needs that platforms built for people do not cover.

```bash +exec_replace
m() { printf '  \e[1;36m%s\e[0m\e[35m%s\e[0m\e[37m%s\e[0m\n' "$1" '›  ' "$2"; }
m 'Context      ' 'a finite budget, so the platform delivers it pre-filtered'
m 'Memory       ' 'sessions start empty unless the platform keeps knowledge'
m 'Authority    ' 'its own identity, approved tools, a human before writes'
m 'Containment  ' 'retrieved text is data, outbound only to approved places'
m 'Testing      ' 'manipulation and data-leak cases run on every change'
printf '\n  \e[32m%s\e[0m\n' 'A model can be manipulated; the runtime decides what that costs.'
```

<!-- end_slide -->

## The Runtime

> Where do the tools run, and how are teams kept apart?

```bash +exec_replace
./journey.sh 3
```

<!-- end_slide -->

## Isolating Teams on a Shared Cluster

> Every team needs a space of its own; the question is how strong the walls are.

```bash +exec_replace
m() { printf '  \e[1;36m%s\e[0m\e[35m%s\e[0m\e[37m%s\e[0m\n' "$1" '›  ' "$2"; }
m 'Namespace per team        ' "cheap, but teams share the cluster's admin"
m 'Real cluster per team     ' 'strong walls, but slow and costly to run'
m 'Virtual cluster per team  ' 'a full cluster of its own, on shared machines'
printf '\n'
t() { printf '  \e[35m%s\e[0m\e[1;36m%-14s\e[0m\e[37m%s\e[0m\n' "$1" "$2" "$3"; }
printf '  \e[1;37m%s\e[0m\n' 'shared cluster, run by the platform team'
t '  ├──▶  ' 'team-docs' 'own admin, own rules, own tools'
t '  ├──▶  ' 'team-support' 'own admin, own rules, own tools'
t '  └──▶  ' 'team-data' 'own admin, own rules, own tools'
printf '\n  \e[37m%s\e[0m\n' 'Built on vCluster, open source. On a platform, a team creates one with a click.'
```

<!-- end_slide -->

## The Contract

> Every runtime on this road inherits the same baseline.

```bash +exec_replace
c() { printf '  \e[32m✓\e[0m  \e[1;37m%s\e[0m\e[37m%s\e[0m\n' "$1" "$2"; }
c 'Safe defaults   ' 'no tool runs as the all-powerful root user'
c 'Spending cap    ' 'each team may reserve up to 8 CPUs and 16 GB of memory'
c 'Fair share      ' 'every tool gets default CPU and memory limits'
c 'Network fence   ' 'traffic rules declared for every tool'
printf '\n  \e[33m%s\e[0m\n' 'The team writes none of it.'
printf '  \e[37m%s\e[0m\n' 'Changes to these rules arrive as reviewed pull requests.'
printf '  \e[37m%s\e[0m\n' 'In rehearsal, it refused my own image for running as root.'
```

<!-- end_slide -->

## Step 1: A Cluster the Team Owns

> The team gets a private cluster to run as it likes.

```bash +exec_replace
m() { printf '  \e[1;36m%s\e[0m\e[37m%s\e[0m\n' "$1" "$2"; }
m 'Doing   ' 'act as the team inside its cluster, then look at the shared one'
m 'Why     ' 'teams get full freedom without reaching each other'
```

```bash +exec
./isolation.sh
```

<!-- end_slide -->

## Step 2: Ship the MCP Server

> The team ships its tool and writes no security rules.

```bash +exec_replace
m() { printf '  \e[1;36m%s\e[0m\e[37m%s\e[0m\n' "$1" "$2"; }
m 'Doing   ' 'ship the tool: the program, its address, its entrance'
m 'Why     ' "the team writes only its tool; the road supplies the rules"
```

```bash +exec
./ship.sh
```

<!-- end_slide -->

## Step 3: An Unsafe Tool Is Refused

> The road's rules apply even when a team forgets them.

```bash +exec_replace
m() { printf '  \e[1;36m%s\e[0m\e[37m%s\e[0m\n' "$1" "$2"; }
m 'Doing   ' 'ship a tool the unsafe way, on purpose'
m 'Why     ' 'guardrails only count if they stop real mistakes'
```

```bash +exec
./guardrails.sh
```

<!-- end_slide -->

## The Interface

> How do agents reach the tools teams ship?

```bash +exec_replace
./journey.sh 4
```

<!-- end_slide -->

## The Tool Is Real

> The demo tool is an AI assistant's helper for one product's configuration.

```bash +exec_replace
m() { printf '  \e[1;36m%s\e[0m\e[37m%s\e[0m\n' "$1" "$2"; }
m 'Doing   ' 'check the same tool, running in production right now'
m 'Why     ' 'the demo uses a real service anyone can call'
```

```bash +exec_replace
printf '  \e[35m•\e[0m \e[37m%s\e[0m\n' 'Image: piotrzan/vcluster-yaml-mcp-server:1.5.1'
printf '  \e[35m•\e[0m \e[37m%s\e[0m\n' 'Shipped by Argo CD from Git'
printf '  \e[35m•\e[0m \e[37m%s\e[0m\n' 'Public endpoint: vcluster-yaml.cloudrumble.net'
```

```bash +exec
curl -s https://vcluster-yaml.cloudrumble.net/health | jq '{status, name, version}'
```

<!-- end_slide -->

## Step 4: Add It to Your AI Client

> Any MCP client can connect to the same server.

```bash +exec_replace
m() { printf '  \e[1;36m%s\e[0m\e[37m%s\e[0m\n' "$1" "$2"; }
m 'Doing   ' 'connect an AI assistant to the tool with one command'
m 'Why     ' 'MCP is a standard plug, so any assistant can use any tool'
```

Claude Code:

```bash
claude mcp add --transport http vcluster-yaml \
  https://vcluster-yaml.cloudrumble.net/mcp
```

Any MCP client:

```json
{ "type": "http", "url": "https://vcluster-yaml.cloudrumble.net/mcp" }
```

<!-- end_slide -->

## Step 5: Another Team Asks for Help

> A teammate asks the assistant, in plain English, for a safe team setup.

```bash +exec_replace
m() { printf '  \e[1;36m%s\e[0m\e[37m%s\e[0m\n' "$1" "$2"; }
m 'Doing   ' "ask the assistant, which calls the team's tool"
m 'Why     ' "one team's tool becomes a shared expert for everyone"
```

```markdown
Write a config for a team cluster capped at 4 CPUs and 8 GB of memory,
that blocks tools running as root, and check that it is valid.
```

<!-- end_slide -->

## Next Steps

> Where does an organization start?

```bash +exec_replace
./journey.sh 5
```

<!-- end_slide -->

## Agent Platform Maturity

> Platform maturity levels apply to agents too.

```bash +exec_replace
m() { printf '  \e[1;36m%s\e[0m\e[35m%s\e[0m\e[37m%s\e[0m\n' "$1" '›  ' "$2"; }
m 'Provisional  ' 'ad hoc API keys, whole files in prompts, no memory'
m 'Operational  ' 'MCP tools, curated prompts, static allowlists'
m 'Scalable     ' 'skill chaining, long-term memory, delegated authority'
m 'Optimizing   ' 'agents request context and earn wider permissions'
printf '\n  \e[32m%s\e[0m\n' 'Most teams are scalable for developers and provisional for agents.'
```

<!-- end_slide -->

## Example: Research Data Agents

> The same roads fit agents that work with lab data.

```bash +exec_replace
m() { printf '  \e[1;36m%s\e[0m\e[35m%s\e[0m\e[37m%s\e[0m\n' "$1" '›  ' "$2"; }
m 'Experiment data access     ' 'data-tool road, read-only, approved sources'
m 'Experiment planning agent  ' 'agent-runtime road, a scientist approves each run'
m 'Reporting agent            ' 'drafts results with links to the source data'
m 'Partner tools              ' 'connected through MCP servers on their own road'
printf '\n  \e[32m%s\e[0m\n' 'A new research team starts on an existing road instead of a new project.'
```

<!-- end_slide -->

## Takeaways

> Paved roads let many teams ship AI tools safely.

```bash +exec_replace
printf '  \e[32m✓\e[0m  \e[37m%s\e[0m\n' 'Teams ship AI tools on runtimes the platform defines'
printf '  \e[32m✓\e[0m  \e[37m%s\e[0m\n' 'Roads fork by risk, and each fork adds guardrails'
printf '  \e[32m✓\e[0m  \e[37m%s\e[0m\n' 'Agents are platform users: serve them tools, context, and memory'
printf '  \e[33m▶\e[0m  \e[37m%s\e[0m\n' 'Start with a single road and a real tool, then fork as risk grows'
```

<!-- end_slide -->

<!-- jump_to_middle -->

```bash +exec_replace
echo "Thank You!" | figlet -f small -w 90
```

## Questions?
