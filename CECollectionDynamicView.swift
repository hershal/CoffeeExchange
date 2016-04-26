//
//  CEEntryDetailBackgroundView.swift
//  CoffeeExchange
//
//  Created by Hershal Bhave on 2016-04-24.
//  Copyright © 2016 Hershal Bhave. All rights reserved.
//

import UIKit
import CoreGraphics

class CECollectionDynamicView: UIView {

    var animator: UIDynamicAnimator!
    var dynamicBehavior: CEThrowBehavior!
    var dynamicItems: [CEEntryDynamicItem]

    var dataSource: CECollectionDynamicViewDataSource?

    required init?(coder aDecoder: NSCoder) {
        dynamicItems = [CEEntryDynamicItem]()
        super.init(coder: aDecoder)
        dynamicBehavior = CEThrowBehavior()
        animator = UIDynamicAnimator(referenceView: self)
        animator.addBehavior(dynamicBehavior)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        dynamicBehavior.layoutCollisions(frame)
    }

    private func distanceFrom(point: CGPoint, to: CGPoint) -> CGFloat {
        let dx = point.x - to.x
        let dy = point.y - to.y
        return sqrt(dx*dx + dy*dy)
    }

    private func itemsIntersectWithItem(dynamicItem: CEEntryDynamicItem) -> Bool {
        let doesIntersect = dynamicItems
            .map { (item) -> Bool in
                distanceFrom(dynamicItem.center, to: item.center) < (item.bounds.radius)
            }
            .filter { (element) -> Bool in element == true }
            .first
        if let doesIntersect = doesIntersect {
            return doesIntersect
        }

        return false
    }

    private func addView(dynamicItem: CEEntryDynamicItem) {
        let randomX = CGFloat.random() * (bounds.width - dynamicItem.bounds.width)
        dynamicItem.center.x = randomX

        while (itemsIntersectWithItem(dynamicItem)) {
            dynamicItem.center.y -= dynamicItem.view.bounds.radius
        }

        dynamicItems.append(dynamicItem)
        addSubview(dynamicItem.view)
        dynamicBehavior.addItem(dynamicItem)
    }

    private func removeView(dynamicItem: CEEntryDynamicItem) {
        guard let index = dynamicItems.indexOf(dynamicItem) else {
            NSLog("CECollectionDynamicView::RemoveView::ViewNotFound: \(dynamicItem)")
            return
        }
        dynamicItems.removeAtIndex(index)
        UIView.animateWithDuration(0.5, animations: {
            dynamicItem.view.alpha = 0.0
            }, completion: { (finished) in
                dynamicItem.removeFromSuperview()
                self.dynamicBehavior.removeItem(dynamicItem)
        })
    }

    func reloadData() {
        guard let dataSource = dataSource else {
            NSLog("CECollectionDynamicView:ReloadData::NoDataSource!")
            return
        }

        // Clear items
        while dynamicItems.count > 0 {
            removeView(dynamicItems.first!)
        }

        // Ask for new items from the dataSource and add them to the view
        let count = dataSource.dynamicViewNumberOfItems(self)
        for var i in 0..<count {
            // To suppress (incorrect) compiler warning
            i = i+0
            let cell = dataSource.dynamicView(cellForItemAtIndex: i)
            addView(cell)
        }
    }
}

protocol CECollectionDynamicViewDataSource {
    func dynamicViewNumberOfItems(dynamicView: CECollectionDynamicView) -> Int
    func dynamicView(cellForItemAtIndex index: Int) -> CEEntryDynamicItem
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
