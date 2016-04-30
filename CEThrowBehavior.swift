//
//  CEThrowBehavior.swift
//  CoffeeExchange
//
//  Created by Hershal Bhave on 2016-04-24.
//  Copyright © 2016 Hershal Bhave. All rights reserved.
//

import UIKit

class CEThrowBehavior: UIDynamicBehavior {
    var gravity: UIGravityBehavior
    var initialBehavior: UIDynamicItemBehavior
    var boundsCollision: UICollisionBehavior

    override init() {
        gravity = UIGravityBehavior()
        initialBehavior = UIDynamicItemBehavior()
        boundsCollision = UICollisionBehavior()
        super.init()

        [gravity, initialBehavior, boundsCollision].forEach { (behavior) in
            addChildBehavior(behavior)
        }
        action = unrotateTextView
    }

    func unrotateTextView() {
        for item in gravity.items {
            if let item = item as? CEEntryDynamicItem {
                item.textView.transform = CGAffineTransformIdentity
            }
        }
    }

    func layoutCollisions(frame: CGRect) {
        let tl = CGPoint(x: frame.minX, y: -10000.0)
        let tr = CGPoint(x: frame.maxX, y: -10000.0)
        let bl = CGPoint(x: frame.minX, y: frame.maxY)
        let br = CGPoint(x: frame.maxX, y: frame.maxY)

        boundsCollision.removeAllBoundaries()
        boundsCollision.addBoundaryWithIdentifier("bottom", fromPoint: bl, toPoint: br)
        boundsCollision.addBoundaryWithIdentifier("left", fromPoint: tl, toPoint: bl)
        boundsCollision.addBoundaryWithIdentifier("right", fromPoint: tr, toPoint: br)
    }

    func addItem(dynamicItem: UIDynamicItem) {
        gravity.addItem(dynamicItem)
        boundsCollision.addItem(dynamicItem)
        initialBehavior.addItem(dynamicItem)
        initialBehavior.addAngularVelocity(CGFloat.srandom()*CGFloat(M_PI), forItem: dynamicItem)
        initialBehavior.addLinearVelocity(CGPoint(x: CGFloat.srandom()*1000, y: CGFloat.random()*1000), forItem: dynamicItem)
        initialBehavior.elasticity = 0.25
        dynamicItem.transform = CGAffineTransformRotate(dynamicItem.transform, CGFloat.random()*2*CGFloat(M_PI))
    }

    func removeItem(dynamicItem: UIDynamicItem) {
        gravity.removeItem(dynamicItem)
        boundsCollision.removeItem(dynamicItem)
        initialBehavior.removeItem(dynamicItem)
    }

    func printCenters() {
        NSLog(gravity.items.map { $0.center }.description)
    }
}
