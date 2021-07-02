//
//  ColorView.swift
//  TouchBarVisualizer
//
//  Created by Addison Hanrattie on 6/6/19.
//  Copyright © 2019 Addison Hanrattie. All rights reserved.
//

import Cocoa
import SpriteKit

class ColorView: SKView {

	let lineScene = LineScene(size: CGSize(width: 1005, height: 30))
	let boxScene = BoxesScene(size: CGSize(width: 1005, height: 30))
	let tScene = TextScene(size: CGSize(width: 1005, height: 30))
	
	func presentLine() {
		self.presentScene(lineScene, transition: SKTransition.crossFade(withDuration: 0.1))
	}
	
	func presentBoxes() {
		self.presentScene(boxScene, transition: SKTransition.crossFade(withDuration: 0.1))
	}
	
	func presentText() {
		self.presentScene(tScene, transition: SKTransition.doorway(withDuration: 0.5))
	}
}
