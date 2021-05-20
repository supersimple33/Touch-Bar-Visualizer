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
	let wid : CGFloat = 10.5 //10.5
	
	var allNodes : [[SKSpriteNode]] = []
	
	var active = true
	var created = false
	
	var masterTransform = CGAffineTransform.identity
	
	override func didMove(to view: SKView) { // Initialize all sprites for leveling
		print(self.size.width)
		self.backgroundColor = .black
		
		if !created {
			NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(appChange(_:)), name: NSWorkspace.didActivateApplicationNotification, object: nil)
			created = true
			moveCent() //Correct call point?
		}
		
		// Creating Vissualizer Line
		let spriteLine = SKShapeNode(circleOfRadius: 1.0)
		spriteLine.strokeColor = .red
		spriteLine.fillColor = .black
		spriteLine.name = "spriteLine"
		spriteLine.zPosition = 2
		addChild(spriteLine)
		
		// Creating Gradient
		if let gradImage2 = gradient2colorIMG(c1: NSColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0), c2: NSColor(red: 255.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0), width: self.size.width + 2, height: self.size.height * 2) {
			let sampleback2 = SKShapeNode(path: CGPath(roundedRect: CGRect(x: -1, y: -1, width: self.size.width + 2, height: self.size.height * 2), cornerWidth: 1, cornerHeight: 1, transform: nil))
			sampleback2.fillColor = .white
			sampleback2.fillTexture = SKTexture(cgImage: gradImage2)
			sampleback2.position = CGPoint(x: 0, y: -5)
			sampleback2.name = "gradientImage"
			self.addChild(sampleback2)
		}
	}

	func reCreateColor(customColor: NSColor) {
		if let child = childNode(withName: "gradientImage") as? SKShapeNode {
			if let gradImage2 = gradient2colorIMG(c1: NSColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0), c2: customColor, width: self.size.width + 2, height: self.size.height * 2) {
				child.fillTexture = SKTexture(cgImage: gradImage2)
			}
			let spriteLine = childNode(withName: "spriteLine") as! SKShapeNode
			spriteLine.strokeColor = customColor
		}
	}
	
	// MARK: Vissualizing Music
	
	func levelForAll(levels: [Int]) {
		guard let child = childNode(withName: "spriteLine") as? SKShapeNode else {
			return
		}
		
		// Convert levels to CGPoints
		let points = levels.enumerated().map { (index, level) in
			return CGPoint(x: wid * (CGFloat(index)), y: max(3.0 * (CGFloat(level) - 1.0), 0.0))
		}
		let path = CGMutablePath()
		path.move(to: points[0].applying(masterTransform))
		
		// Placing control points and creating bezier curves
		let leftPush = CGAffineTransform(translationX: wid / 3.0, y: 0.0) // Tweak x to change slope
		let rightPull = CGAffineTransform(translationX: wid / -3.0, y: 0.0) // Tweak x to change slope
		
		for i in 1..<points.count {
			let p1 = points[i - 1].applying(masterTransform.concatenating(leftPush))
			let p2 = points[i].applying(masterTransform.concatenating(rightPull))
			path.addCurve(to: points[i].applying(masterTransform), control1: p1, control2: p2)
		}
		
		// Enclose // fixed right edge bug by filling zeros but could also over sample instead
		path.addLine(to: CGPoint(x: self.size.width + 1, y: points.last!.applying(masterTransform).y)) // transform not necessay
		
		path.addLine(to: CGPoint(x: self.size.width + 1, y: self.size.height + 1))
		path.addLine(to: CGPoint(x: -1, y: self.size.height + 1))
		path.addLine(to: CGPoint(x: -1, y: -1))
		path.addLine(to: CGPoint(x: points[0].applying(masterTransform).x, y: -1))
		path.closeSubpath()
		
		// Set new path
		child.path = path
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
		masterTransform = CGAffineTransform(translationX: -105.0, y: 0.0) // pulling values too much
	}
	
	func moveAJ() {
		masterTransform = .identity
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
