# Synobotix Marketplace

Plugin marketplace for the gen/critique/gate orchestration system.

## Plugins

- **orchestration-core** — Core pipeline (poc-developer, critics, gates). Install on every project.
- **embedded-safety** — MISRA/Polyspace/SIL2 criteria. Install on embedded projects only, after orchestration-core.

## Installation

```bash
# Register this marketplace (once per machine)
/plugin marketplace add Synobotix/synobotix-marketplace

# Install on any project
/plugin install orchestration-core@synobotix

# Also install for embedded projects
/plugin install embedded-safety@synobotix
```

## Invariants (GAR constitution)

1. Generator and critic never share context
2. No artifact without a gate — quarantine before merge
3. `spec/` is the single source of truth
4. Gates are deterministic — never delegate to a model
5. Escalation over silence after N failed attempts
