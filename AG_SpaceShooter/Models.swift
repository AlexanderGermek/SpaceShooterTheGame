//
//  Models.swift
//  AG_SpaceShooter
//
//  Created by iMac on 02.02.2021.
//

import UIKit
import SpriteKit

enum ColliderType: UInt32 {
    case alienCategory  = 1
    case bulletCategory = 2
}



struct Alien {
    
    var alienMask: ColliderType = .alienCategory
    var alienImageName: String
    var alienNode: SKSpriteNode
    
    init() {
        alienImageName  = ["alien", "alien2", "alien3"].shuffled()[0]
        alienNode       = SKSpriteNode(imageNamed: alienImageName) 
    }

}
