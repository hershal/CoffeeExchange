//
//  CESetRegionToClosestAddressOperation.swift
//  CoffeeExchange
//
//  Created by Hershal Bhave on 2016-04-29.
//  Copyright © 2016 Hershal Bhave. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

class CESetRegionToClosestAddressOperation: CEOperation {
    let mapView: MKMapView
    let locationsManager: CELocationsManager
    let viewModel: CEEntryDetailViewModel
    static let mileInMeters = 1609.344

    init(mapView: MKMapView, locationsManager: CELocationsManager, viewModel: CEEntryDetailViewModel) {
        self.viewModel = viewModel
        self.mapView = mapView
        self.locationsManager = locationsManager
        super.init()
    }

    override func main() {
        state = .Executing
        NSLog("Executing CESetRegionToClosestAddressOperation")
        let user = locationsManager.userLocation.coordinate
        if let closestPlacemark = locationsManager.closestPlacemarkToUser(),
            closest = closestPlacemark.placemark.location?.coordinate
            where closestPlacemark.distance < (10 * CESetRegionToClosestAddressOperation.mileInMeters) {
            let maxLat = max(closest.latitude, user.latitude)
            let minLat = min(closest.latitude, user.latitude)
            let maxLon = max(closest.longitude, user.longitude)
            let minLon = min(closest.longitude, user.longitude)

            let latDelta = (maxLat - minLat)
            let lonDelta = (maxLon - minLon)

            let centerlat = latDelta/2 + minLat
            let centerlon = lonDelta/2 + minLon

            let center = CLLocationCoordinate2D(latitude: centerlat, longitude: centerlon)

            let span = MKCoordinateSpanMake(latDelta*2, lonDelta*2)

            let region = MKCoordinateRegion(center: center, span: span)
            locationsManager.region = region

            dispatch_async(dispatch_get_main_queue(), {
                self.mapView.setRegion(region, animated: false)
                let annotation = MKPointAnnotation()
                annotation.coordinate = closest
                if closestPlacemark.label != "" {
                    annotation.title = "\(self.viewModel.truth.contact.givenName)'s \(closestPlacemark.label)"
                } else {
                    annotation.title = "\(self.viewModel.truth.contact.givenName)"
                }
                annotation.subtitle = closestPlacemark.placemark.name
                self.mapView.addAnnotation(annotation)
            })
        }
        NSLog("Finished CESetRegionToClosestAddressOperation")
        
        state = .Finished
    }
}