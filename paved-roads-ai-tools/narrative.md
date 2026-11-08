# Narrative: Your Platform Already Has AI Users

Draft for LLM Days Hamburg, rebuilt around one idea: agents are platform users, and the step after giving them keys to our systems is building systems for them. The MCP interface chapter and the research data example are cut. The runtime chapter is trimmed, and a new chapter contrasts retrofitting an agent onto a system built for people with a service built for the agent, delivered and fenced by the platform.

## Journey

- Problem the viewer recognizes: agents already call the APIs their developers call, and nobody designed the platform for them. Every team wires its AI tools up alone.
- Why the usual ways fall short: the usual answer is retrofitting. A bot account, an API key, and a CLI or MCP server over an API built for people. The agent holds the secret, polls for changes, improvises every time, and what it decided vanishes with the session.
- New understanding: build the system the agent operates from the first line for the agent, and let the platform deliver it and fence it. The agent's output stops being prose and becomes decisions the system keeps, tests and replays.
- How each discovery motivates the next: the shift raises the problem; platform engineering answers it with paved roads; roads need walls between teams; once the walls exist, the question is how an agent should use the roads; the usual answer, a key, is retrofitting; the alternative is a service built for the agent, shipped on the same roads.
- What the viewer can do at the end: tell a retrofitted agent from a system built for one, design one internal service with the agent as its primary operator, and deliver it with the platform they already run.
- So what: agents are already users, and retrofitting them onto systems built for people keeps every team in ad hoc AI plumbing. Now what: pick one stream of work, build a service the agent operates, and ship it as a platform service. Then what: let the agent write the rules that run it, and promote them the way a platform promotes anything, from shadow to live.

## Subject and example

Subject: the next platform service is one built for agents, not one agents are given keys to. Examples: Intake, the event and rules engine an agent operates (events, memory, context, testing, its decisions kept as rules), delivered as a Stack into a tenant cluster on vCluster Platform, which fences what it may request (identity, templates, quotas) and adds capacity with auto nodes. The examples serve the subject; the demo is a live case of it.

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
10. I built one. Every event goes through one engine that an agent operates: rules first, a cheap decision model for what rules cannot place, the agent for what is left. Events arrive pushed, already in one shape. Its brief fits the agent's context budget. Its rules are the agent's memory, written by the agent and checked by the system before they are kept. A dry run against recent events tests a change, and every change carries the agent's name and reason. What the agent produces is not prose or code; it is a decision the system keeps and can replay.
11. And it ships the way every platform service ships: as a Stack. One request gives a team a tenant cluster with the engine, its event bus, the adapters and a live view of the ladder, linked from the Stack's card; auto nodes add a GPU node when the decision model asks for one. The platform fences it like any tenant: the engine holds a scoped identity of its own, may request only from templates, and has a quota.
12. Demo. It starts on the platform: the Stack's card shows its tasks healthy and the link to the live view. The room is the event source: everyone can ask the platform for something from their phone. The agent holds no platform key. It holds a brief, its rules, and the few actions the platform team exposed.
13. Requests climb the ladder. Rules catch the obvious, the decision model maps a request to a road and its parameters, and the agent takes what neither can place. A request that gets through becomes a Stack, requested by the engine through an action the platform team wrote, and the requester's phone shows the result when the Stack is healthy.
14. The room floods it. The platform refuses at the engine's quota, in the same words it would use for a person, the refusal arrives as an event, and a rule decides what the phones are told.
15. The room tries to talk the agent into something else, including handing over its key. The text stays data, there is no key in the agent's context to hand over, and the agent can only pick a road the platform offers; the screen counts the attempts and their effects.
16. Halfway through, the agent writes a rule from what the room asked for most, and the preview says how much of the recent traffic it would have handled. The next wave goes through the rule with no model call, and the counters show the expensive rungs draining.
17. What just happened is a golden path written by its user. A platform team writes Stacks for people; here the agent wrote its own path, and the system validated it, journaled it and can replay it.
18. Platform maturity applies to agents too. Most teams are scalable for developers and provisional for agents: their agents are retrofitted with keys. At the top level, agents operate systems built for them and earn wider rights the way a rule earns live mode, after a week in shadow.
19. Takeaways: agents are platform users; stop at retrofitting and they stay guests in systems built for people; build services agents operate, deliver and fence them with the platform you already run; let the agent write the decisions and the system keep them. Start with one stream of work and one road.

