//
//  CESearchForCoffeeOperation.swift
//  CoffeeExchange
//
//  Created by Hershal Bhave on 2016-04-29.
//  Copyright © 2016 Hershal Bhave. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

class CESearchForCoffeeOperation: CEOperation {
    let mapView: MKMapView
    let locationsManager: CELocationsManager

    init(mapView: MKMapView, locationsManager: CELocationsManager) {
        self.mapView = mapView
        self.locationsManager = locationsManager
    }

    override func main() {
        if cancelled {
            state = .Finished
            return
        }
        state = .Executing
        NSLog("Executing CESearchForCoffeeOperation")

        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = "coffee"

        request.region = locationsManager.region != nil ? locationsManager.region! : mapView.region
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler { (response, error) in
            if let response = response {
                self.locationsManager.mapItems = response.mapItems
                let annotations = response.mapItems.map { (mapItem) -> CEPointAnnotation in
                    return CEPointAnnotation(mapItem: mapItem)
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.mapView.addAnnotations(annotations)
                }
            }
            NSLog("Finished CESearchForCoffeeOperation")
            self.state = .Finished
        }
    }
}

class CEPointAnnotation: MKPointAnnotation {
    var mapItem: MKMapItem

    init(mapItem: MKMapItem) {
        self.mapItem = mapItem
        super.init()
        coordinate = mapItem.placemark.coordinate
        title = mapItem.name
    }
}

class CEOpenMapsButton: UIButton {
    var mapItem: MKMapItem!
}