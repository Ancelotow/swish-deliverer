//
//  AppSession.swift
//  swish-deliverer
//
//  Created by Owen Ancelot on 09/01/2023.
//

import Foundation

class AppInstance {
    
    private static var instance: AppInstance? = nil
    public let idBundle: String
    
    private init() {
        self.idBundle = "com.esgi.swish.swish-delivery"
    }
    
    class func getInstance() -> AppInstance {
        if instance == nil {
            instance = AppInstance()
        }
        return instance!
    }
    
}
