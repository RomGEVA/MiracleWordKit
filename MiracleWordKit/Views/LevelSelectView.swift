import SwiftUI

struct LevelSelectView: View {
    @ObservedObject var gameModel: GameModel
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedLevel: Int? = nil
    
    var body: some View {
        ZStack {
            CartoonBackground()
            VStack(spacing: 20) {
                Text("Select Level")
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .blue.opacity(0.5), radius: 8, x: 0, y: 4)
                    .padding(.top)
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 18) {
                        ForEach(gameModel.levels) { level in
                            Button(action: {
                                if gameModel.isLevelUnlocked(level.id) {
                                    selectedLevel = level.id
                                }
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(
                                            gameModel.isLevelPassed(level.id) ?
                                                LinearGradient(gradient: Gradient(colors: [.green, .yellow]), startPoint: .top, endPoint: .bottom) :
                                            (gameModel.isLevelUnlocked(level.id) ?
                                                LinearGradient(gradient: Gradient(colors: [.blue, .mint]), startPoint: .top, endPoint: .bottom) :
                                                LinearGradient(gradient: Gradient(colors: [.gray.opacity(0.3), .gray.opacity(0.1)]), startPoint: .top, endPoint: .bottom))
                                        )
                                        .frame(height: 70)
                                        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 4)
                                    VStack(spacing: 4) {
                                        Text("Level \(level.id + 1)")
                                            .font(.title3)
                                            .fontWeight(.heavy)
                                            .foregroundColor(.white)
                                            .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
                                        if gameModel.isLevelPassed(level.id) {
                                            Image(systemName: "checkmark.seal.fill").foregroundColor(.yellow).font(.title2)
                                        } else if !gameModel.isLevelUnlocked(level.id) {
                                            Image(systemName: "lock.fill").foregroundColor(.white).font(.title2)
                                        }
                                    }
                                }
                            }
                            .disabled(!gameModel.isLevelUnlocked(level.id))
                            .scaleEffect(gameModel.isLevelUnlocked(level.id) ? 1.0 : 0.97)
                            .opacity(gameModel.isLevelUnlocked(level.id) ? 1.0 : 0.6)
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: gameModel.isLevelUnlocked(level.id))
                        }
                    }
                    .padding(.horizontal, 8)
                }
                Button("Reset Progress") {
                    gameModel.resetProgress()
                }
                .font(.title3)
                .fontWeight(.heavy)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, minHeight: 48)
                .buttonStyle(CartoonButtonStyle(gradient: Gradient(colors: [.red, .orange]), shadow: .red))
                .padding(.horizontal, 32)
                .padding(.bottom)
            }
            .padding(.horizontal, 8)
            .background(Color.clear)
            .navigationBarTitleDisplayMode(.inline)
            .background(
                NavigationLink(
                    destination: selectedLevel.map { GameView(gameModel: gameModel, levelToStart: $0) },
                    isActive: Binding(
                        get: { selectedLevel != nil },
                        set: { if !$0 { selectedLevel = nil } }
                    )
                ) { EmptyView() }
                .hidden()
            )
        }
    }
} 