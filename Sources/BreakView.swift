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
        case .nature(let imageURL):
            NatureImageView(imageURL: imageURL, isFullScreen: isFullScreen)
            
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

struct NatureImageView: View {
    let imageURL: String
    let isFullScreen: Bool
    @State private var currentImageIndex = 0
    @State private var imageOpacity: Double = 1.0
    
    private let natureQuotes = [
        "In every walk with nature, one receives far more than he seeks.",
        "Nature does not hurry, yet everything is accomplished.",
        "Look deep into nature, and you will understand everything better.",
        "The earth has music for those who listen.",
        "Adopt the pace of nature: her secret is patience."
    ]
    
    var body: some View {
        ZStack {
            AsyncImage(url: URL(string: imageURL)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: isFullScreen ? .fill : .fill)
                        .opacity(imageOpacity)
                case .failure:
                    fallbackNatureView
                case .empty:
                    ZStack {
                        Color(hex: "1a2a3a")
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                @unknown default:
                    fallbackNatureView
                }
            }
            
            LinearGradient(
                colors: [.clear, .clear, Color.black.opacity(0.6)],
                startPoint: .top,
                endPoint: .bottom
            )
            
            VStack {
                Spacer()
                Text(natureQuotes[currentImageIndex % natureQuotes.count])
                    .font(isFullScreen ? .title3 : .caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.bottom, isFullScreen ? 40 : 16)
                    .shadow(color: .black.opacity(0.5), radius: 4)
            }
        }
        .frame(maxWidth: isFullScreen ? .infinity : 480, maxHeight: isFullScreen ? .infinity : 300)
        .clipShape(RoundedRectangle(cornerRadius: isFullScreen ? 0 : 16))
        .overlay(
            isFullScreen ? nil : RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .onAppear {
            currentImageIndex = Int.random(in: 0..<natureQuotes.count)
        }
    }
    
    private var fallbackNatureView: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "1a3a2a"), Color(hex: "0a2a1a")],
                startPoint: .top,
                endPoint: .bottom
            )
            
            VStack(spacing: 12) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.green.opacity(0.6))
                Text("Nature awaits...")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }
}

struct AnimatedNatureView: View {
    @State private var time: Double = 0
    @State private var sunPosition: CGFloat = 0
    @State private var cloudOffset1: CGFloat = -200
    @State private var cloudOffset2: CGFloat = -300
    @State private var wavePhase: CGFloat = 0
    @State private var fireflyPositions: [(x: CGFloat, y: CGFloat, opacity: Double)] = []
    @State private var shootingStarOffset: CGFloat = -100
    @State private var showShootingStar = false
    
    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            SkyGradientView(time: time)
            
            SunMoonView(time: time, position: sunPosition)
            
            StarsView(time: time)
            
            if showShootingStar {
                ShootingStarView(offset: shootingStarOffset)
            }
            
            CloudView(offset: cloudOffset1, size: 1.0, opacity: 0.9)
                .offset(y: -60)
            
            CloudView(offset: cloudOffset2, size: 0.7, opacity: 0.7)
                .offset(y: -30)
            
            MountainsView(time: time)
            
            ForestView()
            
            WaterView(phase: wavePhase, time: time)
            
            FirefliesView(positions: fireflyPositions, time: time)
            
            AuroraView(time: time)
        }
        .onAppear {
            generateFireflies()
            startAnimations()
        }
        .onReceive(timer) { _ in
            time += 0.05
            wavePhase += 0.03
        }
    }
    
    private func generateFireflies() {
        fireflyPositions = (0..<15).map { _ in
            (
                x: CGFloat.random(in: -200...200),
                y: CGFloat.random(in: -50...100),
                opacity: Double.random(in: 0.3...1.0)
            )
        }
    }
    
    private func startAnimations() {
        withAnimation(.linear(duration: 60).repeatForever(autoreverses: false)) {
            cloudOffset1 = 500
        }
        withAnimation(.linear(duration: 80).repeatForever(autoreverses: false)) {
            cloudOffset2 = 500
        }
        withAnimation(.easeInOut(duration: 20).repeatForever(autoreverses: true)) {
            sunPosition = 30
        }
        
        triggerShootingStar()
    }
    
    private func triggerShootingStar() {
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 5...15)) {
            showShootingStar = true
            shootingStarOffset = -100
            withAnimation(.easeIn(duration: 1)) {
                shootingStarOffset = 500
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                showShootingStar = false
                triggerShootingStar()
            }
        }
    }
}

