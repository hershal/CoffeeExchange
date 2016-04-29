//
//  CELocationsManager.swift
//  CoffeeExchange
//
//  Created by Hershal Bhave on 2016-04-29.
//  Copyright © 2016 Hershal Bhave. All rights reserved.
//

import Foundation
import CoreLocation

class CELocationsManager: NSObject {
    var userLocation: CLLocation
    private var _placemarks: [CLPlacemark]
    private let lock = NSLock()

    init(userLocation: CLLocation) {
        self.userLocation = userLocation
        self._placemarks = [CLPlacemark]()
        super.init()
    }

    func addPlacemarks(placemarks: [CLPlacemark]) {
        lock.withCriticalScope {
            self._placemarks.appendContentsOf(placemarks)
        }
    }

    func placemarks() -> [CLPlacemark] {
        return lock.withCriticalScope { _placemarks }
    }

    func closestPlacemarkToUser() -> CLPlacemark? {
        var minAssoc: (CLLocationDistance, CLPlacemark)?
        placemarks().map { (placemark) -> (CLLocationDistance, CLPlacemark) in
            (userLocation.distanceFromLocation(placemark.location!), placemark)
        }.forEach { (assoc) in
            if minAssoc == nil || minAssoc!.0 > assoc.0  {
                minAssoc = assoc
            }
        }
        return minAssoc?.1
    }
}