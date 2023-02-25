//
//  TourService.swift
//  swish-deliverer
//
//  Created by Owen Ancelot on 11/01/2023.
//

import Foundation

protocol TourService {
    
    func getCurrentTour(_ completion: @escaping (Tour?, Error?) -> Void)
    
    func deliverParcel(parcel: Parcel, proofData: Data, _ completion: @escaping (Error?) -> Void)
 
    func updateState(id: Int, state: TourState, _ completion: @escaping (Error?) -> Void);
}
