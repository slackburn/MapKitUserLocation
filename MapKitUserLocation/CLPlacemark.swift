//
//  CLPlacemark.swift
//  MapKitUserLocation
//
//  Created by Codenation13 on 08/11/2018.
//  Copyright © 2018 samblackburn. All rights reserved.
//

import CoreLocation

extension CLPlacemark {
    
    var compactAddress: String? {
        if let name = name {
            var result = name
            
            if let street = thoroughfare {
                result += ", \(street)"
            }
            if let city = locality {
                result += ", \(city)"
            }
            if let zip = postalCode {
                result += ", \(zip)"
            }
            if let country = country {
                result += ", \(country)"
            }
            return result
        }
        return nil
    }
}
