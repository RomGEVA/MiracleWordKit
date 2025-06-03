
import SwiftUI

struct ContentView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @StateObject private var gameModel = GameModel()
    
    var body: some View {
        ZStack {
            CartoonBackground()
            if !hasSeenOnboarding {
                OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
            } else {
                if #available(iOS 16.0, *) {
                    NavigationStack {
                        MainMenuView(gameModel: gameModel)
                            .background(Color.clear)
                    }
                } else {
                    NavigationView {
                        MainMenuView(gameModel: gameModel)
                            .background(Color.clear)
                    }
                }
            }
        }
    }
}

struct MainMenuView: View {
    @ObservedObject var gameModel: GameModel
    
    var body: some View {
        VStack(spacing: 28) {
            ZStack {
                Capsule()
                    .fill(Color.white.opacity(0.7))
                    .frame(height: 64)
                    .padding(.horizontal, -8)
                    .shadow(color: .blue.opacity(0.18), radius: 16, x: 0, y: 8)
                Text("Guess the Word")
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundColor(.blue)
                    .shadow(color: .white, radius: 0, x: 0, y: 0)
                    .shadow(color: .blue.opacity(0.4), radius: 8, x: 0, y: 4)
            }
            .padding(.top, 30)
            
            NavigationLink(destination: GameView(gameModel: gameModel, levelToStart: gameModel.lastUnlockedLevel)) {
                MenuButton(title: "Play")
            }
            .buttonStyle(CartoonButtonStyle(gradient: Gradient(colors: [.yellow, .orange]), shadow: .orange))
            
            NavigationLink(destination: LevelSelectView(gameModel: gameModel)) {
                MenuButton(title: "Select Level")
            }
            .buttonStyle(CartoonButtonStyle(gradient: Gradient(colors: [.mint, .blue]), shadow: .blue))
            
            NavigationLink(destination: HowToPlayView()) {
                MenuButton(title: "How to Play")
            }
            .buttonStyle(CartoonButtonStyle(gradient: Gradient(colors: [.pink, .purple]), shadow: .pink))
            
            NavigationLink(destination: SettingsView(gameModel: gameModel)) {
                MenuButton(title: "Settings")
            }
            .buttonStyle(CartoonButtonStyle(gradient: Gradient(colors: [.green, .yellow]), shadow: .green))
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

struct MenuButton: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.title2)
            .fontWeight(.heavy)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, minHeight: 56)
    }
}

struct CartoonButtonStyle: ButtonStyle {
    var gradient: Gradient = Gradient(colors: [.yellow, .orange])
    var shadow: Color = .orange
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background(
                LinearGradient(gradient: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .cornerRadius(28)
            .shadow(color: shadow.opacity(configuration.isPressed ? 0.2 : 0.5), radius: 14, x: 0, y: 8)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct CartoonBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color.pink.opacity(0.7), Color.blue.opacity(0.7), Color.yellow.opacity(0.7)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

// #Preview {
//     ContentView()
// }
