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
import SCLAlertView


class JoinRoomViewController: UIViewController {
    
    enum SelectedAction {
        case join
        case create
    }

    let slideInView = UIView()
    let headerView = UIView()
    let nameTextField = TextField()
    let passwordTextField = TextField()
    let roomTextField = TextField()
    let createButton = FlatButton()
    let joinButton = FlatButton()
    let label = UILabel()
    let button = FlatButton()
    var selectedAction : SelectedAction = .create
    var disconnect : () -> Void = { }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeader()
        setupViews()
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
    
    
    func setupViews() {
        self.view.backgroundColor = .grayBG
        self.statusBarController?.statusBarStyle = .lightContent
        
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tap)
        
        nameTextField.placeholder = "Nickname"
        nameTextField.tintColor = .primary
        nameTextField.textColor = .darkPromptText
        nameTextField.detailColor = .primary
        nameTextField.placeholderActiveColor = .primary
        nameTextField.dividerActiveColor = .primary
        nameTextField.dividerNormalColor = .primary
        nameTextField.placeholderNormalColor = .darkPromptText
        self.view.addSubview(nameTextField)
        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(64)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-32)
            make.height.equalTo(40)
        }
        
        let halfWidth = (Screen.width / 2) - 64
        joinButton.titleColor = .grayBG
        joinButton.backgroundColor = .primary
        joinButton.layer.cornerRadius = 4
        joinButton.title = "Join a Room"
        joinButton.addTarget(self, action: #selector(joinButtonPressed), for: .touchUpInside)
        self.view.addSubview(joinButton)
        joinButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-128)
            make.left.equalTo(32)
            make.width.equalTo(halfWidth)
            make.height.equalTo(50)
        }
        
        createButton.titleColor = .grayBG
        createButton.backgroundColor = .primary
        createButton.layer.cornerRadius = 4
        createButton.title = "Create a Room"
        createButton.addTarget(self, action: #selector(createButtonPressed), for: .touchUpInside)
        self.view.addSubview(createButton)
        createButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-128)
            make.right.equalToSuperview().offset(-32)
            make.width.equalTo(halfWidth)
            make.height.equalTo(50)
        }
        
    }
    
    
    func setupSlideInView() {
        
        slideInView.removeFromSuperview()
        
        slideInView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        slideInView.layer.cornerRadius = 6
        slideInView.layer.masksToBounds = true
        
        
        label.text = self.selectedAction == .create ? "Create a Room" : "Join a Room"
        label.textAlignment = .center
        label.textColor = .darkText
        label.font = .avinerMedium
        slideInView.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(48)
            make.width.equalToSuperview()
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
        }
        
        roomTextField.placeholder = "Room Name"
        roomTextField.tintColor = .primary
        roomTextField.textColor = .darkPromptText
        roomTextField.detailColor = .primary
        roomTextField.placeholderActiveColor = .primary
        roomTextField.dividerActiveColor = .primary
        roomTextField.dividerNormalColor = .primary
        roomTextField.placeholderNormalColor = .darkPromptText
        slideInView.addSubview(roomTextField)
        roomTextField.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-32)
            make.height.equalTo(40)
        }
        
        passwordTextField.placeholder = "Room Password"
        passwordTextField.tintColor = .primary
        passwordTextField.textColor = .darkPromptText
        passwordTextField.detailColor = .primary
        passwordTextField.placeholderActiveColor = .primary
        passwordTextField.dividerActiveColor = .primary
        passwordTextField.dividerNormalColor = .primary
        passwordTextField.placeholderNormalColor = .darkPromptText
        slideInView.addSubview(passwordTextField)
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(roomTextField.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-32)
            make.height.equalTo(40)
        }
        
        button.titleColor = .grayBG
        button.backgroundColor = .primary
        button.layer.cornerRadius = 4
        button.title = self.selectedAction == .create ? "Create Room" : "Join Room"
        button.addTarget(self, action: #selector(continueButtonPressed), for: .touchUpInside)
        slideInView.addSubview(button)
        button.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(48)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-32)
            make.height.equalTo(50)
        }
        
        
        let closebutton = IconButton(image: Icon.cm.close, tintColor: Color.grey.darken1)
        closebutton.addTarget(self, action: #selector(pressedClose), for: .touchUpInside)
        slideInView.addSubview(closebutton)
        closebutton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.left.equalToSuperview().offset(16)
            make.size.equalTo(CGSize(width: 24, height: 24))
        }
        self.slideInView.alpha = 0
        self.view.addSubview(slideInView)
        slideInView.snp.makeConstraints { make in
            make.top.equalTo(joinButton.snp.bottom).offset(24)
            make.width.equalToSuperview().offset(-64)
            make.bottom.equalToSuperview().offset(-64)
            make.centerX.equalToSuperview()
        }
        
        
        UIView.animate(withDuration: 0.2, animations: {
            self.slideInView.alpha = 1.0
        })
    }
    
    func setDisconnect() {
        if let tabBarController = self.tabBarController as? TabBarController {
            tabBarController.disconnect = self.disconnect
            tabBarController.setDisconnect()
        }
    }
    
    @objc func pressedClose() {
        UIView.animate(withDuration: 0.2, animations: {
            self.slideInView.alpha = 0
        })
    }
    
    @objc func hideKeyboard() {
        for field in self.view.subviews.filter({ $0 as? TextField != nil }) {
            if let field = field as? TextField {
                field.resignFirstResponder()
            }
        }
        for field in self.slideInView.subviews.filter({ $0 as? TextField != nil }) {
            if let field = field as? TextField {
                field.resignFirstResponder()
            }
        }
    }
    
    @objc func joinButtonPressed() {
        selectedAction = .join
        setupSlideInView()
    }
    @objc func createButtonPressed() {
        selectedAction = .create
        setupSlideInView()
    }
    @objc func continueButtonPressed() {
        if selectedAction == .join {
            joinRoom()
        } else {
            createRoom()
        }
    }
    
    func joinRoom(roomName : String? = nil) {
        if nameTextField.text == "" {
            SCLAlertView().showInfo("No nickname", subTitle: "Please enter a nickname to continue.", colorStyle: primaryHex)
            return
        }
        
        let name = roomName != nil ? roomName : roomTextField.text
        if let roomName = name, roomName != "" {
            let urlComponents = NSURLComponents(string: "http://206.189.205.9/room/join")!
            
            if passwordTextField.text == "" {
                urlComponents.queryItems = [
                    (NSURLQueryItem(name: "name", value: roomName) as URLQueryItem)
                ]
            } else {
                urlComponents.queryItems = [
                    (NSURLQueryItem(name: "name", value: roomName) as URLQueryItem),
                    (NSURLQueryItem(name: "password", value: passwordTextField.text) as URLQueryItem)
                ]
            }
            
            guard let url = urlComponents.url else { return }
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
                        joinRoomAction(nil)
                        DispatchQueue.main.async {
                            let audioRoom = AudioRoomViewController()
                            audioRoom.roomName = roomName
                            audioRoom.disconnect = self.disconnect
                            audioRoom.modalPresentationStyle = . overFullScreen
                            self.present(audioRoom, animated: true, completion: nil)
                        }
                    } else {
                        DispatchQueue.main.async {
                            SCLAlertView().showInfo("No room found", subTitle: "Please check the name of the room you are joining.", colorStyle: primaryHex)
                        }
                    }
                }
            }
            
            task.resume()
            
        } else {
            DispatchQueue.main.async {
                SCLAlertView().showInfo("No room found", subTitle: "Please check the name of the room you are joining.", colorStyle: primaryHex)
            }
        }
    }
    
    func createRoom() {
        if roomTextField.text == "" || nameTextField.text == "" {
            SCLAlertView().showInfo("No room name", subTitle: "Please enter a room name to continue.", colorStyle: primaryHex)
            return
        }
        if let roomName = roomTextField.text, let creator = nameTextField.text {
            
            let json: [String: Any] = [
                "name" : roomName,
                "creator" : creator,
                "private" : false,
                "password": passwordTextField.text
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
                    joinRoomAction(nil)
                    DispatchQueue.main.async {
                        let audioRoom = AudioRoomViewController()
                        audioRoom.roomName = roomName
                        audioRoom.disconnect = self.disconnect
                        audioRoom.modalPresentationStyle = . overFullScreen
                        self.present(audioRoom, animated: true, completion: nil)
                    }
                }
            }
            
            task.resume()
            
        }
    }
    
    
}
