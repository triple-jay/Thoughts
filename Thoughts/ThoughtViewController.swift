
//
//  ThoughtViewController.swift
//  Thoughts
//
//  Created by Jeremy Jung on 1/7/20.
//  Copyright © 2020 Jeremy Jung. All rights reserved.
//

import UIKit
import Firebase

class ThoughtViewController: UIViewController {
    
    var tableView: UITableView!
    var thoughts = [Thoughts]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    var savedThoughts = [Thoughts]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    var writeButton: UIBarButtonItem!
    var reloadButton: UIBarButtonItem!
    var profileButton: UIBarButtonItem!
    var searchController: UISearchController!
    
    let reuseIdentifier = "reuseIdentifier"
    let cellHeight: CGFloat = 200
    let ref = Database.database().reference().child("thoughts")
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

        ref.observe(.value) { snapshot in
            self.savedThoughts.removeAll()
            self.thoughts.removeAll()
            for child in snapshot.children {
                let childSnapshot = child as! DataSnapshot
                let thought = Thoughts(snapshot: childSnapshot)
                self.thoughts.insert(thought, at: 0)
                self.savedThoughts.insert(thought, at: 0)
            }
        }
        self.tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Thoughts"
        view.backgroundColor = .white
        
        writeButton = UIBarButtonItem(title: "Compose", style: .plain, target: self, action: #selector(newThought))
        writeButton.image = UIImage(named: "write")
        
        reloadButton = UIBarButtonItem(title: "Reload", style: .plain, target: self, action: #selector(reload))
        navigationItem.leftBarButtonItem = reloadButton
                
        profileButton = UIBarButtonItem(title: "Profile", style: .plain, target: self, action: #selector(profile))
        navigationItem.rightBarButtonItems = [profileButton, writeButton]

        tableView = UITableView()
        tableView.register(ThoughtsTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search thoughts (case-sensitive)"
        searchController.searchBar.sizeToFit()

        setupConstraints()

    }
    
    func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalTo(view)
        }
    }
    
    @objc func newThought() {
        let viewController = NewThoughtViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func reload() {
        tableView.reloadData()
    }
    
    @objc func profile() {
        let viewController = ProfileViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }

}

extension ThoughtViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return thoughts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ThoughtsTableViewCell
        let thought = thoughts[indexPath.row]
        cell.thought = thought
        cell.selectionStyle = .none
        cell.configure(thought: thought)
        return cell
    }
    
    
}

extension ThoughtViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
}

extension ThoughtViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            if !searchText.isEmpty {
                thoughts.removeAll()
                for thought in savedThoughts {
                    if thought.content.contains(searchText) {
                        thoughts.insert(thought, at: 0)
                    }
                }
                tableView.reloadData()
            } else {
                thoughts = savedThoughts
                tableView.reloadData()
            }
        }
    }
}
