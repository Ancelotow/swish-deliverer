//
//  ConnectionDbService.swift
//  swish-deliverer
//
//  Created by Owen Ancelot on 09/01/2023.
//

import Foundation

class ConnectionDbService: ConnectionService {
    
    func connection(login: String, password: String, _ completion: @escaping (String?, Error?) -> Void) {
        let body = ["login": login, "password": password]
        let urlComponents = URLComponents(string: "https://swish.herokuapp.com/login")
        var urlRequest = URLRequest(url: urlComponents!.url!)
        urlRequest.httpMethod = "POST"
        do {
            urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: body)
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
            let task = URLSession.shared.dataTask(with: urlRequest) { data, response, err in
            guard err == nil else {
                completion(nil, err)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(nil, NSError(domain: AppInstance.getInstance().idBundle, code: 2, userInfo: [
                    NSLocalizedFailureReasonErrorKey: "No data found"
                ]))
                return
            }
            if httpResponse.statusCode == 400 {
                completion(nil, NSError(domain: AppInstance.getInstance().idBundle, code: 2, userInfo: [
                    NSLocalizedFailureReasonErrorKey: String(bytes: data!, encoding: String.Encoding.utf8)
                ]))
                return
            }
            guard let d = data else {
                completion(nil, NSError(domain: AppInstance.getInstance().idBundle, code: 2, userInfo: [
                    NSLocalizedFailureReasonErrorKey: "No data found"
                ]))
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: d, options: .allowFragments)
                guard let dict = json as? [String: Any] else {
                    completion(nil, NSError(domain: AppInstance.getInstance().idBundle, code: 3, userInfo: [
                        NSLocalizedFailureReasonErrorKey: "Invalid format"
                    ]))
                    return
                }
                guard Session.open(dict: dict) else {
                    completion(nil, NSError(domain: AppInstance.getInstance().idBundle, code: 3, userInfo: [
                        NSLocalizedFailureReasonErrorKey: "La session de connexion n'as pas pu être ouverte"
                    ]))
                    return
                }
                completion(nil, nil)
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
    
    func logout() {
        
    }
    
}
