import SwiftUI

struct BreakView: View {
    @AppStorage("contentPreference") private var preference: ContentPreference = .tech
    @StateObject private var contentProvider = BreakContentProvider()
    @State private var breatheScale: CGFloat = 1.0
    @State private var showTimeWarning = false
    @State private var breakStartTime: Date?
    @State private var warningTimer: Timer?
    @State private var isFullScreen = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "1a1a2e"), Color(hex: "16213e"), Color(hex: "0f3460")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            VStack(spacing: isFullScreen ? 36 : 16) {
                HStack {
                    if showTimeWarning {
                        HStack(spacing: 6) {
                            Image(systemName: "clock.badge.exclamationmark")
                                .foregroundColor(.orange)
                            Text("5+ minutes on break")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.2))
                        .cornerRadius(12)
                    }
                    Spacer()
                    Button(action: toggleFullScreen) {
                        Image(systemName: isFullScreen ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 8)
                    Button(action: closeWindow) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .buttonStyle(.plain)
                    .padding()
                }
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .stroke(Color.cyan.opacity(0.3), lineWidth: 3)
                            .frame(width: isFullScreen ? 80 : 60, height: isFullScreen ? 80 : 60)
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color.cyan.opacity(0.6), Color.purple.opacity(0.3)],
                                    center: .center,
                                    startRadius: 5,
                                    endRadius: isFullScreen ? 40 : 30
                                )
                            )
                            .frame(width: isFullScreen ? 70 : 50, height: isFullScreen ? 70 : 50)
                            .scaleEffect(breatheScale)
                            .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: breatheScale)
                    }
                    Text("Breathe & Relax")
                        .font(isFullScreen ? .title3 : .caption)
                        .foregroundColor(.cyan.opacity(0.8))
                }
                contentView
                Spacer()
                HStack(spacing: 20) {
                    Button(action: {
                        contentProvider.loadContent(for: preference)
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.clockwise")
                            Text("Refresh")
                        }
                        .font(isFullScreen ? .title3 : .subheadline)
                        .foregroundColor(.cyan)
                        .padding(.horizontal, isFullScreen ? 32 : 20)
                        .padding(.vertical, isFullScreen ? 16 : 10)
                        .background(Color.cyan.opacity(0.15))
                        .cornerRadius(24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    Button(action: closeWindow) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.right.circle.fill")
                            Text("Back to Work")
                        }
                        .font(isFullScreen ? .title3 : .headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, isFullScreen ? 40 : 32)
                        .padding(.vertical, isFullScreen ? 18 : 12)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "00b894"), Color(hex: "00a8a8")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(28)
                        .shadow(color: Color(hex: "00b894").opacity(0.4), radius: 10, y: 4)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, isFullScreen ? 50 : 24)
            }
            .padding(isFullScreen ? 60 : 0)
        }
        .frame(
            minWidth: isFullScreen ? 900 : 540,
            maxWidth: isFullScreen ? .infinity : 540,
            minHeight: isFullScreen ? 600 : 520,
            maxHeight: isFullScreen ? .infinity : 520
        )
        .cornerRadius(isFullScreen ? 0 : 20)
        .overlay(
            isFullScreen ? nil : RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .onAppear {
            breatheScale = 1.3
            breakStartTime = Date()
            contentProvider.loadContent(for: preference)
            startWarningTimer()
        }
        .onDisappear {
            warningTimer?.invalidate()
        }
    }
    
    private func toggleFullScreen() {
        if let window = NSApp.keyWindow {
            window.toggleFullScreen(nil)
            isFullScreen.toggle()
        }
    }
    
    private func closeWindow() {
        warningTimer?.invalidate()
        if isFullScreen {
            toggleFullScreen()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                NSApp.keyWindow?.close()
            }
        } else {
            NSApp.keyWindow?.close()
        }
    }
    
    private func startWarningTimer() {
        warningTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: false) { _ in
            DispatchQueue.main.async {
                showTimeWarning = true
                showTimeAlert()
            }
        }
    }
    
    private func showTimeAlert() {
        let alert = NSAlert()
        alert.messageText = "Taking a longer break?"
        alert.informativeText = "You've been on break for over 5 minutes. Remember to get back to work when you're ready!"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Got it!")
        alert.runModal()
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch contentProvider.state {
        case .loading:
            VStack(spacing: 12) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .cyan))
                    .scaleEffect(1.2)
                Text("Loading...")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity, maxHeight: isFullScreen ? .infinity : 300)
        case .loaded(let content):
            contentCard(for: content)
        case .error:
            VStack(spacing: 12) {
                Image(systemName: "wifi.slash")
                    .font(.largeTitle)
                    .foregroundColor(.white.opacity(0.5))
                Text("Unable to load content")
                    .foregroundColor(.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity, maxHeight: isFullScreen ? .infinity : 300)
        }
    }
    
    @ViewBuilder
    private func contentCard(for content: BreakContent) -> some View {
        switch content {
        case .techNews(let headline, let source, let url):
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 60, height: 60)
                    Image(systemName: "newspaper.fill")
                        .font(.title)
                        .foregroundColor(.cyan)
                }
                
                Text(headline)
                    .font(isFullScreen ? .title : .title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(4)
                    .padding(.horizontal, 20)
                
                Text("— \(source)")
                    .font(.subheadline)
                    .foregroundColor(.cyan.opacity(0.7))
                
                if let urlString = url, let link = URL(string: urlString) {
                    Link(destination: link) {
                        HStack(spacing: 4) {
                            Text("Read full article")
                            Image(systemName: "arrow.up.right")
                        }
                        .font(.caption)
                        .foregroundColor(.cyan)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.cyan.opacity(0.15))
                        .cornerRadius(12)
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: isFullScreen ? 600 : 480, maxHeight: isFullScreen ? .infinity : 300)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.cyan.opacity(0.2), lineWidth: 1)
                    )
            )
            
        case .joke(let text):
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 60, height: 60)
                    Image(systemName: "face.smiling.fill")
                        .font(.title)
                        .foregroundColor(.orange)
                }
                
                Text(text)
                    .font(isFullScreen ? .title2 : .body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(8)
                    .padding(.horizontal, 20)
                
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                    Text("Programming Humor")
                }
                .font(.caption)
                .foregroundColor(.orange.opacity(0.7))
            }
            .padding(24)
            .frame(maxWidth: isFullScreen ? 600 : 480, maxHeight: isFullScreen ? .infinity : 300)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                    )
            )
            
        case .game(let gameType):
            Group {
                switch gameType {
                case .ticTacToe:
                    TicTacToeView()
                case .memoryMatch:
                    MemoryMatchView()
                case .rockPaperScissors:
                    RockPaperScissorsView()
                case .numberGuess:
                    NumberGuessView()
                }
            }
            .frame(maxWidth: isFullScreen ? 500 : 480, maxHeight: isFullScreen ? 400 : 300)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.purple.opacity(0.2), lineWidth: 1)
                    )
            )

        case .meme(let imageURL, let title):
            VStack(spacing: 16) {
                AsyncImage(url: URL(string: imageURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: isFullScreen ? 500 : 400, maxHeight: isFullScreen ? 350 : 220)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    case .failure:
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.green.opacity(0.2))
                            VStack(spacing: 8) {
                                Image(systemName: "photo.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.green.opacity(0.6))
                                Text("Failed to load meme")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                        .frame(width: isFullScreen ? 500 : 400, height: isFullScreen ? 350 : 220)
                    case .empty:
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.green.opacity(0.1))
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .green))
                        }
                        .frame(width: isFullScreen ? 500 : 400, height: isFullScreen ? 350 : 220)
                    @unknown default:
                        EmptyView()
                    }
                }

                Text(title)
                    .font(isFullScreen ? .title3 : .subheadline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.horizontal, 20)

                HStack(spacing: 4) {
                    Image(systemName: "face.smiling")
                    Text("Tech Meme")
                }
                .font(.caption)
                .foregroundColor(.green.opacity(0.7))
            }
            .padding(24)
            .frame(maxWidth: isFullScreen ? 600 : 480, maxHeight: isFullScreen ? .infinity : 320)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.green.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
}

