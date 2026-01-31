import SwiftUI

struct MenuBarView: View {
    weak var appDelegate: AppDelegate?
    @AppStorage("contentPreference") private var preference: ContentPreference = .tech
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "leaf.circle.fill")
                    .font(.title)
                    .foregroundColor(.green)
                Text("Mindful Break")
                    .font(.headline)
            }
            .padding(.top, 8)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Break Content")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Picker("Preference", selection: $preference) {
                    ForEach(ContentPreference.allCases, id: \.self) { pref in
                        HStack {
                            Image(systemName: pref.icon)
                            Text(pref.rawValue)
                        }
                        .tag(pref)
                    }
                }
                .pickerStyle(.radioGroup)
                .labelsHidden()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            
            Divider()
            
            Button(action: { appDelegate?.showBreakWindow() }) {
                HStack {
                    Image(systemName: "sparkles")
                    Text("Take a Break Now")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .padding(.horizontal)
            
            Divider()
            
            Button(action: { NSApplication.shared.terminate(nil) }) {
                HStack {
                    Image(systemName: "power")
                    Text("Quit")
                }
                .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 8)
        }
        .padding()
        .frame(width: 280)
    }
}

enum ContentPreference: String, CaseIterable {
    case tech = "Tech News"
    case jokes = "Jokes"
    case game = "Quick Game"
    case meme = "Tech Meme"

    var icon: String {
        switch self {
        case .tech: return "newspaper.fill"
        case .jokes: return "face.smiling.fill"
        case .game: return "gamecontroller.fill"
        case .meme: return "photo.fill"
        }
    }
}
