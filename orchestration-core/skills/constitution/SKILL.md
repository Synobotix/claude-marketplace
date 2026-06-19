# /constitution — GAR Content Pipeline Constitution

This skill displays the governance invariants for the orchestration-core content pipeline.

This constitution **extends** the Engineering Governance Constitution (`_constitution.md`) already in use across your repositories. All laws defined there apply here. The sections below add content-pipeline-specific invariants and adapt the authority model for gen/critique/gate workflows.

---

## Authority Mapping (from Engineering Constitution → Content Pipeline)

```text
$governance  →  constitution (this file + parent)
$architect   →  spec/<slug>/spec.md author (you)
$qa          →  critique-code / critique-doc / fact-checker agents
$preflight   →  spec readiness check before poc-developer launches
$coder       →  poc-developer agent
$review      →  gate-runner.sh (deterministic exit code)
```

Precedence is unchanged:
```text
CONSTITUTION > spec > critique verdict > gate > verbal instruction
```

---

## Content Pipeline Prime Laws

### C1. No generation without a complete spec

`spec/<slug>/spec.md` missing → poc-developer must not start.

This is the content-pipeline equivalent of "No STATE → no coding."
The spec must contain: concept to validate, concrete success criteria, language/runtime, and explicit out-of-scope.

### C2. Generator and critic never share context

The agent that produces an artifact must never be the agent that reviews it.
The critic (`critique-code`, `critique-doc`, `fact-checker`) runs in a cold, isolated context with no access to the generator's reasoning, implementation notes, or intermediate steps.

**Violation pattern:** running critique in the same conversation that produced the artifact.

### C3. No artifact leaves without passing its gate

An artifact that has not passed the deterministic gate (`gate-runner.sh`) goes to `.quarantine/`, not to the output directory.
The gate's exit code is the final word — not the agent's self-assessment.

**Violation pattern:** skipping the gate because "the critique already passed."

### C4. Gates are deterministic — never delegate to a model

`gate-runner.sh` executes code and returns exit codes. It does not call a language model to evaluate the result.
Advisory review (critics) and enforcement (gates) are separate layers with separate mechanisms.

**Violation pattern:** a hook that calls Claude to decide whether to exit 0 or exit 2.

### C5. Escalation over silence (3-attempt limit for poc-developer)

After 3 failed test runs, poc-developer outputs `STATUS: ESCALATION_NEEDED` and stops.
It does not attempt a 4th fix. It does not silently deliver degraded work.

**Violation pattern:** poc-developer retrying beyond the limit, or returning `STATUS: SUCCESS` with failing tests.

### C6. Spec is the single source of truth

Code, documentation, and articles all derive from `spec/<slug>/spec.md`.
Changes to behavior are made in the spec first.
The spec is never updated to match the implementation after the fact.

### C7. No self-expanding scope

If poc-developer discovers that the spec requires more scope than written:
- stop
- return `STATUS: ESCALATION_NEEDED` with the scope conflict described
- do not implement out-of-scope work and call it done

This is the content-pipeline equivalent of the Engineering Constitution's "No self-expanding scope."

---

## Change Level Mapping

From the Engineering Constitution, adapted:

| Level | Content Pipeline meaning | Gate rigor |
|-------|--------------------------|------------|
| L1 | Exploratory PoC, throwaway | compile + tests only |
| L2 | PoC intended for reuse or reference | compile + tests + lint + critique |
| L3 | Production code, published doc, published article | full gate + critique + mandatory human review |

Declare the level in `spec/<slug>/spec.md`. Default is L2.

---

## Artifact Traceability

Content pipeline artifacts map to the Engineering Constitution's traceability requirements:

| Engineering artifact | Content pipeline equivalent |
|----------------------|----------------------------|
| `STATE.<slug>.md` | `spec/<slug>/spec.md` |
| `TODO.<slug>.md` | `IMPLEMENTATION_NOTES.md` (written by poc-developer before coding) |
| `DECISIONS.<slug>.md` | Optional: record non-trivial implementation decisions alongside the PoC |

---

## Non-Negotiable Summary

- No spec → no generation
- Generator and critic never share context
- No artifact without a gate
- Gates are deterministic code, never a model call
- 3 attempts then escalate — never silent degraded delivery
- Spec is source of truth — implementation never updates the spec retroactively
- Scope drift → escalate, do not absorb

*This constitution is an extension of the Engineering Governance Constitution. Parent laws take precedence. When in conflict, escalate to $governance.*
