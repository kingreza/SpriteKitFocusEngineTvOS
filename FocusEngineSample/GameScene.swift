//
//  GameScene.swift
//  FocusEngineSample
//
//  Created by Reza Shirazian on 2017-04-10.
//  Copyright © 2017 Reza Shirazian. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {

  var touchStart: CGPoint?
  var container: SKNode?
  var focusedButton: FocusableButton?

  override func didMove(to view: SKView) {
    let container = SKNode()
    self.container = container
    self.addChild(container)
    for i in 0..<15 {
      let newButton = FocusableButton(value: i)
      newButton.position = CGPoint(x: ((-self.frame.width/2.0) + 70) + CGFloat(i * 120), y: 0)
      container.addChild(newButton)
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let focusedButton = self.focusedButton {
      focusedButton.touchesBeganForFocusedButton(touches, with: event)
    }
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let focusedButton = self.focusedButton {
      focusedButton.touchesMovedForFocusedButton(touches, with: event)
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let focusedButton = self.focusedButton {
      focusedButton.touchesEndedForFocusedButton(touches, with: event)
    }
  }
  
  override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
    
    let prevItem = context.previouslyFocusedItem
    let nextItem = context.nextFocusedItem
    
    if let prevItem = prevItem as? FocusableButton {
      prevItem.lostFocus()
    }
    
    if let nextItem = nextItem as? FocusableButton {
      self.focusedButton = nextItem
      nextItem.gainedFocus()
      let positionInScene = container!.convert(nextItem.position, to: self)
      if positionInScene.x > self.frame.width/2 {
        let moveLeft = SKAction.moveBy(x: -120, y: 0, duration: 0.5)
        container?.run(moveLeft)
      } else if positionInScene.x < -self.frame.width/2 {
        let moveRight = SKAction.moveBy(x: 120, y: 0, duration: 0.5)
        container?.run(moveRight)
      }
    }
  }
  
  override var preferredFocusEnvironments: [UIFocusEnvironment] {
    return self.children.filter{$0 is FocusableButton}
  }
}
