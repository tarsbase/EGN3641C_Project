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
        
        let titleLabel = UILabel()
        titleLabel.text = roomName == nil ? "Welcome" : "You are now talking in: " + roomName!
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.font = .avinerMedium
        titleLabel.fontSize = 20
        self.view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(64)
            make.width.equalToSuperview()
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
        }
        
        
        let backButton = FlatButton()
        backButton.title = "Back"
        backButton.backgroundColor = .greenAccent
        backButton.titleColor = .white
        backButton.addTarget(self, action: #selector(backPressed), for: .touchUpInside)
        self.view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(16)
            make.width.equalTo(80)
            make.height.equalTo(40)
        }
        
    }

    @objc func backPressed() {
        disconnect()
        self.dismiss(animated: true, completion: nil)
    }

}
