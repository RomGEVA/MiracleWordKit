import SwiftUI

struct HowToPlayView: View {
    var body: some View {
        ZStack {
            CartoonBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    Text("How to Play")
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .blue.opacity(0.5), radius: 8, x: 0, y: 4)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top)
                    
                    InstructionSection(
                        title: "Game Objective",
                        description: "Guess the hidden word by selecting letters one at a time."
                    )
                    
                    InstructionSection(
                        title: "Gameplay",
                        description: "• The word is displayed as a series of underscores\n• Tap letters from the grid to make your guess\n• Correct letters will be revealed in their positions\n• You have 5 attempts and a timer"
                    )
                    
                    InstructionSection(
                        title: "Winning",
                        description: "You win when you successfully guess all the letters in the word before running out of attempts or time."
                    )
                    
                    InstructionSection(
                        title: "Losing",
                        description: "The game ends if you make 5 incorrect guesses or run out of time."
                    )
                    
                    InstructionSection(
                        title: "Tips",
                        description: "• Start with common letters like E, T, A, O, I, N\n• Look for patterns in the revealed letters\n• Use hints if you get stuck (but they cost time!)"
                    )
                }
                .padding()
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InstructionSection: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title2)
                .fontWeight(.heavy)
                .foregroundColor(.yellow)
                .shadow(color: .orange.opacity(0.4), radius: 4, x: 0, y: 2)
            
            Text(description)
                .font(.body)
                .foregroundColor(.white)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.5), .mint.opacity(0.5)]), startPoint: .top, endPoint: .bottom))
                        .shadow(color: .blue.opacity(0.15), radius: 4, x: 0, y: 2)
                )
        }
        .padding(.bottom, 6)
    }
} 