struct TicTacToeView: View {
    @State private var board: [String] = Array(repeating: "", count: 9)
    @State private var isXTurn = true
    @State private var winner: String? = nil
    @State private var gameOver = false
    @State private var winningCells: [Int] = []
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "gamecontroller.fill")
                    .foregroundColor(.purple)
                Text("Tic Tac Toe")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            if let winner = winner {
                HStack(spacing: 6) {
                    Image(systemName: winner == "X" ? "trophy.fill" : (winner == "Draw" ? "equal.circle.fill" : "xmark.circle.fill"))
                        .foregroundColor(winner == "X" ? .yellow : (winner == "Draw" ? .gray : .red))
                    Text(winner == "Draw" ? "It's a Draw!" : (winner == "X" ? "You Win! 🎉" : "Computer Wins"))
                        .foregroundColor(winner == "X" ? .green : (winner == "Draw" ? .white.opacity(0.7) : .red))
                }
                .font(.subheadline)
                .fontWeight(.medium)
            } else {
                Text(isXTurn ? "Your turn (X)" : "Computer thinking...")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(65), spacing: 6), count: 3), spacing: 6) {
                ForEach(0..<9, id: \.self) { index in
                    Button(action: { playerMove(index) }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(
                                    winningCells.contains(index) 
                                        ? Color.green.opacity(0.3) 
                                        : Color.white.opacity(0.1)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(
                                            winningCells.contains(index) 
                                                ? Color.green.opacity(0.5) 
                                                : Color.white.opacity(0.2),
                                            lineWidth: 1
                                        )
                                )
                                .frame(width: 65, height: 65)
                            
                            Text(board[index])
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(board[index] == "X" ? .cyan : .pink)
                                .shadow(color: board[index] == "X" ? .cyan.opacity(0.5) : .pink.opacity(0.5), radius: 5)
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(board[index] != "" || gameOver || !isXTurn)
                }
            }
            
            Button(action: resetGame) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.counterclockwise")
                    Text("New Game")
                }
                .font(.caption)
                .foregroundColor(.purple)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.purple.opacity(0.15))
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
        }
        .padding()
    }
    
    private func playerMove(_ index: Int) {
        guard board[index] == "" && !gameOver && isXTurn else { return }
        
        board[index] = "X"
        if let cells = checkWinnerCells("X") {
            winner = "X"
            winningCells = cells
            gameOver = true
            return
        }
        
        if !board.contains("") {
            winner = "Draw"
            gameOver = true
            return
        }
        
        isXTurn = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            computerMove()
        }
    }
    
    private func computerMove() {
        let emptyIndices = board.enumerated().compactMap { $0.element == "" ? $0.offset : nil }
        guard let randomIndex = emptyIndices.randomElement() else { return }
        
        board[randomIndex] = "O"
        
        if let cells = checkWinnerCells("O") {
            winner = "O"
            winningCells = cells
            gameOver = true
            return
        }
        
        if !board.contains("") {
            winner = "Draw"
            gameOver = true
            return
        }
        
        isXTurn = true
    }
    
    private func checkWinnerCells(_ player: String) -> [Int]? {
        let winPatterns = [
            [0, 1, 2], [3, 4, 5], [6, 7, 8],
            [0, 3, 6], [1, 4, 7], [2, 5, 8],
            [0, 4, 8], [2, 4, 6]
        ]
        
        for pattern in winPatterns {
            if pattern.allSatisfy({ board[$0] == player }) {
                return pattern
            }
        }
        return nil
    }
    
    private func resetGame() {
        board = Array(repeating: "", count: 9)
        isXTurn = true
        winner = nil
        gameOver = false
        winningCells = []
    }
}

