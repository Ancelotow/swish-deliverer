//
//  DelivererService.swift
//  swish-deliverer
//
//  Created by Owen Ancelot on 25/02/2023.
//

import Foundation
import CoreLocation
import UIKit

protocol DelivererService {
    
    func updateMyPosition(position: CLLocationCoordinate2D, _ completion: @escaping (Error?) -> Void);
 
    func getProfilePhoto(uuid: UUID, _ completion: @escaping (UIImage?, Error?) -> Void);
}
