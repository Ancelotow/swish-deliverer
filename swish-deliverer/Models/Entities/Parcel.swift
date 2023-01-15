//
//  Parcel.swift
//  swish-deliverer
//
//  Created by Owen Ancelot on 11/01/2023.
//

import Foundation

class Parcel {
    
    let uuid: UUID
    let addressStreet: String
    let town: String
    let zipCode: String
    let country: String
    let isDelivered: Bool
    let dateDelivered: Date?
    let urlProofDelivered: String?
    
    init(uuid: UUID, addressStreet: String, town: String, zipCode: String, country: String, isDelivered: Bool, dateDelivered: Date? = nil, urlProofDelivered: String? = nil) {
        self.uuid = uuid
        self.addressStreet = addressStreet
        self.town = town
        self.zipCode = zipCode
        self.country = country
        self.isDelivered = isDelivered
        self.dateDelivered = dateDelivered
        self.urlProofDelivered = urlProofDelivered
    }
    
    class func fromDictionary(dict: [String: Any]) -> Parcel? {
        guard let uuidStr = dict[ParcelKeys.uuid.rawValue] as? String,
              let addressStreet = dict[ParcelKeys.addressstreet.rawValue] as? String,
              let town = dict[ParcelKeys.town.rawValue] as? String,
              let zipCode = dict[ParcelKeys.zipcode.rawValue] as? String,
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
        let isDelivered = false
        let urlProofDelivered = dict[ParcelKeys.urlproofdelivered.rawValue] as? String
        return Parcel(uuid: uuid, addressStreet: addressStreet, town: town, zipCode: zipCode, country: country, isDelivered: isDelivered, dateDelivered: dateDelivered, urlProofDelivered: urlProofDelivered)
    }
    
}
