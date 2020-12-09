//
//  GameScene.swift
//  Project26 - CoreMotion
//
//  Created by Nick Harris on 09/08/2020.
//  Copyright © 2020 Nick Harris. All rights reserved.
//

import SpriteKit
import CoreMotion

enum CollisionTypes: UInt32 {
    case player = 1
    case wall = 2
    case star = 4
    case vortex = 8
    case finish = 16
    case teleport = 32
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var player: SKSpriteNode!
    var motionManager: CMMotionManager?
    var lastTouchPosition: CGPoint?
    
    var scoreLabel: SKLabelNode!
var level = 3
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var isGameOver = false
    var isTeleporting = false
    
override func didMove(to view: SKView) {
    
    
    

    

    createScore()
    createBackground()
    createPlayer()
        loadLevel()
     
    physicsWorld.gravity = .zero
    physicsWorld.contactDelegate = self
    
    
    motionManager = CMMotionManager()
    motionManager?.startAccelerometerUpdates()
    }
    
    func createScore() {
            scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: \(score)"
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.zPosition = 2
        addChild(scoreLabel)    }
    
    func createBackground() {
            let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
    }
    func createPlayer() {
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 96, y: 672)
        player.zPosition = 1
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody?.allowsRotation = false
        //would ruin shadowing on image
        player.physicsBody?.linearDamping = 0.5
//applies friction to movement makes game slightly easier
        player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player.physicsBody?.contactTestBitMask = CollisionTypes.star.rawValue | CollisionTypes.vortex.rawValue | CollisionTypes.finish.rawValue | CollisionTypes.teleport.rawValue        //combines the enums to create  value
        player.physicsBody?.collisionBitMask = CollisionTypes.wall.rawValue
        addChild(player)
    }
    func loadLevel() {
        
        guard let levelURL = Bundle.main.url(forResource: "level\(level)", withExtension: "txt") else { fatalError("Could not find level\(level).txt in app bundle") }
        //if we can't find level 1 txt then bail out immediately
        
        
        guard let levelString = try? String(contentsOf: levelURL) else { fatalError("Could not load level1.txt in app bundle") }
        //if we can't load into a string bail out
        
        //we know for sure that we have found the URL
        
        let lines =  levelString.components(separatedBy: "\n")
            var count = 1
        
        for (row, line) in lines.reversed().enumerated() {
            for (column, letter) in line.enumerated() {
                let position = CGPoint(x: (64 * column) + 32, y: (64 * row) + 32)
                
            if letter == "x" {
                                // load wall
                loadWall(position: position)
            } else if letter == "v"  {
                loadVortex(position: position)
                              
                            } else if letter == "s"  {
                loadStar(position: position)
                                                         }
            else if letter == "f"  {
                loadFinish(position: position)
                            } else if letter == " " {
                                // this is an empty space – do nothing!
            } else if letter == "t" {
            
                loadTeleport(position: position, count: count)
                count += 1
            }
            
            
            else {
                                fatalError("Unknown level letter: \(letter)")
                            }
                        }
                    }
                }
    
    func loadTeleport(position: CGPoint, count: Int) {
        let node = SKSpriteNode(imageNamed: "penguinGood")
        node.position = position
              node.name = "teleport\(count)"
          node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
          node.physicsBody?.isDynamic = false
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
         node.physicsBody?.categoryBitMask = CollisionTypes.teleport.rawValue
        print("\(position)")
        addChild(node)
        
    }
    func loadWall(position: CGPoint) {
         let node = SKSpriteNode(imageNamed: "block")
                       node.position = position

                       node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
                       node.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
                       node.physicsBody?.isDynamic = false
                       addChild(node)
        
    }
    
    func loadVortex(position: CGPoint) {
         let node = SKSpriteNode(imageNamed: "vortex")
                                       node.name = "vortex"
                                       node.position = position
                                       node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
                                       node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
                                       node.physicsBody?.isDynamic = false

                                       node.physicsBody?.categoryBitMask = CollisionTypes.vortex.rawValue
                                       node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
                       
                       //want to be notified when the player is hit
                                       node.physicsBody?.collisionBitMask = 0
                                       addChild(node)
        
    }
    
    func loadStar(position: CGPoint) {
         let node = SKSpriteNode(imageNamed: "star")
        node.name = "star"
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = CollisionTypes.star.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        node.position = position
        addChild(node)
        
    }
    
    func loadFinish(position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "finish")
        node.name = "finish"
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false

        node.physicsBody?.categoryBitMask = CollisionTypes.finish.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        node.position = position
        addChild(node)    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPosition = location
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPosition = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchPosition = nil
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }

        if nodeA == player {
            playerCollided(with: nodeB)
        } else if nodeB == player {
            playerCollided(with: nodeA)
        }
    }
    
    func playerCollided(with node: SKNode) {
         if node.name == "vortex" {
               player.physicsBody?.isDynamic = false
               isGameOver = true
               score -= 1

               let move = SKAction.move(to: node.position, duration: 0.25)
               let scale = SKAction.scale(to: 0.0001, duration: 0.25)
               let remove = SKAction.removeFromParent()
               let sequence = SKAction.sequence([move, scale, remove])

               player.run(sequence) { [weak self] in
                   self?.createPlayer()
                   self?.isGameOver = false
               }
           } else if node.name == "star" {
               node.removeFromParent()
               score += 1
        } else if node.name == "teleport1" {
            isTeleporting = true
           print("teleport1")
            score += 1
               let move = SKAction.move(to: node.position, duration: 0.25)
                        let scale = SKAction.scale(to: 0.0001, duration: 0.25)
                        let sequence = SKAction.sequence([move, scale])
            
            player.run(sequence) { [weak self] in
                self?.player.position = CGPoint(x: 288, y: 672 )
                self?.isTeleporting = false
            }
            
        } else if node.name == "teleport2" {
            print("teleport2")
            isTeleporting = true
            score += 1
               let move = SKAction.move(to: node.position, duration: 0.25)
                        let scale = SKAction.scale(to: 0.0001, duration: 0.25)
                        
                        let sequence = SKAction.sequence([move, scale])
            
            player.run(sequence) { [weak self] in
                self?.player.position = CGPoint(x: 250, y: 288 )
                self?.isTeleporting = false
            }
            
            
            
        }        else if node.name == "finish" {
               level = level+1
            
            
            player.removeFromParent()
            self.removeAllChildren()
            createBackground()
            createPlayer()
            createScore()
            loadLevel()
           }
    }
        
        override func update(_ currentTime: TimeInterval) {
            
            guard isGameOver == false else { return }
            guard isTeleporting == false else { return }
    #if targetEnvironment(simulator)
        if let currentTouch = lastTouchPosition {
            let diff = CGPoint(x: currentTouch.x - player.position.x, y: currentTouch.y - player.position.y)
            physicsWorld.gravity = CGVector(dx: diff.x / 100, dy: diff.y / 100)
        }
    #else
        if let accelerometerData = motionManager.accelerometerData {
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)
        }
    #endif
    }
    
}
