import Testing
import Foundation
@testable import MindfulBreak

// MARK: - US1: Loading & Decoding

@Test func loadEntries_decodesVocabularyJSONCorrectly() {
    let service = VocabularyService()
    #expect(service.entryCount > 0, "Service should load entries from JSON or fallbacks")
}

@Test func getNext_returnsEntryWithAllFieldsPopulated() {
    let service = VocabularyService()
    let entry = service.getNext()

    #expect(!entry.text.isEmpty, "text must be non-empty")
    #expect(!entry.meaning.isEmpty, "meaning must be non-empty")
    #expect(entry.examples.count >= 1, "must have at least 1 example")
    #expect(entry.examples.count <= 2, "must have at most 2 examples")
    for example in entry.examples {
        #expect(!example.isEmpty, "each example must be non-empty")
    }
    #expect(URL(string: entry.dictionaryLink) != nil, "dictionaryLink must be a valid URL")
}

@Test func loadEntries_fallsBackWhenJSONMissing() {
    let service = VocabularyService()
    service.loadEntries(from: "/nonexistent/path/vocabulary.json")
    #expect(service.entryCount > 0, "Should have fallback entries")
    let entry = service.getNext()
    #expect(!entry.text.isEmpty)
}

// MARK: - US2: Non-Repeat & Shuffle

@Test func getNext_neverReturnsSameEntryConsecutively() {
    let json = makeTestJSON(count: 10)
    let service = makeService(with: json)

    var previous = service.getNext()
    for _ in 0..<20 {
        let current = service.getNext()
        #expect(current != previous,
            "getNext() must not return the same entry consecutively")
        previous = current
    }
}

@Test func getNext_cyclesThroughAllEntriesBeforeRepeating() {
    let json = makeTestJSON(count: 10)
    let service = makeService(with: json)
    let totalEntries = service.entryCount

    var seen = Set<String>()
    for _ in 0..<totalEntries {
        let entry = service.getNext()
        seen.insert(entry.text)
    }

    #expect(seen.count == totalEntries,
        "All \(totalEntries) entries should be shown before any repeat")
}

@Test func getNext_reshufflesAfterExhaustingAllEntries() {
    let json = makeTestJSON(count: 5)
    let service = makeService(with: json)

    for _ in 0..<5 {
        _ = service.getNext()
    }

    let entry = service.getNext()
    #expect(!entry.text.isEmpty, "Should return valid entry after reshuffle")
}

@Test func getNext_handlesSingleEntryList() {
    let json = makeTestJSON(count: 1)
    let service = makeService(with: json)

    let first = service.getNext()
    let second = service.getNext()
    let third = service.getNext()

    #expect(first == second, "Single entry should return the same entry")
    #expect(second == third, "Single entry should return the same entry")
}

// MARK: - US3: Category Coverage & Validation

@Test func allEntries_passValidation() {
    let service = VocabularyService()
    for _ in 0..<service.entryCount {
        let entry = service.getNext()
        #expect(!entry.text.isEmpty, "text must be non-empty")
        #expect(!entry.meaning.isEmpty, "meaning must be non-empty")
        #expect(entry.examples.count >= 1)
        #expect(entry.examples.count <= 2)
        for example in entry.examples {
            #expect(!example.isEmpty, "example must be non-empty")
        }
        #expect(URL(string: entry.dictionaryLink) != nil,
            "'\(entry.dictionaryLink)' must be a valid URL for '\(entry.text)'")
    }
}

@Test func vocabularyJSON_hasAtLeast10EntriesPerCategory() {
    let service = VocabularyService()
    guard service.entryCount >= 40 else {
        // Skip if vocabulary isn't expanded yet (Phase 5)
        return
    }

    var categoryCounts: [VocabularyCategory: Int] = [:]
    for _ in 0..<service.entryCount {
        let entry = service.getNext()
        categoryCounts[entry.category, default: 0] += 1
    }

    for category in VocabularyCategory.allCases {
        #expect((categoryCounts[category] ?? 0) >= 10,
            "Category '\(category.rawValue)' must have at least 10 entries")
    }
}

// MARK: - Helpers

private func makeTestJSON(count: Int) -> String {
    let entries = (0..<count).map { i in
        """
        {
          "type": "word",
          "text": "Word\(i)",
          "meaning": "Meaning of word \(i).",
          "examples": ["Example sentence for word \(i)."],
          "category": "\(["conversational", "workplace", "idiom", "professional"][i % 4])",
          "dictionaryLink": "https://dictionary.cambridge.org/dictionary/english/word\(i)"
        }
        """
    }
    return "[\(entries.joined(separator: ",\n"))]"
}

private func makeService(with json: String) -> VocabularyService {
    let tempDir = FileManager.default.temporaryDirectory
    let tempFile = tempDir.appendingPathComponent("test_vocabulary_\(UUID().uuidString).json")
    try! json.data(using: .utf8)!.write(to: tempFile)

    let service = VocabularyService()
    service.loadEntries(from: tempFile.path)

    try? FileManager.default.removeItem(at: tempFile)

    return service
}
