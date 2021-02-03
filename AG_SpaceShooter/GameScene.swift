//
//  GameScene.swift
//  AG_SpaceShooter
//
//  Created by iMac on 02.02.2021.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var starfield:  SKEmitterNode!
    var player:     SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var gameEnemyTimer: Timer!
    let scoreStep: Int = 10
    var livesLabel: SKLabelNode!
    var myViewController : UIViewController!
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Счет: \(score)"
        }
    }
    
    var lives: Int = 3 {
        didSet {
            livesLabel.text = "Жизни: \(lives)"
        }
    }
    
    var aliensObject: [Alien] = []
     
    
    let motionManager = CMMotionManager()
    var xAccelerate: CGFloat = 0

    override func didMove(to view: SKView) {
        
        //Game starfield:
        starfield = SKEmitterNode(fileNamed: "Starfield")
        starfield.position  = CGPoint(x: 0, y: UIScreen.main.bounds.maxY)
        starfield.zPosition = -1
        starfield.advanceSimulationTime(20)
        self.addChild(starfield)
        
        
        //Game Player:
        player = SKSpriteNode(imageNamed: "shuttle")
        player.position = CGPoint(x: UIScreen.main.bounds.width / 2, y: 25)
        self.addChild(player)
        
        
        //Score Label:
        scoreLabel = SKLabelNode(text: "Счет : 0")
        scoreLabel.fontName  = "AmericanTypewriter-Bold"
        scoreLabel.fontSize  = 20
        scoreLabel.fontColor = .white
        scoreLabel.position  = CGPoint(x: 50, y: UIScreen.main.bounds.height - 30)//CGPoint(x: 100, y: 100)
        self.addChild(scoreLabel)
        
        //Lives label:
        livesLabel = SKLabelNode(text: "Жизни : 3")
        livesLabel.fontName  = "AmericanTypewriter-Bold"
        livesLabel.fontSize  = 20
        livesLabel.fontColor = .white
        livesLabel.position  = CGPoint(x: UIScreen.main.bounds.width - 50, y: UIScreen.main.bounds.height - 30)
        self.addChild(livesLabel)
        
        
        //Settings:
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        //Game timer for creation enemies:
        let isHard = UserDefaults.standard.string(forKey: "level") == "Сложно"
        lives = isHard ? 3 : 5
        let timeInterval = isHard ? 1.0 : 2.0
        gameEnemyTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true)
        
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data, error) in
            
            if let aData = data {
                let acceleration = aData.acceleration
                self.xAccelerate = CGFloat(acceleration.x) * 0.75 + self.xAccelerate * 0.25
            }
        }
    }
    
    
    // 1. Меняем позицию игрока по акселерометру:
    override func didSimulatePhysics() {
        player.position.x += xAccelerate * 50
        
        if player.position.x < 0 {
            player.position = CGPoint(x: UIScreen.main.bounds.width - player.size.width, y: player.position.y)
            
        } else if player.position.x > UIScreen.main.bounds.width {
            player.position = CGPoint(x: 20, y: player.position.y)
            
        }
    }
    
    // 2. Добавляем алиенов по таймеру:
    @objc func addAlien(){
        
        let alien = Alien()
        self.aliensObject.append(alien)
        
        let alienNode = alien.alienNode
        
        let randomPosition = GKRandomDistribution(lowestValue: 25, highestValue: Int(UIScreen.main.bounds.size.width) - 25)
        let pos = CGFloat(randomPosition.nextInt())
        
        alienNode.position    = CGPoint(x: pos, y: UIScreen.main.bounds.size.height + alienNode.size.height)
        alienNode.physicsBody = SKPhysicsBody(rectangleOf: alienNode.size)
        alienNode.physicsBody?.isDynamic = true
        
        alienNode.physicsBody?.categoryBitMask    = ColliderType.alienCategory.rawValue
        alienNode.physicsBody?.contactTestBitMask = ColliderType.bulletCategory.rawValue
        alienNode.physicsBody?.collisionBitMask   = 0
        
        self.addChild(alienNode)
        
        let animDuration: TimeInterval = 6
        
        var actions = [SKAction]()
        actions.append(SKAction.move(to: CGPoint(x: pos, y: -alienNode.size.height), duration: animDuration))
        actions.append(SKAction.removeFromParent())
        
        alienNode.run(SKAction.sequence(actions))
        
    }
    
    // 3. Действия при выстреле:
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        fireBullet()
    }
    
    func fireBullet() {
        self.run(SKAction.playSoundFileNamed("vzriv.mp3", waitForCompletion: false))
        
        let bullet = SKSpriteNode(imageNamed: "torpedo")
        bullet.position = player.position
        bullet.position.y += player.size.height / 2
        
        
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width / 2)
        bullet.physicsBody?.isDynamic = true
        
        bullet.physicsBody?.categoryBitMask    = ColliderType.bulletCategory.rawValue
        bullet.physicsBody?.contactTestBitMask = ColliderType.alienCategory.rawValue
        bullet.physicsBody?.collisionBitMask   = 0
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(bullet)
        
        let animDuration: TimeInterval = 0.3
        
        var actions = [SKAction]()
        actions.append(SKAction.move(to: CGPoint(x: player.position.x, y: UIScreen.main.bounds.size.height + bullet.size.height), duration: animDuration))
        actions.append(SKAction.removeFromParent())
        
        bullet.run(SKAction.sequence(actions))
    }
    
    // 4.  При столкновении объектов:
    func didBegin(_ contact: SKPhysicsContact) {
        var alienBody: SKPhysicsBody
        var bulletBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            alienBody = contact.bodyA
            bulletBody = contact.bodyB
        } else {
            alienBody = contact.bodyB
            bulletBody = contact.bodyA
        }
        
        if alienBody.categoryBitMask == ColliderType.alienCategory.rawValue && bulletBody.categoryBitMask == ColliderType.bulletCategory.rawValue {
            
            didCollision(bulletNode: bulletBody.node as! SKSpriteNode, andAlienNode: alienBody.node as! SKSpriteNode)
            
        }
    }

    // 5. Столкновение пули и алиена:
    func didCollision(bulletNode: SKSpriteNode, andAlienNode alienNode: SKSpriteNode){
        
        let explosion = SKEmitterNode(fileNamed: "Vzriv")!
        explosion.position = alienNode.position
        self.addChild(explosion)
        
        self.run(SKAction.playSoundFileNamed("vzriv.mp3", waitForCompletion: false))
        
        bulletNode.removeFromParent()
        
        self.aliensObject.removeAll{$0.alienNode.isEqual(alienNode)}
        
        alienNode.removeFromParent()
        
        self.run(SKAction.wait(forDuration: 2)){
            explosion.removeFromParent()
        }
        
        score += self.scoreStep
        
    }
        
    // 6. Функция вызывается после отрисовки каждого фрейма - проверяем есть ли еще жизни у игрока и заканчиваем игру если нет:
    override func didEvaluateActions() {
        for alien in self.aliensObject {
            
            let alienNode = alien.alienNode
            if alienNode.position.y < 0 {
                self.aliensObject.removeAll{$0.alienNode.isEqual(alienNode)}
                alienNode.removeFromParent()
                if self.lives > 0 {
                    self.lives -= 1
                    if self.lives == 0 {
                        finishedGame()
                    }
                }
                
            }
        }
    }
    
    // 7. Вывод алерта об окончании игры:
    func finishedGame() {
        setMaxScore(fromCurrentScore: score)
        let message = "Ваш счет: \(score)"
        let alertController = UIAlertController(title: "Игра окончена!", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Начать заново", style: .default, handler: {action in self.toNextGame()})
        let mainMenuAction = UIAlertAction(title: "В главное меню", style: .cancel, handler: {action in self.toMainMenu()})
        
        alertController.addAction(mainMenuAction)
        alertController.addAction(okAction)
        
        self.myViewController.present(alertController, animated: true, completion: nil)
    }
    
    // 8. После окончания игры - проверяем и изменяем максимальное количество очков:
    func setMaxScore(fromCurrentScore score: Int) {
        
        let userDef = UserDefaults.standard
        let maxScore = userDef.integer(forKey: "maxScore")
        if score > maxScore {
            userDef.setValue(score, forKey: "maxScore")
            
        }
        
    }
    
    // 9. Переход в главное меня после окончания игры:
    @objc func toMainMenu() {
        let transition = SKTransition.flipVertical(withDuration: 0.5)
        let mainMenuScene = SKScene(fileNamed: "MainMenuScene")! as! MainMenu
        mainMenuScene.size = CGSize(width: 750, height: 1334)
        mainMenuScene.scaleMode = .aspectFill

        (self.myViewController as! GameViewController).currentScene = mainMenuScene
        mainMenuScene.myViewController = self.myViewController
        self.view?.presentScene(mainMenuScene, transition: transition)
    }
    
    // 10. Запуск новой игры после окончания предыдущей:
    @objc func toNextGame() {
        let transition = SKTransition.flipVertical(withDuration: 0.5)
        let gameScene = SKScene(fileNamed: "GameScene")! as! GameScene
        (self.myViewController as! GameViewController).currentScene = gameScene
        gameScene.myViewController = self.myViewController
        self.view?.presentScene(gameScene, transition: transition)
    }
    

    
    // НЕИСПОЛЬЗОВАНННЫЕ ФУНКЦИИ:
//    func touchDown(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.green
//            self.addChild(n)
//        }
//    }
//
//    func touchMoved(toPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.blue
//            self.addChild(n)
//        }
//    }
//
//    func touchUp(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.red
//            self.addChild(n)
//        }
//    }
//
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if let label = self.label {
//            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
//        }
//
//        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
//    }
//
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
//    }
//
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
//    }
//
//
//    override func update(_ currentTime: TimeInterval) {
//        // Called before each frame is rendered
//    }
}
