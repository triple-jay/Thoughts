//
//  ProfileViewController.swift
//  Thoughts
//
//  Created by Jeremy Jung on 1/14/20.
//  Copyright © 2020 Jeremy Jung. All rights reserved.
//

import UIKit
import SnapKit
import Firebase
import FirebaseStorage

class ProfileViewController: UIViewController {
    
    var changeProfilePicture: UIButton!
    var imagePicker: UIImagePickerController!
    var profileImage: UIImageView!
    var usernameField: UITextField!
    var passwordField: UITextField!
    var saveChanges: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        view.backgroundColor = .white
        
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
        profileImage = UIImageView()
        if let profileImageUrl = Auth.auth().currentUser?.photoURL {
            URLSession.shared.dataTask(with: profileImageUrl) { (data, response, error) in
                if error == nil && data != nil {
                    DispatchQueue.main.async {
                        self.profileImage.image = UIImage(data: data!)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.profileImage.image = UIImage(named: "profile")
                    }
                }
            }.resume()
        } else {
            self.profileImage.image = UIImage(named: "profile")
        }
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(imageTap)
        profileImage.layer.cornerRadius = profileImage.bounds.height / 2
        profileImage.clipsToBounds = true
        view.addSubview(profileImage)
        
        changeProfilePicture = UIButton()
        changeProfilePicture.addTarget(self, action: #selector(openImagePicker), for: .touchUpInside)
        changeProfilePicture.setTitle("Change picture", for: .normal)
        changeProfilePicture.setTitleColor(.blue, for: .normal)
        view.addSubview(changeProfilePicture)
        
        saveChanges = UIButton()
        saveChanges.addTarget(self, action: #selector(saveFields), for: .touchUpInside)
        saveChanges.setTitle("Save Changes", for: .normal)
        saveChanges.setTitleColor(.blue, for: .normal)
        saveChanges.addTarget(self, action: #selector(saveFields), for: .touchUpInside)
        view.addSubview(saveChanges)
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        usernameField = UITextField()
        usernameField.font = UIFont.systemFont(ofSize: 15)
        usernameField.textColor = .black
        if let usernameText = Auth.auth().currentUser?.displayName {
            usernameField.text = usernameText
        } else {
            usernameField.placeholder = "Username"
        }
        usernameField.textAlignment = .center
        view.addSubview(usernameField)

        setupConstraints()
    }
    
    @objc func openImagePicker() {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func saveFields() {
        guard let image = profileImage.image else {return}
        guard let username = usernameField.text else {return}
        
        self.uploadProfileImage(image) { url in
            if url != nil {
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = username
                changeRequest?.photoURL = url
                changeRequest?.commitChanges(completion: { error in
                    if error == nil {
                        self.saveProfile(username: username, profileImageURL: url!) { success in
                            if success {
                                self.navigationController?.popViewController(animated: true)
                            } else {
                                self.errorAlert()
                            }
                        }
                    }
                })
            }
        }
        
    }
    
    func setupConstraints() {
        profileImage.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).offset(150)
            make.centerX.equalTo(view)
            make.height.width.equalTo(50)
        }
        
        changeProfilePicture.snp.makeConstraints { make in
            make.top.equalTo(profileImage.snp.bottom).offset(10)
            make.centerX.equalTo(view)
        }
        
        usernameField.snp.makeConstraints { make in
            make.top.equalTo(changeProfilePicture.snp.bottom).offset(10)
            make.centerX.equalTo(view)
        }
        
        saveChanges.snp.makeConstraints { make in
            make.top.equalTo(usernameField.snp.bottom).offset(10)
            make.centerX.equalTo(view)
        }
    }
    
    func errorAlert() {
        let alert = UIAlertController(title: "Error", message: "There was an error in saving your changes.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func uploadProfileImage(_ image:UIImage, completion: @escaping ((_ url: URL?) -> ())) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let ref = Storage.storage().reference().child("user/\(uid)")
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {return}
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        ref.putData(imageData, metadata: metaData) { (metaData, error) in
            if metaData != nil, error == nil {
                ref.downloadURL { (url, error) in
                    completion(url)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    func saveProfile(username: String, profileImageURL: URL, completion: @escaping ((_ success: Bool) -> ())) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let databaseRef = Database.database().reference().child("users/\(uid)")
        let userObject = [
            "username": username,
            "photoURL": profileImageURL.absoluteString
        ] as [String: Any]
        databaseRef.setValue(userObject) { (error, ref) in
            completion(error == nil)
        }
    }
    

}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            profileImage.image = pickedImage
        }
    }
}
