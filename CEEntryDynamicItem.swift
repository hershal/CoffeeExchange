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
            return .Ellipse
        }
    }

    override func drawRect(rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            UIColor.brownColor().setFill()
            CGContextFillEllipseInRect(context, bounds)
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
        get {
            let path = UIBezierPath(ovalInRect: bounds)
            return path
        }
    }

//    override init(frame: CGRect) {
//        var newFrame = frame
//        newFrame.origin.x = CGFloat.lerp(4/5, x_min: frame.minX, x_max: frame.maxX)
//        newFrame.size.width = 50
//        newFrame.size.height = 50
//        super.init(frame: newFrame)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }

    override func drawRect(rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
//            UIColor.blueColor().setFill()
//            CGContextFillRect(context, rect)
            UIColor.redColor().setFill()
            CGContextFillEllipseInRect(context, bounds)
        }
    }
}

class CEEntryDynamicItem: UIDynamicItemGroup {
    static let size = CGSize(width: 125, height: 100)

    private var cupTop: CEEntryDynamicItemCupTop
    private var cupBottom: CEEntryDynamicItemCupBottom
    private var cupSide: CEEntryDynamicItemCupBottom

    var alpha: CGFloat {
        get {
            return cupBottom.alpha
        }
        set {
            items.forEach { item in
                if let item = item as? CEEntryDynamicItemComponent {
                    item.alpha = alpha
                }
            }
        }
    }

    var frame: CGRect {
        get {
            return cupBottom.frame
        }
    }

    func removeFromSuperview() {
        items.forEach { item in
            if let item = item as? CEEntryDynamicItemComponent {
                item.removeFromSuperview()
            }
        }
    }

    func addSubviewsToView(view: UIView) {
        items.forEach { item in
            if let item = item as? CEEntryDynamicItemComponent {
                view.addSubview(item)
            }
        }
    }

    convenience init(origin: CGPoint) {
        let rect = CGRect(origin: origin, size: CEEntryDynamicItem.size)
        self.init(frame: rect)
    }

    init(frame: CGRect) {
        let mainFrame = CGRect(origin: frame.origin, size: CGSize(width: frame.width*4/5, height: frame.height))
        self.cupBottom = CEEntryDynamicItemCupBottom(frame: mainFrame)
        let topFrame = CGRect(origin: frame.origin, size: CGSize(width: frame.width*4/5, height: frame.height/2))
        self.cupTop = CEEntryDynamicItemCupTop(frame: topFrame)

        let sideX = CGFloat.lerp(3/5, x_min: frame.minX, x_max: frame.maxX)
        let sideY = frame.minY
        let sideFrame = CGRect(x: sideX, y: sideY, width: 50, height: 50)
        self.cupSide = CEEntryDynamicItemCupBottom(frame: sideFrame)
        super.init(items: [cupTop, cupBottom, cupSide])

        self.transform = CGAffineTransformRotate(self.transform, CGFloat.random()*2*CGFloat(M_PI))
    }
}

extension CGFloat {
    static func lerp(x: CGFloat, x_min: CGFloat, x_max: CGFloat) -> CGFloat {
        return ((1 - x) * x_min) + (x * x_max)
    }
}