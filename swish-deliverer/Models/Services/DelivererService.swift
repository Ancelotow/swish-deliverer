//
//  DelivererService.swift
//  swish-deliverer
//
//  Created by Owen Ancelot on 25/02/2023.
//

import Foundation
import CoreLocation

protocol DelivererService {
    
    func updateMyPosition(position: CLLocationCoordinate2D, _ completion: @escaping (Error?) -> Void);
    
}
