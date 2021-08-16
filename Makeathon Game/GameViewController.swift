//
//  GameViewController.swift
//  Makeathon Game
//
//  Created by Basanta Chaudhuri on 7/17/17.
//  Copyright © 2017 Abhishek Chaudhuri. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation // For background music

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'TitleScreen.sks'
            if let scene = SKScene(fileNamed: "TitleScreen") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            // Background music
            do {
                let soundFilePath = Bundle.main.path(forResource: "397796__blockfighter298__modern-6-basic-loop", ofType: "wav")
                let soundFileURL = URL(fileURLWithPath: soundFilePath!)
                let player = try AVAudioPlayer(contentsOf: soundFileURL)
                player.numberOfLoops = -1 // Infinite loop
                player.prepareToPlay()
                player.play()
            } catch {
                print("Music can't be played.")
            }
            
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
