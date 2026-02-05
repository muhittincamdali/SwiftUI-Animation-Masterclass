//
//  AnimationShowcase.swift
//  SwiftUIAnimationMasterclass Examples
//
//  Created by Muhittin Camdali
//  Copyright © 2023-2025 Muhittin Camdali. All rights reserved.
//

import SwiftUI
import SwiftUIAnimationMasterclass

// MARK: - Animation Showcase App

@available(iOS 17.0, macOS 14.0, *)
struct AnimationShowcaseApp: App {
    var body: some Scene {
        WindowGroup {
            AnimationShowcaseView()
        }
    }
}

// MARK: - Main Showcase View

@available(iOS 17.0, macOS 14.0, *)
struct AnimationShowcaseView: View {
    
    @State private var selectedCategory: AnimationCategory = .attention
    @State private var trigger = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("Categories") {
                    ForEach(AnimationCategory.allCases, id: \.self) { category in
                        NavigationLink(value: category) {
                            Label(category.rawValue, systemImage: category.icon)
                        }
                    }
                }
                
                Section("Special Effects") {
                    NavigationLink("Loading Animations") {
                        LoadingShowcaseView()
                    }
                    NavigationLink("Micro-Interactions") {
                        MicroInteractionsShowcaseView()
                    }
                    NavigationLink("3D Effects") {
                        ThreeDShowcaseView()
                    }
                    NavigationLink("Particle Effects") {
                        ParticleShowcaseView()
                    }
                    NavigationLink("Page Transitions") {
                        PageTransitionShowcaseView()
                    }
                }
            }
            .navigationTitle("Animation Masterclass")
            .navigationDestination(for: AnimationCategory.self) { category in
                AnimationCategoryView(category: category)
            }
        }
    }
}

// MARK: - Animation Category View

@available(iOS 17.0, macOS 14.0, *)
struct AnimationCategoryView: View {
    
    let category: AnimationCategory
    @State private var trigger = false
    
    var animations: [AnimationType] {
        AnimationType.allCases.filter { $0.category == category }
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) {
                ForEach(Array(animations.enumerated()), id: \.offset) { _, animation in
                    AnimationDemoCard(animation: animation, trigger: $trigger)
                }
            }
            .padding()
        }
        .navigationTitle(category.rawValue)
        .toolbar {
            Button("Trigger All") {
                trigger.toggle()
            }
        }
    }
}

// MARK: - Animation Demo Card

@available(iOS 17.0, macOS 14.0, *)
struct AnimationDemoCard: View {
    
    let animation: AnimationType
    @Binding var trigger: Bool
    @State private var localTrigger = false
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(.blue.gradient)
                .frame(width: 60, height: 60)
                .animate(animation, trigger: $localTrigger)
            
            Text(String(describing: animation))
                .font(.caption)
                .lineLimit(1)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onTapGesture {
            localTrigger.toggle()
        }
        .onChange(of: trigger) { _, _ in
            localTrigger.toggle()
        }
    }
}

// MARK: - Loading Showcase

@available(iOS 17.0, macOS 14.0, *)
struct LoadingShowcaseView: View {
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 20) {
                ForEach(LoadingAnimationType.allCases, id: \.self) { type in
                    VStack {
                        LoadingView(type: type, color: .blue, size: 50)
                            .frame(height: 60)
                        
                        Text(type.rawValue)
                            .font(.caption)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
        }
        .navigationTitle("Loading Animations")
    }
}

// MARK: - Micro-Interactions Showcase

@available(iOS 17.0, macOS 14.0, *)
struct MicroInteractionsShowcaseView: View {
    
    @State private var isLiked = false
    @State private var isToggled = false
    @State private var showSuccess = false
    @State private var showError = false
    @State private var isAdded = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Tap Scale
                GroupBox("Tap Scale") {
                    Button("Tap Me")
                        .buttonStyle(.borderedProminent)
                        .tapScale { print("Tapped!") }
                }
                
                // Tap Bounce
                GroupBox("Tap Bounce") {
                    Image(systemName: "star.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.yellow)
                        .tapBounce { print("Bounced!") }
                }
                
                // Like Heart
                GroupBox("Like Heart") {
                    LikeHeartButton(isLiked: $isLiked, size: 40)
                }
                
                // Success Check
                GroupBox("Success Animation") {
                    VStack {
                        SuccessCheckView(isShowing: $showSuccess, size: 60)
                        Button("Show Success") {
                            showSuccess = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showSuccess = false
                            }
                        }
                    }
                }
                
