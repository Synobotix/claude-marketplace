# /pipeline-code — Full code generation pipeline

Orchestrates: spec → poc-developer → critique-code → [fix loop] → gate

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
4. Do NOT proceed further.

**If `STATUS: SUCCESS`** — proceed to Step 3.

---

## Step 3 — Critique + Fix loop

This loop runs at most **3 times** (initial critique + 2 correction rounds).
Track the round number: `CRITIQUE_ROUND = 1`.

### Each round:

**3a — Critique (critique-code agent)**

Spawn `critique-code` with:
- All files in `src/<slug>/` and `tests/<slug>/`
- **Never include `IMPLEMENTATION_NOTES.md`** — cold context must stay cold

**If `VERDICT: PASS` or `PASS_WITH_NOTES`:**
- Surface any NOTES to the user (advisory, non-blocking)
- Proceed to Step 4 (gate)

**If `VERDICT: FAIL`:**
- Check `CRITIQUE_ROUND`
- If `CRITIQUE_ROUND < 3` → go to Step 3b
- If `CRITIQUE_ROUND = 3` → stop, quarantine, escalate (see below)

**3b — Correction (poc-developer agent, correction mode)**

Spawn `poc-developer` in **CORRECTION MODE** with:
- The spec path (contract is unchanged)
- The current code files in `src/<slug>/` and `tests/<slug>/`
- The full critique output (CRITICAL items, NOTES)
- Instruction: **fix the reported issues, do not rewrite from scratch**

Increment `CRITIQUE_ROUND`.
Go back to Step 3a.

### Escalation after 3 critique rounds

If the code still fails critique after 3 rounds:
1. Move the artifact to `.quarantine/<slug>/round-<n>/`
2. Report to the user:
   - All CRITICAL items that remain unresolved
   - The history of correction attempts
3. Ask: "The code failed critique after 3 correction rounds. How would you like to proceed?"
4. Do NOT run the gate on a failing artifact.

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
DEVELOPER_ATTEMPTS: <n from initial poc-developer>
CRITIQUE_ROUNDS: <n>
CRITIQUE: <PASS | PASS_WITH_NOTES | FAIL>
GATE: <PASS | FAIL | SKIPPED>
STATUS: <SUCCESS | QUARANTINED | ESCALATED>
OUTPUT: <src/<slug>/ | .quarantine/<slug>/ | pending escalation>
```
