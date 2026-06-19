# /gen-doc — Generate documentation for existing source code

## Usage
`/gen-doc <path to source> [--spec <path to spec>]`

---

## What this does

Generates documentation for a codebase, then routes it through `/pipeline-doc` for critique and gate validation.

---

## Process

### Step 1 — Read the source
Read all source files at the given path. Understand the public API surface: functions, classes, methods, parameters, return types, side effects.

### Step 2 — Read the glossary
If `spec/glossary.md` exists, read it. All domain terms in the documentation must use the canonical names from the glossary. Do not invent synonyms.

### Step 3 — Generate
Write documentation to `docs/<module-name>/`:

```
docs/<module>/
  index.md     — overview: what this module does, when to use it
  api.md       — function reference with one runnable example per public function
```

Rules for examples:
- Every example must be copy-paste runnable (include imports, setup)
- Use only functions that actually exist in the source
- Show at least one error case per non-trivial function

### Step 4 — Handoff
Say: "Documentation written to `docs/<module>/`. Launching `/pipeline-doc`."
Then invoke `/pipeline-doc <path to docs>`.
