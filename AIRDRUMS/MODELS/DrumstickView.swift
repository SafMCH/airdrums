//
//  DrumstickView.swift
//  airdrums
//
//  Created by safae machmoum on 29/01/2026.
//


import SwiftUI

// MARK: - Drumstick View
struct DrumstickView: View {
    let angle: Double
    let isHitting: Bool
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Stick body
            RoundedRectangle(cornerRadius: 2)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.6, green: 0.4, blue: 0.2),
                            Color(red: 0.5, green: 0.3, blue: 0.15),
                            Color(red: 0.4, green: 0.25, blue: 0.1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 8, height: 100)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
            
            // Stick tip (bead)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.9, green: 0.7, blue: 0.5),
                            Color(red: 0.6, green: 0.4, blue: 0.2)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 8
                    )
                )
                .frame(width: 16, height: 16)
                .offset(y: -100)
                .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 2)
        }
        .rotationEffect(.degrees(angle), anchor: .bottom)
        .offset(y: isHitting ? 10 : 0)
    }
}

// MARK: - Enhanced Tom View with Drumsticks
struct EnhancedTomView: View {
    let size: CGFloat
    let color: Color
    @Binding var isHit: Bool
    let onTap: () -> Void
    
    @State private var leftStickAngle: Double = -25
    @State private var rightStickAngle: Double = 25
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Shadow
                Circle()
                    .fill(Color.black.opacity(0.5))
                    .frame(width: size * 0.8, height: size * 0.3)
                    .blur(radius: 15)
                    .offset(y: size * 0.4)
                
                // Tom drum
                ZStack {
                    // Drum shell (3D cylinder effect)
                    ZStack {
                        // Back ellipse (bottom of drum)
                        Ellipse()
                            .fill(color.opacity(0.4))
                            .frame(width: size, height: size * 0.3)
                            .offset(y: 20)
                        
                        // Shell body
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [color.opacity(0.7), color, color.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: size, height: 40)
                            .offset(y: 10)
                        
                        // Top ellipse (drum head)
                        ZStack {
                            // Drum head
                            Ellipse()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            Color.white.opacity(0.9),
                                            Color.white.opacity(0.7),
                                            Color.white.opacity(0.5)
                                        ],
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: size / 2
                                    )
                                )
                                .overlay(
                                    Ellipse()
                                        .strokeBorder(Color.gray.opacity(0.3), lineWidth: 3)
                                )
                            
                            // Hit impact circle with ripple effect
                            if isHit {
                                Circle()
                                    .fill(Color.white.opacity(0.8))
                                    .frame(width: 40, height: 40)
                                    .blur(radius: 10)
                                
                                Circle()
                                    .stroke(Color.white.opacity(0.5), lineWidth: 3)
                                    .frame(width: 50, height: 50)
                                    .scaleEffect(isHit ? 1.5 : 1.0)
                                    .opacity(isHit ? 0 : 1)
                            }
                        }
                        .frame(width: size, height: size * 0.3)
                        .shadow(color: color.opacity(isHit ? 0.8 : 0.3), radius: isHit ? 30 : 15)
                    }
                    .rotation3DEffect(
                        .degrees(60),
                        axis: (x: 1, y: 0, z: 0),
                        perspective: 0.5
                    )
                }
                .scaleEffect(isHit ? 0.95 : 1.0)
                .offset(y: isHit ? 5 : 0)
                
                // Drumsticks
                ZStack {
                    // Left stick
                    DrumstickView(angle: leftStickAngle, isHitting: isHit)
                        .offset(x: -size * 0.25, y: -size * 0.5)
                    
                    // Right stick
                    DrumstickView(angle: rightStickAngle, isHitting: isHit)
                        .offset(x: size * 0.25, y: -size * 0.5)
                }
                .opacity(0.8)
            }
            .frame(height: size)
            
            Text("Tom")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))
        }
        .onTapGesture {
            onTap()
            animateSticks()
        }
        .onChange(of: isHit) { _, newValue in
            if newValue {
                animateSticks()
            }
        }
    }
    
    private func animateSticks() {
        // Animate sticks hitting the drum
        withAnimation(.spring(response: 0.1, dampingFraction: 0.6)) {
            leftStickAngle = -5
            rightStickAngle = 5
        }
        
        // Return to rest position
        withAnimation(.spring(response: 0.2, dampingFraction: 0.5).delay(0.1)) {
            leftStickAngle = -25
            rightStickAngle = 25
        }
    }
}

