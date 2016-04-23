//
//  CEEntryDetailView.swift
//  CoffeeExchange
//
//  Created by Hershal Bhave on 2016-04-23.
//  Copyright © 2016 Hershal Bhave. All rights reserved.
//

import UIKit
import Darwin

class CEEntryDetailViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var detailBackgroundView: CEEntryDetailBackgroundView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var balanceControl: UIStepper!
    @IBAction func balanceChanged(sender: AnyObject) {
        let value = balanceControl.value
        entry.balance = value < 0 ? Int(value - 0.5) : Int(value + 0.5)
        refreshView()

        // gives a random float between 0 and 1
        let randomFloat = CGFloat.random()
        let xSpawn = (detailBackgroundView.frame.width - CEEntryDynamicItem.size.width) * randomFloat
        let ySpawn = CGFloat(100) // detailBackgroundView.frame.origin.y
        let origin = CGPoint(x: xSpawn, y: ySpawn)
        let dynamicItem = CEEntryDynamicItem(origin: origin)
        detailBackgroundView.addSubview(dynamicItem)
        gravity.addItem(dynamicItem)
        boundsCollision.addItem(dynamicItem)
    }

    var entry: CEEntry!
    var delegate: CEEntryDetailDelegate?
    var animator: UIDynamicAnimator!
    var gravity: UIGravityBehavior!
    var boundsCollision: UICollisionBehavior!

    func refreshView() {
        if self.viewIfLoaded != nil {
            balanceLabel.text = "\(entry.balance)"
            self.title = "\(entry.contact.givenName) \(entry.contact.familyName)"
        }
    }

    // It's assumed the model is initailized before this method is called,
    // i.e. before we're ready to display to the screen
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
        refreshView()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.detailWillDisappear(self, withEntry: entry)
    }

    func commonInit() {
        balanceControl.stepValue = 1.0
        balanceControl.minimumValue = -1.0 * (balanceControl.maximumValue)
        balanceControl.value = Double(entry.balance)

        animator = UIDynamicAnimator(referenceView: detailBackgroundView)
        gravity = UIGravityBehavior()
        boundsCollision = UICollisionBehavior()
        boundsCollision.translatesReferenceBoundsIntoBoundary = true

        animator.addBehavior(boundsCollision)
        animator.addBehavior(gravity)
    }
}

protocol CEEntryDetailDelegate {
    func detailWillDisappear(detail: CEEntryDetailViewController, withEntry entry: CEEntry)
}

class CEEntryDetailBackgroundView: UIView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
    static func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UINT32_MAX))
    }
}