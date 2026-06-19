# /gen-code — Prepare spec and launch autonomous PoC generation

## Usage
`/gen-code <topic or path to existing spec>`

---

## What this does

1. **If given a topic** (not a file path): draft a minimal spec interactively
2. **If given a spec path**: validate it has the required fields, then hand off

The spec becomes the contract for the `poc-developer` agent. Everything the agent produces must satisfy it.

---

## Spec drafting (when no spec exists)

Ask the user for any missing information:
- What concept are we validating?
- What does "it works" look like concretely?
- Language and runtime (Python 3.x, Node 20, C99, etc.)?
- What is explicitly out of scope?

Then write to `spec/<slug>/spec.md`:

```markdown
# PoC Spec: <topic>

## Concept to validate
<one sentence — what hypothesis does this PoC prove or disprove>

## Success criteria
- [ ] <concrete, runnable test criterion>
- [ ] <concrete, runnable test criterion>

## Constraints
- Language: <language + version>
- Runtime: <environment>
- Out of scope: <explicit exclusions>

## Minimal scope
<the smallest thing that proves the concept — resist scope creep>
```

---

## Handoff

After writing the spec, say:

> Spec written to `spec/<slug>/spec.md`. Launching `/pipeline-code spec/<slug>/spec.md`.

Then invoke `/pipeline-code` with the spec path.
