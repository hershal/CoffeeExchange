//
//  CEGeocodeAddressOperation.swift
//  CoffeeExchange
//
//  Created by Hershal Bhave on 2016-04-29.
//  Copyright © 2016 Hershal Bhave. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

class CEGeocodeAddressOperation: CEOperation {
    let address: String
    let label: String
    var error: NSError?
    var locationsManager: CELocationsManager

    init(label: String, address: String, locationsManager: CELocationsManager) {
        self.label = label
        self.address = address
        self.locationsManager = locationsManager
        super.init()
    }

    override func start() {
        super.start()
    }

    override func main() {
        if isCancelled {
            state = .Finished
            return
        }

        state = .Executing
        NSLog("Executing CEGeocodeAddressOperation: \(address)")
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if let placemarks = placemarks {
                for placemark in placemarks {
                    self.locationsManager.addPlacemark(placemark: placemark, withLabel: self.label)
                }
                NSLog("CEGeocodeAddressOperation::ObtainedPlacemarkForAddress: \(self.address)")
            } else {
                self.error = error as NSError?
                NSLog("CEGeocodeAddressOperation::FailedWithError: \(String(describing: error))")
            }
            self.state = .Finished
        }
    }
}
