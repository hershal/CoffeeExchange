//
//  CEEntryDynamicItem.swift
//  CoffeeExchange
//
//  Created by Hershal Bhave on 2016-04-25.
//  Copyright © 2016 Hershal Bhave. All rights reserved.
//

import UIKit
import CoreGraphics

class CEEntryDynamicItemComponent: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CEEntryDynamicItemCupTop: CEEntryDynamicItemComponent {
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        get {
            return .Rectangle
        }
    }

    override func drawRect(rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            UIColor.brownColor().setFill()
            CGContextFillRect(context, rect)
        }
    }
}

class CEEntryDynamicItemCupBottom: CEEntryDynamicItemComponent {
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        get {
            return .Path
        }
    }

    override var collisionBoundingPath: UIBezierPath {
        let path = UIBezierPath()
        let physicsCenter = CGPoint(x: -12.5, y: 0)
        path.addArcWithCenter(physicsCenter, radius: 50, startAngle: 0, endAngle: CGFloat(2*M_PI), clockwise: true)
        return path
    }

    override func drawRect(rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            UIColor.brownColor().setFill()
            CGContextFillEllipseInRect(context, rect)
        }
    }
}

class CEEntryDynamicItemCupSide: CEEntryDynamicItemComponent {
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        get {
            return .Path
        }
    }

    override var collisionBoundingPath: UIBezierPath {
        let path = UIBezierPath()
        let physicsCenter = CGPoint(x: 12.5+25, y: -25)
        path.addArcWithCenter(physicsCenter, radius: 25, startAngle: 0, endAngle: CGFloat(2*M_PI), clockwise: true)
        return path
    }

    override func drawRect(rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            UIColor.brownColor().setFill()
            CGContextFillEllipseInRect(context, bounds)
        }
    }
}

class CEEntryDynamicItem: UIDynamicItemGroup {
    var alpha: CGFloat {
        get {
            let item = items.filter { $0 as? UIView != nil }.first as? UIView
            if let item = item { return item.alpha } else { return -1.0 }
        }
        set {
            items.forEach { item in
                if let item = item as? UIView {
                    item.alpha = alpha
                }
            }
        }
    }

    var frame: CGRect {
        return CGRect(x: center.x - bounds.width/2, y: center.y - bounds.height/2,
                      width: bounds.width, height: bounds.height)
    }

    func removeFromSuperview() {
        items.forEach { item in
            if let item = item as? UIView {
                item.removeFromSuperview()
            }
        }
    }

    func addSubviewsToView(view: UIView) {
        items.forEach { item in
            if let item = item as? UIView {
                view.addSubview(item)
            }
        }
    }

    init(origin: CGPoint) {
        // origin is unused in this demonstration
        let cupTopFrame = CGRect(x: 0, y: 0, width: 100, height: 50)
        let cupBottomFrame = CGRect(x: 0, y: 0, width: 100, height: 100)
        let cupSideFrame = CGRect(x: 75, y: 0, width: 50, height: 50)
        let cupTop = CEEntryDynamicItemCupTop(frame: cupTopFrame)
        let cupBottom = CEEntryDynamicItemCupBottom(frame: cupBottomFrame)
        let cupSide = CEEntryDynamicItemCupSide(frame: cupSideFrame)
        super.init(items: [cupTop, cupBottom, cupSide])
    }
}

extension CGFloat {
    static func lerp(x: CGFloat, x_min: CGFloat, x_max: CGFloat) -> CGFloat {
        return ((1 - x) * x_min) + (x * x_max)
    }
}