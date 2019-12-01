//
//  BrowseTableViewController.swift
//  EGN3641C
//
//  Created by Brandon Baker on 11/30/19.
//  Copyright © 2019 Brandon Baker. All rights reserved.
//

import UIKit

class BrowseTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var rooms : [RoomData] = []
    var tableView = UITableView()
    var joinRoomAction : (String) -> Void = { _ in }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }

        let backBarItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(backButtonPressed))
        self.navigationItem.leftBarButtonItem = backBarItem
        loadRooms()

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
                        for room in responseJSON {
                            if room["error"] == nil {
                                self.rooms.append(RoomData(dictionary: room))
                            }
                        }
                        self.tableView.reloadData()
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
            self.dismiss(animated: true, completion: nil)
            joinRoomAction(roomName)
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
        print(rooms[indexPath.row])
        cell.textLabel?.text = rooms[indexPath.row].uniqueName
        return cell
    }
    
    @objc func backButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }


}
