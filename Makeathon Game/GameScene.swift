//
//  GameScene.swift
//  Makeathon Game
//
//  Created by Basanta Chaudhuri on 7/17/17.
//  Copyright © 2017 Abhishek Chaudhuri. All rights reserved.
//

import SpriteKit

enum GameState {
    case active, gameOver
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    // Sprites
    var hero: SKSpriteNode!
    var damsel: SKSpriteNode!
    var cookie: SKSpriteNode!
    
    // Labels & Buttons
    static var scoreLabel: SKLabelNode! // Required to make score static
    var buttonRestart: MSButtonNode!
    var buttonContinue: MSButtonNode!
    
    static var score = 0 { // Allows same score to carry over between levels
        didSet {
            scoreLabel.text = String(score)
        }
    }
    var winMessage: SKLabelNode = {
        let label = SKLabelNode(fontNamed: "Helvetica Neue Bold")
        label.fontSize = 48
        label.fontColor = .green
        label.position = CGPoint(x: 0, y: 0)
        label.zPosition = 2
        label.text = "You win!"
        return label
    } () // Don't forget parentheses!
    var loseMessage: SKLabelNode = {
        let label = SKLabelNode(fontNamed: "Helvetica Neue Bold")
        label.fontSize = 48
        label.fontColor = .red
        label.position = CGPoint(x: 0, y: 0)
        label.zPosition = 2
        label.text = "You lose!"
        return label
    } ()
    var continueMessage: SKLabelNode = {
        let label = SKLabelNode(fontNamed: "Helvetica Neue Bold")
        label.fontSize = 24
        label.fontColor = .yellow
        label.position = CGPoint(x: 210, y: -65)
        label.zPosition = 2
        label.text = "Continue?"
        return label
    } ()
    var highScoreLabel: SKLabelNode = {
        let label = SKLabelNode(fontNamed: "Helvetica Neue Bold")
        label.fontSize = 48
        label.fontColor = .blue
        label.position = CGPoint(x: 0, y: -40)
        label.zPosition = 2
        label.text = "High Score: \(UserDefaults().integer(forKey: "highscore"))"
        return label
    } ()
    
    // Other variables
    var gameState: GameState = .active
    var touchCount = 0
    var touchLimit = 2
    var onGround = true // Player always starts on the ground
    static var levelNumber = 1 // Program will always know which level a player is in between all functions
    
    override func didMove(to view: SKView) {
        // Called immediately after scene is loaded into view
        hero = childNode(withName: "hero") as? SKSpriteNode
        damsel = childNode(withName: "damsel") as? SKSpriteNode
        cookie = childNode(withName: "cookie") as? SKSpriteNode
        GameScene.scoreLabel = childNode(withName: "score") as? SKLabelNode
        buttonRestart = childNode(withName: "buttonRestart") as? MSButtonNode
        buttonContinue = childNode(withName: "buttonContinue") as? MSButtonNode
        
        if gameState == .active {
            buttonContinue.isHidden = true
        }
        
        // Setup physics contacts
        physicsWorld.contactDelegate = self
        
        buttonRestart.selectedHandler = {
            let sound = SKAction.playSoundFileNamed("click3.wav", waitForCompletion: false)
            self.run(sound)
            
            GameScene.score = 0 // Reset score every time player restarts
            let skView = self.view as SKView?
            self.isPaused = false // Unpauses the game
            guard let scene = GameScene(fileNamed: "Level_\(GameScene.levelNumber)") as GameScene? else {
                return
            }
            scene.scaleMode = .aspectFit
            skView?.presentScene(scene)
        }
        buttonContinue.selectedHandler = {
            let sound = SKAction.playSoundFileNamed("click3.wav", waitForCompletion: false)
            self.run(sound)
            
            GameScene.levelNumber += 1
            if GameScene.levelNumber > 10 { GameScene.levelNumber = 1 } // Game loops after last level
            
            // Same as loadGame()
            guard let skView = self.view as SKView? else {
                print("Could not get SKView")
                return
            }
            
            guard let scene = GameScene.level(GameScene.levelNumber) else {
                print("Could not load GameScene with level \(GameScene.levelNumber)")
                return
            }
            
            self.isPaused = false
            scene.scaleMode = .aspectFit
            skView.showsFPS = true
            let fade = SKTransition.fade(withDuration: 1)
            
            skView.presentScene(scene, transition: fade)
        }
    }
    
