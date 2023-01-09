//
//  Session.swift
//  swish-deliverer
//
//  Created by Owen Ancelot on 04/01/2023.
//

import Foundation

class Session {
    
    fileprivate static var session: Session? = nil
    let token: String
    let name: String
    let firstname: String
    let email: String
    
    fileprivate init(token: String, name: String, firstname: String, email: String) {
        self.token = token
        self.name = name
        self.firstname = firstname
        self.email = email
    }

    class func open(dict: [String:Any]) -> Bool {
        guard session == nil else {
            return false
        }
        guard let token = dict[SessionKeys.token.rawValue] as? String,
              let deliveryPerson = dict[SessionKeys.deliveryPerson.rawValue] as? [String: Any] else {
            return false
        }
        guard let name = deliveryPerson[SessionKeys.name.rawValue] as? String,
              let firstname = deliveryPerson[SessionKeys.firstname.rawValue] as? String,
              let email = deliveryPerson[SessionKeys.email.rawValue] as? String else {
            return false
        }
        session = Session(token: token, name: name, firstname: firstname, email: email)
        return true
    }
    
    class func close() {
        session = nil
    }
    
    class func getSession() -> Session? {
        return session
    }
    
}
