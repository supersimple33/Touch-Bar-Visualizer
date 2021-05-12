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
import CoreImage

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
		
		let layer = CAGradientLayer()
		layer.frame = CGRect(origin: CGPoint.zero, size: self.size)
		layer.colors = [SKColor.red.cgColor, SKColor.green.cgColor]
		
		if let gradImage2 = gradient2colorIMG(c1: NSColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0), c2: NSColor(red: 255.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0), width: self.size.width + 2, height: self.size.height * 2) {
			let sampleback2 = SKShapeNode(path: CGPath(roundedRect: CGRect(x: -1, y: -1, width: self.size.width + 2, height: self.size.height * 2), cornerWidth: 1, cornerHeight: 1, transform: nil))
			sampleback2.fillColor = .white
			sampleback2.fillTexture = SKTexture(cgImage: gradImage2)
			sampleback2.position = CGPoint(x: 0, y: -5)
			self.addChild(sampleback2)
		}
	}
	
	func levelForAll(levels: [Int]) {
		if let child = childNode(withName: "spriteLine") {
			child.removeFromParent()
		}
		
		// Convert levels to CGPoints
		let points = levels.enumerated().map { (index, level) in
			return CGPoint(x: wid * (CGFloat(index) - 1.0), y: 3.0 * (CGFloat(level) - 1.0))
		}
		let path = CGMutablePath()
		path.move(to: points[0])
		
		// Placing control points and creating bezier curves
		let leftPush = CGAffineTransform(translationX: wid / 3.0, y: 0.0) // Tweak x to change slope
		let rightPull = CGAffineTransform(translationX: wid / -3.0, y: 0.0) // Tweak x to change slope
		
		for i in 1..<points.count {
			let p1 = points[i - 1].applying(leftPush)
			let p2 = points[i].applying(rightPull)
			path.addCurve(to: points[i], control1: p1, control2: p2)
		}
		
		// Enclose
		path.addLine(to: CGPoint(x: self.size.width + 1, y: self.size.height + 1))
		path.addLine(to: CGPoint(x: -1, y: self.size.height + 1))
		path.closeSubpath()
		
		let spriteLine = SKShapeNode(path: path)
		spriteLine.strokeColor = .red //Extract for custom user selection
		spriteLine.fillColor = .black
		spriteLine.name = "spriteLine"
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
	
	// REFRENCE: stackoverflow.com/questions/63866624/why-is-cilineargradient-resulting-in-a-very-non-linear-gradient
	func gradient2colorIMG(c1: NSColor, c2: NSColor, width: CGFloat, height: CGFloat) -> CGImage? {
		if let gradientFilter = CIFilter(name: "CILinearGradient") {
			let startVector:CIVector = CIVector(x: 0, y: 0 + 1)
			let endVector:CIVector = CIVector(x: 0, y: height - 1)
			let color1 = CIColor(color: c1)
			let color2 = CIColor(color: c2)
			let context = CIContext(options: nil)
			if let currentFilter = CIFilter(name: "CILinearGradient") {
				currentFilter.setValue(startVector, forKey: "inputPoint0")
				currentFilter.setValue(endVector, forKey: "inputPoint1")
				currentFilter.setValue(color1, forKey: "inputColor0")
				currentFilter.setValue(color2, forKey: "inputColor1")
				if let output = currentFilter.outputImage {
					if let cgimg = context.createCGImage(output, from: CGRect(x: 0, y: 0, width: width, height: height)) {
						let gradImage = cgimg
						return gradImage
					}
				}
			}
		}
		return nil
	}
}
