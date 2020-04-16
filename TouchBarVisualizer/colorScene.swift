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
    let height : CGFloat = 30.0
    let wid : CGFloat = 10.0
    
    var allNodes : [[SKSpriteNode]] = []
    
    override func didMove(to view: SKView) { // Initialize all sprites for leveling
        print(self.size.width)
        self.backgroundColor = .black
        for i in 0...99 {
            var popul : [SKSpriteNode] = []
            for c in 0...10 { // 10,9 / 8,7
                var color : NSColor!
                if c < 5 {
                    color = .green
                } else if c < 8 {
                    color = .orange
                } else {
                    color = .red
                }
                let x : CGFloat = wid * CGFloat(i + 1)
                let texture = SKTexture(imageNamed: "square")
                
                let rect = SKSpriteNode(texture: texture, color: color, size: CGSize(width: wid, height: 3))
                rect.colorBlendFactor = 1.0
                self.addChild(rect)
                rect.position = CGPoint(x: x, y: (rect.size.height * CGFloat(c - 1)) + (rect.size.height / 2))
                
                popul.append(rect)
                
                
            }
            allNodes.append(popul)
        }
        
        if !ready {
            self.backgroundColor = .black
            ready = true
        }
    }
    
    
    func levelFor(group: Int, level: Int) {
        guard allNodes.count != 0 else { return }
        
        for i in 0...level { // Reveal all needed nodes
            if i > 10 {
                continue
            }
            allNodes[group][i].isHidden = false
        }
        
        if level < 10 {
            for i in (level + 1)...10 { // Hide all nodes below peak volume
                allNodes[group][i].isHidden = true
            }
        }
    }
}
