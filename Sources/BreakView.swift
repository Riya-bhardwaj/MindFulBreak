import SwiftUI

struct BreakView: View {
    @AppStorage("contentPreference") private var preference: ContentPreference = .surpriseMe
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
            
        case .game:
            TicTacToeView()
                .frame(maxWidth: isFullScreen ? 500 : 480, maxHeight: isFullScreen ? 400 : 300)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.purple.opacity(0.2), lineWidth: 1)
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
