import SwiftUI

struct SplashScreen: View {
    @State private var isActive = false
    @State private var opacity = 0.0
    
    var body: some View {
        if isActive {
            MainMenuView() // Ganti ini ke view utama lo
        } else {
            ZStack {
                // Background gradient ungu ke biru neon
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple, Color.blue]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
                
                // Logo Ballvive
                Image("Ballvive Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300) // Dari 200x200 jadi 300x300
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.easeIn(duration: 1.5)) {
                            self.opacity = 1.0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation {
                                self.isActive = true
                            }
                        }
                    }
            }
        }
    }
}

// Preview
struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
