//
//  DateConverter.swift
//  swish-deliverer
//
//  Created by Owen Ancelot on 15/01/2023.
//

import Foundation

class DateConverter {
    
    private let formatter: DateFormatter
    
    init() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        self.formatter = dateFormatter
    }
    
    func toDate(_ dateStr: String) -> Date? {
        return self.formatter.date(from: dateStr)
    }
    
}
