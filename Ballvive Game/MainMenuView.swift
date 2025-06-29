import SwiftUI

struct MainMenuView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple, Color.blue]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)

                VStack(spacing: 30) {
                    Spacer()

                    // Logo
                    Image("Ballvive Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .shadow(radius: 10)

                    Spacer(minLength: 30)

                    // Time Survival Button
                    NavigationLink(destination: TimeSurvivalView()) {
                        Text("Time Survival")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 250, height: 60)
                            .background(Color.white.opacity(0.3))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.4), radius: 5, x: 0, y: 3)
                    }
                    .padding(.bottom, 15)

                    // Ball Survival Button
                    NavigationLink(destination: BallSurvivalView()) {
                        Text("Ball Survival")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 250, height: 60)
                            .background(Color.white.opacity(0.3))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.4), radius: 5, x: 0, y: 3)
                    }

                    Spacer(minLength: 40)
                }
                .padding(.top, 20)
            }
        }
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
    }
}
