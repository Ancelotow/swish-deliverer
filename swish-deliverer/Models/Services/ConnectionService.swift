//
//  ConnectionService.swift
//  swish-deliverer
//
//  Created by Owen Ancelot on 04/01/2023.
//

import Foundation

protocol ConnectionService {
    
    func connection(login: String, password: String, _ completion: @escaping (String?, Error?) -> Void)
    
    func logout()
    
}
