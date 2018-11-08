//
//  ViewController.swift
//  MapKitUserLocation
//
//  Created by Codenation13 on 08/11/2018.
//  Copyright © 2018 samblackburn. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var displayLocationLabel: UILabel!
    @IBOutlet weak var map: MKMapView!
    
    @IBAction func findLocationButtonPressed(_ sender: UIButton) {
        checkLocationServices()
    }
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAuthorization()
        } else {
        }
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            map.showsUserLocation = true
            locationManager.startUpdatingLocation()
            break
        case .denied:
            // Alert users telling them how to use location services
            let alert = UIAlertController(title: "Cannot Use Location", message: "MapKitUserLocation needs Location enabled. \nTo use, go to your Setings, MapKitUserLocation > Privacy > Location", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (_) -> Void in
            })
            present(alert, animated: true, completion: nil)
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .authorizedAlways:
            break
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let region = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: 300, longitudinalMeters: 300) // 300 reopresents the zoom on the map
        let lat = locations.last!.coordinate.latitude // Stores the latitude and longitude which can be submitted to database
        let long = locations.last!.coordinate.longitude
        print("\(lat),\(long)") // Prints the lat & long
        
        map.setRegion(region, animated: true)
        
        lookUpCurrentLocation { geoLoc in
            if geoLoc != nil {
                let userLocationName = geoLoc!.locality // Stores user location
                print(userLocationName ?? "nil") // prints which city the user is in
                
                let geoCoder = CLGeocoder()
                let location = CLLocation(latitude: lat, longitude: long)
                geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
                    
                    // Place details
                    var placeMark: CLPlacemark?
                    placeMark = placemarks?[0]
                    
                    let address = (placeMark?.compactAddress)
                    self.displayLocationLabel.text = address
                    print(address ?? "nil")
                })
            } else{ // default location chosen on simulator, actual location only works on physical device
                print("unknown geo location")
            }
        }
    }
    
    func lookUpCurrentLocation(completionHandler: @escaping (CLPlacemark?) -> Void ) {
        // Last reported location
        if let lastLocation = self.locationManager.location {
            let geocoder = CLGeocoder()
            
            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(lastLocation, completionHandler: { (placemarks, error) in
                if error == nil {
                    let firstLocation = placemarks?[0]
                    completionHandler(firstLocation)
                }
                else {
                    completionHandler(nil)
                }
            })
        } else {
            completionHandler(nil) // occurs when no location found
        }
    }
}
