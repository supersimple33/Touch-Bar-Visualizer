//
//  TextScene.swift
//  TouchBarVisualizer
//
//  Created by Addison Hanrattie on 5/26/20.
//  Copyright © 2020 Addison Hanrattie. All rights reserved.
//

import Cocoa
import SpriteKit

class TextScene: SKScene {
    override func didMove(to view: SKView) {
        self.backgroundColor = .black
        let node = SKSpriteNode(imageNamed: "arrow")
        self.addChild(node)
        node.position = CGPoint(x: node.size.width / 2, y: node.size.height / 2)
    }
}
