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

    init(frame: CGRect) {
        gravity = UIGravityBehavior()
        initialBehavior = UIDynamicItemBehavior()
        boundsCollision = UICollisionBehavior()
        super.init()

        boundsCollision.translatesReferenceBoundsIntoBoundary = true
        [gravity, initialBehavior, boundsCollision].forEach { (behavior) in
            addChildBehavior(behavior)
        }
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
}
