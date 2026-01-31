import Foundation
import SwiftUI

enum BreakContent {
    case techNews(headline: String, source: String, url: String?)
    case joke(text: String)
    case game
}

enum ContentState {
    case loading
    case loaded(BreakContent)
    case error
}

@MainActor
class BreakContentProvider: ObservableObject {
    @Published var state: ContentState = .loading

    func loadContent(for preference: ContentPreference) {
        state = .loading

        let actualPreference: ContentPreference
        if preference == .surpriseMe {
            actualPreference = [.tech, .jokes, .game].randomElement() ?? .tech
        } else {
            actualPreference = preference
        }

        Task {
            switch actualPreference {
            case .tech:
                await loadTechNews()
            case .jokes:
                await loadJoke()
            case .game:
                state = .loaded(.game)
            case .surpriseMe:
                await loadTechNews()
            }
        }
    }
    
    private func loadTechNews() async {
        let fallbackNews: [(String, String, String?)] = [
            ("Scientists develop new quantum computing breakthrough", "Tech Daily", nil),
            ("AI assists in discovering high-potential compounds in medicine", "Science Today", nil),
            ("New renewable energy system achieves significant efficiency", "Green Tech", nil),
            ("Researchers create biodegradable electronics from natural materials", "Innovation Weekly", nil),
            ("Space telescope captures detailed images of distant galaxies", "Cosmos News", nil)
        ]
        
        guard let url = URL(string: "https://hacker-news.firebaseio.com/v0/topstories.json") else {
            let news = fallbackNews.randomElement()!
            state = .loaded(.techNews(headline: news.0, source: news.1, url: news.2))
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let storyIds = try JSONSerialization.jsonObject(with: data) as? [Int],
               let randomId = storyIds.prefix(30).randomElement(),
               let storyURL = URL(string: "https://hacker-news.firebaseio.com/v0/item/\(randomId).json") {
                
                var storyRequest = URLRequest(url: storyURL)
                storyRequest.timeoutInterval = 5
                let (storyData, _) = try await URLSession.shared.data(for: storyRequest)
                
                if let story = try JSONSerialization.jsonObject(with: storyData) as? [String: Any],
                   let title = story["title"] as? String {
                    let storyLink = story["url"] as? String
                    state = .loaded(.techNews(headline: title, source: "Hacker News", url: storyLink))
                    return
                }
            }
        } catch { }
        
        let news = fallbackNews.randomElement()!
        state = .loaded(.techNews(headline: news.0, source: news.1, url: news.2))
    }
    
    private func loadJoke() async {
        let fallbackJokes = [
            "Why do programmers prefer dark mode? Because light attracts bugs.",
            "A SQL query walks into a bar, walks up to two tables and asks... 'Can I join you?'",
            "Why do Java developers wear glasses? Because they can't C#.",
            "There are only 10 types of people in the world: those who understand binary and those who don't.",
            "Why was the JavaScript developer sad? Because he didn't Node how to Express himself."
        ]
        
        guard let url = URL(string: "https://v2.jokeapi.dev/joke/Programming?type=twopart") else {
            state = .loaded(.joke(text: fallbackJokes.randomElement()!))
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                if let setup = json["setup"] as? String,
                   let delivery = json["delivery"] as? String {
                    state = .loaded(.joke(text: "\(setup)\n\n\(delivery)"))
                    return
                } else if let joke = json["joke"] as? String {
                    state = .loaded(.joke(text: joke))
                    return
                }
            }
        } catch { }
        
        state = .loaded(.joke(text: fallbackJokes.randomElement()!))
    }
}
