//
//  GameScene.swift
//  AvoidShit
//
//  Created by Taejong Han on 2022/09/15.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory {
    static let none :UInt32 = 0
    static let all  :UInt32 = UInt32.max
    static let shit :UInt32 = 0b1
    static let human:UInt32 = 0b10
}

class GameScene: SKScene {
    let human = SKSpriteNode(imageNamed: "human")
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.shit != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.human != 0)){
            if let shit = firstBody.node as? SKSpriteNode,
               let human = secondBody.node as? SKSpriteNode {
                humanDidCollideShit(human: human, shit: shit)
            }
        }
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        physicsWorld.gravity = CGVector(dx: 0, dy: -1.62)
        physicsWorld.contactDelegate = self
        
        human.position = CGPoint(x: 0, y: -size.height/2 + human.size.height/2)
        human.physicsBody = SKPhysicsBody(rectangleOf: human.size)
        //중력영향 안받음!
        human.physicsBody?.isDynamic = false
        human.physicsBody?.categoryBitMask = PhysicsCategory.human
        human.physicsBody?.contactTestBitMask = PhysicsCategory.shit
        human.physicsBody?.collisionBitMask = PhysicsCategory.none
        addChild(human)
        
        //떨어저라 shit
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(addShit), SKAction.wait(forDuration: 0.5)])))
    }
    
    func random() -> CGFloat {
      return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }

    func random(min: CGFloat, max: CGFloat) -> CGFloat {
      return random() * (max - min) + min
    }
    
    func addShit(){
        let shit = SKSpriteNode(imageNamed: "shit")
        shit.physicsBody = SKPhysicsBody(circleOfRadius: shit.size.width/2)
        shit.physicsBody?.isDynamic = true
        shit.physicsBody?.categoryBitMask = PhysicsCategory.shit
        shit.physicsBody?.contactTestBitMask = PhysicsCategory.human
        shit.physicsBody?.collisionBitMask = PhysicsCategory.none
        shit.physicsBody?.usesPreciseCollisionDetection = true
        
        let actualX = random(min: (-size.width/2)+(shit.size.width/2), max:size.width/2 - shit.size.width/2)
        shit.position = CGPoint(x: actualX, y: size.height/2 - shit.size.height/2)
        addChild(shit)
        
        //떨어지는 속도 지정
        let actualDuration = random(min:CGFloat(2.0), max:CGFloat(4.0))
        //떨어지는 애니메이션
        let actionMove = SKAction.move(to: CGPoint(x: actualX, y: -size.height), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        shit.run(SKAction.sequence([actionMove, actionMoveDone]))
                                       
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        
        //터치한 위치와 휴먼의 차이만 큼 이동
        let actionMove = SKAction.move(to: CGPoint(x: touchLocation.x, y: human.position.y), duration: 1.0)
        human.run(SKAction.sequence([actionMove]))
    }
    
    func humanDidCollideShit(human:SKSpriteNode, shit:SKSpriteNode){
        print("HIT")
        //GameOver
    }
}

extension GameScene: SKPhysicsContactDelegate{
    
}
