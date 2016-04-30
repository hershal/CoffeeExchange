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
                let annotations = response.mapItems.map { (mapItem) -> MKAnnotation in
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = mapItem.placemark.coordinate
                    annotation.title = mapItem.name
                    return annotation
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
