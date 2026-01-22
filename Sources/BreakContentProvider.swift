import Foundation
import SwiftUI

enum BreakContent {
    case nature(imageURL: String)
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
    
    private let natureImages = [
        "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=1200",
        "https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=1200",
        "https://images.unsplash.com/photo-1426604966848-d7adac402bff?w=1200",
        "https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=1200",
        "https://images.unsplash.com/photo-1447752875215-b2761acb3c5d?w=1200",
        "https://images.unsplash.com/photo-1433086966358-54859d0ed716?w=1200",
        "https://images.unsplash.com/photo-1501854140801-50d01698950b?w=1200",
        "https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=1200",
        "https://images.unsplash.com/photo-1518173946687-a4c036bc6c9f?w=1200",
        "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=1200",
        "https://images.unsplash.com/photo-1505144808419-1957a94ca61e?w=1200",
        "https://images.unsplash.com/photo-1439066615861-d1af74d74000?w=1200",
        "https://images.unsplash.com/photo-1470252649378-9c29740c9fa8?w=1200",
        "https://images.unsplash.com/photo-1472214103451-9374bd1c798e?w=1200",
        "https://images.unsplash.com/photo-1504567961542-e24d9439a724?w=1200",
        "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=1200",
        "https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?w=1200",
        "https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?w=1200",
        "https://images.unsplash.com/photo-1508739773434-c26b3d09e071?w=1200",
        "https://images.unsplash.com/photo-1518495973542-4542c06a5843?w=1200"
    ]
    
    func loadContent(for preference: ContentPreference) {
        state = .loading
        
        let actualPreference: ContentPreference
        if preference == .surpriseMe {
            actualPreference = [.nature, .tech, .jokes, .game].randomElement() ?? .nature
        } else {
            actualPreference = preference
        }
        
        Task {
            switch actualPreference {
            case .nature:
                await loadNatureImage()
            case .tech:
                await loadTechNews()
            case .jokes:
                await loadJoke()
            case .game:
                state = .loaded(.game)
            case .surpriseMe:
                await loadNatureImage()
            }
        }
    }
    
    private func loadNatureImage() async {
        let randomImage = natureImages.randomElement() ?? natureImages[0]
        state = .loaded(.nature(imageURL: randomImage))
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
