//
//  AccountViewController.swift
//  swish-deliverer
//
//  Created by Owen Ancelot on 26/02/2023.
//

import UIKit

class AccountViewController: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var labelFirstname: UILabel!
    @IBOutlet weak var labelLastname: UILabel!
    @IBOutlet weak var labelEmail: UILabel!
    @IBOutlet weak var labelBirthday: UILabel!
    @IBOutlet weak var labelUsername: UILabel!
    let delivererService: DelivererService = DelivererApiService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadInformations()
        self.loadProfileImage()
    }
    
    func loadInformations() {
        guard let session = Session.getSession() else {
            return
        }
        labelLastname.text = session.name
        labelFirstname.text = session.firstname
        let usernameLabel = NSLocalizedString(LocalizedStringKeys.username.rawValue, comment: "")
        let emailLabel = NSLocalizedString(LocalizedStringKeys.email.rawValue, comment: "")
        let birthdayLabel = NSLocalizedString(LocalizedStringKeys.birthday.rawValue, comment: "")
        labelUsername.text = "\(usernameLabel): \(session.login)"
        labelEmail.text = "\(emailLabel): \(session.email)"
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let birthdayStr = formatter.string(from: session.birthday)
        labelBirthday.text = "\(birthdayLabel): \(birthdayStr)"
    }
    
    func loadProfileImage() {
        self.profileImage.isHidden = true
        if let uuid = Session.getSession()?.uuid {
            self.profileImage.isHidden = false
            self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
            delivererService.getProfilePhoto(uuid: uuid) { image, err in
                guard err == nil else {
                    return
                }
                if let image = image {
                    DispatchQueue.main.async {
                        self.profileImage.image = image
                    }
                }
            }
        }
    }

}
