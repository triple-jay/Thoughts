//
//  ViewController.swift
//  Thoughts
//
//  Created by Jeremy Jung on 1/7/20.
//  Copyright © 2020 Jeremy Jung. All rights reserved.
//

import UIKit
import SnapKit
import Firebase
import FirebaseStorage

class ViewController: UIViewController {
    
    var titleText: UILabel!
    var creationText: UILabel!
    var usernameField: UITextField!
    var emailField: UITextField!
    var passwordField: UITextField!
    var signUpButton: UIButton!
    var loginButton: UIButton!
    
    var alert: UIAlertController!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        titleText = UILabel()
        titleText.text = "Thoughts ☁️"
        titleText.font = UIFont.boldSystemFont(ofSize: 40)
        view.addSubview(titleText)
        
        creationText = UILabel()
        creationText.text = "Created by Jeremy Jung"
        creationText.font = UIFont.systemFont(ofSize: 15)
        view.addSubview(creationText)
        
        signUpButton = UIButton()
        signUpButton.setTitle("Sign Up", for: .normal)
        signUpButton.setTitleColor(.blue, for: .normal)
        signUpButton.addTarget(self, action: #selector(signUp), for: .touchUpInside)
        view.addSubview(signUpButton)
        
        loginButton = UIButton()
        loginButton.setTitle("Login", for: .normal)
        loginButton.setTitleColor(.blue, for: .normal)
        loginButton.addTarget(self, action: #selector(loginWithCredentials), for: .touchUpInside)
        view.addSubview(loginButton)
        
        usernameField = UITextField()
        usernameField.layer.borderWidth = 1
        usernameField.layer.borderColor = UIColor.systemBlue.cgColor
        usernameField.layer.cornerRadius = 5
        usernameField.font = UIFont.systemFont(ofSize: 15)
        usernameField.textColor = .black
        usernameField.placeholder = "Username"
        usernameField.textAlignment = .center
        view.addSubview(usernameField)
        
        emailField = UITextField()
        emailField.font = UIFont.systemFont(ofSize: 15)
        emailField.layer.borderWidth = 1
        emailField.layer.borderColor = UIColor.systemBlue.cgColor
        emailField.layer.cornerRadius = 5
        emailField.textColor = .black
        emailField.placeholder = "📧 Email"
        emailField.textAlignment = .center
        view.addSubview(emailField)
        
        passwordField = UITextField()
        passwordField.isSecureTextEntry = true
        passwordField.layer.borderWidth = 1
        passwordField.layer.borderColor = UIColor.systemBlue.cgColor
        passwordField.layer.cornerRadius = 5
        passwordField.font = UIFont.systemFont(ofSize: 15)
        passwordField.textColor = .black
        passwordField.placeholder = "🔑 Password"
        passwordField.textAlignment = .center
        view.addSubview(passwordField)

        // Do any additional setup after loading the view.
        setupConstraints()
    }
    
    func setupConstraints() {
        
        usernameField.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.width.equalTo(view).offset(-80)
            make.height.equalTo(30)
            make.bottom.equalTo(emailField.snp.top).offset(-10)
        }
        
        emailField.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.width.equalTo(view).offset(-80)
            make.height.equalTo(30)
            make.bottom.equalTo(passwordField.snp.top).offset(-10)
        }
        
        passwordField.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.width.equalTo(view).offset(-80)
            make.height.equalTo(30)
            make.bottom.equalTo(loginButton.snp.top).offset(-10)
        }
        
        loginButton.snp.makeConstraints { make in
            make.centerY.equalTo(view).offset(50)
            make.centerX.equalTo(view)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(loginButton.snp.bottom)
        }
        
        titleText.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.bottom.equalTo(loginButton.snp.top).offset(-150)
        }
        
        creationText.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.bottom.equalTo(view.snp.bottom).offset(-30)
        }
    }
    
    @objc func loginWithCredentials() {
        login {
            let viewController = ThoughtViewController()
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func login(_ didSignIn: @escaping (() -> Void)) {
        if (emailField.text?.isEmpty)! || (passwordField.text?.isEmpty)! {
            createAlert(message: "One or more fields are empty.")
        } else {
            Auth.auth().signIn(withEmail: emailField.text!, password: passwordField.text!) { (result, error) in
                if error == nil {
                    didSignIn()
                } else {
                    self.createAlert(message: "Error: \((error?.localizedDescription)!)")
                            }
                            }
                        }
                    }
    // Handles sign up
    @objc func signUp() {
        if (emailField.text?.isEmpty)! || (passwordField.text?.isEmpty)! || (usernameField.text?.isEmpty)! {
            createAlert(message: "One or more fields are empty.")
        } else {
            Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!) { (result, error) in
                if error == nil {
                    guard let username = self.usernameField.text else {return}
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.displayName = username
                    changeRequest?.commitChanges(completion: { (error) in
                        if error == nil {
                            print("Username created!")
                        } else {
                            print("Error: \((error?.localizedDescription)!)")
                        }
                    })
                    if let image = UIImage(named: "profile") {
                        self.setDefaultImage(image) { (url) in
                            if url != nil {
                                let change = Auth.auth().currentUser?.createProfileChangeRequest()
                                change?.photoURL = url
                                change?.commitChanges(completion: { (error) in
                                    if error == nil {
                                        guard let username = Auth.auth().currentUser?.displayName else {return}
                                        self.saveProfile(username: username, profileImageURL: url!) { (success) in
                                            if success {
                                                self.successSignIn(message: "Sign up successful!")
                                            } else {
                                                self.createAlert(message: "Error: \((error?.localizedDescription)!)")
                                            }
                                        }
                                    }
                                })
                            }
                        }
                    }
                } else {
                    self.createAlert(message: "Error: \((error?.localizedDescription)!)")
                }
            }
        }
    }
    
    
    func createAlert(message: String) {
        alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    func successSignIn(message: String) {
        alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    func setDefaultImage(_ image:UIImage, completion: @escaping((_ url: URL?) -> ())) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let ref = Storage.storage().reference().child("user/\(uid)")
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {return}
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        ref.putData(imageData, metadata: metaData) { (metaData, error) in
            if metaData != nil, error == nil {
                ref.downloadURL { (url, error) in
                    completion(url)
                } } else {
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



