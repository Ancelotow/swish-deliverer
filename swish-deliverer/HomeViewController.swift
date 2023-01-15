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
    var loadingAlert: UIAlertController? = nil
    
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
    
    func showErrorAlertWithMessage(_ message: String) {
        let title = NSLocalizedString(LocalizedStringKeys.invalid.rawValue, comment: "")
        let closeTitle = NSLocalizedString(LocalizedStringKeys.close.rawValue, comment: "")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: closeTitle, style: .cancel))
        self.present(alert, animated: true)
    }
    
    func showLoadingAlert() {
        let connectionMsg = NSLocalizedString(LocalizedStringKeys.connection_loding.rawValue, comment: "")
        self.loadingAlert = UIAlertController(title: nil, message: connectionMsg, preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();
        self.loadingAlert!.view.addSubview(loadingIndicator)
        present(self.loadingAlert!, animated: true, completion: nil)
    }
    
    func dismissLoadingAlert(_ completion: @escaping () -> Void) {
        guard let alert = self.loadingAlert else {
            return
        }
        alert.dismiss(animated: true, completion: completion)
        self.loadingAlert = nil
    }

    @IBAction func signIn(_ sender: Any) {
        guard let login = loginTextField.text,
              let password = passwordTextField.text,
              !login.isEmpty, !password.isEmpty  else {
            let errMsg = NSLocalizedString(LocalizedStringKeys.logins_required.rawValue, comment: "")
            self.showErrorAlertWithMessage(errMsg)
            return
        }
        self.showLoadingAlert()
        connectionService.connection(login: login, password: password) { msg, err in
            guard err == nil else {
                DispatchQueue.main.async {
                    self.dismissLoadingAlert() {
                        let unknowErr = NSLocalizedString(LocalizedStringKeys.unknow_error.rawValue, comment: "")
                        let message = (err as? NSError)?.localizedFailureReason ?? unknowErr
                        self.showErrorAlertWithMessage(message)
                    }
                }
                return
            }
            DispatchQueue.main.async {
                self.dismissLoadingAlert() {
                    self.navigationController?.pushViewController(TourViewController(), animated: true)
                }
            }
        }
    }
    
}
