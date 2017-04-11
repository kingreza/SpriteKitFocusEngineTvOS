 //
//  FocusableButton.swift
//  FocusEngineSample
//
//  Created by Reza Shirazian on 2017-04-10.
//  Copyright © 2017 Reza Shirazian. All rights reserved.
//

import SpriteKit

 
 class FocusableButton: SKNode {
  var touchStart: CGPoint?
  var isFocused: Bool = false
  let sourcePositions: [vector_float2] = [
    vector_float2(0, 1),   vector_float2(1, 1),
    vector_float2(0, 0),   vector_float2(1, 0)
  ]
  
  init(value: Int) {
    super.init()
    self.name = "\(value)"
    let bg = SKSpriteNode()
    bg.size = CGSize(width: 100, height: 100)
    bg.color = UIColor.red
    bg.name = "bg"
    bg.position = CGPoint(x: 0, y: 0)
    bg.zPosition = 0
    let label = SKLabelNode()
    label.text = "\(value)"
    label.zPosition = 1
    self.addChild(label)
    self.addChild(bg)
    self.isUserInteractionEnabled = true

  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override var canBecomeFocused: Bool {
    return true
  }

  func getLeanGeometry(shift: Float, direction: Direction) -> [vector_float2] {
    switch direction {
    case .left:
      return [
        vector_float2(0.0 + shift, 1.0 - shift), vector_float2(1.0 + shift, 1.0 + shift),
        vector_float2(0.0 + shift, 0 + shift), vector_float2(1.0 + shift, 0 - shift)
      ]
    case .right:
      return [
        vector_float2(0.0 - shift, 1.0 + shift), vector_float2(1.0 - shift, 1.0 - shift),
        vector_float2(0.0 - shift, 0 - shift), vector_float2(1.0 - shift, 0 + shift)
      ]
    case .up:
      return [
        vector_float2(0.0 - shift, 1.0 + shift), vector_float2(1.0 + shift, 1.0 + shift),
        vector_float2(0.0 + shift, 0 + shift), vector_float2(1.0 - shift, 0 + shift)
      ]
    case .down:
      return [
        vector_float2(0.0 + shift, 1.0 - shift), vector_float2(1.0 - shift, 1.0 - shift),
        vector_float2(0.0 - shift, 0 - shift), vector_float2(1.0 + shift, 0 - shift)
      ]
    }
  }
  
  func gainedFocus() {
    if let bg = self.childNode(withName: "bg") as? SKSpriteNode {
      bg.color = UIColor.blue
      self.isFocused = true
      self.scaleSelf(value: 1.1)
     // self.becomeFirstResponder()
    }
  }
  
  func lostFocus() {
    if let bg = self.childNode(withName: "bg") as? SKSpriteNode {
      bg.color = UIColor.red
      self.isFocused = false
      self.scaleSelf(value: 1.0)
      self.resetWarpGeometry()
    }
  }
  
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let scene = self.scene as? GameScene {
      scene.touchesBegan(touches, with: event)
    }
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let scene = self.scene as? GameScene {
      scene.touchesMoved(touches, with: event)
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let scene = self.scene as? GameScene {
      scene.touchesEnded(touches, with: event)
    }
  }
  
  func touchesBeganForFocusedButton(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard isFocused else {
      return
    }
    touchStart = touches.first!.location(in: self)
  }
  
  func touchesMovedForFocusedButton(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard isFocused else {
      return
    }
    let newLocation = touches.first!.location(in: self)
    
    if let touchStart = self.touchStart {
      let xOffset = touchStart.x - newLocation.x
      let yOffset = touchStart.y - newLocation.y
      let xOrder = abs(Float((xOffset/103.0) * 0.01))
      let yOrder = abs(Float((yOffset/103.0) * 0.01))
      var lean: Direction?
     
      if xOrder > yOrder {
        if touchStart.x - newLocation.x > 0 {
          lean = .left
        } else {
          lean = .right
        }
      } else {
        if touchStart.y - newLocation.y > 0 {
          lean = .up
        } else {
          lean = .down
        }
      }
      
      if let bg = self.childNode(withName: "bg") as? SKSpriteNode, let lean = lean {
        var leanGeometry: [vector_float2]?
        if lean == .left || lean == .right {
          leanGeometry = self.getLeanGeometry(shift: xOrder, direction: lean)
        }
        if lean == .up || lean == .down {
          leanGeometry = self.getLeanGeometry(shift: yOrder, direction: lean)
        }
        if let leanGeometry = leanGeometry {
          let warpGeometryGrid = SKWarpGeometryGrid(columns: 1, rows: 1, sourcePositions: sourcePositions, destinationPositions: leanGeometry)
          bg.warpGeometry = warpGeometryGrid
        }
      }
    }
  }
  
  func touchesEndedForFocusedButton(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard isFocused else {
      return
    }
    self.resetWarpGeometry()
  }
  
  func resetWarpGeometry() {
    let warpGeometryGrid = SKWarpGeometryGrid(columns: 1, rows: 1, sourcePositions: sourcePositions, destinationPositions: sourcePositions)
    if let bg = self.childNode(withName: "bg") as? SKSpriteNode {
      let wrapAnimation = SKAction.warp(to: warpGeometryGrid, duration: 0.3)
      wrapAnimation?.timingMode = .easeOut
      bg.run(wrapAnimation!)
    }
  }
  
  func scaleSelf(value: CGFloat) {
    let scale = SKAction.scale(to: value, duration: 0.3)
    self.run(scale)
  }
}
 
 enum Direction: Int {
  case up = 0, right, down, left;
 }
 
