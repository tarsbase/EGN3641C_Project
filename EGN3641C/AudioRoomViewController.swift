//
//  AudioRoomViewController.swift
//  EGN3641C
//
//  Created by Brandon Baker on 11/18/19.
//  Copyright © 2019 Brandon Baker. All rights reserved.
//

import UIKit
import Material

class AudioRoomViewController: UIViewController {
    
    let messages : [String] = []
    var roomName : String? = nil
    var disconnect : () -> Void = { }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .grayBG
        self.statusBarController?.statusBarStyle = .lightContent
        
        
        
        let statusLabel = UILabel()
        statusLabel.text = "Connected"
        statusLabel.textAlignment = .center
        statusLabel.textColor = .darkText
        statusLabel.font = .avinerMedium
        statusLabel.fontSize = 24
        self.view.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(64)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        let titleLabel = UILabel()
        titleLabel.text = roomName == nil ? "Welcome" : roomName!
        titleLabel.textAlignment = .center
        titleLabel.textColor = .darkGray
        titleLabel.font = .avinerMedium
        titleLabel.fontSize = 20
        self.view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(statusLabel.snp.bottom)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
//
//        let participantsView = UIView()
//        participantsView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
//        participantsView.layer.cornerRadius = 6
//        participantsView.layer.masksToBounds = true
//        let participantsLabel = UILabel()
//        participantsLabel.text = "Participants: "
//        participantsLabel.textAlignment = .left
//        participantsLabel.textColor = .darkText
//        participantsLabel.font = .avinerMedium
//        participantsLabel.fontSize = 22
//        participantsView.addSubview(participantsLabel)
//
//
//        participantsLabel.snp.makeConstraints { make in
//            make.right.equalToSuperview()
//            make.top.equalToSuperview().offset(16)
//            make.left.equalToSuperview().offset(8)
//        }
//
//        self.view.addSubview(participantsView)
//        participantsView.snp.makeConstraints { make in
//            make.top.equalTo(titleLabel.snp.bottom).offset(16)
//            make.width.equalToSuperview().offset(-64)
//            make.height.equalTo(180)
//            make.centerX.equalToSuperview()
//        }
        
        let halfWidth = (Screen.width / 2) - 64
        let backButton = FlatButton()
        backButton.title = "END CALL"
        backButton.backgroundColor = .primary
        backButton.titleColor = .white
        backButton.addTarget(self, action: #selector(backPressed), for: .touchUpInside)
        self.view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
//            make.top.equalTo(participantsView.snp.bottom).offset(16)
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(halfWidth)
            make.height.equalTo(50)
        }
        
        let imageView = UIImageView(image: UIImage(named: "microphone"))
        imageView.contentMode = .scaleAspectFill
        self.view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.bottom.equalTo(titleLabel.snp.bottom).offset(-16)
            make.right.equalToSuperview().offset(-32)
            make.width.height.equalTo(45)
        }
    }

    @objc func backPressed() {
        disconnect()
        self.dismiss(animated: true, completion: nil)
    }

}
