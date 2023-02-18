//
//  HomeViewController.swift
//  swish-deliverer
//
//  Created by Owen Ancelot on 04/01/2023.
//

import UIKit
import LocalAuthentication
import CoreLocation

class HomeViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    let connectionService: ConnectionService = ConnectionApiService()
    var loadingAlert: UIAlertController? = nil
    var coordinate: CLLocationCoordinate2D?
    var locationManager: CLLocationManager?
    var context = LAContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.askLocationPermission()
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
    
    func askLocationPermission() {
        let manager = CLLocationManager()
        manager.delegate = self
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
            
        } else {
            print(manager.authorizationStatus)
        }
        self.locationManager = manager
    }
    
    @IBAction func signIn(_ sender: Any) {
        //self.authenticate()
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
                    self.goToTourView()
                }
            }
        }
    }
    
    func goToTourView() {
        if let coordinate = self.coordinate {
            let controller = TourViewController.newInstance(coordinate: coordinate)
            self.navigationController?.pushViewController(controller, animated: true)
        } else {
            displayDeniedMessage()
        }
    }
    
    func authenticate() {
        context = LAContext()
        context.localizedCancelTitle = "Enter Username/Password"

        // First check if we have the needed hardware support.
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            print(error?.localizedDescription ?? "Can't evaluate policy")

            // Fall back to a asking for username and password.
            // ...
            return
        }
        Task {
            do {
                try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Log in to your account")
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
}

extension HomeViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.hasLocationManagerStatus(manager)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else {
            return
        }
        self.coordinate = lastLocation.coordinate
        manager.stopUpdatingLocation()
    }
    
    func hasLocationManagerStatus(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .restricted || manager.authorizationStatus == .denied {
            self.displayDeniedMessage()
        } else if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            self.handleGPSCoordinate(manager)
        }
    }
    
    func displayDeniedMessage() {
        let title = NSLocalizedString(LocalizedStringKeys.location_denied.rawValue, comment: "")
        let message = NSLocalizedString(LocalizedStringKeys.enable_location_in_phone_prefs.rawValue, comment: "")
        let cancelLabel = NSLocalizedString(LocalizedStringKeys.cancel.rawValue, comment: "")
        let openPrefs = NSLocalizedString(LocalizedStringKeys.open_prefs.rawValue, comment: "")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: cancelLabel, style: .cancel))
        alert.addAction(UIAlertAction(title: openPrefs, style: .default, handler: { _ in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }))
        self.present(alert, animated: true)
    }
    
    func handleGPSCoordinate(_ manager: CLLocationManager) {
        manager.startUpdatingLocation()
    }

}
