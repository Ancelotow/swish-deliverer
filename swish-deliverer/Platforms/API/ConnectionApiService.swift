//
//  ConnectionDbService.swift
//  swish-deliverer
//
//  Created by Owen Ancelot on 09/01/2023.
//

import Foundation

class ConnectionApiService: ConnectionService {
    
    func connection(login: String, password: String, _ completion: @escaping (String?, Error?) -> Void) {
        let body = ["login": login, "password": password]
        let apiCaller = ApiCaller(endpoint: "login", method: HttpMethod.POST).withBody(body: body)
        apiCaller.execute() { data, err in
            guard err == nil else {
                completion(nil, err)
                return
            }
            guard let d = data else {
                completion(nil, NSError(domain: AppInstance.getInstance().idBundle, code: 2, userInfo: [
                    NSLocalizedFailureReasonErrorKey: NSLocalizedString(LocalizedStringKeys.no_data_found.rawValue, comment: "")
                ]))
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: d, options: .allowFragments)
                guard let dict = json as? [String: Any] else {
                    completion(nil, NSError(domain: AppInstance.getInstance().idBundle, code: 3, userInfo: [
                        NSLocalizedFailureReasonErrorKey: NSLocalizedString(LocalizedStringKeys.invalid_format.rawValue, comment: "")
                    ]))
                    return
                }
                guard Session.open(dict: dict) else {
                    completion(nil, NSError(domain: AppInstance.getInstance().idBundle, code: 3, userInfo: [
                        NSLocalizedFailureReasonErrorKey: NSLocalizedString(LocalizedStringKeys.session_cannot_open.rawValue, comment: "")
                    ]))
                    return
                }
                completion(nil, nil)
            } catch {
                completion(nil, err)
                return
            }
        }
    }
    
    func logout() {
        
    }
    
}
