//
//  TourViewController.swift
//  swish-deliverer
//
//  Created by Owen Ancelot on 09/01/2023.
//

import UIKit
import MapKit
import CoreLocation

class TourViewController: UIViewController, CLLocationManagerDelegate {
    
    static let parcelCellId = "PARCEL_CELL_ID"
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var labelParcels: UILabel!
    @IBOutlet weak var tableParcels: UITableView!
    @IBOutlet weak var labelNoParcels: UILabel!
    var locationManager: CLLocationManager?
    var coordinate: CLLocationCoordinate2D!
    let tourService: TourService = TourApiService()
    var tour: Tour? {
        didSet {
            self.tableParcels.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        askLocationPermission()
        let parcelCell = UINib(nibName: "ParcelTableViewCell", bundle: nil)
        self.mapView.setRegion(MKCoordinateRegion(center: self.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000), animated: true)
        self.tableParcels.register(parcelCell, forCellReuseIdentifier: TourViewController.parcelCellId)
        self.tableParcels.dataSource = self
        self.tableParcels.delegate = self
        self.tableParcels.rowHeight = 90.0
        self.labelParcels.text = NSLocalizedString(LocalizedStringKeys.my_parcels.rawValue, comment: "")
        tourService.getCurrentTour { tour, err in
            guard err == nil else {
                return
            }
            DispatchQueue.main.async {
                guard let tour = tour else {
                    self.showNoParcelMessage()
                    return
                }
                
                self.tour = tour
                if(self.tour!.parcels.isEmpty) {
                    self.showNoParcelMessage()
                }
                
                self.labelNoParcels.isHidden = true
                self.tableParcels.isHidden = false
                for parcel in self.tour!.parcels {
                    self.addMarkerFromParcel(parcel: parcel)
                }
                Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.handleMoveUser), userInfo: nil, repeats: true)
            }
        }
    }

    func showNoParcelMessage() {
        self.tableParcels.isHidden = true
        self.labelNoParcels.isHidden = false
        self.labelNoParcels.text = NSLocalizedString(LocalizedStringKeys.no_parcels.rawValue, comment: "")
    }
    
    static func newInstance(coordinate: CLLocationCoordinate2D) -> TourViewController {
        let controller = TourViewController()
        controller.coordinate = coordinate
        return controller
    }
    
    func addMarkerFromParcel(parcel: Parcel) {
        parcel.initLocation() {
            if let coordinate = parcel.coordinate {
                let marker = MKPointAnnotation()
                marker.coordinate = coordinate.coordinate
                marker.title = parcel.getFullname()
                self.mapView.addAnnotation(marker)
            }
        }
    }
    
    func askLocationPermission() {
        let manager = CLLocationManager()
        manager.delegate = self
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
            
        }
        self.locationManager = manager
    }
    
    @objc func handleMoveUser()
    {
        askLocationPermission()
        if let indexPaths = self.tableParcels?.indexPathsForVisibleRows {
             for indexPath in indexPaths {
                 guard let parcel = self.tour?.parcels[indexPath.row] else {
                     return
                 }
                 (self.tableParcels.cellForRow(at: indexPath) as! ParcelTableViewCell).redraw(parcel: parcel, userPosition: self.coordinate)
             }
         }
    }
    
}

extension TourViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tour?.parcels.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let parcel = self.tour?.parcels[indexPath.row] else {
            return ParcelTableViewCell()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: TourViewController.parcelCellId, for: indexPath) as! ParcelTableViewCell
        cell.redraw(parcel: parcel, userPosition: self.coordinate)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let parcel = self.tour?.parcels[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .normal, title: "Livrer") { (rowAction, indexPath) in
            guard let parcel = self.tour?.parcels[indexPath.row] else {
                return
            }
            parcel.delivered()
            (self.tableParcels.cellForRow(at: indexPath) as! ParcelTableViewCell).redraw(parcel: parcel, userPosition: self.coordinate)
        }
        editAction.backgroundColor = .systemGreen

        return [editAction]
    }
    
}

extension TourViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let pinAnnotation = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "")
        pinAnnotation.canShowCallout = true
        pinAnnotation.markerTintColor = .orange
        return pinAnnotation
    }
}
