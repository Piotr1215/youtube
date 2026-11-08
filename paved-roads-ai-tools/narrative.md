# Narrative: Your Platform Already Has AI Users

Draft for LLM Days Hamburg, rebuilt around one idea: the agent is a platform user. The MCP interface chapter and the research data example are cut. The runtime chapter is trimmed, and a new chapter shows an agent using the platform under its own identity, with a system built for it filling what the platform lacks.

## Journey

- Problem the viewer recognizes: agents already call the APIs their developers call, and nobody designed the platform for them. Every team wires its AI tools up alone.
- Why the usual ways fall short: handing an agent tools (MCP) gives it hands, not a place in the platform. The platform does not know it is there, so the agent gets no identity, no limits, no events and no memory beyond what the team hand-builds.
- New understanding: an agent is a platform user with needs of its own. A platform built for automation already meets half of them (identity, limits, golden paths). The other half (events, memory, context, testing) needs a service built for agents from the first line.
- How each discovery motivates the next: the shift raises the problem; platform engineering answers it with paved roads; roads need walls between teams; once the walls exist, the question is whether an agent can walk the same roads as a person, and what it still lacks when it does.
- What the viewer can do at the end: audit their own platform against an agent's needs, give an agent its own identity and limits on the roads they already have, and add the missing half as a service built for agents.
- So what: agents are already users, so a platform that ignores them pushes every team into ad hoc AI plumbing. Now what: give one agent an identity, a quota and one road. Then what: let it react to events and write its own rules, and promote it the way a platform promotes anything, from shadow to live.

## Subject and example

Subject: agents are platform users; meet their needs with the platform's own primitives where they exist, and with services built for agents where they do not. Examples: tenant clusters on vCluster Platform (identity, templates, quotas, Stacks), and Intake, the event and rules engine an agent operates (events, memory, context, testing). The examples serve the subject; the demo is a live case of it.

## Narration

1. Your platform already has AI users. Agents call the same APIs your developers do, and most platforms do not know it yet.
2. Developers and agents differ where it matters: an agent's bottleneck is its context window, it remembers nothing between sessions unless something keeps it, and it acts at machine speed.
3. Teams across the company now ship AI tools and agents. Each needs a place to run, credentials, and limits on what it reaches; without shared guardrails each team solves that alone, and the platform team becomes a ticket queue.
4. Platform engineering has answered this before with paved roads: a team brings its tool, the platform provides the runtime and the guardrails around it, and roads fork by risk.
5. Agents bring needs a platform built for people never had to meet: authority of their own, containment of what they reach, events instead of polling, memory the platform keeps, context delivered pre-filtered, and tests for manipulation.
6. The runtime: every team gets a tenant cluster of its own on one control plane cluster, with full freedom inside and walls between teams. Every tenant cluster inherits the same baseline, and the team writes none of it; an unsafe tool is refused before it starts.
7. The question that follows: the roads work for people. Can an agent walk them too, and what does it still lack when it does?
8. Audit the platform against the agent's needs. Authority: the platform treats a user as one identity, human or automated, with keys scoped to one project, short-lived keys, and a lock that stops them at once. Containment: non-admins create only from templates, and quotas cap what one user may hold. Roads: a Stack is a golden path written as a task graph, with health gates and outputs, requested through the API.
9. Now the other half. Events: the platform has none to push; an agent would have to poll, burning context and tokens. Memory, context and testing: nothing. That half needs a service built for the agent from the first line.
10. I built one. Every event goes through one engine that an agent operates: rules first, a cheap decision model for what rules cannot place, the agent for what is left. Its brief fits the agent's context budget, its rules are the agent's memory, every change carries the agent's name and reason, and a dry run against recent events tests a rule before it is written.
11. Demo. The room is the event source: everyone can ask the platform for something from their phone. The agent holds its own platform identity, a quota, and a few roads it may request.
12. Requests climb the ladder. Rules catch the obvious, the decision model maps a request to a road and its parameters, and the agent takes what neither can place. A request that gets through becomes a Stack on the platform under the agent's identity, and the requester's phone shows the result when the Stack is healthy.
13. The room floods it. The platform refuses the agent at its quota, in the same words it would use for a person, and the refusal shows on the phones. The guardrails need no new code for an agent user.
14. The room tries to talk the agent into something else. The text stays data, and the agent can only pick a road the platform offers; the screen counts the attempts and their effects.
15. Halfway through, the agent writes a rule from what the room asked for most, and the preview says how much of the recent traffic it would have handled. The next wave goes through the rule with no model call, and the counters show the expensive rungs draining.
16. What just happened is a golden path written by its user. A platform team writes Stacks for people; here the agent wrote its own path, and the platform validated it, journaled it and can replay it.
17. Platform maturity applies to agents too. Most teams are scalable for developers and provisional for agents; at the top level, an agent earns wider permissions the way a rule earns live mode, after a week in shadow.
18. Takeaways: agents are platform users; give them an identity, limits and roads with the primitives you already have; build the missing half (events, memory, context, testing) as a service for agents; start with one agent, one quota and one road.

