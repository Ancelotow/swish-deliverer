//
//  DelivererApiService.swift
//  swish-deliverer
//
//  Created by Owen Ancelot on 25/02/2023.
//

import Foundation
import CoreLocation
import UIKit

class DelivererApiService: DelivererService {
    
    func updateMyPosition(position: CLLocationCoordinate2D, _ completion: @escaping (Error?) -> Void) {
        guard let token = Session.getSession()?.token else {
            completion(NSError(domain: AppInstance.getInstance().idBundle, code: ErrorCode.notConnected.hashValue, userInfo: [
                NSLocalizedFailureReasonErrorKey: NSLocalizedString(LocalizedStringKeys.no_login_token.rawValue, comment: "")
            ]))
            return
        }
        let body = ["latitude": position.latitude, "longitude": position.longitude]
        let apiCaller = ApiCaller(endpoint: "deliverer/me/current-position", method: HttpMethod.PATCH)
            .withJwtToken(token: token)
            .withJsonBody(body: body)
        apiCaller.execute() { data, err in
            guard err == nil else {
                completion(err)
                return
            }
            completion(nil)
        }
    }
    
    func getProfilePhoto(uuid: UUID, _ completion: @escaping (UIImage?, Error?) -> Void) {
        guard let token = Session.getSession()?.token,
              let uuid = Session.getSession()?.uuid else {
            completion(nil, NSError(domain: AppInstance.getInstance().idBundle, code: ErrorCode.notConnected.hashValue, userInfo: [
                NSLocalizedFailureReasonErrorKey: NSLocalizedString(LocalizedStringKeys.no_login_token.rawValue, comment: "")
            ]))
            return
        }
        let apiCaller = ApiCaller(endpoint: "download/deliverer/\(uuid)", method: HttpMethod.GET)
            .withJwtToken(token: token)
        apiCaller.execute() { data, err in
            guard err == nil else {
                completion(nil, err)
                return
            }
            guard let data = data else {
                completion(nil, NSError(domain: AppInstance.getInstance().idBundle, code: ErrorCode.notConnected.hashValue, userInfo: [
                    NSLocalizedFailureReasonErrorKey: NSLocalizedString(LocalizedStringKeys.no_data_found.rawValue, comment: "")
                ]))
                return
            }
            guard let image = UIImage(data: data) else {
                completion(nil, NSError(domain: AppInstance.getInstance().idBundle, code: ErrorCode.notConnected.hashValue, userInfo: [
                    NSLocalizedFailureReasonErrorKey: NSLocalizedString(LocalizedStringKeys.no_data_found.rawValue, comment: "")
                ]))
                return
            }
            completion(image, nil)
        }
    }
    
}
