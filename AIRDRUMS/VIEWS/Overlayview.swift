import SwiftUI

struct OverlayView: View {
    let lastHitType: DrumType?
    let hitTimestamp: TimeInterval

    var body: some View {
        ZStack {
            // Drum kit visualization
            RealisticDrumKit(lastHitType: lastHitType, hitTimestamp: hitTimestamp)
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Realistic Drum Kit

struct RealisticDrumKit: View {
    let lastHitType: DrumType?
    let hitTimestamp: TimeInterval
    
    @State private var animatingDrum: DrumType?
    @State private var lastAnimationTime: TimeInterval = 0
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            ZStack {
                // CYMBALS (Top row - Gold colored circles)
                
                // Crash Cymbal - Far Left
                CymbalView(
                    drumType: .crash,
                    isActive: animatingDrum == .crash,
                    size: 120
                )
                .position(x: width * 0.15, y: height * 0.2)
                
                // Hi-Hat - Top Right
                CymbalView(
                    drumType: .hihat,
                    isActive: animatingDrum == .hihat,
                    size: 100
                )
                .position(x: width * 0.75, y: height * 0.25)
                
                // DRUMS (White/gray colored circles with rim)
                
                // Tom - Top Center
                DrumView(
                    drumType: .tom,
                    isActive: animatingDrum == .tom,
                    size: 110
                )
                .position(x: width * 0.5, y: height * 0.3)
                
                // Snare - Center Right
                DrumView(
                    drumType: .snare,
                    isActive: animatingDrum == .snare,
                    size: 130
                )
                .position(x: width * 0.6, y: height * 0.55)
                
                // Kick - Bottom Center (larger)
                DrumView(
                    drumType: .kick,
                    isActive: animatingDrum == .kick,
                    size: 160
                )
                .position(x: width * 0.35, y: height * 0.7)
            }
        }
        .onChange(of: lastHitType) { oldValue, newValue in
            if let newValue, hitTimestamp != lastAnimationTime {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                    animatingDrum = newValue
                    lastAnimationTime = hitTimestamp
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeOut(duration: 0.15)) {
                        if animatingDrum == newValue {
                            animatingDrum = nil
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Cymbal View (Gold/Yellow)

struct CymbalView: View {
    let drumType: DrumType
    let isActive: Bool
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Main cymbal body
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.85, green: 0.75, blue: 0.4),
                            Color(red: 0.75, green: 0.65, blue: 0.3)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size / 2
                    )
                )
                .overlay(
                    Circle()
                        .stroke(Color(red: 0.6, green: 0.5, blue: 0.2), lineWidth: 3)
                )
                .frame(width: size, height: size)
            
            // Center mount
            Circle()
                .fill(Color(red: 0.4, green: 0.4, blue: 0.4))
                .frame(width: size * 0.15, height: size * 0.15)
            
            // Liquid glass hit indicator
            if isActive {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                drumColor.opacity(0.8),
                                drumColor.opacity(0.3),
                                .clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: size / 2
                        )
                    )
                    .frame(width: size * 1.2, height: size * 1.2)
                    .blur(radius: 10)
            }
            
            // Label
            Text(label)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(.black.opacity(0.6))
                .offset(y: size * 0.6)
        }
        .shadow(color: isActive ? drumColor.opacity(0.8) : .black.opacity(0.5),
                radius: isActive ? 20 : 8,
                x: 0,
                y: isActive ? 6 : 3)
        .scaleEffect(isActive ? 1.1 : 1.0)
        .brightness(isActive ? 0.2 : 0)
    }
    
    private var label: String {
        switch drumType {
        case .crash: return "CRASH"
        case .hihat: return "HI-HAT"
        default: return ""
        }
    }
    
    private var drumColor: Color {
        switch drumType {
        case .crash: return .yellow
        case .hihat: return .green
        default: return .white
        }
    }
}

// MARK: - Drum View (White/Gray drums with rim)

struct DrumView: View {
    let drumType: DrumType
    let isActive: Bool
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Drum rim (wood color)
            Circle()
                .fill(Color(red: 0.6, green: 0.4, blue: 0.2))
                .frame(width: size * 1.1, height: size * 1.1)
            
            // Drum head
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.95),
                            Color.gray.opacity(0.3)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size / 2
                    )
                )
                .overlay(
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                )
                .frame(width: size, height: size)
            
            // Drum brand/texture
            Circle()
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                .frame(width: size * 0.7, height: size * 0.7)
            
            // Liquid glass hit indicator
            if isActive {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                drumColor.opacity(0.8),
                                drumColor.opacity(0.3),
                                .clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: size / 2
                        )
                    )
                    .frame(width: size * 1.3, height: size * 1.3)
                    .blur(radius: 12)
            }
            
            // Label
            Text(label)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(.black.opacity(0.5))
                .offset(y: size * 0.6)
        }
        .shadow(color: isActive ? drumColor.opacity(0.8) : .black.opacity(0.5),
                radius: isActive ? 25 : 10,
                x: 0,
                y: isActive ? 8 : 4)
        .scaleEffect(isActive ? 1.08 : 1.0)
        .brightness(isActive ? 0.15 : 0)
    }
    
    private var label: String {
        switch drumType {
        case .kick: return "KICK"
        case .snare: return "SNARE"
        case .tom: return "TOM"
        default: return ""
        }
    }
    
    private var drumColor: Color {
        switch drumType {
        case .kick: return .blue
        case .snare: return .red
        case .tom: return .orange
        default: return .white
        }
    }
}

#Preview {
    ZStack {
        Color.black
        OverlayView(lastHitType: .snare, hitTimestamp: Date().timeIntervalSince1970)
    }
}