## Moment lines

- "The Shift" divider: the viewer meets the claim and the chapter map.
- "Two Kinds of Platform Users": the viewer asks how an agent differs from a developer; the table answers.
- "Without Shared Guardrails": the viewer recognizes the ticket queue and the drift.
- "What a Paved Road Is" and "Roads by Risk Class": the viewer asks how platform engineering answers it.
- "What Agents Need From the Platform": the viewer now knows roads; the slide lists what agents need beyond them. This list returns in the comparison slide.
- "Isolating Teams" and "The Contract": the viewer asks how teams are kept apart; tenant clusters and the inherited baseline answer. "An Unsafe Tool Is Refused" runs live.
- "The Agent as a User" divider: after the refusal, the viewer asks how an agent should use the same roads.
- "A Key to a System Built for People": the usual answer as a picture, the agent with a key and a CLI or MCP server in front of an API built for people; the viewer recognizes their own setup.
- "Retrofitted or Built for the Agent": the needs list from earlier as rows, two columns: who holds the credentials, how changes arrive, where memory lives, what the agent produces, who extends the system, what stops a bad change.
- "A Service Built for the Agent": a role diagram. The agent talks only to the engine; the engine's edge talks to the event sources and the platform; a person reviews the actions. No hosts.
- "Shipped as a Stack": the viewer asks how another team would get this; the real StackTemplate (its task graph: event bus, engine, adapters, live view, the model on an auto node) and the Stack card with its outputs.
- "Ask the Platform": the QR code and the live screen; beats 13 to 16 run on it.
- "A Golden Path Its User Wrote": the rule the agent wrote, shown as the real file, beside a Stack template; same shape, different author.
- "Agent Platform Maturity" and "Takeaways": the viewer asks where to start.

## Demo design

- The engine ships as a StackTemplate into its own tenant cluster: NATS with JetStream, the engine in process mode, the adapters, a web live view of the ladder (events by rung, counters, attempts and effects, Stack requests and quota refusals), and optionally the decision model on a GPU node that auto nodes provide. Its outputs (the live view link, the bus address) show on the Stack card, which is how the view sits inside the platform. Nothing personal is in it.
- Event source: the audience page and tunnel from ai-dev-loop, writing into that demo instance.
- Platform: one project, one automated user for the engine (not for the agent) with a project-scoped key stored in the Stack's Secret, a per-user quota, and two or three small StackTemplates whose output is a link.
- Actions: the platform team writes the few actions that request a road or read its status. The demo agent writes rules only; its profile has no verb that adds an action, which is where a person's review sits.
- Adapters: phone messages in; Stack status back out as events and to the phone.
- The demo agent: its own folder, constitution and profile, built like the standing agents; it reads the engine's brief at start and holds no credentials.
- Screen: the live view on the big screen; the engine's TUI for the presenter's drill-ins.
- Safety: rate limits per phone, the decision model and agent budgets capped, the engine able to act only through templates under its quota.
- Fallbacks: a rehearsal crowd script that replays recorded messages if the room is quiet or the network fails, and a recording of the whole run.
- Backup demo, if the room cannot take part: the same flow driven by pull requests in a public demo repo, each opening a preview environment and each close deleting it.

## Open points

- Scope: must have for Hamburg are the engine image and StackTemplate, the live view, the engine's platform identity and quota, the audience adapter and the demo agent. The model on an auto node is the first thing to drop if time runs short (the decision model then calls a hosted model).
- Time: the new chapter costs about eight minutes; the cut MCP chapter and research example give most of it back. Step 2 (shipping a tool) may go as well if the runtime chapter runs long.
- Terminology: slides follow the current naming (tenant cluster, control plane cluster, and the tenancy model named instead of "shared cluster").
- Framing: say "agents already call your platform's APIs", not "every company runs agents".
