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
    @IBOutlet weak var backgroundView: UIView!

    var animator: UIDynamicAnimator!
    var dynamicBehavior: CEThrowBehavior!
    var dynamicItems: [CEEntryDynamicItem]
    var dataSource: CECollectionDynamicViewDataSource?
    var delegate: CECollectionDynamicViewDelegate?

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
        dynamicItem.center.x = bounds.width/2

        while (itemsIntersectWithItem(dynamicItem)) {
            dynamicItem.center.y -= dynamicItem.view.bounds.radius
        }

        dynamicItems.append(dynamicItem)
        addSubview(dynamicItem.view)
        dynamicBehavior.addItem(dynamicItem)
        dynamicItem.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CECollectionDynamicView.handleTap(_:))))
    }

    func setEditMode(editMode: CEViewControllerEditMode) {
        dynamicItems.forEach { (item) in
            item.setEditMode(editMode)
        }
    }

    func handleTap(tapGestureRecognizer: UITapGestureRecognizer) {
        guard let view = tapGestureRecognizer.view as? CEEntryDynamicItemContainerView,
            item = view.dynamicItem else {
                NSLog("CECollectionDynamicView::HandleTap::CouldNotFindContainerView: \(tapGestureRecognizer)")
                return
        }

        guard let delegate = delegate else {
            NSLog("CECollectionDynamicView:HandleTap::NoDelegate!")
            return
        }
        delegate.dynamicView(self, didSelectEntry: item.entry)
    }

    func invalidateItemAtIndex(index: Int) {
        // HACK: Not sure why I have to go deep within the subviews to setNeedsDisplay
        // Should be able to just do dynamicItems[index].view.setNeedsDisplay(). What's up with this?
        dynamicItems[index].view.subviews.forEach {
            $0.setNeedsDisplay()
        }
    }

    func removeItemAtIndex(index: Int) {
        removeView(dynamicItems[index])
    }

    func appendItem() {
        guard let dataSource = dataSource else {
            NSLog("CECollectionDynamicView:AppendItem::NoDataSource!")
            return
        }

        let dataSourceCount = dataSource.dynamicViewNumberOfItems(self)
        let selfCount = dynamicItems.count
        if dataSourceCount == (selfCount + 1) {
            let cell = dataSource.dynamicView(cellForItemAtIndex: selfCount)
            addView(cell)
        } else {
            NSLog("CECollectionDynamicView::AppendItem::DataSourceCountOutOfSync: \(dataSourceCount) != (\(selfCount) + 1)")
            reloadData()
        }
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
                self.dynamicBehavior.removeItem(dynamicItem)
                dynamicItem.removeFromSuperview()
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

protocol CECollectionDynamicViewDelegate {
    func dynamicView(dynamicView: CECollectionDynamicView, didSelectEntry entry: CEEntry)
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
