import SwiftUI
import SpriteKit

struct BallSurvivalView: View {
    var scene: SKScene {
        let scene = BallSurvivalScene()
        scene.size = UIScreen.main.bounds.size
        scene.scaleMode = .resizeFill
        return scene
    }

    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
    }
}


#Preview {
    BallSurvivalView()
}
