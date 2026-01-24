import Foundation
import SwiftUI

enum BreakContent {
    case nature(imageURL: String)
    case techNews(headline: String, source: String)
    case joke(text: String)
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
            actualPreference = [.nature, .tech, .jokes].randomElement() ?? .nature
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
            case .surpriseMe:
                await loadNatureImage()
            }
        }
    }
    
    private func loadNatureImage() async {
        let fallbackImages = [
            "https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=800",
            "https://images.unsplash.com/photo-1426604966848-d7adac402bff?w=800",
            "https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=800",
            "https://images.unsplash.com/photo-1447752875215-b2761acb3c5d?w=800",
            "https://images.unsplash.com/photo-1433086966358-54859d0ed716?w=800"
        ]
        
        guard let url = URL(string: "https://source.unsplash.com/random/800x600/?nature,calm,peaceful") else {
            state = .loaded(.nature(imageURL: fallbackImages.randomElement()!))
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 10
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse,
               let imageUrl = httpResponse.url?.absoluteString,
               httpResponse.statusCode == 200 {
                state = .loaded(.nature(imageURL: imageUrl))
                return
            }
        } catch { }
        
        state = .loaded(.nature(imageURL: fallbackImages.randomElement()!))
    }
    
    private func loadTechNews() async {
        let fallbackNews = [
            ("Scientists develop new quantum computing breakthrough", "Tech Daily"),
            ("AI assists in discovering high-potential compounds in medicine", "Science Today"),
            ("New renewable energy system achieves significant efficiency", "Green Tech"),
            ("Researchers create biodegradable electronics from natural materials", "Innovation Weekly"),
            ("Space telescope captures detailed images of distant galaxies", "Cosmos News"),
            ("Breakthrough in battery technology extends device life", "Energy Review"),
            ("New programming language focuses on developer safety", "Dev Journal")
        ]
        
        let news = fallbackNews.randomElement()!
        state = .loaded(.techNews(headline: news.0, source: news.1))
    }
    
    private func loadJoke() async {
        let fallbackJokes = [
            "Why do programmers prefer dark mode? Because light attracts bugs.",
            "A SQL query walks into a bar, walks up to two tables and asks... 'Can I join you?'",
            "Why do Java developers wear glasses? Because they can't C#.",
            "There are only 10 types of people in the world: those who understand binary and those who don't.",
            "Why was the JavaScript developer sad? Because he didn't Node how to Express himself.",
            "A programmer's wife tells him: 'Go to the store and get a loaf of bread. If they have eggs, get a dozen.' He comes home with 12 loaves of bread.",
            "Why do programmers always mix up Halloween and Christmas? Because Oct 31 = Dec 25."
        ]
        
        guard let url = URL(string: "https://official-joke-api.appspot.com/jokes/programming/random") else {
            state = .loaded(.joke(text: fallbackJokes.randomElement()!))
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let jokes = try JSONSerialization.jsonObject(with: data) as? [[String: Any]],
               let joke = jokes.first,
               let setup = joke["setup"] as? String,
               let punchline = joke["punchline"] as? String {
                state = .loaded(.joke(text: "\(setup)\n\n\(punchline)"))
                return
            }
        } catch { }
        
        state = .loaded(.joke(text: fallbackJokes.randomElement()!))
    }
}
