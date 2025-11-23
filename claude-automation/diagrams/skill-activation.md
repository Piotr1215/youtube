# Skill Activation Sequence Diagrams

## Option 1: Mermaid Sequence

```mermaid
sequenceDiagram
    User->>Hook: Submit prompt
    Hook->>Skills: Evaluate all skills
    Skills->>Hook: Match: presenterm-writer
    Hook->>Claude: Activate skill
    Claude->>User: Act with expertise
```

## Option 2: State Machine

```mermaid
stateDiagram-v2
    [*] --> Evaluate
    Evaluate --> Activate: Skills match
    Evaluate --> Skip: No match
    Activate --> Act
    Act --> [*]
    Skip --> Act
```

## Option 3: Simple Steps

```
┌──────────┐    ┌──────────┐    ┌──────┐
│ EVALUATE │ -> │ ACTIVATE │ -> │ ACT  │
└──────────┘    └──────────┘    └──────┘
     ↓               ↓              ↓
  Check all     Load skills   Use expertise
   skills        needed
```
