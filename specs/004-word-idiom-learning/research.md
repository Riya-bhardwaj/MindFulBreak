# Research: Word / Idiom Learning Section

**Branch**: `004-word-idiom-learning` | **Date**: 2026-03-09

## R1: Data Storage Format

**Decision**: Bundled JSON file at `Sources/Resources/vocabulary.json`

**Rationale**: The existing app already uses this pattern for
`config.json`. JSON is natively supported by Foundation's
`JSONDecoder` with zero external dependencies. The vocabulary dataset
is small (50-100 entries, ~50KB) and read-only, making a bundled file
the simplest and most performant option.

**Alternatives considered**:
- **Property list (plist)**: Equivalent capability but JSON is more
  human-readable and easier to edit/review.
- **Hardcoded Swift arrays**: Used for fallback data in existing
  content providers, but 50-100 entries would bloat source files.
  JSON separates data from code.
- **SQLite/GRDB**: Overkill for a static, read-only dataset of this
  size. Adds an external dependency for no benefit.

## R2: Random Selection with Non-Repeat

**Decision**: Fisher-Yates shuffle-based approach. On first load,
shuffle the full vocabulary list into a randomized queue. Pop entries
from the front. When exhausted, reshuffle and restart.

**Rationale**: Guarantees every entry is shown before any repeats
(unlike pure random which can repeat). Simple to implement. In-memory
only per spec clarification, so state resets on app restart.

**Alternatives considered**:
- **Random index with last-shown check**: Only prevents immediate
  consecutive repeat, not broader duplicates. Does not satisfy SC-005
  (no duplicates in 10 consecutive refreshes).
- **Set-based tracking**: Track shown indices in a Set, pick random
  from unshown. Works but shuffle queue is simpler and has identical
  behavior.

## R3: Dictionary URL Construction

**Decision**: Cambridge Dictionary as fixed provider. Single words use
pattern `https://dictionary.cambridge.org/dictionary/english/{word}`.
Idioms store a pre-verified full URL in the JSON data.

**Rationale**: Cambridge has reliable URL patterns for single words.
Multi-word idioms have inconsistent URL slugs (e.g., "break-the-ice"
vs "break+the+ice"), so pre-verified URLs ensure SC-003 (100% valid
links).

**Alternatives considered**:
- **Search URL fallback**: Use Cambridge search URL for idioms. Works
  but shows search results page, not the definition directly.
- **Multiple providers**: Adds complexity with no user benefit per
  clarification decision.

## R4: Integration Pattern

**Decision**: Follow the existing ContentPreference + BreakContent +
BreakContentProvider + BreakView pattern exactly.

**Rationale**: The app already has a well-established pattern for
adding content types:
1. Add case to `ContentPreference` enum (MenuBarView.swift)
2. Add case to `BreakContent` enum (BreakContentProvider.swift)
3. Add loader method in `BreakContentProvider`
4. Add card renderer in `BreakView.contentCard(for:)`

Following this pattern ensures Non-Breaking Changes (Principle I) and
Simplicity (Principle V).

**Alternatives considered**:
- **Separate module/package**: Unnecessary overhead for a single
  content type that follows an established pattern.
- **Protocol-based content system**: Would require refactoring all
  existing content types. Violates Principle I.

## R5: Test Infrastructure

**Decision**: Create `Tests/` directory with XCTest target. Test the
`VocabularyService` (data loading, random selection, non-repeat
logic). Extract vocabulary business logic into a separate
`VocabularyService` class to enable unit testing without UI
dependencies.

**Rationale**: Constitution requires unit tests for all new logic
(Principle III). The existing app has no tests, but the vocabulary
service is a clean, isolated unit that can be tested without UI
framework dependencies.

**Alternatives considered**:
- **Skip tests**: Violates constitution Principle III.
- **UI tests only**: Slower, flakier, and harder to maintain. Unit
  tests for the service layer provide better coverage per effort.

## R6: Adapting User's Phase 3 (API Layer)

**Decision**: No API layer needed. The user's plan mentioned a
`GET /api/vocabulary/random` endpoint, but MindFulBreak is a native
macOS desktop app, not a client-server architecture. The vocabulary
service is called directly from the content provider -- no HTTP
endpoints are involved.

**Rationale**: The existing content types (tech news, jokes, memes)
fetch from external APIs but the vocabulary feature intentionally uses
bundled local data per spec. The "API" in the user's plan maps to the
`VocabularyService` interface called by `BreakContentProvider`.

**Alternatives considered**:
- **Local HTTP server**: Extreme overengineering for an in-process
  data lookup.
