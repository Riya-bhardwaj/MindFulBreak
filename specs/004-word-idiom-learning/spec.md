# Feature Specification: Word / Idiom Learning Section

**Feature Branch**: `004-word-idiom-learning`
**Created**: 2026-03-09
**Status**: Draft
**Input**: User description: "Add a vocabulary learning section that displays a word or idiom with meaning, usage examples, dictionary link, and refresh capability"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View Word of the Day (Priority: P1)

A user taking a break sees a vocabulary card displaying a word or idiom.
The card shows the term, its meaning, 1-2 usage examples, and a link
to an external dictionary for further reading. The user learns a new
word passively during their break without any extra effort.

**Why this priority**: This is the core value proposition -- displaying
vocabulary content is the fundamental feature. Without it, nothing
else works.

**Independent Test**: Can be fully tested by opening the break view
and verifying a vocabulary card appears with all required fields
(word/idiom, meaning, examples, dictionary link).

**Acceptance Scenarios**:

1. **Given** the vocabulary section is visible, **When** the user
   views it, **Then** a card is displayed showing a word or idiom,
   its meaning, at least one usage example, and a clickable dictionary
   link.
2. **Given** the vocabulary section displays a word, **When** the user
   clicks the dictionary link, **Then** the link opens in their
   default browser pointing to a valid dictionary page for that word.
3. **Given** the vocabulary section displays an idiom, **When** the
   user reads the examples, **Then** each example demonstrates the
   idiom used in a natural, contextually appropriate sentence.

---

### User Story 2 - Refresh to Load Another Word (Priority: P2)

A user has read the current word/idiom and wants to see another one.
They click a refresh button and the vocabulary card updates to show a
different word or idiom with its corresponding meaning, examples, and
dictionary link.

**Why this priority**: Refresh enables repeat engagement and ensures
users see varied content. It is the primary interaction beyond
passive viewing.

**Independent Test**: Can be fully tested by clicking the refresh
button and verifying the displayed word/idiom changes, along with
its meaning, examples, and dictionary link.

**Acceptance Scenarios**:

1. **Given** a vocabulary card is currently displayed, **When** the
   user clicks the refresh button, **Then** a new word or idiom is
   loaded with updated meaning, examples, and dictionary link.
2. **Given** the user clicks refresh, **When** the new word loads,
   **Then** it MUST be different from the previously displayed word
   (when the vocabulary list contains more than one entry).
3. **Given** the vocabulary list has been exhausted (all words shown),
   **When** the user clicks refresh, **Then** the system cycles back
   through the list starting from a word not recently shown.

---

### User Story 3 - Curated Professional Vocabulary (Priority: P3)

A user benefits from vocabulary content that is curated for
professional and conversational contexts. The words and idioms shown
are relevant to daily conversation, workplace communication, and
professional development -- not obscure or overly academic terms.

**Why this priority**: Content quality determines long-term engagement.
While the feature works without curation (P1/P2), curated content
makes it genuinely useful for professional growth.

**Independent Test**: Can be tested by reviewing the vocabulary list
and verifying that entries fall into the categories: daily
conversational English, office/workplace language, common idioms, or
professional vocabulary.

**Acceptance Scenarios**:

1. **Given** the vocabulary list, **When** reviewing its contents,
   **Then** at least 80% of entries fall into one of these categories:
   daily conversational English, office/workplace language, common
   idioms, or professional vocabulary.
2. **Given** the user views multiple words across sessions, **When**
   evaluating the variety, **Then** entries span multiple categories
   (not all from a single category).

---

### Edge Cases

- What happens when the vocabulary list contains only one entry?
  The refresh button MUST still be functional but the same word is
  re-displayed (no error).
- What happens when the dictionary link points to a page that is
  unavailable? The link still opens in the browser; the system does
  not validate external URL availability at runtime.
- What happens when the app launches for the first time? A random
  word/idiom is selected from the vocabulary list as the initial
  display.
- What happens when the user rapidly clicks refresh multiple times?
  Each click MUST load a different word (debounce if needed) without
  visual glitches or duplicate displays.

## Clarifications

### Session 2026-03-09

- Q: Dictionary provider strategy (single fixed, per-entry, or user-configurable)? → A: Single fixed provider -- Cambridge Dictionary for all entries.
- Q: Does seen-word history persist across app restarts? → A: In-memory only -- history resets when the app restarts.
- Q: How to handle dictionary links for multi-word idioms? → A: Idiom entries store a pre-verified dictionary URL; single words use the URL pattern.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST display a vocabulary card containing: the
  word or idiom, its meaning, 1-2 usage examples, and a dictionary
  link.
- **FR-002**: System MUST provide a refresh button that loads a
  different word or idiom when clicked.
- **FR-003**: The refreshed word MUST be different from the currently
  displayed word when more than one entry exists in the vocabulary
  list.
- **FR-004**: All dictionary links MUST use Cambridge Dictionary as
  the single fixed provider. Single-word entries use the URL pattern
  `https://dictionary.cambridge.org/dictionary/english/{word}`.
  Idiom entries MUST store a pre-verified Cambridge Dictionary URL
  (curated at data authoring time) to ensure link validity.
- **FR-005**: The dictionary link MUST open in the user's default
  browser when clicked.
- **FR-006**: The vocabulary list MUST contain words and idioms from
  these content categories: daily conversational English,
  office/workplace language, common idioms, and professional
  vocabulary.
- **FR-007**: The system MUST select a random word/idiom on initial
  display.
- **FR-008**: The UI MUST update dynamically when refresh is triggered
  without requiring a full view reload.

### Key Entities

- **VocabularyEntry**: A single word or idiom with its meaning,
  1-2 usage example sentences, a content category (conversational,
  workplace, idiom, professional), entry type (word or idiom), and a
  dictionary URL. For words, the URL is generated from a pattern; for
  idioms, it is a pre-verified curated URL.
- **VocabularyList**: The complete collection of vocabulary entries
  available for display, supporting random selection and
  non-repeating sequential access. Seen-word tracking is in-memory
  only and resets on app restart.

### Assumptions

- The vocabulary data is bundled locally with the app (not fetched
  from a remote API). This keeps the feature simple, offline-capable,
  and fast.
- Dictionary links use Cambridge Dictionary exclusively. Single words
  use the pattern `https://dictionary.cambridge.org/dictionary/english/{word}`;
  idioms store a pre-verified URL curated at data authoring time.
- The initial vocabulary list ships with a reasonable set of entries
  (50-100 words/idioms) covering all four content categories.
- The vocabulary section is one component within the existing break
  view, not a standalone screen.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can read a word, its meaning, and examples within
  5 seconds of the vocabulary section becoming visible.
- **SC-002**: Clicking refresh loads a new word within 0.5 seconds
  (perceived instant).
- **SC-003**: 100% of dictionary links resolve to a valid dictionary
  page for the displayed word.
- **SC-004**: The vocabulary list covers all four content categories
  with at least 10 entries per category.
- **SC-005**: Users encounter no duplicate words in at least 10
  consecutive refreshes (given sufficient vocabulary list size).
