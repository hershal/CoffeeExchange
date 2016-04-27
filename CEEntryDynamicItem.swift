//
//  CEEntryDynamicItem.swift
//  CoffeeExchange
//
//  Created by Hershal Bhave on 2016-04-25.
//  Copyright © 2016 Hershal Bhave. All rights reserved.
//

import UIKit
import CoreGraphics

class CEEntryDynamicItem: UIDynamicItemGroup {
    var view: CEEntryDynamicItemContainerView
    var entry: CEEntry
    func removeFromSuperview() {
        items.forEach { item in
            if let item = item as? UIView {
                item.removeFromSuperview()
            }
        }
        view.removeFromSuperview()
    }

    private func addSubviews() {
        items.forEach { item in
            if let item = item as? UIView {
                view.addSubview(item)
            }
        }
    }

    init(entry: CEEntry) {
        self.entry = entry

        view = CEEntryDynamicItemContainerView(frame: CGRect(x: 0, y: 0, width: 125, height: 100))
        let cupTopFrame = CGRect(x: 0, y: 0, width: 100, height: 50)
        let cupBottomFrame = CGRect(x: 0, y: 0, width: 100, height: 100)
        let cupSideFrame = CGRect(x: 75, y: 0, width: 50, height: 50)
        let cupTop = CEEntryDynamicItemCupTop(frame: cupTopFrame)
        let cupBottom = CEEntryDynamicItemCupBottom(frame: cupBottomFrame)
        let cupSide = CEEntryDynamicItemCupSide(frame: cupSideFrame)

        let viewModel = CEEntryDetailViewModel(truth: entry)
        cupTop.viewModel = viewModel
        cupBottom.viewModel = viewModel

        super.init(items: [cupTop, cupBottom, cupSide])
        view.dynamicItem = self
        addSubviews()
    }
}

class CEEntryDynamicItemContainerView: UIView {
    weak var dynamicItem: CEEntryDynamicItem?

    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let subviewHitTests = subviews.map { $0.hitTest(point, withEvent: event) }
        let subviewHits = subviewHitTests.filter{ $0 != nil }
        if subviewHits.count != 0 {
            return self
        }
        return super.hitTest(point, withEvent: event)
    }
}

class CEEntryDynamicItemComponent: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }

    var textFontAttributes: [String: NSObject] {
        let textStyle = NSMutableParagraphStyle()
        textStyle.alignment = .Center

        let textFontAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(UIFont.labelFontSize()), NSForegroundColorAttributeName: UIColor.whiteColor(), NSParagraphStyleAttributeName: textStyle]
        return textFontAttributes
    }

    var viewModel: CEEntryDetailViewModel?

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        let isInside = frame.contains(point)
        return isInside
    }

    // HACK: I can't guarantee which view is on top (cupTop or cupBottom),
    // so this is a hack to guarantee that both are visible
    func drawTextInRect(rect: CGRect) {
        viewModel?.truth.fullName.drawInRect(CGRectInset(rect, 3, 3), withAttributes: textFontAttributes)

        let textRect = CGRectOffset(rect, 0, 40)
        viewModel?.balanceText.drawInRect(CGRectInset(textRect, 3, 3), withAttributes: textFontAttributes)
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
            drawTextInRect(rect)
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
            drawTextInRect(rect)
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
            UIColor.brownColor().set()
            let handleWidth = CGFloat(12.5)
            CGContextBeginPath(context)
            CGContextAddArc(context, bounds.width/2, bounds.height/2, bounds.width/2-handleWidth/2,
                            CGFloat(M_PI / 2 + 0.1), CGFloat(3 * M_PI / 2 - 0.1), 1)
            CGContextSetLineWidth(context, handleWidth)
            CGContextStrokePath(context)
        }
    }
}

extension CGFloat {
    static func lerp(x: CGFloat, x_min: CGFloat, x_max: CGFloat) -> CGFloat {
        return ((1 - x) * x_min) + (x * x_max)
    }
}

extension CGRect {
    var radius: CGFloat {
        let xDist = maxX - minX
        let yDist = maxY - minY
        return sqrt(xDist*xDist + yDist*yDist)
    }
}
