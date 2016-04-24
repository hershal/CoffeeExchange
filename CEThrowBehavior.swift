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

        action = printCenters
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

    func addSubview(view: UIView) {
        gravity.addItem(view)
        boundsCollision.addItem(view)
        initialBehavior.addItem(view)
        initialBehavior.addAngularVelocity(CGFloat.srandom()*CGFloat(M_PI), forItem: view)
        initialBehavior.addLinearVelocity(CGPoint(x: CGFloat.srandom()*1000, y: CGFloat.random()*1000), forItem: view)
        initialBehavior.elasticity = 0.25
    }

    func removeSubview(view: UIView) {
        gravity.removeItem(view)
        boundsCollision.removeItem(view)
        initialBehavior.removeItem(view)
    }

    func printCenters() {
        NSLog(gravity.items.map { $0.center }.description)
    }
}
