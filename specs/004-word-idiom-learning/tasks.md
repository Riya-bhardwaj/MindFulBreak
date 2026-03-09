# Tasks: Word / Idiom Learning Section

**Input**: Design documents from `/specs/004-word-idiom-learning/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md

**Tests**: Included -- constitution Principle III requires unit tests for all new logic.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup

**Purpose**: Project initialization and test infrastructure

- [x] T001 Add test target to Package.swift for XCTest support in Package.swift
- [x] T002 [P] Create VocabularyEntry model with EntryType and Category enums (Codable, fields: text, type, meaning, examples, category, dictionaryLink) in Sources/VocabularyService.swift

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core vocabulary service and data that ALL user stories depend on

- [x] T003 Implement VocabularyService class with loadFromJSON() method that reads and decodes Sources/Resources/vocabulary.json using JSONDecoder, with hardcoded fallback entries (3-5 entries) if file is missing, in Sources/VocabularyService.swift
- [x] T004 [P] Create initial vocabulary.json with 10 sample entries (at least 2 per category: conversational, workplace, idiom, professional; mix of word and idiom types; each with text, meaning, 1-2 examples, and verified Cambridge Dictionary dictionaryLink) in Sources/Resources/vocabulary.json
- [x] T005 Add .vocabulary case to BreakContent enum with associated value VocabularyEntry in Sources/BreakContentProvider.swift

**Checkpoint**: VocabularyService can load data, BreakContent has vocabulary case

---

## Phase 3: User Story 1 - View Word of the Day (Priority: P1)

**Goal**: Display a vocabulary card with word/idiom, meaning, examples, and dictionary link during breaks

**Independent Test**: Open break view with "Learn Words" selected, verify vocabulary card renders with all fields

### Tests for User Story 1

- [x] T006 [P] [US1] Unit test: VocabularyService loads and decodes vocabulary.json correctly (verify entry count, field values for known entry) in Tests/VocabularyServiceTests.swift
- [x] T007 [P] [US1] Unit test: VocabularyService returns a VocabularyEntry from getNext() after loading (verify all fields are non-empty, examples has 1-2 items, dictionaryLink is valid URL) in Tests/VocabularyServiceTests.swift
- [x] T008 [P] [US1] Unit test: VocabularyService falls back to hardcoded entries when JSON file is missing (inject missing path, verify fallback entries returned) in Tests/VocabularyServiceTests.swift

### Implementation for User Story 1

- [x] T009 [US1] Implement getNext() method in VocabularyService that returns a random VocabularyEntry from the loaded list in Sources/VocabularyService.swift
- [x] T010 [US1] Add loadVocabulary() method to BreakContentProvider that calls VocabularyService.getNext() and sets state to .loaded(.vocabulary(entry)) in Sources/BreakContentProvider.swift
- [x] T011 [US1] Add .vocabulary case to loadContent(for:) switch in BreakContentProvider to call loadVocabulary() in Sources/BreakContentProvider.swift
- [x] T012 [US1] Add .vocabulary case to ContentPreference enum with rawValue "Learn Words", icon "book.fill", and color .teal in Sources/MenuBarView.swift
- [x] T013 [US1] Add vocabulary card rendering to contentCard(for:) ViewBuilder in BreakView: display book icon, word/idiom text, meaning, numbered examples list, and "More Info" link that opens dictionaryLink via NSWorkspace.shared.open() in Sources/BreakView.swift

**Checkpoint**: User can select "Learn Words" in menu bar, take a break, and see a vocabulary card with all fields. Dictionary link opens in browser.

---

## Phase 4: User Story 2 - Refresh to Load Another Word (Priority: P2)

**Goal**: Clicking refresh loads a different word/idiom with no consecutive repeats

**Independent Test**: Click refresh 10+ times, verify each click shows a different word

### Tests for User Story 2

- [x] T014 [P] [US2] Unit test: VocabularyService.getNext() never returns the same entry consecutively (call getNext() 20 times, verify no adjacent duplicates) in Tests/VocabularyServiceTests.swift
- [x] T015 [P] [US2] Unit test: VocabularyService cycles through all entries before repeating (load 10 entries, call getNext() 10 times, verify all 10 unique entries returned) in Tests/VocabularyServiceTests.swift
- [x] T016 [P] [US2] Unit test: VocabularyService reshuffles after exhausting all entries (load 5 entries, call getNext() 6 times, verify 6th call returns valid entry from reshuffled queue) in Tests/VocabularyServiceTests.swift
- [x] T017 [P] [US2] Unit test: VocabularyService handles single-entry list gracefully (load 1 entry, call getNext() 3 times, verify same entry returned each time without error) in Tests/VocabularyServiceTests.swift

### Implementation for User Story 2

- [x] T018 [US2] Implement Fisher-Yates shuffle queue in VocabularyService: on first load shuffle entries into randomized queue, getNext() pops from front, reshuffle when exhausted in Sources/VocabularyService.swift
- [x] T019 [US2] Verify refresh button in BreakView triggers loadContent(for: .vocabulary) which calls VocabularyService.getNext() and updates the vocabulary card dynamically in Sources/BreakView.swift

**Checkpoint**: Refresh button loads different words each time. No duplicates across 10 consecutive refreshes. Single-entry edge case works.

---

## Phase 5: User Story 3 - Curated Professional Vocabulary (Priority: P3)

**Goal**: Vocabulary list contains 50+ curated entries spanning all four categories with professional/conversational focus

**Independent Test**: Review vocabulary.json and verify at least 10 entries per category, all relevant to professional/conversational contexts

### Tests for User Story 3

- [x] T020 [P] [US3] Unit test: vocabulary.json contains at least 10 entries per category (decode file, group by category, assert each group.count >= 10) in Tests/VocabularyServiceTests.swift
- [x] T021 [P] [US3] Unit test: all vocabulary entries pass validation (non-empty text, non-empty meaning, 1-2 non-empty examples, valid URL dictionaryLink, valid type and category values) in Tests/VocabularyServiceTests.swift

### Implementation for User Story 3

- [x] T022 [US3] Expand vocabulary.json to 50+ entries: at least 12 conversational, 12 workplace, 12 idiom, and 12 professional entries, each with verified Cambridge Dictionary links (pre-verified URLs for idiom type entries) in Sources/Resources/vocabulary.json

**Checkpoint**: vocabulary.json has 50+ entries across all 4 categories. All dictionary links are valid. All entries are relevant to daily/professional English.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final validation and cleanup

- [x] T023 Verify all existing content types (tech, jokes, game, meme) still work correctly after adding vocabulary case -- no regressions in Sources/BreakContentProvider.swift and Sources/BreakView.swift
- [x] T024 [P] Run full test suite (swift test) and verify all unit tests pass
- [x] T025 [P] Build and run the app (swift build && swift run), manually verify end-to-end flow: menu bar selection, break window, vocabulary card display, refresh, dictionary link

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 (T001, T002)
- **User Story 1 (Phase 3)**: Depends on Phase 2 (T003, T004, T005)
- **User Story 2 (Phase 4)**: Depends on Phase 3 (needs basic getNext() before adding shuffle)
- **User Story 3 (Phase 5)**: Depends on Phase 2 only (data expansion is independent of UI)
- **Polish (Phase 6)**: Depends on all user stories complete

### User Story Dependencies

- **User Story 1 (P1)**: Requires Foundational phase. No dependency on other stories.
- **User Story 2 (P2)**: Requires US1 complete (needs getNext() to exist before adding shuffle queue logic).
- **User Story 3 (P3)**: Can start after Foundational phase. Independent of US1/US2 (data-only work). However, should complete after US1 so entries can be manually tested.

### Within Each User Story

- Tests MUST be written and FAIL before implementation
- Model/service changes before UI changes
- Service integration before view rendering
- Story complete before moving to next priority

### Parallel Opportunities

- T002 and T001 can run in parallel (different files)
- T003 and T004 can run in parallel (different files)
- T006, T007, T008 can all run in parallel (same file but independent tests)
- T014, T015, T016, T017 can all run in parallel (independent tests)
- T020, T021 can run in parallel (independent tests)
- T023, T024, T025 can run in parallel (independent validation)
- US3 (Phase 5) data expansion can run in parallel with US2 (Phase 4) implementation

---

## Parallel Example: User Story 1

```bash
# Launch all tests for US1 together:
Task: "Unit test: VocabularyService loads vocabulary.json" (T006)
Task: "Unit test: VocabularyService returns entry from getNext()" (T007)
Task: "Unit test: VocabularyService fallback on missing JSON" (T008)

# Then implement sequentially:
Task: "Implement getNext() in VocabularyService" (T009)
Task: "Add loadVocabulary() to BreakContentProvider" (T010)
Task: "Add .vocabulary to loadContent switch" (T011)
Task: "Add .vocabulary to ContentPreference enum" (T012)
Task: "Add vocabulary card rendering to BreakView" (T013)
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001-T002)
2. Complete Phase 2: Foundational (T003-T005)
3. Complete Phase 3: User Story 1 (T006-T013)
4. **STOP and VALIDATE**: Build, run, verify vocabulary card displays
5. All tests pass

### Incremental Delivery

1. Setup + Foundational -> vocabulary data and service ready
2. Add User Story 1 -> vocabulary card displays -> Test independently
3. Add User Story 2 -> refresh shows different words -> Test independently
4. Add User Story 3 -> expand to 50+ curated entries -> Test independently
5. Polish -> full regression check, all tests green

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Verify tests fail before implementing
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Existing app has no tests; Phase 1 creates the test infrastructure
