# Narrative: Your Platform Already Has AI Users

Draft for LLM Days Hamburg. It keeps the deck's four chapters and adds a fifth, "the operator", before next steps. The new beats are marked NEW; the rest restate what the deck already says, so the whole talk can be read as one story.

## Journey

- Problem the viewer recognizes: agents already call the APIs their developers call, and every team wires its AI tools up alone, with its own keys, its own isolation and its own rules.
- Why the usual ways fall short: tickets make the platform team the bottleneck, and per-team solutions drift. Handing agents tools (MCP) solves how they reach a service, not who runs the service or what it keeps between sessions.
- New understanding: agents are platform users with their own needs (context budget, no memory, authority, containment, testing). A platform can serve them twice: as a paved road for the AI tools teams ship, and as services built for agents to operate.
- How each discovery motivates the next: the shift raises the problem; platform engineering answers it with paved roads; roads need a runtime with walls; the runtime needs an interface agents can call; once agents call services, the next question is what a service looks like when an agent is the one running it.
- What the viewer can do at the end: put a team's AI tool on a paved road by risk class, and design one internal service with the agent as its primary operator.
- So what: agents are already users, so a platform that ignores them pushes every team into ad hoc AI plumbing. Now what: start with one road and one real tool. Then what: build a service an agent operates, where the agent's decisions become rules the platform keeps, tests and replays.

## Subject and example

Subject: platforms now have agent users, so build for them twice: paved roads for the AI tools teams ship, and services designed from the first line for agents to operate. Examples: the docs MCP server on a team's isolated cluster (chapters 2 to 4), and the event intake engine an agent runs on the presenter's behalf (chapter 5). The examples serve the subject; neither is the product being sold.

## Narration

1. Your platform already has AI users. Agents call the same APIs your developers do, and most platforms don't know it yet.
2. Developers and agents differ where it matters: an agent's bottleneck is its context window, it remembers nothing between sessions unless something keeps it, and its cost is tokens.
3. Teams across the company now ship AI tools: docs servers, retrieval over company data, agents that act on other systems. Each needs a place to run, credentials, and limits on what it reaches.
4. Without shared guardrails, each team solves isolation and data access alone. The platform team becomes a ticket queue, and the rules drift team by team.
5. Platform engineering has answered this before with paved roads: a team brings its tool, the platform provides the runtime and the guardrails around it.
6. Roads fork by risk. A read-only docs server and an agent with write access do not get the same road.
7. Agents bring needs a human platform never had to meet: context delivered pre-filtered, memory the platform keeps, authority of their own, containment of what they read, and tests for manipulation.
8. The runtime: every team gets a cluster of its own on shared machines, with full freedom inside and walls between teams.
9. Every runtime on the road inherits the same baseline, and the team writes none of it. The demo shows a team cluster, a tool shipped onto it, and an unsafe tool refused.
10. The interface: MCP is a standard plug, so any assistant can call the tool the team shipped. Another team asks in plain English and gets a valid config back.
11. NEW. So far the agent is a guest: it calls a tool a team built, and a human decided what that tool does. The next question is what changes when the agent is the one running a service, every day.
12. NEW. I run one. Every event that reaches me, from chat, code review, mail and alerts, goes through one engine, and an agent operates it on my behalf. It was not built for me to click through; it was built for the agent from the first line.
13. NEW. Built for the agent means the needs from beat 7 are met by design. Context arrives as a brief sized to the agent's budget. Memory is the rules themselves, so what the agent learned survives a restart or a new model. Authority is the agent's name on every change. Rules need no approval because they are data: checked, logged, committed and reversible. Programs a rule runs are code with the machine's own logins, so they are the part a person reviews, and in this setup that review is still a habit, not a gate. Containment is one typed event shape at the edge, so no feed can smuggle fields in. Testing is a dry run against recent real events before any rule is written.
14. NEW. Demo, from the agent's side: the brief it reads when it starts, an event tested against the rules, a rule change previewed against the last day of events, and the history of rules the agent wrote, each with its reason.
15. NEW. The engine climbs a ladder: rules first, a cheap model only for what rules cannot decide, the agent only for what is left. When the agent handles the same kind of event by hand twice, it writes a rule, so the expensive rung keeps shrinking. The output is not prose or code; it is a decision the platform keeps and can replay.
16. NEW. This is the paved road again, with the agent as the user: a golden path of verbs and a skill, guardrails that refuse a bad rule, a shadow mode before anything goes live, and words that can never be dropped. The platform keeps the standards; the agent does the work.
17. Next steps: platform maturity applies to agents too. Most teams are scalable for developers and provisional for agents; at the top level, agents earn wider permissions, the way a shadow rule earns live.
18. Takeaways: teams ship AI tools on runtimes the platform defines; roads fork by risk; agents are platform users, so serve them tools, context and memory; and build services agents operate, not only tools they call. Start with one road and one real tool.

## Moment lines for the new chapter

- Chapter divider "the operator": after the MCP demo the viewer asks what comes after giving agents tools. The journey map shows a fifth stop.
- Beat 11 to 12, "An Agent Runs This Service": the viewer has seen agents as callers; the slide shows the inverse, a service whose operator is an agent, as a role diagram (event sources, the engine, the agent, the human), no hosts.
- Beat 13, "Agent Needs, Met by Design": the viewer just heard the needs list in chapter 2; the slide puts each need beside the mechanism that meets it, so the earlier slide pays off.
- Beat 14, "What the Agent Sees": the viewer wants proof it is real; the slide runs the real commands on a demo event log with made-up sources (the brief, a test, a previewed change, the rule history).
- Beat 15, "Decisions the Platform Keeps": the viewer wonders about cost and drift; the slide shows the ladder and one rule the agent wrote after handling an event twice.
- Beat 16 folds into the Takeaways slide: one new line, "Build services agents operate, not only tools they call."

## Open points for the presenter

- Demo data: the live engine holds private chat, mail and customer text, so the demo runs against a fixture log with made-up sources. The engine reads every path from environment variables, so a fixture needs no code change.
- Time: the new chapter costs about five minutes. Candidates to trim: "Example: Research Data Agents", or merge "AI Tools Across Teams" with "Without Shared Guardrails".
- Chapter map: journey.sh gains "the operator: built for agents" as chapter 5, and "next steps" moves to 6.
