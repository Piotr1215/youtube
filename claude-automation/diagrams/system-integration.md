# System Integration Diagram

## Option 1: Mermaid Graph

```mermaid
graph TB
    subgraph "Session Start"
        A[direnv detects project]
        B[Load system prompt]
        C[Run session hook]
        D[Inject git history]
        E[Inject tasks]
    end

    subgraph "User Prompt"
        F[Prompt submit hook]
        G[Skill activation]
        H[Domain expertise]
    end

    subgraph "After Work"
        I[Observe behavior]
        J[Praise/Strike]
        K[Update prompts]
    end

    A --> B --> C
    C --> D --> E
    E --> F
    F --> G --> H
    H --> I --> J --> K
    K -.feedback.-> B
```

## Option 2: Layered View

```
┌─────────────────────────────────────────┐
│        SESSION LAYER                    │
│  direnv → prompts → hooks → context     │
└─────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────┐
│        EXECUTION LAYER                  │
│  user prompt → skill eval → activate    │
└─────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────┐
│        FEEDBACK LAYER                   │
│  observe → praise/strike → improve      │
└─────────────────────────────────────────┘
           ↑
           └──────── continuous loop
```

## Option 3: Timeline View

```
TIME →

Session Start    Prompt Submit      Post-Action
     │                │                  │
   direnv          evaluate            observe
     │                │                  │
   prompts         activate          praise/strike
     │                │                  │
   hooks             act              improve
     │                │                  │
  context         complete           update prompts
                                          │
                                     (next session)
```
