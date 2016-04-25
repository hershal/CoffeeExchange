//
//  CEEntryDetailBackgroundView.swift
//  CoffeeExchange
//
//  Created by Hershal Bhave on 2016-04-24.
//  Copyright © 2016 Hershal Bhave. All rights reserved.
//

import UIKit
import CoreGraphics

class CEDynamicBackgroundView: UIView {

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

    private func itemsIntersectWithItem(dynamicItem: CEEntryDynamicItem) -> Bool {
        let doesIntersect = dynamicItems
            .map { (item) -> Bool in CGRectIntersectsRect(item.frame, dynamicItem.frame) }
            .filter { (element) -> Bool in element == true }
            .first
        if let doesIntersect = doesIntersect {
            return doesIntersect
        }

        return false
    }

    func addView() {
        let dynamicItem = CEEntryDynamicItem()
//        let randomX = CGFloat.random()*bounds.width
        NSLog("center: \(dynamicItem.center)")

        while (itemsIntersectWithItem(dynamicItem)) {
            dynamicItem.center.y -= dynamicItem.radius
        }

        dynamicItems.append(dynamicItem)
        dynamicItem.addSubviewsToView(self)
        dynamicBehavior.addItem(dynamicItem)
    }

    func removeView() {
        if let frontView = dynamicItems.first {
            dynamicItems.removeFirst()
            UIView.animateWithDuration(0.5, animations: { 
                frontView.alpha = 0.0
                }, completion: { (finished) in
                    frontView.removeFromSuperview()
                    self.dynamicBehavior.removeItem(frontView)
            })
        }
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
