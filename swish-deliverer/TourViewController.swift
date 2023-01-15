//
//  TourViewController.swift
//  swish-deliverer
//
//  Created by Owen Ancelot on 09/01/2023.
//

import UIKit
import MapKit
import CoreLocation

class TourViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var labelParcels: UILabel!
    @IBOutlet weak var tableParcels: UITableView!
    let tourService: TourService = TourDbService()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.labelParcels.text = NSLocalizedString(LocalizedStringKeys.my_parcels.rawValue, comment: "")
        tourService.getCurrentTour { tour, err in
            guard err == nil else {
                return
            }
            DispatchQueue.main.async {
                guard let tour = tour else {
                    return
                }
                for parcel in tour.parcels {
                    print(parcel.addressStreet)
                }
            }
        }
    }

}
