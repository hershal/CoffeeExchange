//
//  CEThrowBehavior.swift
//  CoffeeExchange
//
//  Created by Hershal Bhave on 2016-04-24.
//  Copyright © 2016 Hershal Bhave. All rights reserved.
//

import UIKit
import CoreMotion

class CEThrowBehavior: UIDynamicBehavior {
    var gravity: UIGravityBehavior
    var initialBehavior: UIDynamicItemBehavior
    var topBoundsCollision: UICollisionBehavior
    var boundsCollision: UICollisionBehavior
    var motionManager: CMMotionManager
    var motionQueue: OperationQueue

    var itemsInView: Set<CEEntryDynamicItem>

    override init() {
        gravity = UIGravityBehavior()
        initialBehavior = UIDynamicItemBehavior()
        boundsCollision = UICollisionBehavior()
        topBoundsCollision = UICollisionBehavior()
        motionManager = CMMotionManager()
        motionQueue = OperationQueue()
        motionQueue.isSuspended = false
        itemsInView = Set<CEEntryDynamicItem>()
        super.init()

        motionManager.startDeviceMotionUpdates(to: motionQueue) { (motion, error) in
            if let motion = motion {
                DispatchQueue.main.async {
                    let gravityMotion = motion.gravity
                    let x = gravityMotion.x
                    let y = -gravityMotion.y + 0.2
                    let vector = CGVector(dx: x, dy: y)
                    self.gravity.gravityDirection = vector
                    self.gravity.magnitude = 2.0
                }
            }
        }
        [gravity, initialBehavior, boundsCollision, topBoundsCollision].forEach { (behavior) in
            addChildBehavior(behavior)
        }
        action = updateAction
    }

    func updateAction() {
        for item in gravity.items {
            if let item = item as? CEEntryDynamicItem {
                item.textView.transform = CGAffineTransform.identity
                if !itemsInView.contains(item) && item.center.y > (64 + item.bounds.height/2) {
                    self.itemsInView.insert(item)
                    self.topBoundsCollision.addItem(item)
                }
            }
        }
    }

    func layoutCollisions(frame: CGRect) {
        let tl = CGPoint(x: frame.minX, y: -10000.0)
        let tr = CGPoint(x: frame.maxX, y: -10000.0)
        let bl = CGPoint(x: frame.minX, y: frame.maxY)
        let br = CGPoint(x: frame.maxX, y: frame.maxY)

        let frameTl = CGPoint(x: frame.minX, y: frame.minY+64)
        let frameTr = CGPoint(x: frame.maxX, y: frame.minY+64)

        boundsCollision.removeAllBoundaries()
        boundsCollision.addBoundary(withIdentifier: "top" as NSCopying, from: tl, to: tr)
        boundsCollision.addBoundary(withIdentifier: "bottom" as NSCopying, from: bl, to: br)
        boundsCollision.addBoundary(withIdentifier: "left" as NSCopying, from: tl, to: bl)
        boundsCollision.addBoundary(withIdentifier: "right" as NSCopying, from: tr, to: br)

        topBoundsCollision.removeAllBoundaries()
        topBoundsCollision.addBoundary(withIdentifier: "top" as NSCopying, from: frameTl, to: frameTr)
    }

    func addItem(dynamicItem: UIDynamicItem) {
        gravity.addItem(dynamicItem)
        boundsCollision.addItem(dynamicItem)
        initialBehavior.addItem(dynamicItem)
        initialBehavior.addAngularVelocity(CGFloat.srandom()*CGFloat(Float.pi), for: dynamicItem)
        initialBehavior.addLinearVelocity(CGPoint(x: CGFloat.srandom()*1000+500, y: CGFloat.random()*1000+500), for: dynamicItem)
        initialBehavior.elasticity = 0.25
        dynamicItem.transform = (dynamicItem.transform).rotated(by: CGFloat.random()*2*CGFloat(Float.pi))
    }

    func removeItem(dynamicItem: UIDynamicItem) {
        gravity.removeItem(dynamicItem)
        boundsCollision.removeItem(dynamicItem)
        initialBehavior.removeItem(dynamicItem)

        if let dynamicItem = dynamicItem as? CEEntryDynamicItem {
            if itemsInView.contains(dynamicItem) {
                itemsInView.remove(dynamicItem)
                topBoundsCollision.removeItem(dynamicItem)
            }
        }
    }

    func printCenters() {
        NSLog(gravity.items.map { $0.center }.description)
    }
}
