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
        guard let addresses = viewModel.postalAddresses else {
            NSLog("CEEntryDetailMapController::BeginOperationsWithCurrentAddress::NoAddressesForEntry")
            return
        }

        // TODO: construct operations front to back so that dependencies can be added
        let closestAddressComputation = CEComputeClosestAddressOperation(locationsManager: locationsManager)

        for address in addresses {
            // TODO: Add dependency on operation which evaluates closest address
            let operation = CEGeocodeAddressOperation(address: address.stringValue, locationsManager: locationsManager)
            closestAddressComputation.addDependency(operation)
            operationQueue.addOperation(operation)
        }
        operationQueue.addOperation(closestAddressComputation)
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        NSLog("keypath: \(keyPath): \(change)")
    }

    // MARK: - CLLocationManagerDelegate Methods
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            NSLog("CEEntryDetailMapController::LocationManagerDidUpdateLocation::CouldNotObtainLocation")
            return
        }

        locationsManager = CELocationsManager(userLocation: location)
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))

        if !locationDidInitialize {
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

class CEComputeClosestAddressOperation: NSOperation {
    var locationsManager: CELocationsManager
    init(locationsManager: CELocationsManager) {
        self.locationsManager = locationsManager
        super.init()
    }

    override func main() {
        NSLog("closest location to user: \(locationsManager.closestPlacemarkToUser())")
    }
}

class CEGeocodeAddressOperation: CEOperation {
    let address: String
    var error: NSError?
    var locationsManager: CELocationsManager

    init(address: String, locationsManager: CELocationsManager) {
        self.address = address
        self.locationsManager = locationsManager
        super.init()
    }

    override func start() {
        super.start()
    }

    override func main() {
        if cancelled {
            state = .Finished
            return
        }

        state = .Executing
        NSLog("Executing operation: \(address)")
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if let placemarks = placemarks {
                self.locationsManager.addPlacemarks(placemarks)
                NSLog("CEGeocodeAddressOperation::ObtainedPlacemarkForAddress: \(self.address)")
            } else {
                self.error = error
                NSLog("CEGeocodeAddressOperation::FailedWithError: \(error)")
            }
            self.state = .Finished
        }
    }
}

class CESearchForCoffeeOperation: NSOperation {
    let mapView: MKMapView

    init(mapView: MKMapView) {
        self.mapView = mapView
    }

    func searchForCoffee() {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = "coffee"
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler { (response, error) in
            if let response = response {
                let annotations = response.mapItems.map { (mapItem) -> MKAnnotation in
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = mapItem.placemark.coordinate
                    annotation.title = mapItem.name
                    return annotation
                }
                self.mapView.addAnnotations(annotations)
            }
        }
    }
}