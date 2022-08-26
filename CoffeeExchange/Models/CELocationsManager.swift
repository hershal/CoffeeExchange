//
//  CELocationsManager.swift
//  CoffeeExchange
//
//  Created by Hershal Bhave on 2016-04-29.
//  Copyright © 2016 Hershal Bhave. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class CELocationsManager: NSObject {
    var userLocation: CLLocation
    var region: MKCoordinateRegion?
    private var _mapItems: [MKMapItem]
    private var _placemarks: [String: CLPlacemark]
    private let lock = NSLock()

    init(userLocation: CLLocation) {
        self.userLocation = userLocation
        self._placemarks = [String: CLPlacemark]()
        self._mapItems = [MKMapItem]()
        super.init()
    }

    func addPlacemark(placemark: CLPlacemark, withLabel label: String) {
        lock.withCriticalScope {
            self._placemarks[label] = placemark
        }
    }

    func addMapItems(mapItems: [MKMapItem]) {
        lock.withCriticalScope {
            self._mapItems.append(contentsOf: mapItems)
        }
    }

    func mapItems() -> [MKMapItem] {
        return lock.withCriticalScope { _mapItems }
    }

    func placemarks() -> [String: CLPlacemark] {
        return lock.withCriticalScope { _placemarks }
    }

    func closestPlacemarkToUser() -> (distance: CLLocationDistance, label: String, placemark: CLPlacemark)? {
        var minAssoc: (distance: CLLocationDistance, label: String, placemark: CLPlacemark)?
        placemarks().map { (label, placemark) -> (distance: CLLocationDistance, label: String, placemark: CLPlacemark) in
            (userLocation.distance(from: placemark.location!), label, placemark)
        }.forEach { (assoc) in
            if minAssoc == nil || minAssoc!.distance > assoc.distance  {
                minAssoc = assoc
            }
        }
        return minAssoc
    }
}
