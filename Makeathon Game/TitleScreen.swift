//
//  TitleScreen.swift
//  Makeathon Game
//
//  Created by Basanta Chaudhuri on 7/18/17.
//  Copyright © 2017 Abhishek Chaudhuri. All rights reserved.
//

import SpriteKit

class TitleScreen: SKScene {
    var buttonStart: MSButtonNode!
    
    override func didMove(to view: SKView) {
        buttonStart = childNode(withName: "buttonStart") as? MSButtonNode
        
        buttonStart.selectedHandler = {
            let sound = SKAction.playSoundFileNamed("click3.wav", waitForCompletion: false)
            self.run(sound)
            
            self.loadGame(level: 1)
        }
    }
    
    // Will load any level created
    func loadGame(level: Int) {
        guard let skView = self.view as SKView? else {
            print("Could not get SKView")
            return
        }
        
        guard let scene = GameScene.level(level) else {
            print("Could not load GameScene with level \(level)")
            return
        }
        
        scene.scaleMode = .aspectFit
        skView.showsFPS = true
        let fade = SKTransition.fade(withDuration: 1)
        
        skView.presentScene(scene, transition: fade)
    }
}
