# Narrative: Your Platform Already Has AI Users

Draft for LLM Days Hamburg, rebuilt around one idea: agents are platform users, and the step after giving them keys to our systems is building systems for them. The MCP interface chapter and the research data example are cut. The runtime chapter is trimmed, and a new chapter contrasts retrofitting an agent onto a system built for people with a service built for the agent, delivered and fenced by the platform.

## Journey

- Problem the viewer recognizes: agents already call the APIs their developers call, and nobody designed the platform for them. Every team wires its AI tools up alone.
- Why the usual ways fall short: the usual answer is retrofitting. A bot account, an API key, and a CLI or MCP server over an API built for people. The agent holds the secret, polls for changes, improvises every time, and what it decided vanishes with the session.
- New understanding: build the system the agent operates from the first line for the agent, and let the platform deliver it and fence it. The agent's output stops being prose and becomes decisions the system keeps, tests and replays.
- How each discovery motivates the next: the shift raises the problem; platform engineering answers it with paved roads; roads need walls between teams; once the walls exist, the question is how an agent should use the roads; the usual answer, a key, is retrofitting; the alternative is a service built for the agent, shipped on the same roads.
- What the viewer can do at the end: tell a retrofitted agent from a system built for one, design one internal service with the agent as its primary operator, and deliver it with the platform they already run.
- So what: agents are already users, and retrofitting them onto systems built for people keeps every team in ad hoc AI plumbing. Now what: pick one stream of work, build a service the agent operates, and ship it as a platform service. Then what: give the agent goals instead of tickets, and let it build and reshape the system that serves them, with the platform fencing what it may reach.

## Subject and example

Subject: the next platform service is one built for agents to operate, not one agents are given keys to. Example: Intake, an agent-native event processing and workflow environment whose primary operator is an agent. The agent gets goals, and from them builds and reshapes the rules, actions and routing while events flow. It is delivered into a tenant cluster on vCluster Platform, which fences what it may reach. The example serves the subject; the demo is a live case of it.

## Narration

