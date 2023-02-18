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
    var parcel: Parcel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        labelDelivery.text = NSLocalizedString(LocalizedStringKeys.date_delivery_label.rawValue, comment: "")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func showDeliveredInformations() {
        if(parcel.isDelivered && parcel.dateDelivered != nil) {
            labelDelivery.isHidden = false
            labelDateDelivery.isHidden = false
            let formatter = DateFormatter()
            formatter.dateFormat = NSLocalizedString(LocalizedStringKeys.date_format.rawValue, comment: "")
            labelDateDelivery.text = formatter.string(from: parcel.dateDelivered!)
        } else {
            labelDelivery.isHidden = true
            labelDateDelivery.isHidden = true
        }
    }
    
    func updateDistance(userPosition: CLLocationCoordinate2D) {
        if let coordinate = parcel?.coordinate {
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
            labelDistance.text = "Distance inconnue"
        }
    }
    
    func redraw(parcel: Parcel, userPosition: CLLocationCoordinate2D) {
        self.parcel = parcel
        labelFullname.text = parcel.getFullname()
        labelAddressStreet.text = parcel.getFullAddress()
        showDeliveredInformations()
        updateDistance(userPosition: userPosition)
    }
    
}