                // Error Shake
                GroupBox("Error Shake") {
                    TextField("Enter text", text: .constant(""))
                        .textFieldStyle(.roundedBorder)
                        .errorShake(shake: $showError)
                    
                    Button("Trigger Error") {
                        showError = true
                    }
                }
                
                // Toggle Switch
                GroupBox("Animated Toggle") {
                    AnimatedToggle(isOn: $isToggled)
                }
                
                // Add to Cart
                GroupBox("Add to Cart") {
                    AddToCartButton(isAdded: $isAdded) {
                        print("Added to cart!")
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Micro-Interactions")
    }
}

// MARK: - 3D Showcase

@available(iOS 17.0, macOS 14.0, *)
struct ThreeDShowcaseView: View {
    
    @State private var isFlipped = false
    @State private var carouselIndex = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                // Flip Card
                GroupBox("3D Flip Card") {
                    FlipCard(isFlipped: $isFlipped) {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.blue.gradient)
                            .frame(width: 200, height: 150)
                            .overlay(Text("Front").foregroundStyle(.white))
                    } back: {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.red.gradient)
                            .frame(width: 200, height: 150)
                            .overlay(Text("Back").foregroundStyle(.white))
                    }
                }
                
                // 3D Carousel
                GroupBox("3D Carousel") {
                    Carousel3D(currentIndex: $carouselIndex, itemCount: 5, radius: 150, itemWidth: 120) { i in
                        RoundedRectangle(cornerRadius: 12)
                            .fill([Color.red, .blue, .green, .yellow, .purple][i].gradient)
                            .frame(height: 150)
                            .overlay(Text("Item \(i + 1)").foregroundStyle(.white))
                    }
                    .frame(height: 200)
                }
                
                // Rotate on Tap
                GroupBox("3D Rotate on Tap") {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.purple.gradient)
                        .frame(width: 100, height: 100)
                        .overlay(Text("Tap").foregroundStyle(.white))
                        .rotate3DOnTap(degrees: 360, axis: .y)
                }
            }
            .padding()
        }
        .navigationTitle("3D Effects")
    }
}

// MARK: - Particle Showcase

@available(iOS 17.0, macOS 14.0, *)
struct ParticleShowcaseView: View {
    
    @State private var showConfetti = false
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 30) {
                    GroupBox("Snow Effect") {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.blue.gradient)
                            .frame(height: 200)
                            .overlay(
                                SnowView(particleCount: 30)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    GroupBox("Sparkle Effect") {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.black)
                            .frame(height: 200)
                            .overlay(
                                SparkleView(particleCount: 20)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    GroupBox("Bubbles Effect") {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.cyan.gradient)
                            .frame(height: 200)
                            .overlay(
                                BubblesView(particleCount: 15)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    GroupBox("Confetti") {
                        Button("Celebrate! 🎉") {
                            showConfetti = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
            }
            
            ConfettiView(isActive: $showConfetti)
        }
        .navigationTitle("Particle Effects")
    }
}

// MARK: - Page Transition Showcase

@available(iOS 17.0, macOS 14.0, *)
struct PageTransitionShowcaseView: View {
    
    @State private var currentPage = 0
    @State private var selectedTransition: PageTransitionType = .slide
    
    let colors: [Color] = [.red, .blue, .green, .orange, .purple]
    
    var body: some View {
        VStack {
            Picker("Transition", selection: $selectedTransition) {
                ForEach(PageTransitionType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            PageTransitionContainer(
                transitionType: selectedTransition,
                currentPage: $currentPage,
                pageCount: 5
            ) { page in
                colors[page]
                    .overlay(
                        Text("Page \(page + 1)")
                            .font(.largeTitle)
                            .foregroundStyle(.white)
                    )
            }
            
            HStack {
                Button("Previous") {
                    withAnimation {
                        currentPage = max(0, currentPage - 1)
                    }
                }
                .disabled(currentPage == 0)
                
                Spacer()
                
                Text("\(currentPage + 1) / 5")
                
                Spacer()
                
                Button("Next") {
                    withAnimation {
                        currentPage = min(4, currentPage + 1)
                    }
                }
                .disabled(currentPage == 4)
            }
            .padding()
        }
        .navigationTitle("Page Transitions")
    }
}

// MARK: - Preview

@available(iOS 17.0, macOS 14.0, *)
#Preview {
    AnimationShowcaseView()
}
