# /safety-criteria — Embedded Safety Domain Reference

Reference and configuration skill for embedded safety-critical projects.

## Applicable standards
- MISRA-C:2012 (required rules mandatory by default, advisory rules configurable)
- IEC 61508 SIL2
- Polyspace Code Prover / Bug Finder

## Project configuration

Add to `gates.config` in your project root:

```bash
# Compilation (adjust for your toolchain)
compile=cmake --build build/ --config Release

# Test runner
test=ctest --test-dir build/ --output-on-failure

# Lint / static analysis
lint=cppcheck --enable=all --error-exitcode=1 src/

# Optional: Polyspace
polyspace=polyspace-bug-finder -sources src/ -report polyspace-report.txt

# Safety config
sil_level=SIL2
misra_advisory=excluded
```

## How the safety critique activates

When `embedded-safety` is installed alongside `orchestration-core`, the `/pipeline-code` command routes code artifacts through `critique-code-misra` instead of `critique-code`.

The MISRA critic extends the generic critic — all general review criteria still apply.

## Quick reference: SIL2 hard rules

| Rule | Description |
|------|-------------|
| No dynamic memory | No `malloc`, `calloc`, `realloc`, `free` |
| No recursion | No recursive function calls (direct or indirect) |
| Bounded loops | Every loop must have a statically provable bound |
| Checked returns | Every non-void function return must be checked |
| No UB | No signed overflow, OOB access, use-after-free |
