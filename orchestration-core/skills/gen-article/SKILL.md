# /gen-article — Generate a technical article draft

## Usage
`/gen-article <topic> [--audience <audience>] [--length <short|medium|long>]`

---

## What this does

Generates a technical article draft with all factual claims pre-marked for fact-checking, then routes it through `/pipeline-article`.

---

## Before writing — clarify first

If audience or length are not provided, ask:
- **Audience**: junior dev / senior dev / architect / manager / mixed?
- **Single core argument**: what should the reader believe or be able to do after reading?
- **Length**: short (~800w) / medium (~2000w) / long (~4000w)?

Do not proceed until these are clear.

---

## Article structure

```
articles/<slug>/draft.md
```

Structure:
1. **Hook** — why should this specific audience care, right now?
2. **Context** — what do they need to know before the core argument?
3. **Core** — the argument, with evidence and examples
4. **Takeaway** — one concrete thing the reader can do or decide

---

## Mandatory: source markers

Every factual claim that is:
- A specific number, percentage, or benchmark
- A comparative assertion ("X is faster than Y")
- A recent event or release (post-2023)

must be marked inline as:

```
[SOURCE_NEEDED: <what to search for to verify this>]
```

The article cannot pass the fact-checker without resolving every `[SOURCE_NEEDED]` marker. Write them as you draft — do not go back and add them later.

---

## Handoff
After writing the draft: "Draft written to `articles/<slug>/draft.md`. Launching `/pipeline-article`."
Then invoke `/pipeline-article articles/<slug>/draft.md`.
