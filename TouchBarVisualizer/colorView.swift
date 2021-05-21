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

	let lineScene = ColorScene(size: CGSize(width: 1005, height: 30))
	let boxScene = nil
	let tScene = TextScene(size: CGSize(width: 1005, height: 30))
	
	func presentLine() {
		self.presentScene(lineScene, transition: SKTransition.crossFade(withDuration: 1.0))
	}
	
	func presentBoxes() {
		self.presentScene(boxScene, transition: SKTransition.crossFade(withDuration: 1.0))
	}
	
	func presentText() {
		self.presentScene(tScene, transition: SKTransition.crossFade(withDuration: 1.0))
	}
}
