//
//  BoxesScene.swift
//  TouchBarVisualizer
//
//  Created by Addison Hanrattie on 5/21/21.
//  Copyright © 2021 Addison Hanrattie. All rights reserved.
//

import Cocoa
import SpriteKit

class BoxesScene: SKScene {
	
	var ready = false
	let height : CGFloat = 30.0
	let wid : CGFloat = 10.0 //10
	
	var allNodes : [[SKSpriteNode]] = []
	
	var active = true
	var created = false
	
	// MARK: The Scene
	
	override func didMove(to view: SKView) { // Initialize all sprites for leveling
		print(self.size.width)
		self.backgroundColor = .black
		
		if !ready {
			self.backgroundColor = .black
			ready = true
		}
		
		if !created {
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
					let x : CGFloat = (wid * CGFloat(i + 1)) // 110 aprox escape key distance
					let texture = SKTexture(imageNamed: "square")
					
					let rect = SKSpriteNode(texture: texture, color: color, size: CGSize(width: wid, height: 3))
					rect.colorBlendFactor = 1.0
					self.addChild(rect)
					rect.position = CGPoint(x: x, y: (rect.size.height * CGFloat(c - 1)) + (rect.size.height / 2))
					
					popul.append(rect)
				}
				allNodes.append(popul)
			}
			
			NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(appChange(_:)), name: NSWorkspace.didActivateApplicationNotification, object: nil)
			created = true
			moveCent() //Correct call point?
		}
	}
	
	// MARK: Vissualizing Music
	
	func levelForAll(levels: [Int]) {
		guard allNodes.count == 100 else { return }
		
		// Iterate through all freqs
		for group in 0..<levels.count {
			let level = levels[group]
			
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
	
	// MARK: Dealing With Movement
	
	@objc func appChange(_ notification: NSNotification) {
		guard let app = notification.userInfo!["NSWorkspaceApplicationKey"] as? NSRunningApplication else {
			fatalError("NSWorkspaceApplicationKey was not of type NSRunningApplication")
		}
		print(app.localizedName!) // track changes
		if "TouchBarVisualizer" == app.localizedName {
			active = true
			print("Changed to TBV")
			moveAJ()
		} else {
			active = false
			moveCent()
			print("Changed to external")
		}
	}
	
	func moveCent() {
//		for i in 0...99 {
//			for j in 0...10 {
//				let x : CGFloat = (wid * CGFloat(i + 1))
//				allNodes[i][j].position = CGPoint(x: x, y: allNodes[i][j].position.y)
//			}
//		}
	}
	
	func moveAJ() {
//		for i in 0...99 {
//			for j in 0...10 {
//				let x : CGFloat = (wid * CGFloat(i + 1)) + 105
//				allNodes[i][j].position = CGPoint(x: x, y: allNodes[i][j].position.y)
//			}
//		}
	}
}
