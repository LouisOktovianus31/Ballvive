import SpriteKit
import GameplayKit
import SwiftUI

class BallSurvivalScene: SKScene, SKPhysicsContactDelegate {
    private var platform: SKSpriteNode!
    private var timerLabel: SKLabelNode!
    private var highScoreLabel: SKLabelNode!
    private var tapToStartLabel: SKLabelNode!

    private var balls: [SKShapeNode] = []
    private var startTime: TimeInterval?
    private var isGameRunning = false
    private var ballCount = 0
    private var highestBallCount = 0

    private let ballRadius: CGFloat = 15
    private let platformWidth: CGFloat = 300
    private let sensitivity: CGFloat = 0.0015
    private let maxTilt: CGFloat = .pi / 4

    override func didMove(to view: SKView) {
        setupGradientBackground(for: self)
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsWorld.contactDelegate = self

        setupPlatform()
        setupDivider()
        setupUI()
        
        highestBallCount = UserDefaults.standard.integer(forKey: "BallSurvivalHighScore")
        highScoreLabel.text = "Highest Ball Survival: \(highestBallCount)"
    }


    func setupPlatform() {
        platform = SKSpriteNode(color: .white, size: CGSize(width: platformWidth, height: 20))
        platform.position = CGPoint(x: frame.midX, y: frame.minY + 360)
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

        timerLabel = SKLabelNode(text: "Count Ball: 0")
        timerLabel.fontColor = .white
        timerLabel.fontSize = 20
        timerLabel.fontName = "AvenirNext-Regular"
        timerLabel.horizontalAlignmentMode = .left
        timerLabel.position = CGPoint(x: 20, y: frame.minY + 210)
        addChild(timerLabel)

        highScoreLabel = SKLabelNode(text: "Highest Ball Survival: 0")
        highScoreLabel.fontColor = .white
        highScoreLabel.fontSize = 20
        highScoreLabel.fontName = "AvenirNext-Regular"
        highScoreLabel.horizontalAlignmentMode = .left
        highScoreLabel.position = CGPoint(x: 20, y: frame.minY + 180)
        addChild(highScoreLabel)
    }

    func startGame() {
        // Reset skor & waktu
        ballCount = 0

        // Hapus semua bola dari scene
        for ball in balls {
            ball.removeFromParent()
        }
        balls.removeAll()

        isGameRunning = true
        startTime = CACurrentMediaTime()

        // Hapus semua label instruksi dan lose
        removeChildren(in: children.filter { $0.name == "tapLabel" || $0.name == "loseLabel" })

        // Mulai spawn bola terus menerus
        let spawnAction = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run { self.addBall() },
                SKAction.wait(forDuration: 10)
            ])
        )
        run(spawnAction, withKey: "spawnBalls")
    }


    func addBall() {
        if !isGameRunning { return }

        let ball = SKShapeNode(circleOfRadius: ballRadius)
        ball.fillColor = .systemPink
        ball.position = CGPoint(x: frame.midX, y: frame.midY + 200)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ballRadius)
        ball.physicsBody?.restitution = 0.4
        ball.physicsBody?.friction = 0.3
        ball.name = "ball"
        ball.zPosition = 10

        addChild(ball)
        balls.append(ball)

        ballCount += 1
        timerLabel.text = "Count Ball: \(ballCount)"
    }

    override func update(_ currentTime: TimeInterval) {
        guard isGameRunning else { return }

        for ball in balls {
            if ball.position.y < frame.minY {
                ball.run(SKAction.sequence([
                    SKAction.fadeOut(withDuration: 0.3),
                    SKAction.removeFromParent()
                ]))

                endGame()
                break
            }
        }
    }

    func endGame() {
        isGameRunning = false
        removeAction(forKey: "spawnBalls")

        if ballCount > highestBallCount {
            highestBallCount = ballCount
            UserDefaults.standard.set(highestBallCount, forKey: "BallSurvivalHighScore")
            highScoreLabel.text = "Highest Ball Survival: \(highestBallCount)"
        }


        let loseLabel = SKLabelNode(text: "You Lose the Ball!\nYour count ball is \(ballCount)")
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

        tapToStartLabel = SKLabelNode(text: "Tap to Get Ready!")
        tapToStartLabel.fontColor = .white
        tapToStartLabel.fontSize = 20
        tapToStartLabel.fontName = "AvenirNext-Regular"
        tapToStartLabel.position = CGPoint(x: frame.midX, y: frame.minY + 430)
        tapToStartLabel.name = "tapLabel"
        tapToStartLabel.zPosition = 99
        addChild(tapToStartLabel)
    }

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
