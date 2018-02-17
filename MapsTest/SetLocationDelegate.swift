//
//  SetLocationDelegate.swift
//  MapsTest
//
//  Created by David on 2/14/18.
//  Copyright © 2018 Admin. All rights reserved.
//

import Foundation
import GoogleMaps
import GooglePlaces

protocol SetLocationDelegate: class {
    func setLocation(location: TaskLocation)
}