// MARK: - Enhanced Snare with Drumsticks
struct EnhancedSnareView: View {
    @Binding var isHit: Bool
    let onTap: () -> Void
    
    @State private var leftStickAngle: Double = -30
    @State private var rightStickAngle: Double = 30
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Shadow
                Circle()
                    .fill(Color.black.opacity(0.5))
                    .frame(width: 140, height: 50)
                    .blur(radius: 15)
                    .offset(y: 70)
                
                // Snare drum
                ZStack {
                    // Shell
                    ZStack {
                        // Bottom
                        Ellipse()
                            .fill(Color.gray.opacity(0.4))
                            .frame(width: 160, height: 50)
                            .offset(y: 30)
                        
                        // Shell body with chrome finish
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(white: 0.6),
                                        Color(white: 0.8),
                                        Color(white: 0.6)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 160, height: 60)
                            .offset(y: 15)
                        
                        // Top drum head
                        ZStack {
                            Ellipse()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            Color.white.opacity(0.95),
                                            Color.white.opacity(0.8),
                                            Color(white: 0.9).opacity(0.7)
                                        ],
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 80
                                    )
                                )
                            
                            // Snare wires indicator
                            ForEach(0..<8) { i in
                                Rectangle()
                                    .fill(Color.gray.opacity(0.4))
                                    .frame(width: 2, height: 50)
                                    .offset(x: CGFloat(i - 4) * 15, y: 25)
                            }
                            
                            // Rim
                            Ellipse()
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [Color(white: 0.5), Color(white: 0.7), Color(white: 0.5)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 4
                                )
                            
                            // Hit impact with ripple
                            if isHit {
                                Circle()
                                    .fill(Color.white.opacity(0.9))
                                    .frame(width: 50, height: 50)
                                    .blur(radius: 15)
                                
                                ForEach(0..<3) { i in
                                    Circle()
                                        .stroke(Color.white.opacity(0.6 - Double(i) * 0.2), lineWidth: 2)
                                        .frame(width: 60 + CGFloat(i) * 20, height: 60 + CGFloat(i) * 20)
                                        .scaleEffect(isHit ? 1.5 : 1.0)
                                        .opacity(isHit ? 0 : 1)
                                }
                            }
                        }
                        .frame(width: 160, height: 50)
                        .shadow(color: .red.opacity(isHit ? 0.8 : 0.3), radius: isHit ? 40 : 20)
                    }
                    .rotation3DEffect(
                        .degrees(55),
                        axis: (x: 1, y: 0, z: 0),
                        perspective: 0.5
                    )
                }
                .scaleEffect(isHit ? 0.93 : 1.0)
                .offset(y: isHit ? 8 : 0)
                
                // Drumsticks
                ZStack {
                    // Left stick
                    DrumstickView(angle: leftStickAngle, isHitting: isHit)
                        .offset(x: -40, y: -80)
                    
                    // Right stick
                    DrumstickView(angle: rightStickAngle, isHitting: isHit)
                        .offset(x: 40, y: -80)
                }
                .opacity(0.8)
            }
            .frame(height: 160)
            
            Text("Snare")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))
        }
        .onTapGesture {
            onTap()
            animateSticks()
        }
        .onChange(of: isHit) { _, newValue in
            if newValue {
                animateSticks()
            }
        }
    }
    
    private func animateSticks() {
        withAnimation(.spring(response: 0.1, dampingFraction: 0.6)) {
            leftStickAngle = -5
            rightStickAngle = 5
        }
        
        withAnimation(.spring(response: 0.2, dampingFraction: 0.5).delay(0.1)) {
            leftStickAngle = -30
            rightStickAngle = 30
        }
    }
}

// MARK: - Preview
struct EnhancedDrumViews_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                EnhancedSnareView(isHit: .constant(false)) {}
                
                HStack(spacing: 40) {
                    EnhancedTomView(size: 120, color: .red, isHit: .constant(false)) {}
                    EnhancedTomView(size: 140, color: .blue, isHit: .constant(false)) {}
                    EnhancedTomView(size: 160, color: .orange, isHit: .constant(false)) {}
                }
            }
            .padding()
        }
    }
}
