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
        operationQueue.suspended = true
        // TODO: construct operations front to back so that dependencies can be added
        let searchOperation = CESearchForCoffeeOperation(mapView: mapView, locationsManager: locationsManager)
        let setRegionOperation = CESetRegionToClosestAddressOperation(mapView: mapView, locationsManager: locationsManager)

        for (addressLabel, address) in addresses {
            // TODO: Add dependency on operation which evaluates closest address
            let operation = CEGeocodeAddressOperation(label: addressLabel, address: address.stringValue, locationsManager: locationsManager)
            setRegionOperation.addDependency(operation)
            operationQueue.addOperation(operation)
        }
        searchOperation.addDependency(setRegionOperation)
        operationQueue.addOperation(setRegionOperation)
        operationQueue.addOperation(searchOperation)
        operationQueue.suspended = false
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

class CESetRegionToClosestAddressOperation: CEOperation {
    let mapView: MKMapView
    let locationsManager: CELocationsManager
    init(mapView: MKMapView, locationsManager: CELocationsManager) {
        self.mapView = mapView
        self.locationsManager = locationsManager
        super.init()
    }

    override func main() {
        state = .Executing
        NSLog("Executing CESetRegionToClosestAddressOperation")
        let user = locationsManager.userLocation.coordinate
        if let closestPlacemark = locationsManager.closestPlacemarkToUser(),
            closest = closestPlacemark.placemark.location?.coordinate {
//            NSLog("closest location to user: \(locationsManager.closestPlacemarkToUser())")
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

            dispatch_async(dispatch_get_main_queue(), { 
                self.mapView.setRegion(region, animated: false)
                let annotation = MKPointAnnotation()
                annotation.coordinate = closest
                annotation.title = closestPlacemark.label
                self.mapView.addAnnotation(annotation)
            })
        }
        NSLog("Finished CESetRegionToClosestAddressOperation")

        state = .Finished
    }
}

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
        if cancelled {
            state = .Finished
            return
        }

        state = .Executing
        NSLog("Executing CEGeocodeAddressOperation: \(address)")
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if let placemarks = placemarks {
                for placemark in placemarks {
                    self.locationsManager.addPlacemark(placemark, withLabel: self.label)
                }
                NSLog("CEGeocodeAddressOperation::ObtainedPlacemarkForAddress: \(self.address)")
            } else {
                self.error = error
                NSLog("CEGeocodeAddressOperation::FailedWithError: \(error)")
            }
            self.state = .Finished
        }
    }
}

class CESearchForCoffeeOperation: CEOperation {
    let mapView: MKMapView
    let locationsManager: CELocationsManager

    init(mapView: MKMapView, locationsManager: CELocationsManager) {
        self.mapView = mapView
        self.locationsManager = locationsManager
    }

    func searchForCoffee() {
        if cancelled {
            state = .Finished
            return
        }
        state = .Executing
        NSLog("Executing CESearchForCoffeeOperation")

        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = "coffee shop"
        request.region = mapView.region
        NSLog("mapview region: \(mapView.region)")
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

    override func main() {
        searchForCoffee()
    }
}

