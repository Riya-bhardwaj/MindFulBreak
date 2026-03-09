# Quickstart: Word / Idiom Learning Section

**Branch**: `004-word-idiom-learning` | **Date**: 2026-03-09

## Prerequisites

- macOS 13+
- Swift 5.9+ toolchain
- Xcode or `swift build` CLI

## Build & Run

```bash
# Clone and checkout feature branch
git checkout 004-word-idiom-learning

# Build
swift build

# Run
swift run MindfulBreak
```

## Verify the Feature

1. Click the leaf icon in the macOS menu bar.
2. In the dropdown, select **"Learn Words"** under BREAK CONTENT.
3. Click **"Take a Break Now"**.
4. The break window opens showing a vocabulary card with:
   - A word or idiom
   - Its meaning
   - 1-2 usage examples
   - A "More Info" dictionary link
5. Click **Refresh** to load a different word/idiom.
6. Click the dictionary link to verify it opens Cambridge Dictionary
   in the default browser.

## Run Tests

```bash
swift test
```

Expected: All VocabularyService tests pass, covering:
- JSON loading and decoding
- Random entry selection
- Non-repeat guarantee across consecutive refreshes
- Fallback behavior when JSON is missing
- Edge case: single entry in list

## Files Changed

| File | Change |
|------|--------|
| `Sources/MenuBarView.swift` | Add `.vocabulary` case to ContentPreference enum |
| `Sources/BreakContentProvider.swift` | Add `.vocabulary` case to BreakContent, add loader |
| `Sources/BreakView.swift` | Add vocabulary card rendering |
| `Sources/VocabularyService.swift` | NEW: vocabulary loading + selection logic |
| `Sources/Resources/vocabulary.json` | NEW: 50-100 curated vocabulary entries |
| `Tests/VocabularyServiceTests.swift` | NEW: unit tests |
| `Package.swift` | Add test target |
