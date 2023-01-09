//
//  HomeViewController.swift
//  swish-deliverer
//
//  Created by Owen Ancelot on 04/01/2023.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    let connectionService: ConnectionService = ConnectionDbService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateLocalizedStrings()
    }
    
    func updateLocalizedStrings() {
        self.titleLabel.text = NSLocalizedString(LocalizedStringKeys.app_name.rawValue, comment: "")
        self.loginTextField.placeholder = NSLocalizedString(LocalizedStringKeys.login.rawValue, comment: "")
        self.passwordTextField.placeholder = NSLocalizedString(LocalizedStringKeys.password.rawValue, comment: "")
        self.forgotPasswordButton.setTitle(NSLocalizedString(LocalizedStringKeys.forgot_password.rawValue, comment: ""), for: .normal)
        self.signInButton.setTitle(NSLocalizedString(LocalizedStringKeys.sign_in.rawValue, comment: ""), for: .normal)
    }
    
    func showErrorMessage(_ message: String) {
        let alert = UIAlertController(title: "Invalide", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Fermer", style: .cancel))
        self.present(alert, animated: true)
    }

    @IBAction func signIn(_ sender: Any) {
        guard let login = loginTextField.text,
              let password = passwordTextField.text,
              !login.isEmpty, !password.isEmpty  else {
            self.showErrorMessage("L'identifiant et le mot de passes sont obligatoires")
            return
        }
        connectionService.connection(login: login, password: password) { msg, err in
            guard err == nil else {
                DispatchQueue.main.async {
                    let message = (err as? NSError)?.localizedFailureReason ?? "Erreur inconnue"
                    self.showErrorMessage(message)
                }
                return
            }
            print(Session.getSession()!.firstname)
        }
    }
    
}
