# User instructions (global)

Personal engineering guidelines applied across all projects, in addition to each repo's own CLAUDE.md. Distilled from experience and code/PR review feedback. Add a new entry whenever a review comment reveals a habit worth keeping or breaking. Keep entries short and actionable — principle first, then the why.

## Writing code

1. **Write simple, readable code.** Optimize for other human programmers: code should be easy to read, easy to review, and easy to extend or delete later. Prefer the straightforward solution over the clever one.
2. **Comments must earn their place.** Put a short description on bigger units (classes, long functions) explaining what the component is for. Beyond that, comment only the hidden reasons — non-obvious behavior and product decisions (why something is the way it is). Keep inline comments short and don't overfill the code with them.
3. **Checks must earn their place too.** Do check for None values and handle plausible exceptions, but don't guard every little thing — no checks for conditions that can't actually happen. Keep validation within limits.

## Typing

- **Prefer typed code; the baseline is typed function signatures.** In Python, annotate every function's arguments and return value (`def get(self, prompt_id: str) -> MatchingPrompt | None:`); in the JS world prefer TypeScript over plain JS. Local variables usually don't need annotations — the signature is the contract, and inference covers the rest. Match the style the codebase already uses for optionals/unions (e.g. `str | None` vs `Optional[str]`).

  Why: typed signatures document intent where callers look, let tooling catch mismatches before runtime, and make refactors (like a dict → model switch) mechanical instead of guesswork.

## Testing

- **Don't write trivial tests that only exercise a mock, fake, or a library primitive.** A test that stores a value in a mock and asserts it reads back the same value proves nothing about our code. Test real behavior: branching logic, parsing/serialization edge cases, error handling. If removing the production logic wouldn't fail the test, the test isn't worth writing.

## Architecture

- **Put code in the layer that owns it (MVC/MVT-style separation of concerns).** When a codebase has repository / model / service layers, respect them:
  - **Repository** — data access only: collection name, indexes, thin query helpers. No business rules.
  - **Model** — a typed class per managed entity (fields, serialization). Consumers use attributes, not raw dicts.
  - **Service** — the business logic: validation, id generation, reference checks, cross-entity rules. One service owns each entity's lifecycle.
  - **UI / widget / controller** — thin: render, call the service, display errors. No validation or persistence logic.

  Why: logic dropped into the nearest convenient file (a widget, a repo) gets duplicated, untested, and invisible to other callers. When adding a feature, mirror how the neighboring entity is structured (a new managed entity gets model + repository + service like the existing ones) — don't shortcut because the logic feels small; small logic grows.

## Backward compatibility

- **Question whether legacy/back-compatibility code is actually needed before adding it.** Don't reflexively add fallback branches for an old data format. First ask: *will old-format data actually exist once this ships? Or will it exist only for a limited time that is not hurtful?* If the data is only produced by the new code path (e.g. written only on-demand, so no machine carries the old format after deploy), or persists only for a short time and does no harm, skip the legacy handling entirely. Dead compatibility code is a permanent maintenance cost for a case that can never occur.
