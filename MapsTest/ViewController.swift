//
//  ViewController.swift
//  MapsTest
//
//  Created by Admin on 08.02.18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps

class ViewController: UIViewController {
    @IBOutlet weak var locationName: UITextField!
    @IBAction func addLocation(_ sender: UIButton) {
        
        guard let gMapVC = storyboard?.instantiateViewController(withIdentifier: String(describing: GMapsViewController.self)) as? GMapsViewController else { return }
        gMapVC.locationDelegate = self
        navigationController?.pushViewController(gMapVC, animated: true)
    }
    
    lazy var gPlace = GMSPlace()
    var taskLocation = TaskLocation() {
        didSet {
            DispatchQueue.main.async {
                //let lat = self.taskLocation.coordinates.latitude.rounded(FloatingPointRoundingRule.)
                if self.taskLocation.name != "" {
                    self.locationName.text = "\(self.taskLocation.name)"
                } else {
                    let lat = self.taskLocation.coordinates.latitude.round(to: 100000)
                    let long = self.taskLocation.coordinates.longitude.round(to: 100000)
                    self.locationName.text = "Loc: \(lat), \(long)"
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

extension ViewController: SetLocationDelegate {
    func setLocation(location: TaskLocation) {
        self.taskLocation = location
        print("Location: \(taskLocation.coordinates), Name: \(taskLocation.name)")
    }
}

extension Double {
    mutating func round(to: Double) -> Double {
        return Darwin.round(to * self)/to
    }
}
