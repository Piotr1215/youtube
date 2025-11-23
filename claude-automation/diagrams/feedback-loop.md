# Feedback Loop Diagram Options

## Option 1: Mermaid Flowchart

```mermaid
graph LR
    A[Claude Acts] --> B{Good or Bad?}
    B -->|Good| C[Praise]
    B -->|Bad| D[Strike]
    C --> E[Review Report]
    D --> E
    E --> F[Update System Prompt]
    F --> G[Claude Learns]
    G --> A
```

## Option 2: ASCII Art

```
   ┌─────────────┐
   │ Claude Acts │
   └──────┬──────┘
          │
      Good/Bad?
          │
    ┌─────┴─────┐
    │           │
 Praise      Strike
    │           │
    └─────┬─────┘
          │
   Review Report
          │
  Update Prompts
          │
   Claude Learns
          │
          └──────> Loop back
```

## Option 3: Simple Flow

```
Claude → Observe → Praise/Strike → Report → Update → Improve
   ↑                                                      │
   └──────────────────────────────────────────────────────┘
```
