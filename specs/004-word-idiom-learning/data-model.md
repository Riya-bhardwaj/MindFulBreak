# Data Model: Word / Idiom Learning Section

**Branch**: `004-word-idiom-learning` | **Date**: 2026-03-09

## Entities

### VocabularyEntry

Represents a single word or idiom in the vocabulary dataset.

| Field          | Type       | Required | Description |
|----------------|------------|----------|-------------|
| text           | String     | Yes      | The word or idiom phrase (e.g., "Outperform", "Break the ice") |
| type           | EntryType  | Yes      | Either "word" or "idiom" |
| meaning        | String     | Yes      | Brief definition in plain English |
| examples       | [String]   | Yes      | 1-2 usage example sentences |
| category       | Category   | Yes      | Content category for variety tracking |
| dictionaryLink | String     | Yes      | Full Cambridge Dictionary URL (pre-verified for idioms, pattern-generated for words) |

### EntryType (enum)

| Value  | Description |
|--------|-------------|
| word   | Single word (URL generated from pattern) |
| idiom  | Multi-word phrase (URL is pre-verified) |

### Category (enum)

| Value          | Description |
|----------------|-------------|
| conversational | Daily conversational English |
| workplace      | Office and workplace language |
| idiom          | Common English idioms |
| professional   | Professional and business vocabulary |

## Relationships

```text
VocabularyService (in-memory)
├── entries: [VocabularyEntry]       # Loaded once from JSON
├── shuffledQueue: [VocabularyEntry] # Current randomized order
└── currentIndex: Int                # Position in shuffled queue
```

- No persistent relationships. All state is in-memory.
- `VocabularyService` owns the loaded entries and manages the
  shuffle queue.

## JSON Schema (vocabulary.json)

```json
[
  {
    "type": "word",
    "text": "Outperform",
    "meaning": "Perform better than someone or something.",
    "examples": [
      "Our team outperformed the sales target this quarter.",
      "This laptop outperforms the previous model in speed."
    ],
    "category": "professional",
    "dictionaryLink": "https://dictionary.cambridge.org/dictionary/english/outperform"
  },
  {
    "type": "idiom",
    "text": "Break the ice",
    "meaning": "To start a conversation in a social setting.",
    "examples": [
      "He told a joke to break the ice at the meeting.",
      "Games helped break the ice between teams."
    ],
    "category": "idiom",
    "dictionaryLink": "https://dictionary.cambridge.org/dictionary/english/break-the-ice"
  }
]
```

## Validation Rules

- `text` MUST be non-empty.
- `examples` MUST contain 1-2 entries. Each example MUST be non-empty.
- `dictionaryLink` MUST be a valid URL string.
- `type` MUST be one of: "word", "idiom".
- `category` MUST be one of: "conversational", "workplace", "idiom",
  "professional".
- The vocabulary list MUST contain at least 10 entries per category
  (SC-004).

## State Transitions

```text
VocabularyService lifecycle:

  [Unloaded] --loadFromJSON()--> [Loaded]
       |                            |
       |                   shuffleQueue()
       |                            |
       v                            v
  [Error/Fallback]           [Ready to Serve]
                                    |
                          getNext() (pops from queue)
                                    |
                         queue empty? --yes--> reshuffleQueue()
                                    |
                                    v
                          [Return VocabularyEntry]
```

No persistent state transitions. Service is re-initialized on each
app launch.
