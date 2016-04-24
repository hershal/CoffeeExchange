//
//  CEEntryDetailBackgroundView.swift
//  CoffeeExchange
//
//  Created by Hershal Bhave on 2016-04-24.
//  Copyright © 2016 Hershal Bhave. All rights reserved.
//

import UIKit
import CoreGraphics

class CEEntryDetailBackgroundView: UIView {

    var animator: UIDynamicAnimator!
    var dynamicBehavior: CEThrowBehavior!
    var dynamicItems: [CEEntryDynamicItem]

    var didLayoutSubviews: Bool

    var viewCount: Int {
        didSet {
            updateViewCount()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        dynamicItems = [CEEntryDynamicItem]()
        viewCount = 0
        didLayoutSubviews = false
        super.init(coder: aDecoder)
        dynamicBehavior = CEThrowBehavior()
        animator = UIDynamicAnimator(referenceView: self)
        animator.addBehavior(dynamicBehavior)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        dynamicBehavior.layoutCollisions(frame)
        didLayoutSubviews = true
        updateViewCount()
    }

    private func updateViewCount() {
        if (didLayoutSubviews) {
            while viewCount > dynamicItems.count {
                addView()
            }
            while viewCount < dynamicItems.count {
                removeView()
            }
        }
    }

    private func viewIntersectsItems(view: UIView) -> Bool {
        let doesIntersect = dynamicItems
            .map { (item) -> Bool in CGRectIntersectsRect(item.frame, view.frame) }
            .filter { (element) -> Bool in element == true }
            .first
        if let doesIntersect = doesIntersect {
            return doesIntersect
        }

        return false
    }

    func addView() {
        let randomFloat = CGFloat.random()
        let maxRadius = sqrt(pow(CEEntryDynamicItem.size.height, 2) + pow(CEEntryDynamicItem.size.width, 2))
        let xSpawn = (frame.width - maxRadius) * randomFloat
        let ySpawn = self.frame.minY - maxRadius

        let origin = CGPoint(x: xSpawn, y: ySpawn)
        let dynamicItem = CEEntryDynamicItem(origin: origin)

        while (viewIntersectsItems(dynamicItem)) {
            dynamicItem.center.y -= maxRadius
        }

        dynamicItems.append(dynamicItem)
        addSubview(dynamicItem)
        dynamicBehavior.addSubview(dynamicItem)
    }

    func removeView() {
        if let frontView = dynamicItems.first {
            dynamicItems.removeFirst()
            UIView.animateWithDuration(0.5, animations: { 
                frontView.alpha = 0.0
                }, completion: { (finished) in
                    frontView.removeFromSuperview()
                    self.dynamicBehavior.removeSubview(frontView)
            })
        }
    }
}

class CEEntryDynamicItem: UIView {
    static let size = CGSize(width: 100, height: 100)

    convenience init(origin: CGPoint) {
        let rect = CGRect(origin: origin, size: CEEntryDynamicItem.size)
        self.init(frame: rect)
    }

    override init(frame: CGRect) {
        super.init(frame: CGRect(origin: frame.origin, size: CEEntryDynamicItem.size))
        self.backgroundColor = UIColor.brownColor()

        self.transform = CGAffineTransformRotate(self.transform, CGFloat.random()*2*CGFloat(M_PI))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CGFloat {
    // unsigned 0..1
    static func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UINT32_MAX))
    }

    // signed -1..1
    static func srandom() -> CGFloat {
        return (CGFloat.random() * 2.0) - 1.0
    }
}