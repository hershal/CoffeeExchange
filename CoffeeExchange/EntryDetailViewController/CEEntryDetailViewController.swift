//
//  CEEntryDetailView.swift
//  CoffeeExchange
//
//  Created by Hershal Bhave on 2016-04-23.
//  Copyright © 2016 Hershal Bhave. All rights reserved.
//

import UIKit
import CoreLocation
import Contacts
import MessageUI
import EventKit
import MapKit

class CEEntryDetailViewController: UIViewController, CEEntryDetailTableControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var stepperLabel: UILabel!
    @IBOutlet weak var stepperSublabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeightConstriant: NSLayoutConstraint!
    @IBOutlet weak var mapView: MKMapView!

    @IBAction func openInMapsButton(sender: AnyObject) {
        mapController.openItemsInMaps()
    }

    @IBAction func stepperChanged(sender: AnyObject) {
        let value = stepper.value
        viewModel.balance = Int(value)
    }

    var viewModel: CEEntryDetailViewModel!
    var delegate: CEEntryDetailDelegate?
    var locationManager: CLLocationManager!
    var tableController: CEEntryDetailTableController!
    var mapController: CEEntryDetailMapController!

    // MARK: - UIView Methods
    // It's assumed the model is initialized before this method is called.
    override func viewDidLoad() {
        super.viewDidLoad()
        stepper.value = Double(viewModel.balance)
        name.text = viewModel.truth.fullName
        tableController = CEEntryDetailTableController(viewModel: viewModel)
        tableController.delegate = self
        tableView.delegate = tableController
        tableView.dataSource = tableController
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CEEntryDetailCell")
        mapController = CEEntryDetailMapController(mapView: mapView, viewModel: viewModel)

        if let contactPicture = viewModel.picture, let image = UIImage(data: contactPicture as Data) {
            imageView.image = renderImagePort(image: image)
        } else {
            imageView.image = renderMonogram()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.addObserver(self, forKeyPath: #keyPath(CEEntryDetailViewModel.balance), options: [.new, .initial], context: nil)
        stepper.value = Double(viewModel.balance)
        let numItems = tableController.tableView(tableView, numberOfRowsInSection: 0)
        self.tableHeightConstriant.constant = 44.0 * CGFloat(numItems)
        UIView.animate(withDuration: 0.5) {
            self.tableView.layoutIfNeeded()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
}

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.removeObserver(self, forKeyPath: #keyPath(CEEntryDetailViewModel.balance))
        delegate?.detailWillDisappear(detail: self, withEntry: viewModel.truth)
    }

    func setupImageContext(rect: CGRect) {
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
        if let context = UIGraphicsGetCurrentContext() {
            UIColor.white.setFill()
            context.fill(rect)
        }
    }

    func teardownImageContext() -> UIImage {
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

    func renderImagePort(image: UIImage) -> UIImage {
        let rect = CGRect(origin: CGPoint.zero, size: imageView.bounds.size)

        setupImageContext(rect: rect)
        if let context = UIGraphicsGetCurrentContext() {
            let path = CGMutablePath()
            path.addEllipse(in: rect)
            context.addPath(path)
            context.clip()
            image.draw(in: rect)
        }
        return teardownImageContext()
    }

    func renderMonogram() -> UIImage {
        let rect = CGRect(origin: CGPoint.zero, size: imageView.bounds.size)

        setupImageContext(rect: rect)
        if let context = UIGraphicsGetCurrentContext() {
            UIColor.lightGray.withAlphaComponent(0.65).setFill()
            context.fillEllipse(in: rect)
            let textStyle = NSMutableParagraphStyle()
            textStyle.alignment = .center
            textStyle.lineBreakMode = .byWordWrapping
            let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white,
                                  NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22),
                                  NSAttributedString.Key.paragraphStyle: textStyle]
            let string = NSString(string: viewModel.initials)
            let stringSize = string.size(withAttributes: textAttributes)
            let textRect = CGRect(x: rect.origin.x, y: rect.origin.y + (rect.size.height - stringSize.height)/2, width: rect.width, height: rect.size.height)
            string.draw(in: textRect, withAttributes: textAttributes)
        }
        return teardownImageContext()
    }

    // MARK: - CEEntryDetailTableControllerDelegate Methods
    func tableControllerPresentViewController(viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }


    // MARK: - ObjC methods
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath else {
            NSLog("CEEntryDetailViewModel::ObserveValueForKeyPath::NilKeyPath")
            return
        }

        switch keyPath {
        case CEEntry.balanceKey:
            stepperLabel.text = viewModel.balanceText
            stepperSublabel.text = viewModel.balanceSubtext
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}

protocol CEEntryDetailDelegate {
    func detailWillDisappear(detail: CEEntryDetailViewController, withEntry entry: CEEntry)
}