// MARK: - Memory Match Game
struct MemoryMatchView: View {
    @State private var cards: [MemoryCard] = []
    @State private var flippedIndices: [Int] = []
    @State private var matchedPairs: Int = 0
    @State private var moves: Int = 0
    @State private var isProcessing = false

    private let emojis = ["🎮", "💻", "🚀", "⚡️", "🔥", "💡"]

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "square.grid.3x3.fill")
                    .foregroundColor(.purple)
                Text("Memory Match")
                    .font(.headline)
                    .foregroundColor(.white)
            }

            HStack(spacing: 20) {
                Text("Moves: \(moves)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                Text("Pairs: \(matchedPairs)/6")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }

            if matchedPairs == 6 {
                Text("You Win! 🎉")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
            }

            LazyVGrid(columns: Array(repeating: GridItem(.fixed(50), spacing: 8), count: 4), spacing: 8) {
                ForEach(0..<cards.count, id: \.self) { index in
                    CardView(card: cards[index])
                        .onTapGesture { flipCard(at: index) }
                }
            }

            Button(action: resetGame) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.counterclockwise")
                    Text("New Game")
                }
                .font(.caption)
                .foregroundColor(.purple)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.purple.opacity(0.15))
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .onAppear { resetGame() }
    }

    private func flipCard(at index: Int) {
        guard !isProcessing,
              !cards[index].isMatched,
              !flippedIndices.contains(index),
              flippedIndices.count < 2 else { return }

        cards[index].isFaceUp = true
        flippedIndices.append(index)

        if flippedIndices.count == 2 {
            moves += 1
            isProcessing = true
            checkForMatch()
        }
    }

    private func checkForMatch() {
        let first = flippedIndices[0]
        let second = flippedIndices[1]

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            if cards[first].emoji == cards[second].emoji {
                cards[first].isMatched = true
                cards[second].isMatched = true
                matchedPairs += 1
            } else {
                cards[first].isFaceUp = false
                cards[second].isFaceUp = false
            }
            flippedIndices.removeAll()
            isProcessing = false
        }
    }

    private func resetGame() {
        let shuffled = (emojis + emojis).shuffled()
        cards = shuffled.map { MemoryCard(emoji: $0) }
        flippedIndices.removeAll()
        matchedPairs = 0
        moves = 0
        isProcessing = false
    }
}

