import SpriteKit
import SwiftUI
import UIKit

class TimeSurvivalScene: SKScene, SKPhysicsContactDelegate {

    private var ball: SKShapeNode?
    private var platform: SKSpriteNode!
    private var timerLabel: SKLabelNode!
    private var highScoreLabel: SKLabelNode!
    private var tapToStartLabel: SKLabelNode!

    private var startTime: TimeInterval?
    private var isGameRunning = false
    private var highestSurvivalTime: TimeInterval = 0

    // Kontrol dua jempol
    private let maxTilt: CGFloat = .pi / 4
    private let sensitivity: CGFloat = 0.0015

    override func didMove(to view: SKView) {
        setupGradientBackground(for: self)
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsWorld.contactDelegate = self

        setupPlatform()
        setupDivider()
        setupUI()
        
        highestSurvivalTime = UserDefaults.standard.double(forKey: "TimeSurvivalHighScore")
        highScoreLabel.text = String(format: "Highest time survival: %.2f S", highestSurvivalTime)
    }

    func setupPlatform() {
        platform = SKSpriteNode(color: .white, size: CGSize(width: 200, height: 20))
        platform.position = CGPoint(x: frame.midX, y: frame.minY + 360)
        platform.zRotation = .pi / 16
        platform.physicsBody = SKPhysicsBody(rectangleOf: platform.size)
        platform.physicsBody?.isDynamic = false
        addChild(platform)
        
        platform.zPosition = 20
    }

    func setupDivider() {
        let divider = SKSpriteNode(color: .white, size: CGSize(width: frame.width * 0.9, height: 2))
        divider.position = CGPoint(x: frame.midX, y: frame.minY + 260)
        addChild(divider)
        divider.zPosition = 100
    }

    func setupUI() {
        tapToStartLabel = SKLabelNode(text: "Tap to Get the Ball")
        tapToStartLabel.fontColor = .white
        tapToStartLabel.fontSize = 24
        tapToStartLabel.fontName = "AvenirNext-Bold"
        tapToStartLabel.position = CGPoint(x: frame.midX, y: frame.minY + 430)
        tapToStartLabel.name = "tapLabel"
        addChild(tapToStartLabel)

        timerLabel = SKLabelNode(text: "Time: 0.00 S")
        timerLabel.fontColor = .white
        timerLabel.fontSize = 20
        timerLabel.fontName = "AvenirNext-Regular"
        timerLabel.horizontalAlignmentMode = .left
        timerLabel.position = CGPoint(x: 20, y: frame.minY + 210)
        addChild(timerLabel)

        highScoreLabel = SKLabelNode(text: "Highest time survival: 0.00 S")
        highScoreLabel.fontColor = .white
        highScoreLabel.fontSize = 20
        highScoreLabel.fontName = "AvenirNext-Regular"
        highScoreLabel.horizontalAlignmentMode = .left
        highScoreLabel.position = CGPoint(x: 20, y: frame.minY + 180)
        addChild(highScoreLabel)
        
        timerLabel.zPosition = 100
        highScoreLabel.zPosition = 100
        tapToStartLabel.zPosition = 100
    }

    func startGame() {
        // Hapus semua label instruksi & end-game
        tapToStartLabel?.removeFromParent()
        
        // ✅ Hapus SEMUA label bernama "tapLabel" (bukan cuma satu)
        enumerateChildNodes(withName: "tapLabel") { node, _ in
            node.removeFromParent()
        }

        // ✅ Hapus lose label juga
        enumerateChildNodes(withName: "loseLabel") { node, _ in
            node.removeFromParent()
        }
        
        isGameRunning = true
        startTime = CACurrentMediaTime()
        addBall()
    }

    func addBall() {
        ball?.removeFromParent()
        
        ball?.alpha = 1.0

        ball = SKShapeNode(circleOfRadius: 25)
        ball?.fillColor = .systemPink
        ball?.position = CGPoint(x: frame.midX, y: frame.midY + 100)
        ball?.physicsBody = SKPhysicsBody(circleOfRadius: 25)
        ball?.physicsBody?.restitution = 0.4
        ball?.physicsBody?.linearDamping = 0.1
        ball?.physicsBody?.friction = 0.3
        ball?.name = "ball"
        ball?.zPosition = 10

        if let ball = ball {
            addChild(ball)
        }
    }

    override func update(_ currentTime: TimeInterval) {
        guard isGameRunning, let start = startTime else { return }

        let elapsed = currentTime - start
        timerLabel.text = String(format: "Time: %.2f S", elapsed)

        if let ball = ball, ball.position.y < frame.minY {
            let fade = SKAction.fadeOut(withDuration: 0.3)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([fade, remove])
            
            ball.run(sequence)
            
            // Panggil endGame sedikit delay setelah fade selesai
            run(SKAction.wait(forDuration: 0.3)) {
                self.endGame(elapsedTime: elapsed)
            }
        }
    }

    func endGame(elapsedTime: TimeInterval) {
        isGameRunning = false
        ball?.removeFromParent()

        // Update high score kalau perlu
        if elapsedTime > highestSurvivalTime {
            highestSurvivalTime = elapsedTime
            UserDefaults.standard.set(highestSurvivalTime, forKey: "TimeSurvivalHighScore")
            highScoreLabel.text = String(format: "Highest time survival: %.2f S", highestSurvivalTime)
        }
        
        // Hapus loseLabel sebelumnya kalau ada
        childNode(withName: "loseLabel")?.removeFromParent()

        let loseLabel = SKLabelNode(text: "You Lose the Ball!\nYour score is \(String(format: "%.2f", elapsedTime)) S")
        loseLabel.name = "loseLabel"
        loseLabel.fontColor = .red
        loseLabel.fontSize = 22
        loseLabel.numberOfLines = 2
        loseLabel.verticalAlignmentMode = .center
        loseLabel.horizontalAlignmentMode = .center
        loseLabel.fontName = "AvenirNext-Bold"
        loseLabel.position = CGPoint(x: frame.midX, y: frame.midY + 100) 
        loseLabel.zPosition = 100
        addChild(loseLabel)

        // Tampilkan instruksi mulai ulang
        tapToStartLabel = SKLabelNode(text: "Tap to Get Ready!")
        tapToStartLabel.fontColor = .white
        tapToStartLabel.fontSize = 20
        tapToStartLabel.fontName = "AvenirNext-Regular"
        tapToStartLabel.position = CGPoint(x: frame.midX, y: frame.minY + 430)
        tapToStartLabel.name = "tapLabel"
        tapToStartLabel.zPosition = 99
        addChild(tapToStartLabel)
    }


    // MARK: - Dua Jempol Kontrol
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isGameRunning {
            startGame()
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let allTouches = event?.allTouches, allTouches.count >= 2 else { return }

        let sortedTouches = allTouches.sorted { $0.location(in: self).x < $1.location(in: self).x }

        let leftY = sortedTouches.first!.location(in: self).y
        let rightY = sortedTouches.last!.location(in: self).y

        let deltaY = rightY - leftY
        let newRotation = -deltaY * sensitivity
        platform.zRotation = newRotation.clamped(to: -maxTilt...maxTilt)
    }
}


