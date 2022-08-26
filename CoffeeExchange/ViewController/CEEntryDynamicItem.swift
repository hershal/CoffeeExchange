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
        self.backgroundColor = UIColor.clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let isInside = frame.contains(point)
        return isInside
    }
}

class CEEntryDynamicItemEditOverlayView: CEEntryDynamicItemComponent {
    func drawEditModeInRect(rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            let insetRect = rect.insetBy(dx: rect.height/2-22, dy: rect.width/2-22)
            let tintColor = UIColor.white
            tintColor.withAlphaComponent(0.9).setFill()
            context.fillEllipse(in: insetRect)
            let xrect = insetRect.insetBy(dx: 15, dy: 15)
            UIColor.lightGray.setStroke()
            context.setLineWidth(1)
            context.move(to: CGPoint(x: xrect.minX, y: xrect.minY))
            context.addLine(to: CGPoint(x: xrect.maxX, y: xrect.maxY))
            context.strokePath()
            context.move(to: CGPoint(x: xrect.maxX, y: xrect.minY))
            context.addLine(to: CGPoint(x: xrect.minX, y: xrect.maxY))
            context.strokePath()
        }
    }

    override func draw(_ rect: CGRect) {
        drawEditModeInRect(rect: rect)
    }
}

class CEEntryDynamicItemTextView: CEEntryDynamicItemComponent {
    var editOverlayView: CEEntryDynamicItemEditOverlayView
    let defaultTransform = CGAffineTransform.identity.scaledBy(x: 0.5, y: 0.5)

    override var editMode: CEViewControllerEditMode {
        didSet {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.25, animations: {
                    switch (self.editMode) {
                    case .EditMode:
                        self.editOverlayView.alpha = 1
                        self.editOverlayView.transform = CGAffineTransform.identity
                    case .NormalMode:
                        self.editOverlayView.alpha = 0
                        self.editOverlayView.transform = self.defaultTransform
                    }
                })
            }
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
        return .path
    }

    override var collisionBoundingPath: UIBezierPath {
        let path = UIBezierPath(rect: CGRect(origin: CGPoint.zero, size: CGSize(width: 1, height: 1)))
        return path
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var textFontAttributes: [NSAttributedString.Key: NSObject] {
        let textStyle = NSMutableParagraphStyle()
        textStyle.alignment = .center
        textStyle.lineBreakMode = .byWordWrapping

        let textFontAttributes =
        [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.smallSystemFontSize),
         NSAttributedString.Key.foregroundColor: UIColor.white,
         NSAttributedString.Key.paragraphStyle: textStyle]
        return textFontAttributes
    }

    func drawTextInRect(rect: CGRect) {
        guard let viewModel = viewModel else {
            return
        }

        var topRect = rect
        topRect.size.height = rect.height/2
        topRect = topRect.offsetBy(dx: 0, dy: 5)
        topRect = topRect.insetBy(dx: 3, dy: 3)
        topRect = topRect.offsetBy(dx: 0, dy: 3)
        viewModel.truth.fullName.draw(with: topRect, options: [.truncatesLastVisibleLine, .usesLineFragmentOrigin], attributes: textFontAttributes, context: nil)

        var bottomRect = rect.offsetBy(dx: 0, dy: rect.height/2 + 5)
        bottomRect.size.height = rect.height/2
        bottomRect = bottomRect.insetBy(dx: 3, dy: 3)
        let str = "\(viewModel.absBalance) \(viewModel.balanceDirectionPast)"
        str.draw(in: bottomRect, withAttributes: textFontAttributes)
    }

    override func draw(_ rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            UIColor.white.set()
            let circleRect = rect.insetBy(dx: 10, dy: 10)
            let textRect = rect.insetBy(dx: 15, dy: 15)
            context.strokeEllipse(in: circleRect)
            drawTextInRect(rect: textRect)
        }
    }
}

class CEEntryDynamicItemContainerView: UIView {
    weak var dynamicItem: CEEntryDynamicItem?

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let subviewHitTests = subviews.map { $0.hitTest(point, with: event) }
        let subviewHits = subviewHitTests.filter{ $0 != nil }
        if subviewHits.count != 0 {
            return self
        }
        return super.hitTest(point, with: event)
    }
}

class CEEntryDynamicItemCupTop: CEEntryDynamicItemComponent {
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        get {
            return .rectangle
        }
    }

    override func draw(_ rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            UIColor.brown.setFill()
            context.fill(rect)
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
            return .path
        }
    }

    override var collisionBoundingPath: UIBezierPath {
        let path = UIBezierPath()
        let physicsCenter = CGPoint(x: -12.5, y: 0)
        path.addArc(withCenter: physicsCenter, radius: 50, startAngle: 0, endAngle: CGFloat(2*Float.pi), clockwise: true)
        return path
    }

    override func draw(_ rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            UIColor.brown.setFill()
            context.fillEllipse(in: rect)
        }
    }
}

class CEEntryDynamicItemCupSide: CEEntryDynamicItemComponent {
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        get {
            return .path
        }
    }

    override var collisionBoundingPath: UIBezierPath {
        let path = UIBezierPath()
        let physicsCenter = CGPoint(x: 12.5+25, y: -25)
        path.addArc(withCenter: physicsCenter, radius: 25, startAngle: 0, endAngle: CGFloat(2*Float.pi), clockwise: true)
        return path
    }

    override func draw(_ rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            UIColor.brown.set()
            let handleWidth = CGFloat(12.5)
            context.beginPath()
            context.addArc(center: CGPoint(x: bounds.width/2, y: bounds.height/2), radius: bounds.width/2-handleWidth/2, startAngle: CGFloat(Float.pi / 2 + 0.1), endAngle: CGFloat(3 * Float.pi / 2 - 0.1), clockwise: true)
            context.setLineWidth(handleWidth)
            context.strokePath()
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