    // Make a class method to load levels
    class func level(_ levelNumber: Int) -> GameScene? {
        guard let scene = GameScene(fileNamed: "Level_\(levelNumber)") else {
            return nil
        }
        scene.scaleMode = .aspectFit // For iPad support
        return scene
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Called once a touch is detected
        if gameState != .active { return }                  // Disable touch at gameOver state
        if !onGround && touchCount >= touchLimit { return } // Or if player double jumped
        
        touchCount += 1
        let sound = SKAction.playSoundFileNamed("1.mp3", waitForCompletion: false)
        self.run(sound)
        
        switch GameScene.levelNumber {
            case 5:
                hero.physicsBody?.applyImpulse(CGVector(dx: 1, dy: 15))
            case 6:
                hero.physicsBody?.applyImpulse(CGVector(dx: 1, dy: -30))
            default:
                hero.physicsBody?.applyImpulse(CGVector(dx: 1, dy: 30)) // Default jump controls
        }
    }
    
    func playerScoreUpdate() {
        // Called once player wins
        addChild(highScoreLabel)
        let highScore = UserDefaults().integer(forKey: "highscore")
        
        if GameScene.score > highScore {
            UserDefaults().set(GameScene.score, forKey: "highscore") // New high score set
            highScoreLabel.text = "High Score: \(GameScene.score)"
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if gameState != .active { return }
        
        switch GameScene.levelNumber {
            case 5:
                self.physicsWorld.gravity = CGVector(dx: 0, dy: -1.6) // On level 5, player is on the moon
            case 6:
                self.physicsWorld.gravity = CGVector(dx: 0, dy: 9.8) // On level 6, player is upside down
            case 10:
                self.physicsWorld.gravity = CGVector(dx: 0, dy: -24) // On level 10, player is on Jupiter
            default:
                break
        }
        
        // If player goes off screen, game over
        if hero.position.x < -299 || hero.position.x > 299 || hero.position.y < -175 || hero.position.y > 175 {
            let sound = SKAction.playSoundFileNamed("06 powerUp3.mp3", waitForCompletion: false)
            self.run(sound)
            addChild(loseMessage)
            gameState = .gameOver
            playerScoreUpdate()
            self.isPaused = true
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        // Called when two bodies make contact
        if gameState != .active { // Prevents this function from accidentally running twice between levels
            return // print("Hah! Take that, glitch!")
        }
        
        let contactA = contact.bodyA
        let contactB = contact.bodyB
        guard let nodeA = contactA.node else { return }
        guard let nodeB = contactB.node else { return }
        
        // We don't know who made contact with whom
        if nodeA.name == "ground" || nodeB.name == "ground" {
            // Reset jump counter when on ground
            onGround = true
            touchCount = 0
        } else {
            onGround = false // This will cue double jump counter
        }
        
        if nodeA.name == "cookie" || nodeB.name == "cookie" {
            // Cookies are worth points and are then removed from the scene
            GameScene.score += 1
            if nodeA.name == "cookie" { nodeA.removeFromParent() }
            else { nodeB.removeFromParent() }
        }
        
        if nodeA.name == "damsel" || nodeB.name == "damsel" {
            // Player wins when reaching the damsel
            let sound = SKAction.playSoundFileNamed("12 powerUp12.mp3", waitForCompletion: false)
            self.run(sound)
            addChild(winMessage)
            addChild(continueMessage)
            gameState = .gameOver
            buttonContinue.isHidden = false
            self.isPaused = true
        }
    }
}
