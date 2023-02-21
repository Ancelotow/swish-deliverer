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
    
    func deliverParcel(parcel: Parcel, proofData: Data, _ completion: @escaping (Error?) -> Void) {
        guard let token = Session.getSession()?.token else {
            completion(NSError(domain: AppInstance.getInstance().idBundle, code: ErrorCode.notConnected.hashValue, userInfo: [
                NSLocalizedFailureReasonErrorKey: NSLocalizedString(LocalizedStringKeys.no_login_token.rawValue, comment: "")
            ]))
            return
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-ddTHH:mm:ss"
        let dateStr = formatter.string(from: parcel.dateDelivered!)
        let endpoint = "parcel/\(parcel.uuid)/delivery?date=\(dateStr)"
        let attachments = [
            AttachmentFile(fileDate: proofData, key: "proof", filename: "proof.png")
        ]
        let apiCaller = ApiCaller(endpoint: endpoint, method: HttpMethod.PATCH)
            .withJwtToken(token: token)
            .withFileBody(attachments: attachments);
        apiCaller.execute() { data, err in
            guard err == nil else {
                completion(err)
                return
            }
            completion(nil)
        }
    }
    
}
