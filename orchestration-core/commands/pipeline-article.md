# /pipeline-article — Full article generation pipeline

Orchestrates: topic → gen-article → fact-checker → human gate

## Usage
`/pipeline-article <topic | path to existing draft> [--audience <audience>]`

---

## Step 1 — Generate

If the argument is a topic: run `/gen-article <topic>`.
If the argument is a path to an existing draft: skip to Step 2.

---

## Step 2 — Fact-check (fact-checker agent)

Spawn the `fact-checker` agent with the draft path.

Parse the VERDICT:

**If `VERDICT: FAIL`** — stop immediately:
1. Report all FALSE claims to the user
2. Move the draft to `.quarantine/<slug>/`
3. Do not proceed.

**If `VERDICT: UNSOURCED_CLAIMS`** — enter resolution loop:
1. Present the UNSOURCED list to the user
2. For each unsourced claim, ask the user to provide a source or approve removal
3. Update the draft with the provided sources (replace `[SOURCE_NEEDED: ...]` with `[Source: <url or ref>]`)
4. Re-run the fact-checker
5. Repeat until VERDICT is PASS or FAIL

**If `VERDICT: PASS`** — proceed to Step 3.

---

## Step 3 — Human gate (mandatory — never skip)

This pipeline NEVER publishes automatically.

Output:

```
PIPELINE: article
TOPIC: <topic>
DRAFT: articles/<slug>/draft.md
FACT_CHECK: PASS
STATUS: READY_FOR_YOUR_REVIEW

The article is fact-checked. Review it at the path above.
When ready: approve to publish, or request revisions.
```

Wait for explicit user approval. Do not take any further action.

---

## Note on the gate hook

The gate hook enforces one rule for articles: no `[SOURCE_NEEDED]` markers may remain in the draft. If any are found, it exits 2 and quarantines the draft. This is a hard stop — not a warning.