## Moment lines

- "The Shift" divider: the viewer meets the claim and the chapter map.
- "Two Kinds of Platform Users": the viewer asks how an agent differs from a developer; the table answers.
- "Without Shared Guardrails": the viewer recognizes the ticket queue and the drift.
- "What a Paved Road Is" and "Roads by Risk Class": the viewer asks how platform engineering answers it.
- "What Agents Need From the Platform": the viewer now knows roads; the slide lists what agents need beyond them. This list returns in beat 8 as the audit.
- "Isolating Teams" and "The Contract": the viewer asks how teams are kept apart; tenant clusters and the inherited baseline answer. "An Unsafe Tool Is Refused" runs live.
- "The Agent as a User" divider: after the refusal, the viewer asks whether an agent can walk the same roads.
- "What the Platform Already Gives an Agent": the needs list beside the platform primitive that meets each need; the met half lights up.
- "What No Platform Gives an Agent": the same list with the missing half (events, memory, context, testing) highlighted.
- "A Service Built for the Agent": a role diagram (event sources, the engine with its ladder, the agent, the platform, the human). No hosts.
- "Ask the Platform": the QR code and the live screen; beats 12 to 15 run on it.
- "A Golden Path Its User Wrote": the rule the agent wrote, shown as the real file, beside a Stack template; same shape, different author.
- "Agent Platform Maturity" and "Takeaways": the viewer asks where to start.

## Demo design

- Event source: the audience page and tunnel from ai-dev-loop, writing into a separate demo instance of the engine with its own NATS, state and rules; nothing personal is in it.
- Platform: one project, one automated user for the agent with a project-scoped key and a per-user quota, two or three small StackTemplates whose output is a link.
- Adapters: phone messages in; Stack status back out as events and to the phone.
- The demo agent: its own folder, constitution and profile, built like the standing agents; it reads the engine's brief at start.
- Screen: the engine's TUI with each event's rung and outcome, counters per rung, the attempts and effects counter.
- Safety: rate limits per phone, the decision model and agent budgets capped, the agent able to act only through templates under its quota.
- Fallbacks: a rehearsal crowd script that replays recorded messages if the room is quiet or the network fails, and a recording of the whole run.
- Backup demo, if the room cannot take part: the same flow driven by pull requests in a public demo repo, each opening a preview environment and each close deleting it.

## Open points

- Time: the new chapter costs about eight minutes; the cut MCP chapter and research example give most of it back. Step 2 (shipping a tool) may go as well if the runtime chapter runs long.
- Terminology: slides follow the current naming (tenant cluster, control plane cluster, and the tenancy model named instead of "shared cluster").
- Framing: say "agents already call your platform's APIs", not "every company runs agents".
