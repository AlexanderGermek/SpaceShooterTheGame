//
//  GameViewController.swift
//  AG_SpaceShooter
//
//  Created by iMac on 02.02.2021.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    weak var currentScene: SKScene!

    override func viewDidLoad() {
        super.viewDidLoad()
        

        if let view = self.view as! SKView? {

            if let scene = SKScene(fileNamed: "MainMenuScene") as? MainMenu {

                scene.scaleMode = .aspectFill
                scene.myViewController = self
                self.currentScene = scene
                
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            //Тестировка:
            //view.showsFPS = true
            //view.showsNodeCount = true
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

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if self.currentScene.name == "GameScene" {
            return
        }
        
        let touch = touches.first
        
        if let location = touch?.location(in: self.currentScene) {
            let nodesArray = self.currentScene.nodes(at: location)

            if nodesArray.first?.name == "creatorsLabel" {
                let message = "Alex Germek\n" + "email: aggermek@mail.ru"
                let alertController = UIAlertController(title: "Разработчики", message: message, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
      }
    }
}
