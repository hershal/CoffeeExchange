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
        let intValue = value < 0 ? Int(value - 0.5) : Int(value + 0.5)
        entry.balance = intValue
        refreshView()
    }

    var entry: CEEntry!
    var delegate: CEEntryDetailDelegate?

    func refreshView() {
        if self.viewIfLoaded != nil {
            balanceLabel.text = "\(entry.balance)"
            detailBackgroundView.count = entry.balance
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

    private func commonInit() {
        self.title = "\(entry.contact.givenName) \(entry.contact.familyName)"
        balanceControl.stepValue = 1.0
        balanceControl.minimumValue = -1.0 * (balanceControl.maximumValue)
        balanceControl.value = Double(entry.balance)
    }
}

protocol CEEntryDetailDelegate {
    func detailWillDisappear(detail: CEEntryDetailViewController, withEntry entry: CEEntry)
}

class CEEntryDetailBackgroundView: UIView {

    var animator: UIDynamicAnimator!
    var gravity: UIGravityBehavior
    var initialBehavior: UIDynamicItemBehavior
    var boundsCollision: UICollisionBehavior
    var count: Int {
        didSet (newCount) {
            // do something
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        gravity = UIGravityBehavior()
        initialBehavior = UIDynamicItemBehavior()
        boundsCollision = UICollisionBehavior()
        count = 0

        super.init(coder: aDecoder)
        animator = UIDynamicAnimator(referenceView: self)

        // TODO: work to remove this
        boundsCollision.translatesReferenceBoundsIntoBoundary = true

        animator.addBehavior(gravity)
        animator.addBehavior(initialBehavior)
        animator.addBehavior(boundsCollision)
    }

    func pushView() {
        // gives a random float between 0 and 1
        let randomFloat = CGFloat.random()
        let maxRadius = sqrt(pow(CEEntryDynamicItem.size.height, 2) + pow(CEEntryDynamicItem.size.width, 2))
        let xSpawn = (frame.width - maxRadius) * randomFloat
        let ySpawn = CGFloat(100) // detailBackgroundView.frame.origin.y
        let origin = CGPoint(x: xSpawn, y: ySpawn)
        let dynamicItem = CEEntryDynamicItem(origin: origin)
        addSubview(dynamicItem)
    }

    func popView() {

    }

    internal override func addSubview(view: UIView) {
        super.addSubview(view)

        gravity.addItem(view)
        boundsCollision.addItem(view)
        initialBehavior.addItem(view)
        initialBehavior.addAngularVelocity(CGFloat.srandom()*CGFloat(M_PI), forItem: view)
        initialBehavior.addLinearVelocity(CGPoint(x: CGFloat.srandom()*1000, y: CGFloat.random()*1000), forItem: view)
        initialBehavior.elasticity = 0.25
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