1. Your platform already has AI users. Agents call the same APIs your developers do, and most platforms do not know it yet.
2. Developers and agents differ where it matters: an agent's bottleneck is its context window, it remembers nothing between sessions unless something keeps it, and it acts at machine speed.
3. Teams across the company now ship AI tools and agents. Each needs a place to run, credentials, and limits on what it reaches; without shared guardrails each team solves that alone, and the platform team becomes a ticket queue.
4. Platform engineering has answered this before with paved roads: a team brings its tool, the platform provides the runtime and the guardrails around it, and roads fork by risk.
5. Agents bring needs a platform built for people never had to meet: authority of their own, containment of what they reach, events instead of polling, memory the platform keeps, context delivered pre-filtered, and tests for manipulation.
6. The runtime: every team gets a tenant cluster of its own on one control plane cluster, with full freedom inside and walls between teams. Every tenant cluster inherits the same baseline, and the team writes none of it; an unsafe tool is refused before it starts.
7. The question that follows: the roads work for people. How should an agent use them?
8. The usual answer is a bot account, an API key, and a CLI or an MCP server over the same API people use. That is retrofitting: the agent drives a system built for people. It holds the secret, polls for what changed, works everything out again each session, and what it decided is gone when the session ends. Everybody does this, and it works, the way a robot arm can type on a keyboard.
9. The other answer is to build the system the agent operates from the first line for the agent, and let the platform deliver it and fence it. The agent never touches the platform's API. It operates its own system, and that system's edge holds the credentials and walks the roads.
10. I built one: an event processing and workflow environment whose primary operator is an agent. Events arrive pushed, already in one shape. The agent gets no dashboard. It gets goals, typed config, a command line and a brief that fits its context. From a goal it builds chains: rules, small programs, a decision model where meaning is ambiguous, a language model step, and agents, itself included, wherever the goal needs judgement. Every change is checked before the system keeps it, carries the agent's name and reason, can be replayed against recent events, and is live on the next event.
11. Its measure is not how rarely it calls the agent. It is how fast the system follows a changed goal, how correct it stays, and whether it keeps up with the load. When the goal, a compliance rule or the load changes, the agent reshapes the rules, the actions and the routing while events keep flowing.
12. And it ships the way every platform service ships: as a Stack. One request gives a team a tenant cluster with the engine, its event bus and its adapters, and a live view linked from the Stack's card. The platform fences it like any tenant: the engine holds a scoped identity of its own, may request only from templates, and has a quota.
13. Seen from the engine, tenant clusters are its periphery, in three ways. They are its home: the engine runs in one. They are its targets: an action creates a Stack in one, retries a task, or puts one to sleep. They are its sources: a Stack's phase, a quota refusal, a refused workload, all come back as events. Every change the engine makes on a tenant cluster produces the next event, so the loop closes through the platform.
14. Demo. The system starts empty: one default rule that hands every event to the agent, and one action that writes a note to the team. Nothing else exists. The agent gets one goal in a sentence: discover the events this team's tenant cluster produces and process them for the highest security.
15. A team deploys a workload that breaks the tenant cluster's security baseline. The tenant cluster refuses it, and the refusals arrive as events. The agent reads them, writes an action that tells the team the exact fix, and a rule that sends the next refusal straight to that action. The rule, its commit and its reason are on screen, and the next refusal goes through them.
16. Then the goal changes, in one sentence: security is loosened for this team, developer speed comes first. The agent reshapes what it built. The note now leads with the quickest way to unblock the developer, and every change carries its reason. Nobody opened a policy editor.
17. The worry follows. The agent writes code that calls APIs, other agents and its own tools, and the system keeps running that code after the agent's session ends. If someone talks the agent into something through an event, the bad action does not happen once: it stays, and runs on every event that matches.
18. The answer is the deal platforms already give teams: treat the agent as an untrusted tenant. The agent can run anywhere, on a laptop or as a managed agent in the cloud, and it holds one credential, access to its own tenant cluster. Inside, it has full freedom: it writes any code, adds workflows and scales its own processing, and nobody approves each change.
19. The fence is set by the platform, outside the agent's reach: outbound traffic blocked except for an allowlist, a quota, a runtime built for untrusted code, narrow and short-lived secrets, an audit trail, and a switch that stops everything. The goal is a record only its owner can write, so no event can change what the agent is for. Assume the agent knows everything inside the fence; the fence decides what that knowledge can reach.
20. What just happened is a golden path written by its user. A platform team writes Stacks and policies for people; here the agent built its own path from a goal and rebuilt it when the goal changed, and the system checked, journaled and kept every step. A static policy engine is written, changed and tested by people; this one is operated by the agent it serves.
21. Platform maturity applies to agents too. Most teams are scalable for developers and provisional for agents: their agents are retrofitted with keys. At the top level, agents operate systems built for them, from goals, inside walls the platform keeps.
22. Takeaways: agents are platform users; stop at retrofitting and they stay guests in systems built for people; build services agents operate, and give the agent goals to build and reshape them; treat the agent as an untrusted tenant, with full freedom inside and the platform's walls outside. Start with one stream of events and one goal.

## Moment lines

