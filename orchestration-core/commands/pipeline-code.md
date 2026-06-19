# /pipeline-code — Full code generation pipeline

Orchestrates: spec → poc-developer → critique-code → gate

## Usage
`/pipeline-code <topic | path to spec>`

---

## Step 1 — Spec

If the argument is a topic (not a path to an existing `spec.md`):
- Run `/gen-code <topic>` first
- Wait for spec to be written to `spec/<slug>/spec.md`
- Continue with that spec path

If the argument is already a spec path, proceed directly.

---

## Step 2 — Generate (poc-developer agent)

Spawn the `poc-developer` agent with:
- The spec path
- Target output: `src/<slug>/` and `tests/<slug>/`

Parse the agent's STATUS from its output:

**If `STATUS: ESCALATION_NEEDED`** — stop the pipeline immediately:
1. Surface the full escalation report to the user verbatim
2. Highlight the `QUESTION_FOR_USER` field
3. Ask: "How would you like to proceed?"
4. Do NOT spawn critique-code. Do NOT run the gate.

**If `STATUS: SUCCESS`** — proceed to Step 3.

---

## Step 3 — Critique (critique-code agent)

Spawn the `critique-code` agent with:
- All files in `src/<slug>/` and `tests/<slug>/`
- **Do NOT include `IMPLEMENTATION_NOTES.md`** — the critic must not see the generator's reasoning

Parse the agent's VERDICT:

**If `VERDICT: FAIL`** — stop:
1. Report CRITICAL items to the user
2. Move the artifact to `.quarantine/<slug>/`
3. Ask: "Fix and re-run, or abandon?"

**If `VERDICT: PASS` or `PASS_WITH_NOTES`** — proceed to Step 4.
If PASS_WITH_NOTES, surface the notes to the user but do not block.

---

## Step 4 — Gate (automatic via hook)

The gate hook runs automatically on Stop. If it exits 2, the artifact is quarantined.

If the gate passes, the artifact stays in `src/<slug>/`.

---

## Step 5 — Summary

Output exactly:

```
PIPELINE: code
TOPIC: <topic>
SPEC: spec/<slug>/spec.md
DEVELOPER_ATTEMPTS: <n from poc-developer output>
CRITIQUE: <PASS | PASS_WITH_NOTES | FAIL>
GATE: <PASS | FAIL | SKIPPED>
STATUS: <SUCCESS | QUARANTINED | ESCALATED>
OUTPUT: <src/<slug>/ | .quarantine/<slug>/ | pending escalation>
```
