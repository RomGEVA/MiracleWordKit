import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    
    var body: some View {
        ZStack {
            CartoonBackground()
            VStack(spacing: 30) {
                Text("Welcome to Guess the Word!")
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .blue.opacity(0.5), radius: 8, x: 0, y: 4)
                    .multilineTextAlignment(.center)
                
                Image(systemName: "textformat.abc")
                    .font(.system(size: 100))
                    .foregroundColor(.yellow)
                    .shadow(color: .orange.opacity(0.5), radius: 10, x: 0, y: 6)
                
                VStack(alignment: .leading, spacing: 20) {
                    InstructionRow(number: "1", text: "A word will be hidden behind underscores.")
                    InstructionRow(number: "2", text: "Tap letters to guess the word.")
                    InstructionRow(number: "3", text: "You have 5 attempts and a timer.")
                    InstructionRow(number: "4", text: "Use hints if you get stuck!")
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(LinearGradient(gradient: Gradient(colors: [.white.opacity(0.7), .yellow.opacity(0.3)]), startPoint: .top, endPoint: .bottom))
                        .shadow(color: .yellow.opacity(0.2), radius: 8, x: 0, y: 4)
                )
                
                Button("Let's Play!") {
                    withAnimation {
                        hasSeenOnboarding = true
                    }
                }
                .font(.title2)
                .fontWeight(.heavy)
                .foregroundColor(.white)
                .frame(width: 220, height: 56)
                .buttonStyle(CartoonButtonStyle(gradient: Gradient(colors: [.mint, .blue]), shadow: .blue))
                .padding(.top, 10)
            }
            .padding()
        }
    }
}

struct InstructionRow: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Text(number)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(Circle().fill(Color.pink))
                .shadow(color: .pink.opacity(0.4), radius: 4, x: 0, y: 2)
            
            Text(text)
                .font(.title3)
                .foregroundColor(.blue)
        }
    }
} 