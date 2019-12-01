//
//  JoinRoomViewController.swift
//  EGN3641C
//
//  Created by Brandon Baker on 10/4/19.
//  Copyright © 2019 Brandon Baker. All rights reserved.
//

import UIKit
import Material
import SnapKit
import TwilioVideo
import FirebaseFirestore
import Alamofire


class JoinRoomViewController: UIViewController {
    
    enum SelectedAction {
        case join
        case create
    }
    
    let nameTextField = TextField()
    let roomTextField = TextField()
    let label = UILabel()
    let button = FlatButton()
    var joinRoomAction : () -> Void = { }
    var selectedAction : SelectedAction = .create
    var disconnect : () -> Void = { }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews() {
        self.view.backgroundColor = .grayBG
        self.statusBarController?.statusBarStyle = .lightContent
        let titleLabel = UILabel()
        titleLabel.text = "Ambience"
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.font = .avinerMedium
        titleLabel.fontSize = 40
        self.view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(64)
            make.width.equalToSuperview()
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tap)
        
        let segmentController = UISegmentedControl(items: ["Create a Room", "Join a Room"])
        segmentController.selectedSegmentIndex = 0
        segmentController.addTarget(self, action: #selector(updateSelectedAction(sender:)), for: .valueChanged)
        segmentController.selectedSegmentTintColor = .greenAccent
        let blackText = [NSAttributedString.Key.foregroundColor: UIColor.black]
        let greenText = [NSAttributedString.Key.foregroundColor: UIColor.greenAccent]
        segmentController.setTitleTextAttributes(greenText, for: .normal)
        segmentController.setTitleTextAttributes(blackText, for: .selected)
        self.view.addSubview(segmentController)
        segmentController.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(300)
            make.height.equalTo(40)
            make.top.equalTo(titleLabel.snp.bottom).offset(64)
        }
        
        label.text = "Create a Room"
        label.textAlignment = .center
        label.textColor = .white
        label.font = .avinerMedium
        self.view.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(segmentController.snp.bottom).offset(24)
            make.width.equalToSuperview()
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
        }
        
        nameTextField.placeholder = "Nickname"
        nameTextField.tintColor = .greenAccent
        nameTextField.textColor = .white
        nameTextField.detailColor = .greenAccent
        nameTextField.placeholderActiveColor = .greenAccent
        nameTextField.dividerActiveColor = .greenAccent
        nameTextField.dividerNormalColor = .greenAccent
        nameTextField.placeholderNormalColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        self.view.addSubview(nameTextField)
        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-32)
            make.height.equalTo(40)
        }
        
        roomTextField.placeholder = "Room Name"
        roomTextField.tintColor = .greenAccent
        roomTextField.textColor = .white
        roomTextField.detailColor = .greenAccent
        roomTextField.placeholderActiveColor = .greenAccent
        roomTextField.dividerActiveColor = .greenAccent
        roomTextField.dividerNormalColor = .greenAccent
        roomTextField.placeholderNormalColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        self.view.addSubview(roomTextField)
        roomTextField.snp.makeConstraints { make in
            make.top.equalTo(nameTextField.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-32)
            make.height.equalTo(40)
        }
        
        button.titleColor = .greenAccent
        button.layer.cornerRadius = 4
        button.layer.borderColor = UIColor.greenAccent.cgColor
        button.layer.borderWidth = 1.5
        button.title = "Create a Room"
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        self.view.addSubview(button)
        button.snp.makeConstraints { make in
            make.top.equalTo(roomTextField.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-32)
            make.height.equalTo(50)
        }
        
        let divider = UIView()
        divider.backgroundColor = .greenAccent
        divider.layer.cornerRadius = 1
        self.view.addSubview(divider)
        divider.snp.makeConstraints { make in
            make.top.equalTo(button.snp.bottom).offset(24)
            make.height.equalTo(2)
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
        }
        
        let browseButton = FlatButton()
        browseButton.titleColor = .greenAccent
        browseButton.layer.cornerRadius = 4
        browseButton.layer.borderColor = UIColor.greenAccent.cgColor
        browseButton.layer.borderWidth = 1.5
        browseButton.title = "Browse Rooms"
        browseButton.addTarget(self, action: #selector(browseButtonPressed), for: .touchUpInside)
        self.view.addSubview(browseButton)
        browseButton.snp.makeConstraints { make in
            make.top.equalTo(divider.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-32)
            make.height.equalTo(50)
        }
        
    }
    
    @objc func hideKeyboard() {
        for field in self.view.subviews.filter({ $0 as? TextField != nil }) {
            if let field = field as? TextField {
                field.resignFirstResponder()
            }
        }
    }
    @objc func browseButtonPressed() {
        let browseVC = BrowseTableViewController()
        browseVC.joinRoomAction = { roomName in
            self.joinRoom(roomName: roomName)
        }
        self.present(browseVC, animated: true, completion: nil)
    }
    @objc func updateSelectedAction(sender: Any) {
        if let sender = sender as? UISegmentedControl {
            if  sender.selectedSegmentIndex == 0 {
                selectedAction = .create
                label.text = "Create a Room"
                button.title = "Create Room"
            } else {
                selectedAction = .join
                label.text = "Join a Room"
                button.title = "Join Room"
            }
        }
    }
    @objc func buttonPressed() {
        if selectedAction == .join {
            joinRoom()
        } else {
            createRoom()
        }
    }
    
    func joinRoom(roomName : String? = nil) {
        let name = roomName != nil ? roomName : roomTextField.text
        if let roomName = name, roomName != "" {
            DispatchQueue.main.async {
                let urlComponents = NSURLComponents(string: "http://206.189.205.9/room/join")!

                urlComponents.queryItems = [
                    (NSURLQueryItem(name: "name", value: roomName) as URLQueryItem)
                ]
                
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
                    if let responseJSON = responseJSON as? [String: Any] {
                        print(responseJSON)
                        if responseJSON["error"] == nil {
                            self.joinRoomAction()
                            DispatchQueue.main.async {
                                let audioRoom = AudioRoomViewController()
                                audioRoom.roomName = roomName
                                audioRoom.disconnect = { self.disconnect() }
                                audioRoom.modalPresentationStyle = . overFullScreen
                                self.present(audioRoom, animated: true, completion: nil)
                            }
                        } else {
                            // alert
                        }
                    }
                }

                task.resume()
                
            }
            
        } else {
            // alert
        }
    }
    
    func createRoom() {
        
        if let roomName = roomTextField.text, let creator = nameTextField.text {
            let json: [String: Any] = [
                "name" : roomName,
                "creator" : creator,
                "private" : false,
                "password": ""
            ]

            let jsonData = try? JSONSerialization.data(withJSONObject: json)

            let url = URL(string: "http://206.189.205.9/room/")!
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = jsonData

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    return
                }
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    print(responseJSON)
                    self.joinRoomAction()
                    DispatchQueue.main.async {
                        let audioRoom = AudioRoomViewController()
                        audioRoom.roomName = roomName
                        audioRoom.disconnect = { self.disconnect() }
                        audioRoom.modalPresentationStyle = . overFullScreen
                        self.present(audioRoom, animated: true, completion: nil)
                    }
                }
            }

            task.resume()
            
        }
    }
    
    
}
