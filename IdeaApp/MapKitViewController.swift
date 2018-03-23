//
//  MapKitViewController.swift
//  IdeaApp
//
//  Created by Lih Heng Yew on 22/03/2018.
//  Copyright © 2018 Lih Heng Yew. All rights reserved.
//

import UIKit
import MapKit

class MapKitViewController: UIViewController, MKMapViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var searchBarMap: UISearchBar!
    @IBOutlet weak var myMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMapView()
        searchBarMap.delegate = self
        
        let lpgr = UILongPressGestureRecognizer.init(target: self, action: #selector(handleLongPress(_:)))
        lpgr.minimumPressDuration = 2.0
        myMapView.addGestureRecognizer(lpgr)
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBarMap.text else {return}
        searchBarMap.resignFirstResponder()
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(searchText) { (placemarks:[CLPlacemark]?, error:Error?) in
            if error == nil {
                let placemark = placemarks?.first
                let anno = MKPointAnnotation()
                anno.coordinate = (placemark?.location?.coordinate)!
                print(anno.coordinate)
                //this part to zoom
                let span = MKCoordinateSpanMake(0.075, 0.075)
                let region = MKCoordinateRegionMake(anno.coordinate, span)
                self.myMapView.setRegion(region, animated: true)
                
                self.myMapView.addAnnotation(anno)
                self.myMapView.selectAnnotation(anno, animated: true)
            } else {
                print(error?.localizedDescription ?? "error")
            }
        }
    }
    
    func setUpMapView() {
        
        //set delegate
        self.myMapView.delegate = self
        
        //create coordinates for Next Academy
        let lat = 3.3149
        let lng = 101.6299
        
        //create annotation for mapview
        let nextAnnot = CustomPointAnnotation()
        
        nextAnnot.coordinate = CLLocationCoordinate2DMake(lat, lng)
        nextAnnot.title = "Next Academy"
        nextAnnot.subtitle = "You are here"
        myMapView.addAnnotation(nextAnnot)
        
        //add annotation to mapView
        let span = MKCoordinateSpanMake(0.4, 0.4)
        
        //region has a center and a span
        let region = MKCoordinateRegionMake(nextAnnot.coordinate, span)
        self.myMapView.setRegion(region, animated: true)
//        loadImageURL(annotation: nextAnnot, venue: sushi)
        
        geoCodeAddressString()
    }
    
    func geoCodeAddressString() {
        let geocoder = CLGeocoder.init()
        geocoder.geocodeAddressString("KLCC") { (placemarks, error) in
            if (error != nil) {
                print(error?.localizedDescription)
            }
            
            if (placemarks != nil) {
                for placemark in placemarks! {
                    let annotation = MKPointAnnotation.init()
                    annotation.coordinate = (placemark.location?.coordinate)!
                    annotation.title = placemark.name
                    annotation.subtitle = placemark.postalCode
                    self.myMapView.addAnnotation(annotation)
                }
            }
        }
    }
    

    @objc func handleLongPress(_ gestureRecognizer : UIGestureRecognizer){
        if gestureRecognizer.state != .began { return }
        
        let touchPoint = gestureRecognizer.location(in: myMapView)
        let touchMapCoordinate = myMapView.convert(touchPoint, toCoordinateFrom: myMapView)
        
        let pin = PinAnnotation(title: "BPP2/3", subtitle: "EquinePark", coordinate: touchMapCoordinate)
        print(touchMapCoordinate)
        myMapView.addAnnotation(pin)
    }

}
