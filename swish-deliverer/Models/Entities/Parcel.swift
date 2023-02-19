//
//  Parcel.swift
//  swish-deliverer
//
//  Created by Owen Ancelot on 11/01/2023.
//

import Foundation
import MapKit
import CoreLocation

class Parcel {
    
    let uuid: UUID
    let addressStreet: String
    let civility: String
    let firstname: String
    let lastname: String
    let town: String
    let zipCode: String
    let country: String
    var isDelivered: Bool
    var dateDelivered: Date?
    let urlProofDelivered: String?
    var coordinate: CLLocation?
    
    init(uuid: UUID, civility: String, lastname: String, firstname: String, addressStreet: String, town: String, zipCode: String, country: String, isDelivered: Bool, dateDelivered: Date? = nil, urlProofDelivered: String? = nil) {
        self.uuid = uuid
        self.civility = civility
        self.lastname = lastname
        self.firstname = firstname
        self.addressStreet = addressStreet
        self.town = town
        self.zipCode = zipCode
        self.country = country
        self.isDelivered = isDelivered
        self.dateDelivered = dateDelivered
        self.urlProofDelivered = urlProofDelivered
    }
    
    func getFullname() -> String {
        return "\(civility) \(firstname) \(lastname)"
    }
    
    func getFullAddress() -> String {
        return "\(addressStreet), \(zipCode) \(town)"
    }
    
    func delivered() {
        self.dateDelivered = Date.now
        self.isDelivered = true
    }
    
    func initLocation(_ completion: @escaping () -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString("\(self.addressStreet) \(self.zipCode) \(self.town) \(self.country)") { placemmarks, err in
            guard let placemmarks = placemmarks else {
                completion()
                return
            }
            self.coordinate = placemmarks.last!.location
            completion()
        }
    }
    
    class func fromDictionary(dict: [String: Any]) -> Parcel? {
        guard let uuidStr = dict[ParcelKeys.uuid.rawValue] as? String,
              let civility = dict[ParcelKeys.civility.rawValue] as? String,
              let lastname = dict[ParcelKeys.lastname.rawValue] as? String,
              let firstname = dict[ParcelKeys.firstname.rawValue] as? String,
              let addressStreet = dict[ParcelKeys.addressstreet.rawValue] as? String,
              let town = dict[ParcelKeys.town.rawValue] as? String,
              let zipCode = dict[ParcelKeys.zipcode.rawValue] as? String,
              let isDelivered = dict[ParcelKeys.isdelivered.rawValue] as? Bool,
              let country = dict[ParcelKeys.country.rawValue] as? String else {
            return nil
        }
        guard let uuid = UUID(uuidString: uuidStr) else {
            return nil
        }
        var dateDelivered: Date? = nil
        if let dateDeliveredStr = dict[ParcelKeys.datedelivered.rawValue] as? String {
            dateDelivered = DateConverter().toDate(dateDeliveredStr)
        }
        let urlProofDelivered = dict[ParcelKeys.urlproofdelivered.rawValue] as? String
        return Parcel(uuid: uuid, civility: civility, lastname: lastname, firstname: firstname, addressStreet: addressStreet, town: town, zipCode: zipCode, country: country, isDelivered: isDelivered, dateDelivered: dateDelivered, urlProofDelivered: urlProofDelivered)
    }
    
}
