//
//  ThoughtsTableViewCell.swift
//  Thoughts
//
//  Created by Jeremy Jung on 1/7/20.
//  Copyright © 2020 Jeremy Jung. All rights reserved.
//

import UIKit
import Firebase

class ThoughtsTableViewCell: UITableViewCell {
    
    var contentText: UITextView!
    var likeButton: UIButton!
    var dislikeButton: UIButton!
    var usernameField: UITextView!
    var profileImageView: UIImageView!
    var thought: Thoughts!
    
    let padding: CGFloat = 15

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentText = UITextView()
        contentText.isEditable = false
        contentText.font = UIFont.systemFont(ofSize: 15)
        contentText.textColor = .black
        contentView.addSubview(contentText)
        
        likeButton = UIButton()
        likeButton.setTitleColor(.black, for: .normal)
        likeButton.addTarget(self, action: #selector(likeButtonPressed), for: .touchUpInside)
        contentView.addSubview(likeButton)
        
        dislikeButton = UIButton()
        dislikeButton.setTitleColor(.black, for: .normal)
        dislikeButton.addTarget(self, action: #selector(dislikeButtonPressed), for: .touchUpInside)
        contentView.addSubview(dislikeButton)
        
        usernameField = UITextView()
        usernameField.textAlignment = .right
        usernameField.isEditable = false
        usernameField.font = UIFont.boldSystemFont(ofSize: 15)
        usernameField.textColor = .black
        contentView.addSubview(usernameField)
        
        profileImageView = UIImageView()
        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
        profileImageView.clipsToBounds = true
        contentView.addSubview(profileImageView)
        
        setupConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints() {
        contentText.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(padding)
            make.leading.equalTo(profileImageView.snp.trailing)
            make.width.equalTo(contentView.snp.width).offset(-55)
            make.height.equalTo(70)
        }
        
        likeButton.snp.makeConstraints { make in
            make.top.equalTo(contentText.snp.bottom).offset(padding)
            make.leading.equalTo(contentView).offset(padding)
        }
        
        dislikeButton.snp.makeConstraints { make in
            make.top.equalTo(contentText.snp.bottom).offset(padding)
            make.leading.equalTo(likeButton).offset(70)
        }
        
        usernameField.snp.makeConstraints { make in
            make.top.equalTo(contentText.snp.bottom).offset(padding)
            make.trailing.equalTo(contentView.snp.trailing)
            make.height.equalTo(50)
            make.width.equalTo(200)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.leading.top.equalTo(contentView).offset(padding)
            make.height.width.equalTo(40)
        }
    }
    
    
    func configure(thought: Thoughts) {
        contentText.text = "\(thought.content)"
        likeButton.setTitle("❤️ \(thought.numLikes)", for: .normal)
        dislikeButton.setTitle("🤔 \(thought.numDislikes)", for: .normal)
        let ref = Database.database().reference().child("users/\(thought.userID)/photoURL")
        ref.observeSingleEvent(of: .value) { snapshot in
                 thought.imageURL = snapshot.value as! String
             }
        let nameReference = Database.database().reference().child("users/\(thought.userID)/username")
        nameReference.observeSingleEvent(of: .value) { snapshot in
            thought.username = snapshot.value as! String
        }
        usernameField.text = "@\(thought.username)"
        if let url = NSURL(string: thought.imageURL) {
            URLSession.shared.dataTask(with: url as URL) { (data, response, error) in
                if error == nil && data != nil {
                    DispatchQueue.main.async {
                        self.profileImageView?.image = UIImage(data: data!)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.profileImageView?.image = UIImage(named: "profile")
                    }
                }
            }.resume()
        } else {
            profileImageView?.image = UIImage(named: "profile")
        }
    }
    
    @objc func likeButtonPressed() {
        if likeButton.currentTitleColor != .blue {
            thought.like()
            likeButton.setTitle("❤️ \(thought.numLikes)", for: .normal)
            likeButton.setTitleColor(.blue, for: .normal)
        } else {
            thought.undoLike()
            likeButton.setTitle("❤️ \(thought.numLikes)", for: .normal)
            likeButton.setTitleColor(.black, for: .normal)
        } }
    
    @objc func dislikeButtonPressed() {
        if dislikeButton.currentTitleColor != .red {
            thought.dislike()
            dislikeButton.setTitle("🤔 \(thought.numDislikes)", for: .normal)
            dislikeButton.setTitleColor(.red, for: .normal)
        } else {
            thought.undoDislike()
            dislikeButton.setTitle("🤔 \(thought.numDislikes)", for: .normal)
            dislikeButton.setTitleColor(.black, for: .normal)
        } }
    
}
