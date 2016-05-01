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
    var textView: CEEntryDynamicItemTextView
    var entry: CEEntry

    func setEditMode(editMode: CEViewControllerEditMode) {
        items.forEach { (item) in
            if let item = item as? CEEntryDynamicItemComponent {
                item.editMode = editMode
                item.setNeedsDisplay()
            }
        }
    }

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
        view.addSubview(textView)
    }

    init(entry: CEEntry) {
        self.entry = entry

        view = CEEntryDynamicItemContainerView(frame: CGRect(x: 0, y: 0, width: 125, height: 100))
        textView = CEEntryDynamicItemTextView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let cupTopFrame = CGRect(x: 0, y: 0, width: 100, height: 50)
        let cupBottomFrame = CGRect(x: 0, y: 0, width: 100, height: 100)
        let cupSideFrame = CGRect(x: 75, y: 0, width: 50, height: 50)
        let cupTop = CEEntryDynamicItemCupTop(frame: cupTopFrame)
        let cupBottom = CEEntryDynamicItemCupBottom(frame: cupBottomFrame)
        let cupSide = CEEntryDynamicItemCupSide(frame: cupSideFrame)

        let viewModel = CEEntryDetailViewModel(truth: entry)
        cupTop.viewModel = viewModel
        cupBottom.viewModel = viewModel
        textView.viewModel = viewModel

        super.init(items: [cupTop, cupBottom, cupSide, textView])
        view.dynamicItem = self
        addSubviews()
    }
}

class CEEntryDynamicItemComponent: UIView {
    var editMode: CEViewControllerEditMode
    var viewModel: CEEntryDetailViewModel?

    override init(frame: CGRect) {
        self.editMode = .NormalMode
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        let isInside = frame.contains(point)
        return isInside
    }
}

class CEEntryDynamicItemEditOverlayView: CEEntryDynamicItemComponent {
    func drawEditModeInRect(rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            let insetRect = rect.insetBy(dx: rect.height/2-22, dy: rect.width/2-22)
            let tintColor = UIColor.whiteColor()
            tintColor.colorWithAlphaComponent(0.9).setFill()
            CGContextFillEllipseInRect(context, insetRect)
            let xrect = insetRect.insetBy(dx: 15, dy: 15)
            UIColor.lightGrayColor().setStroke()
            CGContextSetLineWidth(context, 1)
            CGContextMoveToPoint(context, xrect.minX, xrect.minY)
            CGContextAddLineToPoint(context, xrect.maxX, xrect.maxY)
            CGContextStrokePath(context)
            CGContextMoveToPoint(context, xrect.maxX, xrect.minY)
            CGContextAddLineToPoint(context, xrect.minX, xrect.maxY)
            CGContextStrokePath(context)
        }
    }

    override func drawRect(rect: CGRect) {
        drawEditModeInRect(rect)
    }
}

class CEEntryDynamicItemTextView: CEEntryDynamicItemComponent {
    var editOverlayView: CEEntryDynamicItemEditOverlayView
    let defaultTransform = CGAffineTransformScale(CGAffineTransformIdentity, 0.5, 0.5)

    override var editMode: CEViewControllerEditMode {
        didSet {
            dispatch_async(dispatch_get_main_queue(), {
                UIView.animateWithDuration(0.25, animations: {
                    switch (self.editMode) {
                    case .EditMode:
                        self.editOverlayView.alpha = 1
                        self.editOverlayView.transform = CGAffineTransformIdentity
                    case .NormalMode:
                        self.editOverlayView.alpha = 0
                        self.editOverlayView.transform = self.defaultTransform
                    }
                })
            })
        }
    }

    override init(frame: CGRect) {
        self.editOverlayView = CEEntryDynamicItemEditOverlayView(frame: frame)
        super.init(frame: frame)
        editOverlayView.alpha = 0
        editOverlayView.transform = defaultTransform
        self.addSubview(editOverlayView)
        layer.zPosition = 200
    }

    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return .Path
    }

    override var collisionBoundingPath: UIBezierPath {
        let path = UIBezierPath(rect: CGRect(origin: CGPointZero, size: CGSize(width: 1, height: 1)))
        return path
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var textFontAttributes: [String: NSObject] {
        let textStyle = NSMutableParagraphStyle()
        textStyle.alignment = .Center
        textStyle.lineBreakMode = .ByWordWrapping

        let textFontAttributes =
            [NSFontAttributeName: UIFont.systemFontOfSize(UIFont.smallSystemFontSize()),
             NSForegroundColorAttributeName: UIColor.whiteColor(),
             NSParagraphStyleAttributeName: textStyle]
        return textFontAttributes
    }

    func drawTextInRect(rect: CGRect) {
        guard let viewModel = viewModel else {
            return
        }

        var topRect = rect
        topRect.size.height = rect.height/2
        topRect = CGRectOffset(topRect, 0, 5)
        topRect = CGRectInset(topRect, 3, 3)
        topRect.offsetInPlace(dx: 0, dy: 3)
        viewModel.truth.fullName.drawWithRect(topRect, options: [.TruncatesLastVisibleLine, .UsesLineFragmentOrigin], attributes: textFontAttributes, context: nil)

        var bottomRect = CGRectOffset(rect, 0, rect.height/2 + 5)
        bottomRect.size.height = rect.height/2
        bottomRect = CGRectInset(bottomRect, 3, 3)
        let str = "\(viewModel.absBalance) \(viewModel.balanceDirectionPast)"
        str.drawInRect(bottomRect, withAttributes: textFontAttributes)
    }

    override func drawRect(rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            UIColor.whiteColor().set()
            let circleRect = rect.insetBy(dx: 10, dy: 10)
            let textRect = rect.insetBy(dx: 15, dy: 15)
            CGContextStrokeEllipseInRect(context, circleRect)
            drawTextInRect(textRect)
        }
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
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.zPosition = 100
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
