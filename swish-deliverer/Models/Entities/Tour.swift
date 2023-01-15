//
//  Tour.swift
//  swish-deliverer
//
//  Created by Owen Ancelot on 11/01/2023.
//

import Foundation

class Tour {
    
    let id: Int
    let date: Date
    let parcels: [Parcel]
    
    init(id: Int, date: Date, parcels: [Parcel] = []) {
        self.id = id
        self.date = date
        self.parcels = parcels
    }
    
    class func fromDictionary(dict: [String: Any]) -> Tour? {
        guard let id = dict[TourKeys.id.rawValue] as? Int,
              let dateStr = dict[TourKeys.date.rawValue] as? String else {
            return nil
        }
        let dictParcels = dict[TourKeys.parcels.rawValue] as? [[String: Any]] ?? []
        var parcels: [Parcel] = []
        for dictParcel in dictParcels {
            if let parcel = Parcel.fromDictionary(dict: dictParcel) {
                parcels.append(parcel)
            }
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        guard let date = DateConverter().toDate(dateStr) else {
            return nil
        }
        return Tour(id: id, date: date, parcels: parcels)
    }
    
}
