import SwiftUI

struct MenuBarView: View {
    weak var appDelegate: AppDelegate?
    @AppStorage("contentPreference") private var preference: ContentPreference = .surpriseMe
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 36, height: 36)
                    Image(systemName: "leaf.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                }
                Text("Mindful Break")
                    .font(.headline)
            }
            .padding(.top, 12)
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            VStack(alignment: .leading, spacing: 10) {
                Text("BREAK CONTENT")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .tracking(1)
                
                ForEach(ContentPreference.allCases, id: \.self) { pref in
                    Button(action: { preference = pref }) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(pref.color.opacity(0.2))
                                    .frame(width: 28, height: 28)
                                Image(systemName: pref.icon)
                                    .font(.caption)
                                    .foregroundColor(pref.color)
                            }
                            
                            Text(pref.rawValue)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if preference == pref {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 8)
                        .background(
                            preference == pref 
                                ? Color.green.opacity(0.1) 
                                : Color.clear
                        )
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 8)
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            Button(action: { appDelegate?.showBreakWindow() }) {
                HStack {
                    Image(systemName: "sparkles")
                    Text("Take a Break Now")
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "00b894"), Color(hex: "00a8a8")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 8)
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            Button(action: { NSApplication.shared.terminate(nil) }) {
                HStack {
                    Image(systemName: "power")
                    Text("Quit")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 8)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .frame(width: 260)
    }
}

enum ContentPreference: String, CaseIterable {
    case nature = "Nature Scene"
    case tech = "Tech News"
    case jokes = "Programming Jokes"
    case game = "Quick Game"
    case surpriseMe = "Surprise Me"
    
    var icon: String {
        switch self {
        case .nature: return "moon.stars.fill"
        case .tech: return "newspaper.fill"
        case .jokes: return "face.smiling.fill"
        case .game: return "gamecontroller.fill"
        case .surpriseMe: return "sparkles"
        }
    }
    
    var color: Color {
        switch self {
        case .nature: return .cyan
        case .tech: return .blue
        case .jokes: return .orange
        case .game: return .purple
        case .surpriseMe: return .green
        }
    }
}
