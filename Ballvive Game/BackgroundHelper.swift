import Foundation
import SwiftUI
import SpriteKit

func setupGradientBackground(for scene: SKScene) {
    let texture = gradientTexture(size: scene.size)
    let gradientNode = SKSpriteNode(texture: texture)
    gradientNode.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
    gradientNode.zPosition = -100
    scene.addChild(gradientNode)
}

func gradientTexture(size: CGSize) -> SKTexture {
    let gradientLayer = CAGradientLayer()
    gradientLayer.frame = CGRect(origin: .zero, size: size)
    gradientLayer.colors = [UIColor.purple.cgColor, UIColor.blue.cgColor]
    gradientLayer.startPoint = CGPoint(x: 0, y: 0)
    gradientLayer.endPoint = CGPoint(x: 1, y: 1)

    let renderer = UIGraphicsImageRenderer(size: size)
    let image = renderer.image { ctx in
        gradientLayer.render(in: ctx.cgContext)
    }

    return SKTexture(image: image)
}
