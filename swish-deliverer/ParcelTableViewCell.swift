//
//  ParcelTableViewCell.swift
//  swish-deliverer
//
//  Created by Owen Ancelot on 18/02/2023.
//

import UIKit
import CoreLocation

class ParcelTableViewCell: UITableViewCell {

    @IBOutlet weak var labelFullname: UILabel!
    @IBOutlet weak var labelAddressStreet: UILabel!
    @IBOutlet weak var labelDistance: UILabel!
    @IBOutlet weak var labelDateDelivery: UILabel!
    @IBOutlet weak var labelDelivery: UILabel!
    @IBOutlet weak var iconParcel: UIImageView!
    let tourService: TourService = TourApiService()
    var parcel: Parcel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        labelDelivery.text = NSLocalizedString(LocalizedStringKeys.date_delivery_label.rawValue, comment: "")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    fileprivate func showDeliveredInformations() {
        labelDelivery.isHidden = false
        labelDateDelivery.isHidden = false
        let formatter = DateFormatter()
        formatter.dateFormat = NSLocalizedString(LocalizedStringKeys.date_format.rawValue, comment: "")
        labelDateDelivery.text = formatter.string(from: parcel.dateDelivered!)
        labelDistance.text = NSLocalizedString(LocalizedStringKeys.delivered.rawValue, comment: "")
    }
    
    fileprivate func updateDistance(userPosition: CLLocationCoordinate2D) {
        if let coordinate = parcel.coordinate {
            let myLocation = CLLocation(latitude: userPosition.latitude, longitude: userPosition.longitude)
            let parcelLocation = CLLocation(latitude: coordinate.coordinate.latitude, longitude: coordinate.coordinate.longitude)
            let distance = myLocation.distance(from: parcelLocation)
            if distance >= 1000 {
                let distanceStr = String(format: "%.2f", distance / 1000)
                labelDistance.text = "\(distanceStr)km"
            } else {
                let distanceStr = String(format: "%.2f", distance)
                labelDistance.text = "\(distanceStr)m"
            }
            
        } else {
            labelDistance.text = NSLocalizedString(LocalizedStringKeys.unknow_distance.rawValue, comment: "")
        }
    }
    
    func redraw(parcel: Parcel, userPosition: CLLocationCoordinate2D) {
        self.parcel = parcel
        labelFullname.text = parcel.getFullname()
        labelAddressStreet.text = parcel.getFullAddress()
        if parcel.isDelivered && parcel.dateDelivered != nil {
            showDeliveredInformations()
            iconParcel.image = UIImage(systemName: "cube.box.fill")
            iconParcel.tintColor = .systemGreen
        } else {
            labelDelivery.isHidden = true
            labelDateDelivery.isHidden = true
            iconParcel.image = UIImage(systemName: "box.truck.badge.clock.fill")
            iconParcel.tintColor = .systemOrange
            updateDistance(userPosition: userPosition)
        }
    }
    
}
