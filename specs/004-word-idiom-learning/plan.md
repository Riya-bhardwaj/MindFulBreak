# Implementation Plan: Word / Idiom Learning Section

**Branch**: `004-word-idiom-learning` | **Date**: 2026-03-09 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/004-word-idiom-learning/spec.md`

## Summary

Add a fifth content section ("Learn Words") to the break view that
displays a vocabulary card with a word or idiom, its meaning, 1-2
usage examples, and a Cambridge Dictionary link. Users can refresh to
see a different entry. Vocabulary data is bundled as a local JSON file
with 50-100 curated entries across four professional/conversational
categories. The feature follows existing content patterns
(ContentPreference enum, BreakContent enum, BreakContentProvider
loader, BreakView card renderer).

## Technical Context

**Language/Version**: Swift 5.9+
**Primary Dependencies**: SwiftUI, AppKit, Foundation (no external packages)
**Storage**: Bundled JSON file (`Sources/Resources/vocabulary.json`),
in-memory seen-word tracking
**Testing**: XCTest (new -- no test infrastructure exists yet; must be
created)
**Target Platform**: macOS 13+
**Project Type**: Desktop menu bar app
**Performance Goals**: <0.5s refresh, instant card rendering
**Constraints**: Offline-capable, no external API calls, in-memory
state only (resets on restart)
**Scale/Scope**: 50-100 vocabulary entries, single user

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1
design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Non-Breaking Changes | PASS | New feature is purely additive: new enum case, new loader, new card renderer, new JSON file. No existing code is modified in a breaking way. ContentPreference and BreakContent enums gain a new case; existing cases are untouched. |
| II. Code Quality | PASS | Will follow existing Swift/SwiftUI conventions. Functions decomposed per existing pattern. |
| III. Testability | PASS | VocabularyService will be protocol-based for injectable testing. Unit tests required for data loading, random selection, and non-repeat logic. |
| IV. Modularity | PASS | Vocabulary logic isolated in its own service. No circular dependencies. |
| V. Simplicity | PASS | Follows exact existing pattern (enum case + loader + card). No new design patterns introduced. Bundled JSON avoids API complexity. |
| VI. Extensibility | PASS | Adding a new content type via the existing enum pattern. Future vocabulary expansions only require editing the JSON file. |
| VII. Performance | PASS | JSON loaded once into memory. Random selection is O(1). No main thread blocking. |

## Project Structure

### Documentation (this feature)

```text
specs/004-word-idiom-learning/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
└── tasks.md             # Phase 2 output (/speckit.tasks command)
```

### Source Code (repository root)

```text
Sources/
├── main.swift                          # No changes needed
├── MenuBarView.swift                   # Add .vocabulary case to ContentPreference
├── BreakView.swift                     # Add vocabulary card rendering
├── BreakContentProvider.swift          # Add VocabularyEntry, BreakContent.vocabulary, loader
├── VocabularyService.swift             # NEW: vocabulary loading + random selection logic
├── BreakWindowController.swift         # No changes needed
├── ConfigManager.swift                 # No changes needed
└── Resources/
    ├── config.json                     # No changes needed
    └── vocabulary.json                 # NEW: 50-100 curated vocabulary entries

Tests/
└── VocabularyServiceTests.swift        # NEW: unit tests for vocabulary logic
```

**Structure Decision**: Single project at repository root, following
the existing flat Sources/ structure. New files are
`VocabularyService.swift` (business logic) and
`Resources/vocabulary.json` (data). Tests go in a new `Tests/`
directory.

## Complexity Tracking

No violations. All changes follow existing patterns with minimal
additions.
