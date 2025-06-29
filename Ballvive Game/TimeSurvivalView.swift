import SwiftUI
import SpriteKit

struct TimeSurvivalView: View {
    var scene: SKScene {
        let scene = TimeSurvivalScene()
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
    TimeSurvivalView()
}

