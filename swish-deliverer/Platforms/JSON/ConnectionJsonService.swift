//
//  ConnectionJsonService.swift
//  swish-deliverer
//
//  Created by Owen Ancelot on 04/01/2023.
//

import Foundation

class ConnectionJsonService: ConnectionService {
    
    let filePath: String
    
    init() {
        let directories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        self.filePath = "file://\(directories[0].appending("/accounts.json"))"
        self.initTestsDatas()
    }
    
    fileprivate func initTestsDatas() {
        let account1 = ["login": "patreides", "password": "test", "firstname": "Paul", "name": "ATREÏDES", "email": "test@gmail.com"]
        let account2 = ["login": "rdeckard", "password": "test2", "firstname": "Rick", "name": "DECKARD", "email": "test2@gmail.com"]
        let accounts = [account1, account2]
        do {
            let json = try JSONSerialization.data(withJSONObject: accounts)
            try json.write(to: URL(string: self.filePath)!)
        } catch {
            
        }
    }
    
    func connection(login: String, password: String, _ completion: @escaping (String?, Error?) -> Void) {
        completion(nil, nil)
    }
    
}
