//
//  CEEntryDetailMapController.swift
//  CoffeeExchange
//
//  Created by Hershal Bhave on 2016-04-28.
//  Copyright © 2016 Hershal Bhave. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation
import Contacts

class CEEntryDetailMapController: NSObject, MKMapViewDelegate, CLLocationManagerDelegate {
    let mapView: MKMapView
    let viewModel: CEEntryDetailViewModel
    var locationManager: CLLocationManager
    var locationDidInitialize = false
    var operationQueue: NSOperationQueue

    var userLocation: CLLocation?
    var locationsManager: CELocationsManager!

    init(mapView: MKMapView, viewModel: CEEntryDetailViewModel) {
        self.mapView = mapView
        self.viewModel = viewModel
        self.locationManager = CLLocationManager()
        self.operationQueue = NSOperationQueue()
        super.init()
        mapView.delegate = self

        if !CLLocationManager.locationServicesEnabled() {
            NSLog("CEEntryDetailViewController::ViewDidLoad::LocationServicesDisabled!")
            mapView.alpha = 0
        } else {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
        }
    }

    func beginOperationsWithCurrentLocation(location: CLLocation) {

        operationQueue.suspended = true
        // TODO: construct operations front to back so that dependencies can be added
        let searchOperation = CESearchForCoffeeOperation(mapView: mapView, locationsManager: locationsManager)
        let setRegionOperation = CESetRegionToClosestAddressOperation(mapView: mapView, locationsManager: locationsManager, viewModel: viewModel)
        if let addresses = viewModel.postalAddresses {
            for (addressLabel, address) in addresses {
                // TODO: Add dependency on operation which evaluates closest address
                let operation = CEGeocodeAddressOperation(label: addressLabel, address: address.stringValue, locationsManager: locationsManager)
                setRegionOperation.addDependency(operation)
                operationQueue.addOperation(operation)
            }
        }
        searchOperation.addDependency(setRegionOperation)
        operationQueue.addOperation(setRegionOperation)
        operationQueue.addOperation(searchOperation)
        operationQueue.suspended = false
    }

    // MARK: - MKMapViewDelegate Methods
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? CEPointAnnotation {
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("CEPointAnnotationView") as? MKPinAnnotationView
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "CEPointAnnotationView")
            }

            let button = CEOpenMapsButton(type: .DetailDisclosure)
            button.mapItem = annotation.mapItem
            button.addTarget(self, action: #selector(CEEntryDetailMapController.showMapItemDetail(_:)), forControlEvents: .TouchUpInside)
            annotationView!.rightCalloutAccessoryView = button
            annotationView!.pinTintColor = UIColor.brownColor()
            annotationView!.animatesDrop = true
            annotationView?.canShowCallout = true
            return annotationView
        }
        return nil
    }

    func showMapItemDetail(sender: AnyObject) {
        if let sender = sender as? CEOpenMapsButton {
            sender.mapItem.openInMapsWithLaunchOptions(nil)
        }
    }

    func openItemsInMaps() {
        let mapItems = locationsManager.mapItems()
        if mapItems.count > 0 {
            MKMapItem.openMapsWithItems(mapItems, launchOptions: nil)
        } else {
            let userLocation = locationsManager.userLocation
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: userLocation.coordinate, addressDictionary: nil))
            mapItem.openInMapsWithLaunchOptions(nil)
        }
    }

    // MARK: - CLLocationManagerDelegate Methods
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            NSLog("CEEntryDetailMapController::LocationManagerDidUpdateLocation::CouldNotObtainLocation")
            return
        }

        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))

        if !locationDidInitialize {
            locationsManager = CELocationsManager(userLocation: location)
            mapView.setRegion(region, animated: false)
            beginOperationsWithCurrentLocation(location)
        }
        locationDidInitialize = true
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        NSLog("CEEntryDetailViewController::LocationManagerDidFailWithError: \(error)")
    }
}

extension CNPostalAddress {
    var stringValue: String {
        return "\(street), \(city), \(state), \(postalCode), \(country)"
    }
}
