//
//  NewThoughtViewController.swift
//  Thoughts
//
//  Created by Jeremy Jung on 1/8/20.
//  Copyright © 2020 Jeremy Jung. All rights reserved.
//

import UIKit
import SnapKit
import Firebase

class NewThoughtViewController: UIViewController {
    
    var postButton: UIBarButtonItem!
    var textBox: UITextField!
    var alert: UIAlertController!
    var uid: String!
    var username: String!
    var uploadImage: UIButton!
    var selectedImage: UIImageView!
    var pickImage: UIImagePickerController!
    
    let padding: CGFloat = 5

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "New Thought"
        view.backgroundColor = .white
        
        let imgTap = UIGestureRecognizer(target: self, action: #selector(openPickImage))
        selectedImage = UIImageView()
        selectedImage.addGestureRecognizer(imgTap)
        selectedImage.isUserInteractionEnabled = true
        selectedImage.clipsToBounds = true
        view.addSubview(selectedImage)
        
        postButton = UIBarButtonItem(title: "Post", style: .plain, target: self, action: #selector(post))
        postButton.image = UIImage(named: "plus")
        navigationItem.rightBarButtonItem = postButton
        
        textBox = UITextField()
        textBox.contentVerticalAlignment = .top
        textBox.textAlignment = .left
        textBox.placeholder = "New Thought (maximum 150 characters)"
        textBox.font = UIFont.systemFont(ofSize: 15)
        textBox.textColor = .black
        view.addSubview(textBox)
        
        uploadImage = UIButton()
        uploadImage.setTitle("Upload Image", for: .normal)
        uploadImage.setTitleColor(.blue, for: .normal)
        uploadImage.addTarget(self, action: #selector(openPickImage), for: .touchUpInside)
        view.addSubview(uploadImage)
        
        pickImage = UIImagePickerController()
        pickImage.allowsEditing = true
        pickImage.sourceType = .photoLibrary
        pickImage.delegate = self

        setupConstraints()
    }
    
    @objc func openPickImage() {
        present(pickImage, animated: true, completion: nil)
    }
    
    @objc func post() {
        if let thought = textBox.text {
            if thought != "" && thought.count <= 150 {
                if let userid = Auth.auth().currentUser?.uid {
                    uid = userid
                } else {
                    uid = ""
                }
                if let user = Auth.auth().currentUser?.displayName {
                    username = user
                }
                let newThought = Thoughts(content: thought, userID: uid, username: username)
                newThought.save()
                navigationController?.popViewController(animated: true)
            } else {
                if thought == "" {
                    alert = UIAlertController(title: "Invalid thought", message: "Message is empty.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    present(alert, animated: true)
                } else {
                    alert = UIAlertController(title: "Invalid thought", message: "Message is too long.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    present(alert, animated: true)
                }
                
            }
        }
    }
    
    func setupConstraints() {
        textBox.snp.makeConstraints { make in
            make.leading.equalTo(view).offset(padding)
            make.top.equalTo(view).offset(100)
            make.width.equalTo(view.snp.width)
            make.height.equalTo(view.snp.height).offset(-100)
        }
        
        selectedImage.snp.makeConstraints { make in
            make.top.equalTo(textBox.snp.bottom).offset(10)
            make.centerX.equalTo(view)
            make.width.height.equalTo(40)
        }
        
        uploadImage.snp.makeConstraints { make in
            make.top.equalTo(selectedImage.snp.bottom).offset(10)
            make.centerX.equalTo(view)
        }
    }


}

extension NewThoughtViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        pickImage.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImage.image = img
        }
    }
}
