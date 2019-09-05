//
//  colorScene.swift
//  TouchBarVisualizer
//
//  Created by Addison Hanrattie on 6/6/19.
//  Copyright © 2019 Addison Hanrattie. All rights reserved.
//

import Cocoa
import SpriteKit


class colorScene: SKScene {
    
    var ready = false
//    let wid : CGFloat = 22.5 //self.size.height * 0.75 // maybe delete this
    let height : CGFloat = 30.0
    let wid : CGFloat = 10.0
    
    var allNodes : [[SKSpriteNode]] = []
    
    override func didMove(to view: SKView) {
        print(self.size.width)
        self.backgroundColor = .black
        for i in 0...99 {
            var popul : [SKSpriteNode] = []
            for c in 0...10 {
                
                let x : CGFloat = wid * CGFloat(i + 1)
                
                let rectImg = NSImage(named: "square")
                
                let texture = SKTexture(imageNamed: "square")
                //            let rect = SKSpriteNode(texture: texture)
                let rect = SKSpriteNode(texture: texture, color: .red, size: CGSize(width: wid, height: 3))
                self.addChild(rect)
                //            rect.scale(to: CGSize(width: self.size.height * 1.25, height: self.size.height / 6))
                rect.position = CGPoint(x: x, y: (rect.size.height * CGFloat(c - 1)) + (rect.size.height / 2))
                
                popul.append(rect)
            }
            allNodes.append(popul)
        }
        
        if !ready {
            self.backgroundColor = .black
            ready = true
        }
        
//        levelFor(group: 0, level: 5)
//        levelFor(group: 1, level: 2)
//        levelFor(group: 2, level: 4)
//        levelFor(group: 3, level: 3)
    }
    
    
    func levelFor(group: Int, level: Int) {
        guard allNodes.count != 0 else { return }
        
        
        for i in 0...level {
            if i > 10 {
                continue
            }
            allNodes[group][i].isHidden = false
        }
        
        if level < 10 {
            for i in (level + 1)...10 {
                allNodes[group][i].isHidden = true
            }
        }
    }
}
