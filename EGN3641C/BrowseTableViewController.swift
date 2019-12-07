//
//  BrowseTableViewController.swift
//  EGN3641C
//
//  Created by Brandon Baker on 11/30/19.
//  Copyright © 2019 Brandon Baker. All rights reserved.
//

import UIKit
import Material

class BrowseTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var rooms : [RoomData] = []
    var tableView = UITableView()
    let headerView = UIView()
    var currentTabBarController: TabBarController?
    var disconnect : () -> Void = { }
    let noRoomView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeader()
        self.view.backgroundColor = .white
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        loadRooms()
        
    }
    
    func setupHeader() {
        
        headerView.backgroundColor = .primary
        self.view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(90)
        }
        
        
        let titleLabel = UILabel()
        titleLabel.text = "Ambience"
        titleLabel.textAlignment = .left
        titleLabel.textColor = .white
        titleLabel.font = .avinerMedium
        titleLabel.fontSize = 27
        headerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.bottom.equalToSuperview()
            make.right.equalToSuperview()
        }
    }
    
    func createNoRoomView() {
        
        let label = UILabel()
        label.text = "No rooms available!\n Maybe try creating one?"
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = .darkText
        label.font = .avinerMedium
        self.noRoomView.addSubview(label)
        label.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(70)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-64)
        }
        
        let createButton = FlatButton()
        createButton.titleColor = .grayBG
        createButton.backgroundColor = .primary
        createButton.layer.cornerRadius = 4
        createButton.title = "NEW ROOM"
        createButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        self.noRoomView.addSubview(createButton)
        createButton.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(50)
        }
        
        self.view.addSubview(noRoomView)
        noRoomView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
    }
    
    @objc func buttonPressed() {
        tabBarController?.selectedIndex = 0
    }
    func loadRooms() {
        let urlComponents = NSURLComponents(string: "http://206.189.205.9/room/")!
        
        guard let url = urlComponents.url else { return }
        print(url)
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [[String : Any]] {
                DispatchQueue.main.async {
                    print(responseJSON)
                    self.rooms = []
                    for room in responseJSON {
                        if room["error"] == nil {
                            self.rooms.append(RoomData(dictionary: room))
                        }
                    }
                    self.tableView.reloadData()
                    if self.rooms.count == 0 {
                        self.tableView.isHidden = true
                        self.createNoRoomView()
                    } else {
                        self.noRoomView.removeFromSuperview()
                        self.tableView.isHidden = false
                    }
                }
            } else {
                // alert
            }
        }
        
        task.resume()
        
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let roomName = rooms[indexPath.row].uniqueName {
            joinRoomAction(roomName)
            DispatchQueue.main.async {
                let audioRoom = AudioRoomViewController()
                audioRoom.roomName = roomName
                audioRoom.disconnect = self.disconnect
                audioRoom.modalPresentationStyle = . overFullScreen
                self.present(audioRoom, animated: true, completion: nil)
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let formattedString = NSMutableAttributedString()
        formattedString
            .normal(rooms[indexPath.row].uniqueName)
            .gray(" - Created By " + rooms[indexPath.row].creator)
        cell.textLabel?.attributedText = formattedString
        cell.backgroundColor = .white
        cell.selectionStyle = .none
        return cell
    }
    
    @objc func backButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