struct SkyGradientView: View {
    let time: Double
    var body: some View {
        LinearGradient(
            colors: [
                Color(hex: "0c0c1e"),
                Color(hex: "1a1a3e"),
                Color(hex: "2d2d5a"),
                Color(hex: "1a1a3e")
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

struct SunMoonView: View {
    let time: Double
    let position: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white,
                            Color(hex: "fffacd"),
                            Color(hex: "fffacd").opacity(0.5),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 15,
                        endRadius: 60
                    )
                )
                .frame(width: 120, height: 120)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "fffef0"), Color(hex: "f0e68c")],
                        center: .center,
                        startRadius: 0,
                        endRadius: 25
                    )
                )
                .frame(width: 45, height: 45)
            
            Circle()
                .fill(Color(hex: "d4d4aa").opacity(0.3))
                .frame(width: 12, height: 12)
                .offset(x: -8, y: -5)
            
            Circle()
                .fill(Color(hex: "d4d4aa").opacity(0.2))
                .frame(width: 8, height: 8)
                .offset(x: 10, y: 8)
        }
        .offset(x: 160, y: -90 + position)
        .shadow(color: Color(hex: "fffacd").opacity(0.4), radius: 30)
    }
}

struct StarsView: View {
    let time: Double
    
    var body: some View {
        Canvas { context, size in
            for i in 0..<80 {
                let x = CGFloat((i * 73) % Int(size.width))
                let y = CGFloat((i * 37) % Int(size.height * 0.6))
                let twinkle = sin(time * 2 + Double(i)) * 0.5 + 0.5
                let starSize = CGFloat(1 + (i % 3))
                
                context.opacity = twinkle * 0.8
                context.fill(
                    Path(ellipseIn: CGRect(x: x, y: y, width: starSize, height: starSize)),
                    with: .color(.white)
                )
            }
        }
    }
}

struct ShootingStarView: View {
    let offset: CGFloat
    
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: -60, y: 30))
        }
        .stroke(
            LinearGradient(
                colors: [.white, .white.opacity(0.5), .clear],
                startPoint: .leading,
                endPoint: .trailing
            ),
            lineWidth: 2
        )
        .offset(x: offset, y: -80)
    }
}

struct CloudView: View {
    let offset: CGFloat
    let size: CGFloat
    let opacity: Double
    
    var body: some View {
        ZStack {
            Ellipse()
                .fill(Color.white.opacity(opacity * 0.15))
                .frame(width: 80 * size, height: 35 * size)
                .offset(x: -20)
            
            Ellipse()
                .fill(Color.white.opacity(opacity * 0.2))
                .frame(width: 100 * size, height: 45 * size)
            
            Ellipse()
                .fill(Color.white.opacity(opacity * 0.15))
                .frame(width: 70 * size, height: 30 * size)
                .offset(x: 30, y: 5)
        }
        .offset(x: offset)
    }
}

struct MountainsView: View {
    let time: Double
    
    var body: some View {
        ZStack {
            MountainLayer(
                peaks: [0.3, 0.15, 0.4, 0.2, 0.35],
                color: Color(hex: "1a1a2e"),
                offset: 30
            )
            
            MountainLayer(
                peaks: [0.2, 0.35, 0.25, 0.4, 0.15],
                color: Color(hex: "2d2d44"),
                offset: 50
            )
            
            MountainLayer(
                peaks: [0.15, 0.25, 0.2, 0.3, 0.18],
                color: Color(hex: "3d3d5c"),
                offset: 70
            )
        }
    }
}

struct MountainLayer: View {
    let peaks: [CGFloat]
    let color: Color
    let offset: CGFloat
    
    var body: some View {
        GeometryReader { geo in
            Path { path in
                let width = geo.size.width
                let height = geo.size.height
                let segmentWidth = width / CGFloat(peaks.count)
                
                path.move(to: CGPoint(x: 0, y: height))
                
                for (index, peak) in peaks.enumerated() {
                    let x = segmentWidth * CGFloat(index) + segmentWidth / 2
                    let y = height * (1 - peak) + offset
                    
                    if index == 0 {
                        path.addLine(to: CGPoint(x: 0, y: y + 20))
                    }
                    path.addLine(to: CGPoint(x: x, y: y))
                }
                
                path.addLine(to: CGPoint(x: width, y: height * 0.7 + offset))
                path.addLine(to: CGPoint(x: width, y: height))
                path.closeSubpath()
            }
            .fill(color)
        }
    }
}

struct ForestView: View {
    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 3) {
                ForEach(0..<25, id: \.self) { i in
                    TreeShape(height: CGFloat.random(in: 30...60), opacity: Double.random(in: 0.6...0.9))
                }
            }
            .frame(height: 80)
            .offset(y: geo.size.height - 100)
        }
    }
}

struct TreeShape: View {
    let height: CGFloat
    let opacity: Double
    
    var body: some View {
        VStack(spacing: -5) {
            Triangle()
                .fill(Color(hex: "2d5a2d").opacity(opacity))
                .frame(width: height * 0.6, height: height * 0.5)
            Triangle()
                .fill(Color(hex: "1a4a1a").opacity(opacity))
                .frame(width: height * 0.8, height: height * 0.5)
            Triangle()
                .fill(Color(hex: "0d3d0d").opacity(opacity))
                .frame(width: height, height: height * 0.5)
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
        }
    }
}

