//
//  GMapsViewController.swift
//  MapsTest
//
//  Created by Admin on 08.02.18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import CoreLocation

struct TaskLocation {
    var name = ""
    var coordinates = CLLocationCoordinate2D()
    var radius: CLLocationDegrees?
}

class GMapsViewController: UIViewController {
    @IBOutlet weak var gMapsView: GMSMapView!
    @IBOutlet weak var searchBarView: UIView!
    
    @IBAction func addLocation(_ sender: UIButton) {
        locationDelegate?.setLocation(location: taskLocation)
        navigationController?.popViewController(animated: true)
    }
    
    weak var locationDelegate: SetLocationDelegate?
    lazy var currentPlace = GMSPlace()
    var taskLocation = TaskLocation()
    
    var locationManager = CLLocationManager()
    var userLocation = CLLocation()
    var selectedLocation = CLLocation()
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    var marker = GMSMarker()
    var coordinateForMarker = CLLocationCoordinate2D() {
        didSet {
            
        }
    }
    let defaultCamera = GMSCameraPosition.camera(withLatitude: 0.0,
                                                 longitude: 0.0,
                                                 zoom: 14.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        gMapsView.delegate = self
        gMapsView.camera = defaultCamera
        gMapsView.isMyLocationEnabled = true
        gMapsView.settings.myLocationButton = true
        gMapsView.settings.compassButton = true
        
        if let loc = locationManager.location {
            userLocation = loc
            animateCameraTo(coordinate: userLocation.coordinate)
            marker.position = userLocation.coordinate
            marker.isDraggable = true
            marker.map = gMapsView
        }
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        searchBarView.addSubview((searchController?.searchBar)!)
        searchController?.hidesNavigationBarDuringPresentation = false
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
    }
    
    override func viewWillLayoutSubviews() {
        searchController?.searchBar.frame.size.width = view.frame.size.width
        searchController?.searchBar.frame.size.height = 44.0
    }
    
    private func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            guard let address = response?.firstResult(), let name = address.lines?.first else {
                return
            }
            self.taskLocation.name = name
        }
    }
    private func animateCameraTo(coordinate: CLLocationCoordinate2D, zoom: Float = 14.0) {
        let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: zoom)
        gMapsView.animate(to: camera)
    }
}

extension GMapsViewController: GMSAutocompleteViewControllerDelegate, GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        animateCameraTo(coordinate: place.coordinate)
        searchController?.searchBar.text = place.formattedAddress ?? "Just text..."
    }
    
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        print("Canceling")
    }
}

extension GMapsViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
    }
    
}

extension GMapsViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        marker.position = coordinate
        reverseGeocodeCoordinate(coordinate)
        taskLocation.coordinates = coordinate
    }
    func mapViewDidFinishTileRendering(_ mapView: GMSMapView) {
    }
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        animateCameraTo(coordinate: userLocation.coordinate)
        return true
    }
}

extension GMapsViewController: UISearchBarDelegate, UISearchControllerDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        
    }
}

extension GMapsViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
       // (viewController as! ViewController).place = currentPlace
    }
}
