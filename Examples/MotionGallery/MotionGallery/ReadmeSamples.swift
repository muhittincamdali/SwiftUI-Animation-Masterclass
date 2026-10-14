// The code samples shown in README.md. The README copies them from this file, the example app
// shows each one on its own screen, and the package's test target compiles and renders this
// same file (Tests/SwiftUIAnimationMasterclassTests/ReadmeExamples.swift is a symlink to it).

import SwiftUI
import SwiftUIAnimationMasterclass

// MARK: Quick start

struct LikeButton: View {
    @State private var likes = 0

    var body: some View {
        Button("Like", systemImage: "heart.fill") { likes += 1 }
            .buttonStyle(.borderedProminent)
            .changeEffect(.jump(), value: likes)
            .particleBurst(.hearts, trigger: likes)
    }
}

// MARK: Drop a value with a bounce

struct DropBadge: View {
    @State private var isDropped = false

    var body: some View {
        Image(systemName: "bell.fill")
            .font(.largeTitle)
            .offset(y: isDropped ? 0 : -120)
            .animation(.gravityBounce(restitution: 0.5), value: isDropped)
            .onAppear { isDropped = true }
    }
}

// MARK: Celebrate with particles

struct OrderButton: View {
    @State private var orders = 0

    var body: some View {
        Button("Place order") { orders += 1 }
            .buttonStyle(.borderedProminent)
            .particleBurst(.confetti, trigger: orders)
    }
}

struct WinterScene: View {
    var body: some View {
        LinearGradient(colors: [.indigo, .blue], startPoint: .top, endPoint: .bottom)
            .particleEffect(.snow)
            .ignoresSafeArea()
    }
}

// MARK: Draw attention to a change

struct PasswordField: View {
    @State private var password = ""
    @State private var failures = 0

    var body: some View {
        SecureField("Password", text: $password)
            .textFieldStyle(.roundedBorder)
            .changeEffect(.shake(), value: failures)
            .onSubmit { if password.count < 8 { failures += 1 } }
    }
}

// MARK: Show and hide views

struct PhotoReveal: View {
    @State private var showsPhoto = false

    var body: some View {
        VStack {
            Button(showsPhoto ? "Hide" : "Reveal") {
                withAnimation(.smooth(duration: 0.6)) { showsPhoto.toggle() }
            }
            if showsPhoto {
                Image(systemName: "photo.artframe")
                    .font(.system(size: 120))
                    .foregroundStyle(.blue)
                    .transition(.iris(origin: .topTrailing))
            }
        }
        .frame(height: 220, alignment: .top)
    }
}

// MARK: Drag with momentum

struct PullUpPanel: View {
    @State private var detent = 1

    var body: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(.blue.gradient)
            .frame(height: 400)
            .overlay(alignment: .top) {
                Capsule().fill(.white.opacity(0.6)).frame(width: 40, height: 5).padding(10)
            }
            .snapDrag(.vertical, offsets: [0, 260], selection: $detent)
    }
}

// MARK: Scroll with parallax

struct ParallaxArticle: View {
    var body: some View {
        ScrollView {
            Image(systemName: "mountain.2.fill")
                .font(.system(size: 120))
                .foregroundStyle(.blue)
                .frame(maxWidth: .infinity, minHeight: 240)
                .scrollDriven(multiplier: 0.4)
            Text(String(repeating: "Scroll to see the picture move at a slower pace. ", count: 30))
                .padding()
        }
    }
}

// MARK: Your own particle effect

let stardust = ParticleEmitter(
    source: .edge(.bottom),
    birthRate: 30,
    lifetime: 2...3,
    speed: 60...120,
    direction: .degrees(-90),
    spread: .degrees(20),
    size: 6...10,
    endScale: 0.3,
    forces: [.vortex(center: .center, strength: 80), .gravity(-20)],
    colors: [.white, .cyan],
    shapes: [.star],
    fadeIn: 0.1,
    blending: .additive
)

struct StardustView: View {
    var body: some View {
        Color.black
            .particleEffect(stardust)
            .ignoresSafeArea()
    }
}
