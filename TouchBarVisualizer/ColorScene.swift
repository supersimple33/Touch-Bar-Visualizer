//
//  ColorScene.swift
//  TouchBarVisualizer
//
//  Created by Addison Hanrattie on 6/6/19.
//  Copyright © 2019 Addison Hanrattie. All rights reserved.
//

import Cocoa
import SpriteKit
import CoreGraphics

class ColorScene: SKScene {

	
	var ready = false
	let height : CGFloat = 30.0
	let wid : CGFloat = 10.0 //10
	
	var allNodes : [[SKSpriteNode]] = []
	
	var active = true
	var created = false
	
	override func didMove(to view: SKView) { // Initialize all sprites for leveling
		print(self.size.width)
		self.backgroundColor = .black
		
		if !ready {
			self.backgroundColor = .black
			ready = true
		}
		
		if !created {
			NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(appChange(_:)), name: NSWorkspace.didActivateApplicationNotification, object: nil)
			created = true
			moveCent() //Correct call point?
		}
	}
	
	func levelForAll(levels: [Int]) {
		self.removeAllChildren()
		
		// Convert levels to CGPoints
		let points = levels.enumerated().map { (index, level) in
			return CGPoint(x: wid * (CGFloat(index) - 1.0), y: 3.0 * (CGFloat(level) - 1.0))
		}
		let path = CGMutablePath()
		path.move(to: points[0])
		
		// Placing control points
		let leftPush = CGAffineTransform(translationX: wid / 3, y: 0.0)
		let rightPull = CGAffineTransform(translationX: wid / -3, y: 0.0)
		
		for i in 1..<points.count {
			let p1 = points[i - 1].applying(leftPush)
			let p2 = points[i].applying(rightPull)
			path.addCurve(to: points[i], control1: p1, control2: p2)
		}
		let spriteLine = SKShapeNode(path: path)
		spriteLine.strokeColor = .blue
		addChild(spriteLine)
	}
	
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
