//
//  MainMenu.swift
//  AG_SpaceShooter
//
//  Created by iMac on 02.02.2021.
//

import SpriteKit

class MainMenu: SKScene {
    
    var starfield:         SKEmitterNode!
    var newGameBtnNode:    SKSpriteNode!
    var changeLvlBtnNode:  SKSpriteNode!
    var levelLabelNode:    SKLabelNode!
    var creatorsLabelNode: SKLabelNode!
    var myViewController : UIViewController!
    var maxScoreLabel:     SKLabelNode!
    var maxScore: Int = 0 {
        didSet {
            maxScoreLabel.text = "Max score: \(maxScore)"
        }
    }
    
    override func didMove(to view: SKView) {
        
        starfield = self.childNode(withName: "starfieldAnimation") as? SKEmitterNode
        starfield.advanceSimulationTime(10)
        
        newGameBtnNode   = self.childNode(withName: "newGameButton")   as? SKSpriteNode
        changeLvlBtnNode = self.childNode(withName: "changeLvlButton") as? SKSpriteNode
        levelLabelNode   = self.childNode(withName: "currentLvlLabel") as? SKLabelNode
        maxScoreLabel    = self.childNode(withName: "maxScoreLabel")   as? SKLabelNode
        
        
        let userDef = UserDefaults.standard
        
        self.maxScore = userDef.integer(forKey: "maxScore")
        
        
        let userLevel = userDef.string(forKey: "level")
                
        if userLevel == "Сложно"{
            levelLabelNode.text = "Сложно"
        } else  if  userLevel == "Легко"{
            levelLabelNode.text = "Легко"
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        if let location = touch?.location(in: self) {
            let nodesArray = self.nodes(at: location)
            
            if nodesArray.first?.name == "newGameButton" {
                let transition = SKTransition.flipVertical(withDuration: 0.5)
                let gameScene = SKScene(fileNamed: "GameScene")! as! GameScene
                gameScene.size = UIScreen.main.bounds.size
                (self.myViewController as! GameViewController).currentScene = gameScene
                gameScene.myViewController = self.myViewController
                self.view?.presentScene(gameScene, transition: transition)
                
            } else if nodesArray.first?.name == "changeLvlButton"{
                changeLevel()
            }
        }
    }

    
    func changeLevel() {
        let userLevel = UserDefaults.standard
        
        if levelLabelNode.text == "Легко" {
            levelLabelNode.text = "Сложно"
            userLevel.setValue("Сложно", forKey: "level")
        } else if levelLabelNode.text == "Сложно"{
            levelLabelNode.text = "Легко"
            userLevel.setValue("Легко", forKey: "level")
        }
    }

}
