//
//  TourDbService.swift
//  swish-deliverer
//
//  Created by Owen Ancelot on 11/01/2023.
//

import Foundation

class TourDbService: TourService {
    
    func getCurrentTour(_ completion: @escaping (Tour?, Error?) -> Void) {
        let urlComponents = URLComponents(string: "https://swish.herokuapp.com/current-delivery-tour")
        var urlRequest = URLRequest(url: urlComponents!.url!)
        urlRequest.httpMethod = "GET"
        do {
            urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
            guard let token = Session.getSession()?.token else {
                completion(nil, NSError(domain: AppInstance.getInstance().idBundle, code: ErrorCode.notConnected.hashValue, userInfo: [
                    NSLocalizedFailureReasonErrorKey: NSLocalizedString(LocalizedStringKeys.no_login_token.rawValue, comment: "")
                ]))
                return
            }
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            let task = URLSession.shared.dataTask(with: urlRequest) { data, response, err in
            guard err == nil else {
                completion(nil, err)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(nil, NSError(domain: AppInstance.getInstance().idBundle, code: ErrorCode.noData.hashValue, userInfo: [
                    NSLocalizedFailureReasonErrorKey: NSLocalizedString(LocalizedStringKeys.no_response_found.rawValue, comment: "")
                ]))
                return
            }
            if httpResponse.statusCode == 400 {
                completion(nil, NSError(domain: AppInstance.getInstance().idBundle, code: ErrorCode.badRequest.hashValue, userInfo: [
                    NSLocalizedFailureReasonErrorKey: String(bytes: data!, encoding: String.Encoding.utf8)
                ]))
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
        task.resume()
        } catch {
            completion(nil, error)
        }
    }
    
}
