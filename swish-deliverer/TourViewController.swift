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
    @IBOutlet weak var labelTourState: UILabel!
    @IBOutlet weak var profilImage: UIImageView!
    var loadingAlert: UIAlertController? = nil
    var locationManager: CLLocationManager?
    var coordinate: CLLocationCoordinate2D!
    var parcelToDelivered: Parcel?
    let tourService: TourService = TourApiService()
    let delivererService: DelivererService = DelivererApiService()
    var timer: Timer?
    var tour: Tour? {
        didSet {
            self.tableParcels.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.askLocationPermission()
        self.loadProfileImage()
        let parcelCell = UINib(nibName: "ParcelTableViewCell", bundle: nil)
        self.mapView.setRegion(MKCoordinateRegion(center: self.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000), animated: true)
        self.tableParcels.register(parcelCell, forCellReuseIdentifier: TourViewController.parcelCellId)
        self.tableParcels.dataSource = self
        self.tableParcels.delegate = self
        self.tableParcels.rowHeight = 90.0
        self.labelParcels.text = NSLocalizedString(LocalizedStringKeys.my_parcels.rawValue, comment: "")
        self.loadDatas()
    }
    
    func loadProfileImage() {
        self.profilImage.isHidden = true
        if let uuid = Session.getSession()?.uuid {
            let clickProfileGesture = UITapGestureRecognizer(target: self, action: #selector(clickProfileGesture(gesture:)))
            self.profilImage.isUserInteractionEnabled = true
            self.profilImage.addGestureRecognizer(clickProfileGesture)
            self.profilImage.isHidden = false
            self.profilImage.layer.cornerRadius = self.profilImage.frame.size.width / 2;
            delivererService.getProfilePhoto(uuid: uuid) { image, err in
                guard err == nil else {
                    return
                }
                if let image = image {
                    DispatchQueue.main.async {
                        self.profilImage.image = image
                    }
                }
            }
        }
    }
    
    @objc func clickProfileGesture(gesture: UITapGestureRecognizer) {
        self.navigationController?.pushViewController(AccountViewController(), animated: true)
    }
    
    func updateState(state: TourState) {
        guard let tour = self.tour else {
            return
        }
        self.tourService.updateState(id: tour.id, state: state) { err in
            DispatchQueue.main.async {
                guard err == nil else {
                    return
                }
            }
        }
    }
    
    func loadDatas() {
        self.resetAnnotations()
        if self.timer != nil {
            self.timer = nil
        }
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
                var allParcelDelivered = true
                for parcel in self.tour!.parcels {
                    self.addMarkerFromParcel(parcel: parcel)
                    if !parcel.isDelivered {
                        allParcelDelivered = false
                    }
                }
                if allParcelDelivered {
                    self.labelTourState.text = NSLocalizedString(LocalizedStringKeys.tour_finished.rawValue, comment: "")
                    self.updateState(state: TourState.done)
                } else {
                    self.labelTourState.text = NSLocalizedString(LocalizedStringKeys.tour_in_progress.rawValue, comment: "")
                    self.updateState(state: TourState.in_process)
                }
                self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.handleMoveUser), userInfo: nil, repeats: true)
            }
        }
    }

    func showNoParcelMessage() {
        self.tableParcels.isHidden = true
        self.labelNoParcels.isHidden = false
        self.labelTourState.isHidden = true
        self.labelNoParcels.text = NSLocalizedString(LocalizedStringKeys.no_parcels.rawValue, comment: "")
    }
    
    static func newInstance(coordinate: CLLocationCoordinate2D) -> TourViewController {
        let controller = TourViewController()
        controller.coordinate = coordinate
        return controller
    }
    
    func addMarkerFromParcel(parcel: Parcel) {
        if !parcel.isDelivered {
            parcel.initLocation() {
                if let coordinate = parcel.coordinate {
                    let marker = MKPointAnnotation()
                    marker.coordinate = coordinate.coordinate
                    marker.title = parcel.getFullname()
                    marker.subtitle = parcel.getFullAddress()
                    self.mapView.addAnnotation(marker)
                }
            }
        }
    }
    
    func dismissLoadingAlert(_ completion: @escaping () -> Void) {
        guard let alert = self.loadingAlert else {
            return
        }
        alert.dismiss(animated: true, completion: completion)
        self.loadingAlert = nil
    }
    
    func askLocationPermission() {
        let manager = CLLocationManager()
        manager.delegate = self
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
        self.locationManager = manager
        if let locationManager = self.locationManager {
            if let location = locationManager.location {
                self.coordinate = location.coordinate
            }
        }
    }
    
    func showLoadingAlert() {
        let deliveryMsg = NSLocalizedString(LocalizedStringKeys.delivery_parcel.rawValue, comment: "")
        self.loadingAlert = UIAlertController(title: nil, message: deliveryMsg, preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();
        self.loadingAlert!.view.addSubview(loadingIndicator)
        present(self.loadingAlert!, animated: true, completion: nil)
    }
    
    func showErrorAlertWithMessage(_ message: String) {
        let title = NSLocalizedString(LocalizedStringKeys.invalid.rawValue, comment: "")
        let closeTitle = NSLocalizedString(LocalizedStringKeys.close.rawValue, comment: "")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: closeTitle, style: .cancel))
        self.present(alert, animated: true)
    }
    
    
    
    @objc func handleMoveUser()
    {
        askLocationPermission()
        if let indexPaths = self.tableParcels?.indexPathsForVisibleRows {
             for indexPath in indexPaths {
                 guard let parcel = self.tour?.parcels[indexPath.row] else {
                     return
                 }
                 let cell = self.tableParcels.cellForRow(at: indexPath) as! ParcelTableViewCell
                 cell.redraw(parcel: parcel, userPosition: self.coordinate)
             }
         }
        self.delivererService.updateMyPosition(position: self.coordinate) { err in
            guard err == nil else {
                let unknowErr = NSLocalizedString(LocalizedStringKeys.unknow_error.rawValue, comment: "")
                let message = (err as? NSError)?.localizedFailureReason ?? unknowErr
                self.showErrorAlertWithMessage(message)
                return
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
        var actions: [UITableViewRowAction] = []
        guard let parcel = self.tour?.parcels[indexPath.row] else {
            return actions
        }
        if !parcel.isDelivered {
            actions.append(getEditRowAction(parcel: parcel))
        }
        if let phoneNumber = parcel.phone {
            actions.append(getCallRowAction(phoneNumber: phoneNumber))
        }
        return actions
    }
    
    fileprivate func getCallRowAction(phoneNumber: String) -> UITableViewRowAction {
        let title = NSLocalizedString(LocalizedStringKeys.to_call.rawValue, comment: "")
        let callAction = UITableViewRowAction(style: .normal, title: title) { (rowAction, indexPath) in
            if let url = URL(string: "tel://\(phoneNumber)") {
                 UIApplication.shared.openURL(url)
             }
        }
        callAction.backgroundColor = .systemBlue
        return callAction
    }
    
    fileprivate func getEditRowAction(parcel: Parcel) -> UITableViewRowAction {
        let title = NSLocalizedString(LocalizedStringKeys.to_deliver.rawValue, comment: "")
        let editAction = UITableViewRowAction(style: .normal, title: title) { (rowAction, indexPath) in
            guard let parcelCoordinate = parcel.coordinate else {
                return
            }
            let myLocation = CLLocation(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude)
            let parcelLocation = CLLocation(latitude: parcelCoordinate.coordinate.latitude, longitude: parcelCoordinate.coordinate.longitude)
            let distance = myLocation.distance(from: parcelLocation)
            if distance > 200 {
                self.showErrorAlertWithMessage(NSLocalizedString(LocalizedStringKeys.distance_delivery_invalid.rawValue, comment: ""))
                return
            }
            self.parcelToDelivered = parcel
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                return
            }
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.allowsEditing = true
            picker.delegate = self
            self.present(picker, animated: true)
            (self.tableParcels.cellForRow(at: indexPath) as! ParcelTableViewCell).redraw(parcel: parcel, userPosition: self.coordinate)
        }
        editAction.backgroundColor = .systemGreen
        return editAction
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
    
    func resetAnnotations() {
        let annotations = mapView.annotations.filter {
                $0 !== self.mapView.userLocation
        }
        mapView.removeAnnotations(annotations)
    }
}

extension TourViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
 
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        showLoadingAlert()
        guard let image = info[.editedImage] as? UIImage else {
            self.dismissLoadingAlert {
            }
            return
        }
        guard let imageData = image.pngData(),
              let parcel = parcelToDelivered else {
            self.dismissLoadingAlert {
            }
            return
        }
        parcel.delivered()
        tourService.deliverParcel(parcel: parcel, proofData: imageData) { err in
            DispatchQueue.main.async {
                self.dismissLoadingAlert {
                    guard err == nil else {
                        let unknowErr = NSLocalizedString(LocalizedStringKeys.unknow_error.rawValue, comment: "")
                        let message = (err as? NSError)?.localizedFailureReason ?? unknowErr
                        self.showErrorAlertWithMessage(message)
                        return
                    }
                    self.loadDatas()
                }
            }
        }
        picker.dismiss(animated: true)
    }
    
}
