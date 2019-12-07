//
//  CallManager.swift
//  EGN3641C
//
//  Created by Brandon Baker on 11/18/19.
//  Copyright © 2019 Brandon Baker. All rights reserved.
//

import UIKit
import AVFoundation
import PushKit
import CallKit
import TwilioVoice
import TwilioVideo

let baseURLString = "http://206.189.205.9"
let accessTokenEndpoint = "/accessToken"
let identity = "brandon"

var joinRoomAction : (String?) -> Void = {_ in}

class CallManager : JoinRoomViewController, UITextFieldDelegate {
    
    var room: Room?
    var audioDevice: DefaultAudioDevice = DefaultAudioDevice()
    var localAudioTrack: LocalAudioTrack?
    var remoteParticipant: RemoteParticipant?
    
    // CallKit components
    let callKitProvider: CXProvider
    let callKitCallController: CXCallController
    var callKitCompletionHandler: ((Bool)->Swift.Void?)? = nil
    var userInitiatedDisconnect: Bool = false
    
    var deviceTokenString: String?
    
    var voipRegistry: PKPushRegistry
    var incomingPushCompletionCallback: (()->Swift.Void?)? = nil
    
    var isSpinning: Bool
    var incomingAlertController: UIAlertController?
    
    var callInvite: TVOCallInvite?
    var call: TVOCall?
    var callKitCompletionCallback: ((Bool)->Swift.Void?)? = nil
    
    
    init() {
        
        isSpinning = false
        voipRegistry = PKPushRegistry.init(queue: DispatchQueue.main)
        
        let configuration = CXProviderConfiguration(localizedName: "Quickstart")
        configuration.maximumCallGroups = 5
        configuration.maximumCallsPerCallGroup = 1
        if let callKitIcon = UIImage(named: "iconMask80") {
            configuration.iconTemplateImageData = callKitIcon.pngData()
        }
        
        callKitProvider = CXProvider(configuration: configuration)
        callKitCallController = CXCallController()
        
        super.init(nibName: nil, bundle: nil)
//        super.init(coder: aDecoder)
        
        callKitProvider.setDelegate(self, queue: nil)
        
        super.disconnect = {
            print(self.room)
            self.room?.disconnect()
            self.call?.disconnect()
            super.setDisconnect()
        }
        joinRoomAction = { roomName in
            DispatchQueue.main.async {
                if let roomName = super.roomTextField.text {
                    self.performStartCallAction(uuid: UUID(), roomName: roomName)
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        // CallKit has an odd API contract where the developer must call invalidate or the CXProvider is leaked.
        callKitProvider.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TwilioVideoSDK.audioDevice = self.audioDevice;
        
        joinRoomAction = { roomName in
            DispatchQueue.main.async {
                if roomName != nil {
                    self.performStartCallAction(uuid: UUID(), roomName: roomName)
                } else {
                    if let roomName = super.roomTextField.text {
                        self.performStartCallAction(uuid: UUID(), roomName: roomName)
                    }
                }
            }
        }
        
        super.disconnect = {
            print(self.room)
            self.room?.disconnect()
            self.call?.disconnect()
            super.setDisconnect()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func fetchAccessToken() -> String? {
        let endpointWithIdentity = String(format: "%@?identity=%@", accessTokenEndpoint, identity)
        guard let accessTokenURL = URL(string: baseURLString + endpointWithIdentity) else {
            return nil
        }
        print(baseURLString + endpointWithIdentity)
        return try? String.init(contentsOf: accessTokenURL, encoding: .utf8)
    }
    
    
    func disconnect() {
        if let room = room, let uuid = room.uuid {
            logMessage(messageText: "Attempting to disconnect from room \(room.name)")
            userInitiatedDisconnect = true
            performEndCallAction(uuid: uuid)
        }
    }
    
    func logMessage(messageText: String) {
        NSLog(messageText)
        //        messageLabel.text = messageText
    }
    
    func holdCall(onHold: Bool) {
        localAudioTrack?.isEnabled = !onHold
        //        localVideoTrack?.isEnabled = !onHold
    }
    
    
    func joinRoom(uuid: UUID, client: String?, completionHandler: @escaping (Bool) -> Swift.Void) {
        guard let accessToken = fetchAccessToken() else {
            completionHandler(false)
            return
        }
        let options : ConnectOptions = ConnectOptions(token: accessToken) { builder in
            builder.audioTracks = [LocalAudioTrack(options: AudioOptions(), enabled: true, name: super.roomTextField.text)!]
            builder.uuid = uuid
            builder.roomName = super.roomTextField.text
        }
        
        self.room = TwilioVideoSDK.connect(options: options, delegate: self)
        self.callKitCompletionCallback = completionHandler
    }
    
}
extension CallManager : RoomDelegate {
    func roomDidConnect(room: Room) {
        // At the moment, this example only supports rendering one Participant at a time.
        
        logMessage(messageText: "Connected to room \(room.name) as \(room.localParticipant?.identity ?? "")")
        
        if (room.remoteParticipants.count > 0) {
            self.remoteParticipant = room.remoteParticipants[0]
            self.remoteParticipant?.delegate = self
        }
        
        let cxObserver = callKitCallController.callObserver
        let calls = cxObserver.calls
        
        // Let the call provider know that the outgoing call has connected
        if let uuid = room.uuid, let call = calls.first(where:{$0.uuid == uuid}) {
            if call.isOutgoing {
                callKitProvider.reportOutgoingCall(with: uuid, connectedAt: nil)
            }
        }
        
        self.callKitCompletionHandler!(true)
    }
    
    func roomDidDisconnect(room: Room, error: Error?) {
        logMessage(messageText: "Disconnected from room \(room.name), error = \(String(describing: error))")
        
        if !self.userInitiatedDisconnect, let uuid = room.uuid, let error = error {
            var reason = CXCallEndedReason.remoteEnded
            
            if (error as NSError).code != TwilioVideoSDK.Error.roomRoomCompletedError.rawValue {
                reason = .failed
            }
            
            self.callKitProvider.reportCall(with: uuid, endedAt: nil, reason: reason)
        }
        
        //        self.cleanupRemoteParticipant()
        self.room = nil
        //        self.showRoomUI(inRoom: false)
        self.callKitCompletionHandler = nil
        self.userInitiatedDisconnect = false
    }
    
    func roomDidFailToConnect(room: Room, error: Error) {
        logMessage(messageText: "Failed to connect to room with error: \(error.localizedDescription)")
        
        self.callKitCompletionHandler!(false)
        self.room = nil
        //        self.showRoomUI(inRoom: false)
    }
    
    func roomIsReconnecting(room: Room, error: Error) {
        logMessage(messageText: "Reconnecting to room \(room.name), error = \(String(describing: error))")
    }
    
    func roomDidReconnect(room: Room) {
        logMessage(messageText: "Reconnected to room \(room.name)")
    }
    
    func participantDidConnect(room: Room, participant: RemoteParticipant) {
        if (self.remoteParticipant == nil) {
            self.remoteParticipant = participant
            self.remoteParticipant?.delegate = self
        }
        logMessage(messageText: "Participant \(participant.identity) connected with \(participant.remoteAudioTracks.count) audio and \(participant.remoteVideoTracks.count) video tracks")
    }
    
    func participantDidDisconnect(room: Room, participant: RemoteParticipant) {
        if (self.remoteParticipant == participant) {
            //            cleanupRemoteParticipant()
        }
        logMessage(messageText: "Room \(room.name), Participant \(participant.identity) disconnected")
    }
    
}

// MARK:- RemoteParticipantDelegate
extension CallManager : RemoteParticipantDelegate {
    
    func remoteParticipantDidPublishVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
        // Remote Participant has offered to share the video Track.
        
        logMessage(messageText: "Participant \(participant.identity) published video track")
    }
    
    func remoteParticipantDidUnpublishVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
        // Remote Participant has stopped sharing the video Track.
        
        logMessage(messageText: "Participant \(participant.identity) unpublished video track")
    }
    
    func remoteParticipantDidPublishAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
        // Remote Participant has offered to share the audio Track.
        
        logMessage(messageText: "Participant \(participant.identity) published audio track")
    }
    
    func remoteParticipantDidUnpublishAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
        logMessage(messageText: "Participant \(participant.identity) unpublished audio track")
    }
    
    func didSubscribeToVideoTrack(videoTrack: RemoteVideoTrack, publication: RemoteVideoTrackPublication, participant: RemoteParticipant) {
        // We are subscribed to the remote Participant's video Track. We will start receiving the
        // remote Participant's video frames now.
        
        logMessage(messageText: "Subscribed to video track for Participant \(participant.identity)")
        //
        //        if (self.remoteParticipant == participant) {
        //            setupRemoteVideoView()
        //            videoTrack.addRenderer(self.remoteView!)
        //        }
    }
    
    func didUnsubscribeFromVideoTrack(videoTrack: RemoteVideoTrack, publication: RemoteVideoTrackPublication, participant: RemoteParticipant) {
        // We are unsubscribed from the remote Participant's video Track. We will no longer receive the
        // remote Participant's video.
        
        logMessage(messageText: "Unsubscribed from video track for Participant \(participant.identity)")
        //
        //        if (self.remoteParticipant == participant) {
        //            videoTrack.removeRenderer(self.remoteView!)
        //            self.remoteView?.removeFromSuperview()
        //            self.remoteView = nil
        //        }
    }
    
    func didSubscribeToAudioTrack(audioTrack: RemoteAudioTrack, publication: RemoteAudioTrackPublication, participant: RemoteParticipant) {
        // We are subscribed to the remote Participant's audio Track. We will start receiving the
        // remote Participant's audio now.
        
        logMessage(messageText: "Subscribed to audio track for Participant \(participant.identity)")
    }
    
    func didUnsubscribeFromAudioTrack(audioTrack: RemoteAudioTrack, publication: RemoteAudioTrackPublication, participant: RemoteParticipant) {
        // We are unsubscribed from the remote Participant's audio Track. We will no longer receive the
        // remote Participant's audio.
        
        logMessage(messageText: "Unsubscribed from audio track for Participant \(participant.identity)")
    }
    
    func remoteParticipantDidEnableVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
        logMessage(messageText: "Participant \(participant.identity) enabled video track")
    }
    
    func remoteParticipantDidDisableVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
        logMessage(messageText: "Participant \(participant.identity) disabled video track")
    }
    
    func remoteParticipantDidEnableAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
        logMessage(messageText: "Participant \(participant.identity) enabled audio track")
    }
    
    func remoteParticipantDidDisableAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
        logMessage(messageText: "Participant \(participant.identity) disabled audio track")
    }
    
    func didFailToSubscribeToAudioTrack(publication: RemoteAudioTrackPublication, error: Error, participant: RemoteParticipant) {
        logMessage(messageText: "FailedToSubscribe \(publication.trackName) audio track, error = \(String(describing: error))")
    }
    
    func didFailToSubscribeToVideoTrack(publication: RemoteVideoTrackPublication, error: Error, participant: RemoteParticipant) {
        logMessage(messageText: "FailedToSubscribe \(publication.trackName) video track, error = \(String(describing: error))")
    }
}

// MARK:- VideoViewDelegate
extension CallManager : VideoViewDelegate {
    func videoViewDimensionsDidChange(view: VideoView, dimensions: CMVideoDimensions) {
        self.view.setNeedsLayout()
    }
}

// MARK:- CameraSourceDelegate
extension CallManager : CameraSourceDelegate {
    func cameraSourceDidFail(source: CameraSource, error: Error) {
        logMessage(messageText: "Camera source failed with error: \(error.localizedDescription)")
    }
    
}