struct MemoryCard {
    let emoji: String
    var isFaceUp = false
    var isMatched = false
}

struct CardView: View {
    let card: MemoryCard

    var body: some View {
        ZStack {
            if card.isFaceUp || card.isMatched {
                RoundedRectangle(cornerRadius: 8)
                    .fill(card.isMatched ? Color.green.opacity(0.3) : Color.white.opacity(0.2))
                    .frame(width: 50, height: 50)
                Text(card.emoji)
                    .font(.title2)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.purple.opacity(0.4))
                    .frame(width: 50, height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.purple.opacity(0.6), lineWidth: 1)
                    )
            }
        }
    }
}

// MARK: - Rock Paper Scissors Game
struct RockPaperScissorsView: View {
    @State private var playerChoice: String? = nil
    @State private var computerChoice: String? = nil
    @State private var result: String? = nil
    @State private var playerScore = 0
    @State private var computerScore = 0

    private let choices = ["🪨", "📄", "✂️"]
    private let choiceNames = ["🪨": "Rock", "📄": "Paper", "✂️": "Scissors"]

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "hand.raised.fill")
                    .foregroundColor(.purple)
                Text("Rock Paper Scissors")
                    .font(.headline)
                    .foregroundColor(.white)
            }

            HStack(spacing: 30) {
                VStack {
                    Text("You")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    Text("\(playerScore)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.cyan)
                }
                Text("vs")
                    .foregroundColor(.white.opacity(0.4))
                VStack {
                    Text("CPU")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    Text("\(computerScore)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.pink)
                }
            }

            if let result = result {
                Text(result)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(result.contains("Win") ? .green : (result.contains("Lose") ? .red : .white.opacity(0.7)))
            }

            HStack(spacing: 12) {
                if let player = playerChoice, let computer = computerChoice {
                    Text(player)
                        .font(.system(size: 40))
                    Text("vs")
                        .foregroundColor(.white.opacity(0.5))
                    Text(computer)
                        .font(.system(size: 40))
                }
            }
            .frame(height: 50)

            HStack(spacing: 16) {
                ForEach(choices, id: \.self) { choice in
                    Button(action: { play(choice) }) {
                        Text(choice)
                            .font(.system(size: 36))
                            .frame(width: 60, height: 60)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                }
            }

            Button(action: resetGame) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Reset Score")
                }
                .font(.caption)
                .foregroundColor(.purple)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.purple.opacity(0.15))
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
        }
        .padding()
    }

    private func play(_ choice: String) {
        playerChoice = choice
        computerChoice = choices.randomElement()

        guard let player = playerChoice, let computer = computerChoice else { return }

        if player == computer {
            result = "It's a Tie!"
        } else if (player == "🪨" && computer == "✂️") ||
                  (player == "📄" && computer == "🪨") ||
                  (player == "✂️" && computer == "📄") {
            result = "You Win! 🎉"
            playerScore += 1
        } else {
            result = "You Lose!"
            computerScore += 1
        }
    }

    private func resetGame() {
        playerChoice = nil
        computerChoice = nil
        result = nil
        playerScore = 0
        computerScore = 0
    }
}

