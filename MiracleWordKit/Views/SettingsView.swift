import SwiftUI
import StoreKit

struct SettingsView: View {
    @ObservedObject var gameModel: GameModel
    @Environment(\.openURL) private var openURL
    @Environment(\.requestReview) private var requestReview
    
    var body: some View {
        ZStack {
            CartoonBackground()
            List {
                Section(header: Text("Game Settings")
                    .font(.title3)
                    .fontWeight(.heavy)
                    .foregroundColor(.yellow)
                    .shadow(color: .orange.opacity(0.4), radius: 4, x: 0, y: 2)
                ) {
                    Toggle("Sound Effects", isOn: $gameModel.isSoundEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: .mint))
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Picker("Difficulty", selection: $gameModel.difficulty) {
                        ForEach(GameModel.Difficulty.allCases, id: \.self) { difficulty in
                            Text(difficulty.rawValue).tag(difficulty)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .font(.title3)
                }
                
                Section(header: Text("About")
                    .font(.title3)
                    .fontWeight(.heavy)
                    .foregroundColor(.yellow)
                    .shadow(color: .orange.opacity(0.4), radius: 4, x: 0, y: 2)
                ) {
                    Button("Rate the App") {
                        if #available(iOS 16.0, *) {
                            requestReview()
                        } else {
                            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                                SKStoreReviewController.requestReview(in: scene)
                            }
                        }
                    }
                    .font(.title3)
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .buttonStyle(CartoonButtonStyle(gradient: Gradient(colors: [.pink, .purple]), shadow: .pink))
                    .padding(.vertical, 4)
                    
                    Button("Privacy Policy") {
                        if let url = URL(string: "https://www.termsfeed.com/live/3de59eec-31f9-478e-95f5-022bc154127a") {
                            openURL(url)
                        }
                    }
                    .font(.title3)
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .buttonStyle(CartoonButtonStyle(gradient: Gradient(colors: [.mint, .blue]), shadow: .blue))
                    .padding(.vertical, 4)
                }
                
                Section(header: Text("Version")
                    .font(.title3)
                    .fontWeight(.heavy)
                    .foregroundColor(.yellow)
                    .shadow(color: .orange.opacity(0.4), radius: 4, x: 0, y: 2)
                ) {
                    Text("1.0.0")
                        .foregroundColor(.gray)
                }
            }
            .background(Color.clear)
            .modifier(CartoonListBackground())
        }
        .navigationTitle("Settings")
    }
}

struct CartoonListBackground: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.scrollContentBackground(.hidden)
        } else {
            content
                .onAppear {
                    UITableView.appearance().backgroundColor = .clear
                }
        }
    }
} 
