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
	
	let colScene = ColorScene(size: CGSize(width: 1005, height: 30))
	let tScene = TextScene(size: CGSize(width: 1005, height: 30))
	
	func presentColor() {
		self.presentScene(colScene)
	}
	
	func presentText() {
		self.presentScene(tScene)
	}
}