- "The Shift" divider: the viewer meets the claim and the chapter map.
- "Two Kinds of Platform Users": the viewer asks how an agent differs from a developer; the table answers.
- "Without Shared Guardrails": the viewer recognizes the ticket queue and the drift.
- "What a Paved Road Is" and "Roads by Risk Class": the viewer asks how platform engineering answers it.
- "What Agents Need From the Platform": the viewer now knows roads; the slide lists what agents need beyond them. This list returns in the comparison slide.
- "Isolating Teams" and "The Contract": the viewer asks how teams are kept apart; tenant clusters and the inherited baseline answer. "An Unsafe Tool Is Refused" runs live, and that refusal is the event the demo starts from.
- "The Agent as a User" divider: after the refusal, the viewer asks how an agent should use the same roads.
- "A Key to a System Built for People": the usual answer as a picture, the agent with a key and a CLI or MCP server in front of an API built for people; the viewer recognizes their own setup.
- "Retrofitted or Built for the Agent": the needs list from earlier as rows, two columns: who holds the credentials, how changes arrive, where memory lives, what the agent produces, who reshapes the system, what stops a bad change.
- "A System Its Agent Operates": a role diagram. The agent talks only to the engine, through goals, config and a command line; the engine's edge talks to the event sources and the platform. No hosts.
- "Measured by Adapting": the viewer asks what success means if not fewer model calls; the slide names the three measures, following a changed goal, staying correct, keeping up with load.
- "Shipped as a Stack": the viewer asks how another team would get this; the real StackTemplate and the Stack card with its outputs.
- "The Engine and Its Periphery": a ring with the engine at the center and tenant clusters on the rim as home, target and source, arrows out for actions and in for events.
- "An Empty System and a Goal": the empty rules folder and the goal sentence; beats 14 and 15 run on it, and the agent's rule and action appear as real files with their commit.
- "The Goal Changes": the new goal sentence beside the diff the agent made; beat 16.
- "Injection Becomes Persistence": the viewer's worry, drawn: an event talks the agent into an action, and the action keeps running on every matching event after the session ends.
- "The Agent as an Untrusted Tenant": the agent anywhere, one credential, its tenant cluster with full freedom inside; around it the fence the platform sets (allowlist, quota, runtime, secrets, audit, stop switch), each item the real setting of the tenant cluster. Beats 18 and 19.
- "A Golden Path Its User Wrote": the rule the agent wrote, shown as the real file, beside a policy a person wrote; same shape, different author.
- "Agent Platform Maturity" and "Takeaways": the viewer asks where to start.

## Demo design

- Built and run once (operator-demo/): a local kind cluster with the team's tenant cluster under the restricted security baseline, an adapter that turns the tenant cluster's warning events into events on a local NATS stream, the engine in push mode, and the demo agent with its own folder, constitution and goal file. A workload that breaks the baseline produces the refusals. The agent wrote its first action and rule in about 90 seconds, the next refusal went through them, and a goal change made it reshape the action and keep the rule with its reason.
- The agent owns only its own system: its folder points every shell it opens at the demo's rules and actions, and every change is signed with its name. In the talk version that boundary is the tenant cluster the engine runs in.
- The fence for the talk: the engine, its event bus and every action run in the agent's tenant cluster, actions as pods. The agent holds only that tenant cluster's credential. The tenant cluster runs the restricted security baseline, a quota and a limit range (as the demo's tenant cluster already does), outbound traffic denied except for the allowlist (the compliance agent, the team's notification hook), and secrets synced in narrow. The goal is a record the agent may read and only the owner may write.
- A possible fence moment: play a compromised agent by installing an action that tries to send data out. The network policy refuses it, the refusal arrives as an event, and the journal shows who added the action and when. Not a live injection of the model, which is unreliable on stage.
- To build for the talk: the engine as a StackTemplate into its own tenant cluster (NATS, the engine, the adapter), a live view of events, chains and the agent's changes linked from the Stack card, and the goal change driven from the stage.
- Screen: the agent's pane, the rules folder and its git log, and the live view.
- Safety: the agent holds no platform key; the engine acts only through templates under its quota; model budgets are capped.
- Fallbacks: a recording of the whole run, and the same flow replayed from recorded events if the tenant cluster misbehaves.

## Open points

- Scope: must have for Hamburg are the engine and its StackTemplate, the adapter, the demo agent and the live view. The live view is the first thing to drop if time runs short (the rules folder and its git log carry the story).
- Time: the new chapter costs about eight minutes; the cut MCP chapter and research example give most of it back.
- Terminology: slides follow the current naming (tenant cluster, control plane cluster, and the tenancy model named instead of "shared cluster").
- Framing: say "agents already call your platform's APIs", not "every company runs agents". Do not present fewer model calls as the point.
- The fence holds only if the agent's own runtime is confined too: an agent with a shell and every file on a laptop does not need the engine to do damage. On stage the agent's whole world is one credential, which a managed agent in the cloud gives naturally.
- An allowlist by host name needs more than a plain network policy, which matches address ranges: a network plugin with host name rules, or an egress proxy.
- To build: the engine, its bus and its actions as a StackTemplate in a tenant cluster, actions as pods, and control through the tenant cluster's API.
