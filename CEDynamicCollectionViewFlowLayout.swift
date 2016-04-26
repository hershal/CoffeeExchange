//
//  CEDynamicCollectionViewFlowLayout.swift
//  CoffeeExchange
//
//  Created by Hershal Bhave on 2016-04-25.
//  Copyright © 2016 Hershal Bhave. All rights reserved.
//

import Foundation
import UIKit

class CEDynamicCollectionViewFlowLayout: UICollectionViewFlowLayout {

    var animator: UIDynamicAnimator!
    var throwBehavior: CEThrowBehavior
    var dynamicItems: [CEEntryDynamicItem]

    override init() {
        dynamicItems = [CEEntryDynamicItem]()
        throwBehavior = CEThrowBehavior()
        super.init()
        animator = UIDynamicAnimator(collectionViewLayout: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareLayout() {
        super.prepareLayout()
    }

    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return false
    }
}
