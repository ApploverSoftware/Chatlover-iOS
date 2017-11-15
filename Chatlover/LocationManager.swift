//
//  LocationManager.swift
//  FitnessApp
//
//  Created by Grzegorz Hudziak on 13/03/2017.
//  Copyright © 2017 Applover. All rights reserved.
//

import MapKit

/// Implement this function if you want to receive location update
protocol LocationManagerDelegate {
    func didUpdateLocation(location: CLLocation)
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    // Singleton
    static let instance = LocationManager()
    
    // Private location manager class
    private let locationManager = CLLocationManager()
    
    // Current user location
    var userLocation: CLLocation?
    
    // Delegate to notify when location manager receive new location, then it is saved to userLocation variable and call delegate function
    var delegate: LocationManagerDelegate?
    
    private var callBack: ((CLLocation) -> Void)? = nil
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func start() {
        locationManager.startUpdatingLocation()
    }
    
    func updateLocation(completionHandler: ((CLLocation) -> Void)? = nil) {
        callBack = completionHandler
        start()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location else {
            return
        }
        
        locationManager.stopUpdatingLocation()
        
        // For get location only once
        callBack?(location)
        callBack = nil
        
        // For delegate
        delegate?.didUpdateLocation(location: manager.location!)
    }
    
    func clear() {
        userLocation = nil
        delegate = nil
        callBack = nil
        locationManager.stopUpdatingLocation()
    }
    
    static var addressBuffor: [CLLocation : String] = [:]
    
    static func getAddress(location loc: CLLocationCoordinate2D, completionHandler: @escaping (String) -> Void) {
        let location = CLLocation(latitude: loc.latitude, longitude: loc.longitude)
        
        if let address = addressBuffor[location] {
            completionHandler(address)
        }
        
        let ceo: CLGeocoder = CLGeocoder()
        ceo.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
            if (error != nil) {
                print("reverse geodcode fail: \(error!.localizedDescription)")
            }
            
            let pm = placemarks! as [CLPlacemark]
            if pm.count > 0 {
                let pm = placemarks![0]
                
                var addressString : String = ""
                if pm.subLocality != nil {
                    addressString = addressString + pm.subLocality! + ", "
                }
                if pm.thoroughfare != nil {
                    addressString = addressString + pm.thoroughfare! + ", "
                }
                if pm.locality != nil {
                    addressString = addressString + pm.locality! + ", "
                }
                if pm.country != nil {
                    addressString = addressString + pm.country! + ", "
                }
                if pm.postalCode != nil {
                    addressString = addressString + pm.postalCode! + " "
                }
                addressBuffor[location] = addressString
                completionHandler(addressString)
            }
        })
    }
}

