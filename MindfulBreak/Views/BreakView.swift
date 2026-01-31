import SwiftUI

struct BreakView: View {
    @AppStorage("contentPreference") private var preference: ContentPreference = .tech
    @StateObject private var contentProvider = BreakContentProvider()
    @State private var breatheScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "E8F5E9"), Color(hex: "C8E6C9")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 24) {
                HStack {
                    Spacer()
                    Button(action: { NSApp.keyWindow?.close() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray.opacity(0.6))
                    }
                    .buttonStyle(.plain)
                    .padding()
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    Circle()
                        .fill(Color.green.opacity(0.3))
                        .frame(width: 60, height: 60)
                        .scaleEffect(breatheScale)
                        .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: breatheScale)
                        .onAppear { breatheScale = 1.3 }
                    
                    Text("Take a breath")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                contentView
                
                Spacer()
                
                Button(action: { NSApp.keyWindow?.close() }) {
                    Text("Back to Work")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(Color.green)
                        .cornerRadius(25)
                }
                .buttonStyle(.plain)
                .padding(.bottom, 32)
            }
        }
        .frame(width: 500, height: 450)
        .cornerRadius(16)
        .onAppear {
            contentProvider.loadContent(for: preference)
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch contentProvider.state {
        case .loading:
            ProgressView()
                .scaleEffect(1.2)
        case .loaded(let content):
            contentCard(for: content)
        case .error:
            VStack(spacing: 12) {
                Image(systemName: "wifi.slash")
                    .font(.largeTitle)
                    .foregroundColor(.secondary)
                Text("Unable to load content")
                    .foregroundColor(.secondary)
                Text("Enjoy this moment of stillness")
                    .font(.caption)
                    .foregroundColor(.secondary.opacity(0.7))
            }
        }
    }
    
    @ViewBuilder
    private func contentCard(for content: BreakContent) -> some View {
        VStack(spacing: 16) {
            switch content {
            case .techNews(let headline, let source):
                VStack(spacing: 12) {
                    Image(systemName: "newspaper.fill")
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                    Text(headline)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .lineLimit(4)
                        .padding(.horizontal)
                    Text("— \(source)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(width: 400)
                .background(Color.white.opacity(0.5))
                .cornerRadius(12)

            case .joke(let text):
                VStack(spacing: 12) {
                    Image(systemName: "face.smiling.fill")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text(text)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .lineLimit(6)
                        .padding(.horizontal)
                }
                .padding()
                .frame(width: 400)
                .background(Color.white.opacity(0.5))
                .cornerRadius(12)

            case .meme(let imageURL, let title):
                VStack(spacing: 12) {
                    AsyncImage(url: URL(string: imageURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 380, maxHeight: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        case .failure:
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.green.opacity(0.2))
                                Image(systemName: "photo.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.green.opacity(0.5))
                            }
                            .frame(width: 380, height: 200)
                        case .empty:
                            ProgressView()
                                .frame(width: 380, height: 200)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal)
                }
                .padding()
                .frame(width: 400)
                .background(Color.white.opacity(0.5))
                .cornerRadius(12)
            }
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        self.init(red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255)
    }
}
