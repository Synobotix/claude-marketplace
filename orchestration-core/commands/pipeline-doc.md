# /pipeline-doc — Full documentation generation pipeline

Orchestrates: source → gen-doc → critique-doc → gate

## Usage
`/pipeline-doc <path to source> [--spec <spec path>]`

---

## Step 1 — Generate

Run `/gen-doc <path>` to produce documentation in `docs/<module>/`.
If a spec path is provided, pass it along for glossary reference.

---

## Step 2 — Critique (critique-doc agent)

Spawn the `critique-doc` agent with:
- The generated doc files (`docs/<module>/`)
- The source files they document

The critic will use Context7 to verify external API references.

Parse the VERDICT:

**If `VERDICT: FAIL`** — stop:
1. Report CRITICAL items to the user
2. Move the docs to `.quarantine/<module>/`

**If `VERDICT: PASS_WITH_NOTES`** — surface the notes, continue.
**If `VERDICT: PASS`** — proceed.

**If `API_CHECKS` contains MISMATCH** — always surface these to the user, even on PASS, because they indicate documentation drift.

---

## Step 3 — Gate (automatic via hook)

The gate validates:
- All code examples in the docs are syntactically valid
- Terminology matches `spec/glossary.md` if it exists

Exit 2 → quarantine.

---

## Step 4 — Summary

```
PIPELINE: doc
SOURCE: <path>
CRITIQUE: <verdict>
API_CHECKS: <OK | MISMATCH — library list>
GATE: <PASS | FAIL>
STATUS: <SUCCESS | QUARANTINED>
OUTPUT: <docs/<module>/ | .quarantine/>
```
