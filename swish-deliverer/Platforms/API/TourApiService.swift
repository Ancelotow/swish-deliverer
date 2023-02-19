//
//  TourDbService.swift
//  swish-deliverer
//
//  Created by Owen Ancelot on 11/01/2023.
//

import Foundation

class TourApiService: TourService {
    
    func getCurrentTour(_ completion: @escaping (Tour?, Error?) -> Void) {
        guard let token = Session.getSession()?.token else {
            completion(nil, NSError(domain: AppInstance.getInstance().idBundle, code: ErrorCode.notConnected.hashValue, userInfo: [
                NSLocalizedFailureReasonErrorKey: NSLocalizedString(LocalizedStringKeys.no_login_token.rawValue, comment: "")
            ]))
            return
        }
        let apiCaller = ApiCaller(endpoint: "current-delivery-tour", method: HttpMethod.GET).withJwtToken(token: token);
        apiCaller.execute() { data, err in
            guard err == nil else {
                completion(nil, err)
                return
            }
            guard let d = data else {
                completion(nil, NSError(domain: AppInstance.getInstance().idBundle, code: ErrorCode.noData.hashValue, userInfo: [
                    NSLocalizedFailureReasonErrorKey: NSLocalizedString(LocalizedStringKeys.no_data_found.rawValue, comment: "")
                ]))
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: d, options: .allowFragments)
                guard let dict = json as? [String: Any] else {
                    completion(nil, NSError(domain: AppInstance.getInstance().idBundle, code: ErrorCode.invalidFormat.hashValue, userInfo: [
                        NSLocalizedFailureReasonErrorKey: NSLocalizedString(LocalizedStringKeys.invalid_format.rawValue, comment: "")
                    ]))
                    return
                }
                guard let tour = Tour.fromDictionary(dict: dict) else {
                    completion(nil, NSError(domain: AppInstance.getInstance().idBundle, code: ErrorCode.noData.hashValue, userInfo: [
                        NSLocalizedFailureReasonErrorKey: NSLocalizedString(LocalizedStringKeys.no_tour_found.rawValue, comment: "")
                    ]))
                    return
                }
                completion(tour, nil)
            } catch {
                completion(nil, err)
                return
            }
        }
    }
    
}