// MARK: - Number Guessing Game
struct NumberGuessView: View {
    @State private var targetNumber = Int.random(in: 1...50)
    @State private var guess = ""
    @State private var hint = "Guess a number between 1-50"
    @State private var attempts = 0
    @State private var gameWon = false

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "number.circle.fill")
                    .foregroundColor(.purple)
                Text("Number Guess")
                    .font(.headline)
                    .foregroundColor(.white)
            }

            Text("Attempts: \(attempts)")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))

            Text(hint)
                .font(.subheadline)
                .foregroundColor(gameWon ? .green : (hint.contains("Lower") || hint.contains("Higher") ? .orange : .white.opacity(0.7)))
                .multilineTextAlignment(.center)

            if gameWon {
                Text("🎉")
                    .font(.system(size: 40))
            }

            HStack(spacing: 12) {
                TextField("?", text: $guess)
                    .textFieldStyle(.plain)
                    .font(.title2)
                    .frame(width: 80)
                    .multilineTextAlignment(.center)
                    .padding(12)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .foregroundColor(.white)
                    .disabled(gameWon)

                Button(action: checkGuess) {
                    Text("Guess")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.purple)
                        .cornerRadius(12)
                }
                .buttonStyle(.plain)
                .disabled(gameWon)
            }

            Button(action: resetGame) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.counterclockwise")
                    Text("New Game")
                }
                .font(.caption)
                .foregroundColor(.purple)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.purple.opacity(0.15))
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
        }
        .padding()
    }

    private func checkGuess() {
        guard let number = Int(guess) else {
            hint = "Please enter a valid number"
            return
        }

        attempts += 1

        if number == targetNumber {
            hint = "Correct! You got it in \(attempts) attempts!"
            gameWon = true
        } else if number < targetNumber {
            hint = "Higher! ⬆️"
        } else {
            hint = "Lower! ⬇️"
        }

        guess = ""
    }

    private func resetGame() {
        targetNumber = Int.random(in: 1...50)
        guess = ""
        hint = "Guess a number between 1-50"
        attempts = 0
        gameWon = false
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
