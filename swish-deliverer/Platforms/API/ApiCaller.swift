//
//  ApiCaller.swift
//  swish-deliverer
//
//  Created by Owen Ancelot on 18/02/2023.
//

import Foundation

class ApiCaller {
    
    private let apiServer = "https://swish.ancelotow.com/api/v1/"
    private var request: URLRequest
    
    
    init(endpoint: String, method: HttpMethod) {
        let uri = URLComponents(string: apiServer + endpoint)
        request = URLRequest(url: uri!.url!)
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Accept")
    }
    
    func withJsonBody(body: [String: Any]) -> ApiCaller {
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        return self
    }
    
    func withJwtToken(token: String) -> ApiCaller {
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return self
    }
    
    func withFileBody(attachments: [AttachmentFile]) -> ApiCaller {
        let boundary = "Boundary-\(UUID().uuidString)"
        
        var body = ""
        for attachment in attachments {
            body += "--\(boundary)\r\n"
            body += "Content-Disposition:form-data; name=\"\(attachment.key)\""
            let fileContent = String(data: attachment.fileDate, encoding: .utf8)
            body += "; filename=\"\(attachment.filename)\"\r\n"
            body += "Content-Type: \"content-type header\"\r\n"
            body += "\r\n\(fileContent)\r\n"
        }
        body += "--\(boundary)--\r\n";
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = body.data(using: .utf8)
        return self
    }
    
    func execute(_ completion: @escaping (Data?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { data, response, err in
            guard err == nil else {
                completion(nil, err)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(nil, NSError(domain: AppInstance.getInstance().idBundle, code: 2, userInfo: [
                    NSLocalizedFailureReasonErrorKey: NSLocalizedString(LocalizedStringKeys.no_data_found.rawValue, comment: "")
                ]))
                return
            }
            var statusCode = httpResponse.statusCode
            if statusCode == 500 {
                completion(nil, NSError(domain: AppInstance.getInstance().idBundle, code: 2, userInfo: [
                    NSLocalizedFailureReasonErrorKey: NSLocalizedString(LocalizedStringKeys.http_internal_server_error.rawValue, comment: "")
                ]))
                return
            }
            if statusCode == 404 {
                completion(nil, NSError(domain: AppInstance.getInstance().idBundle, code: 2, userInfo: [
                    NSLocalizedFailureReasonErrorKey: NSLocalizedString(LocalizedStringKeys.http_not_found_error.rawValue, comment: "")
                ]))
                return
            }
            if statusCode == 401 {
                completion(nil, NSError(domain: AppInstance.getInstance().idBundle, code: 2, userInfo: [
                    NSLocalizedFailureReasonErrorKey: NSLocalizedString(LocalizedStringKeys.http_unauthorized_error
                        .rawValue, comment: "")
                ]))
                return
            }
            if statusCode == 403 {
                completion(nil, NSError(domain: AppInstance.getInstance().idBundle, code: 2, userInfo: [
                    NSLocalizedFailureReasonErrorKey: NSLocalizedString(LocalizedStringKeys.http_forbidden_error.rawValue, comment: "")
                ]))
                return
            }
            if statusCode >= 400 {
                completion(nil, NSError(domain: AppInstance.getInstance().idBundle, code: 2, userInfo: [
                    NSLocalizedFailureReasonErrorKey: String(bytes: data!, encoding: String.Encoding.utf8)
                ]))
                return
            }
            if statusCode == 204 {
                completion(nil, nil)
                return
            }
            completion(data, nil)
        }
        task.resume()
    }
    
}
