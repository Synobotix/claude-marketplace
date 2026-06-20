# /pipeline-code — Full code generation pipeline

Orchestrates: spec → poc-developer → critique-code → [fix loop] → gate

## Usage
```
/pipeline-code <topic | path to spec>
/pipeline-code --explore <path to existing src> "<exploration directive>"
```

---

## Exploration mode (--explore)

When called with `--explore`:

1. Verify the path exists and contains code
2. Locate the original spec at `spec/<slug>/spec.md` if it exists (optional context)
3. Spawn `poc-developer` in **EXPLORATION MODE** with:
   - The existing code path
   - The spec path (if found)
   - The exploration directive (the quoted string)
4. On `STATUS: EXPLORATION_COMPLETE` → proceed to critique (Step 3) then gate (Step 4)
5. On `STATUS: DEAD_END` → surface the finding and suggestion to the user. Ask: "This direction is a dead end. Try a different angle, or abandon?"
6. On `STATUS: ESCALATION_NEEDED` → same as standard escalation

Exploration output goes to `src/<slug>/` (extends the existing files in place).

---

## Step 1 — Spec (standard mode only)

The spec is the single point of human control before full autonomy begins.
It is ALWAYS written collaboratively — never generated autonomously.

If the argument is already a path to an existing `spec.md`, proceed directly to Step 2.

If the argument is a topic:
1. Derive a slug from the topic (lowercase, hyphens, no spaces)
2. Use the AskUserQuestion tool with these 4 questions in a single call:
   - "Quel est l'objectif de ce PoC ?" (header: "Objectif") — options: suggest 2-3 plausible goals inferred from the topic + "Autre"
   - "Quelles sont les contraintes techniques ?" (header: "Contraintes") — options: infer likely stack from topic (e.g. Python, TypeScript, Rust) + "Autre"
   - "C'est quoi le critère de succès ?" (header: "Succès") — options: 2-3 concrete outcomes inferred from topic + "Autre"
   - "Qu'est-ce qui est hors périmètre ?" (header: "Hors scope") — options: 2-3 common exclusions for this type of PoC + "Autre"
3. Write `spec/<slug>/spec.md` from the answers. Structure:
   ```
   # <topic>
   ## Goal
   ## Constraints
   ## Definition of Done
   ## Out of scope
   ```
4. Show the spec to the user and use AskUserQuestion: "Cette spec est-elle correcte ?" with options "Oui, on y va" / "Non, à modifier" — do NOT proceed to Step 2 until the user selects "Oui, on y va".

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

### After 3 failed critique rounds — quarantine and restart from scratch

If the code still fails critique after 3 rounds:
1. Move the entire artifact to `.quarantine/<slug>/attempt-<attempt_number>/`
2. Increment the global attempt counter (`ATTEMPT_NUMBER`, starts at 1)
3. If `ATTEMPT_NUMBER <= 2` — **restart from scratch**:
   - Do NOT reuse any code from the quarantined attempt
   - Spawn `poc-developer` again in **initial mode** with the same spec
   - Reset `CRITIQUE_ROUND` to 1
   - Continue from Step 3a
4. If `ATTEMPT_NUMBER = 3` — the spec or concept itself may be the problem. Escalate:
   - Report the full failure history (3 complete attempts, each quarantined)
   - Ask the user: "Three full implementation attempts failed critique. The spec or the approach may need rethinking. How would you like to proceed?"
   - Stop. Do NOT run the gate.

**Total maximum attempts before escalation: 3 complete generation cycles × 3 critique rounds = 9 critique passes.**

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
