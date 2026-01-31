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

            case .game(let gameType):
                Group {
                    switch gameType {
                    case .ticTacToe:
                        SimpleTicTacToeView()
                    case .memoryMatch:
                        SimpleMemoryMatchView()
                    case .rockPaperScissors:
                        SimpleRPSView()
                    case .numberGuess:
                        SimpleNumberGuessView()
                    }
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

// MARK: - Simple Tic Tac Toe
struct SimpleTicTacToeView: View {
    @State private var board = Array(repeating: "", count: 9)
    @State private var isXTurn = true
    @State private var winner: String? = nil

    var body: some View {
        VStack(spacing: 12) {
            Text("Tic Tac Toe")
                .font(.headline)
            if let winner = winner {
                Text(winner == "Draw" ? "Draw!" : "\(winner) Wins!")
                    .foregroundColor(winner == "X" ? .green : .red)
            }
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(50)), count: 3), spacing: 4) {
                ForEach(0..<9, id: \.self) { i in
                    Button(action: { play(i) }) {
                        Text(board[i])
                            .font(.title)
                            .frame(width: 50, height: 50)
                            .background(Color.purple.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    .disabled(board[i] != "" || winner != nil)
                }
            }
            Button("Reset") { reset() }
                .font(.caption)
        }
    }

    func play(_ i: Int) {
        board[i] = isXTurn ? "X" : "O"
        if checkWin("X") { winner = "X" }
        else if checkWin("O") { winner = "O" }
        else if !board.contains("") { winner = "Draw" }
        isXTurn.toggle()
    }

    func checkWin(_ p: String) -> Bool {
        let wins = [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]]
        return wins.contains { $0.allSatisfy { board[$0] == p } }
    }

    func reset() { board = Array(repeating: "", count: 9); isXTurn = true; winner = nil }
}

// MARK: - Simple Memory Match
struct SimpleMemoryMatchView: View {
    @State private var cards: [(emoji: String, faceUp: Bool, matched: Bool)] = []
    @State private var flipped: [Int] = []
    @State private var pairs = 0
    private let emojis = ["🎮", "💻", "🚀", "⚡️"]

    var body: some View {
        VStack(spacing: 12) {
            Text("Memory Match")
                .font(.headline)
            Text("Pairs: \(pairs)/4")
                .font(.caption)
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(45)), count: 4), spacing: 6) {
                ForEach(0..<cards.count, id: \.self) { i in
                    Button(action: { flip(i) }) {
                        Text(cards[i].faceUp || cards[i].matched ? cards[i].emoji : "?")
                            .font(.title2)
                            .frame(width: 45, height: 45)
                            .background(cards[i].matched ? Color.green.opacity(0.3) : Color.purple.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    .disabled(cards[i].faceUp || cards[i].matched)
                }
            }
            Button("Reset") { reset() }
                .font(.caption)
        }
        .onAppear { reset() }
    }

    func flip(_ i: Int) {
        cards[i].faceUp = true
        flipped.append(i)
        if flipped.count == 2 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                if cards[flipped[0]].emoji == cards[flipped[1]].emoji {
                    cards[flipped[0]].matched = true
                    cards[flipped[1]].matched = true
                    pairs += 1
                } else {
                    cards[flipped[0]].faceUp = false
                    cards[flipped[1]].faceUp = false
                }
                flipped.removeAll()
            }
        }
    }

    func reset() {
        cards = (emojis + emojis).shuffled().map { ($0, false, false) }
        flipped.removeAll()
        pairs = 0
    }
}

// MARK: - Simple Rock Paper Scissors
struct SimpleRPSView: View {
    @State private var result = ""
    @State private var playerScore = 0
    @State private var cpuScore = 0
    private let choices = ["🪨", "📄", "✂️"]

    var body: some View {
        VStack(spacing: 12) {
            Text("Rock Paper Scissors")
                .font(.headline)
            Text("You: \(playerScore) - CPU: \(cpuScore)")
                .font(.caption)
            Text(result)
                .foregroundColor(result.contains("Win") ? .green : (result.contains("Lose") ? .red : .secondary))
            HStack(spacing: 12) {
                ForEach(choices, id: \.self) { c in
                    Button(action: { play(c) }) {
                        Text(c)
                            .font(.largeTitle)
                            .frame(width: 60, height: 60)
                            .background(Color.purple.opacity(0.2))
                            .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                }
            }
            Button("Reset") { playerScore = 0; cpuScore = 0; result = "" }
                .font(.caption)
        }
    }

    func play(_ p: String) {
        let cpu = choices.randomElement()!
        if p == cpu { result = "Tie! \(p) vs \(cpu)" }
        else if (p == "🪨" && cpu == "✂️") || (p == "📄" && cpu == "🪨") || (p == "✂️" && cpu == "📄") {
            result = "You Win! \(p) vs \(cpu)"
            playerScore += 1
        } else {
            result = "You Lose! \(p) vs \(cpu)"
            cpuScore += 1
        }
    }
}

// MARK: - Simple Number Guess
struct SimpleNumberGuessView: View {
    @State private var target = Int.random(in: 1...50)
    @State private var guess = ""
    @State private var hint = "Guess 1-50"
    @State private var attempts = 0
    @State private var won = false

    var body: some View {
        VStack(spacing: 12) {
            Text("Number Guess")
                .font(.headline)
            Text("Attempts: \(attempts)")
                .font(.caption)
            Text(hint)
                .foregroundColor(won ? .green : .secondary)
            HStack {
                TextField("?", text: $guess)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 60)
                    .disabled(won)
                Button("Guess") { check() }
                    .disabled(won)
            }
            Button("New Game") { reset() }
                .font(.caption)
        }
    }

    func check() {
        guard let n = Int(guess) else { hint = "Enter a number"; return }
        attempts += 1
        if n == target { hint = "Correct! 🎉"; won = true }
        else if n < target { hint = "Higher ⬆️" }
        else { hint = "Lower ⬇️" }
        guess = ""
    }

    func reset() {
        target = Int.random(in: 1...50)
        guess = ""
        hint = "Guess 1-50"
        attempts = 0
        won = false
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
