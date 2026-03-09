import Foundation

// MARK: - Models

enum EntryType: String, Codable, CaseIterable {
    case word
    case idiom
}

enum VocabularyCategory: String, Codable, CaseIterable {
    case conversational
    case workplace
    case idiom
    case professional
}

struct VocabularyEntry: Codable, Equatable {
    let text: String
    let type: EntryType
    let meaning: String
    let examples: [String]
    let category: VocabularyCategory
    let dictionaryLink: String
}

// MARK: - VocabularyService

class VocabularyService {
    private var entries: [VocabularyEntry] = []
    private var shuffledQueue: [VocabularyEntry] = []
    private var currentIndex: Int = 0

    private static let fallbackEntries: [VocabularyEntry] = [
        VocabularyEntry(
            text: "Collaborate",
            type: .word,
            meaning: "To work jointly with others on an activity or project.",
            examples: [
                "Our teams collaborated on the product launch.",
                "She collaborated with engineers to solve the issue."
            ],
            category: .workplace,
            dictionaryLink: "https://dictionary.cambridge.org/dictionary/english/collaborate"
        ),
        VocabularyEntry(
            text: "Break the ice",
            type: .idiom,
            meaning: "To make people feel more comfortable in a social situation.",
            examples: [
                "He told a joke to break the ice at the meeting.",
                "Games helped break the ice between the new team members."
            ],
            category: .idiom,
            dictionaryLink: "https://dictionary.cambridge.org/dictionary/english/break-the-ice"
        ),
        VocabularyEntry(
            text: "Benchmark",
            type: .word,
            meaning: "A standard or point of reference against which things may be compared.",
            examples: [
                "We use industry benchmarks to measure our performance."
            ],
            category: .professional,
            dictionaryLink: "https://dictionary.cambridge.org/dictionary/english/benchmark"
        ),
        VocabularyEntry(
            text: "Catch up",
            type: .idiom,
            meaning: "To talk to someone you have not seen for a while and learn about what they have been doing.",
            examples: [
                "Let's grab coffee and catch up sometime.",
                "I need to catch up on what happened in the meeting."
            ],
            category: .conversational,
            dictionaryLink: "https://dictionary.cambridge.org/dictionary/english/catch-up"
        ),
        VocabularyEntry(
            text: "Streamline",
            type: .word,
            meaning: "To make a system or organization more efficient by simplifying it.",
            examples: [
                "We streamlined the onboarding process to save time."
            ],
            category: .professional,
            dictionaryLink: "https://dictionary.cambridge.org/dictionary/english/streamline"
        )
    ]

    init() {
        loadEntries()
    }

    /// Load entries from bundled JSON or fall back to hardcoded entries.
    func loadEntries() {
        if let entries = loadFromJSON() {
            self.entries = entries
        } else {
            self.entries = Self.fallbackEntries
        }
        shuffleQueue()
    }

    /// Load entries from a custom file path (used for testing).
    func loadEntries(from filePath: String) {
        guard let data = FileManager.default.contents(atPath: filePath),
              let decoded = try? JSONDecoder().decode([VocabularyEntry].self, from: data) else {
            self.entries = Self.fallbackEntries
            shuffleQueue()
            return
        }
        self.entries = decoded
        shuffleQueue()
    }

    /// Returns the next vocabulary entry from the shuffled queue.
    /// Guarantees no consecutive repeats when more than one entry exists.
    func getNext() -> VocabularyEntry {
        guard !entries.isEmpty else {
            return Self.fallbackEntries[0]
        }

        if entries.count == 1 {
            return entries[0]
        }

        if currentIndex >= shuffledQueue.count {
            reshuffleQueue()
        }

        let entry = shuffledQueue[currentIndex]
        currentIndex += 1
        return entry
    }

    /// The total number of loaded entries.
    var entryCount: Int {
        entries.count
    }

    // MARK: - Private

    private func loadFromJSON() -> [VocabularyEntry]? {
        // Try Bundle.main first (release app)
        if let url = Bundle.main.url(forResource: "vocabulary", withExtension: "json") {
            return decodeJSON(from: url)
        }

        // Try Bundle.module (SPM resource bundle)
        #if SWIFT_PACKAGE
        if let url = Bundle.module.url(forResource: "vocabulary", withExtension: "json",
                                        subdirectory: "Resources") {
            return decodeJSON(from: url)
        }
        #endif

        // Try relative path for development
        let devPath = "Sources/Resources/vocabulary.json"
        if FileManager.default.fileExists(atPath: devPath) {
            return decodeJSON(from: URL(fileURLWithPath: devPath))
        }

        return nil
    }

    private func decodeJSON(from url: URL) -> [VocabularyEntry]? {
        guard let data = try? Data(contentsOf: url),
              let entries = try? JSONDecoder().decode([VocabularyEntry].self, from: data),
              !entries.isEmpty else {
            return nil
        }
        return entries
    }

    private func shuffleQueue() {
        shuffledQueue = entries.shuffled()
        currentIndex = 0
    }

    private func reshuffleQueue() {
        let lastEntry = currentIndex > 0 ? shuffledQueue[currentIndex - 1] : nil
        shuffledQueue = entries.shuffled()
        currentIndex = 0

        // Ensure the first entry after reshuffle differs from the last shown
        if let last = lastEntry, shuffledQueue.count > 1, shuffledQueue[0] == last {
            if let swapIndex = shuffledQueue.dropFirst().firstIndex(where: { $0 != last }) {
                shuffledQueue.swapAt(0, swapIndex)
            }
        }
    }
}