struct WaterView: View {
    let phase: CGFloat
    let time: Double
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                WaterWave(phase: phase, amplitude: 8)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "1a3a5c").opacity(0.9),
                                Color(hex: "2a4a6c").opacity(0.8)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .offset(y: geo.size.height - 60)
                
                WaterWave(phase: phase + 1, amplitude: 5)
                    .fill(Color(hex: "3a5a7c").opacity(0.5))
                    .offset(y: geo.size.height - 50)
                
                WaterWave(phase: phase + 2, amplitude: 3)
                    .fill(Color(hex: "4a6a8c").opacity(0.3))
                    .offset(y: geo.size.height - 45)
                
                ReflectionView(time: time)
                    .offset(y: geo.size.height - 55)
            }
        }
    }
}

struct WaterWave: Shape {
    var phase: CGFloat
    var amplitude: CGFloat
    
    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: 0, y: rect.height / 2))
            
            for x in stride(from: 0, through: rect.width, by: 2) {
                let y = sin((x / rect.width) * .pi * 4 + phase) * amplitude + rect.height / 2
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.closeSubpath()
        }
    }
}

struct ReflectionView: View {
    let time: Double
    
    var body: some View {
        Canvas { context, size in
            let shimmer = sin(time * 2) * 0.3 + 0.7
            
            for i in 0..<8 {
                let x = CGFloat(i * 60 + 30)
                let length = CGFloat.random(in: 20...40)
                
                context.opacity = shimmer * Double.random(in: 0.3...0.6)
                context.stroke(
                    Path { path in
                        path.move(to: CGPoint(x: x, y: 10))
                        path.addLine(to: CGPoint(x: x + 5, y: 10 + length))
                    },
                    with: .color(Color(hex: "fffacd").opacity(0.5)),
                    lineWidth: 2
                )
            }
        }
        .frame(height: 50)
    }
}

struct FirefliesView: View {
    let positions: [(x: CGFloat, y: CGFloat, opacity: Double)]
    let time: Double
    
    var body: some View {
        ForEach(0..<positions.count, id: \.self) { i in
            let pos = positions[i]
            let glow = sin(time * 3 + Double(i) * 0.5) * 0.5 + 0.5
            
            Circle()
                .fill(Color(hex: "ffff99"))
                .frame(width: 4, height: 4)
                .shadow(color: Color(hex: "ffff99").opacity(glow), radius: 8)
                .offset(
                    x: pos.x + sin(time + Double(i)) * 10,
                    y: pos.y + cos(time * 0.7 + Double(i)) * 8
                )
                .opacity(pos.opacity * glow)
        }
    }
}

struct AuroraView: View {
    let time: Double
    
    var body: some View {
        Canvas { context, size in
            let colors: [Color] = [
                Color(hex: "00ff88").opacity(0.15),
                Color(hex: "00ffcc").opacity(0.1),
                Color(hex: "88ffcc").opacity(0.08)
            ]
            
            for (index, color) in colors.enumerated() {
                let offset = sin(time * 0.5 + Double(index)) * 20
                
                context.fill(
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: 50 + offset))
                        path.addCurve(
                            to: CGPoint(x: size.width, y: 70 + offset),
                            control1: CGPoint(x: size.width * 0.3, y: 20 + offset),
                            control2: CGPoint(x: size.width * 0.7, y: 100 + offset)
                        )
                        path.addLine(to: CGPoint(x: size.width, y: 0))
                        path.addLine(to: CGPoint(x: 0, y: 0))
                        path.closeSubpath()
                    },
                    with: .color(color)
                )
            }
        }
        .blendMode(.screen)
    }
}

struct MountainShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: rect.width * 0.15, y: rect.height * 0.4))
        path.addLine(to: CGPoint(x: rect.width * 0.25, y: rect.height * 0.6))
        path.addLine(to: CGPoint(x: rect.width * 0.4, y: rect.height * 0.2))
        path.addLine(to: CGPoint(x: rect.width * 0.55, y: rect.height * 0.5))
        path.addLine(to: CGPoint(x: rect.width * 0.7, y: rect.height * 0.25))
        path.addLine(to: CGPoint(x: rect.width * 0.85, y: rect.height * 0.45))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height * 0.3))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.closeSubpath()
        return path
    }
}

struct CloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addEllipse(in: CGRect(x: rect.width * 0.1, y: rect.height * 0.4, width: rect.width * 0.4, height: rect.height * 0.5))
        path.addEllipse(in: CGRect(x: rect.width * 0.3, y: rect.height * 0.1, width: rect.width * 0.5, height: rect.height * 0.6))
        path.addEllipse(in: CGRect(x: rect.width * 0.5, y: rect.height * 0.3, width: rect.width * 0.45, height: rect.height * 0.55))
        return path
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
