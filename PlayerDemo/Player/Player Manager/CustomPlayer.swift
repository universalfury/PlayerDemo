//
//  CustomPlayerManager.swift
//  PlayerDemo
//
//  Created by Vartika Singh on 11/01/22.
//

import UIKit
import AVKit

class CustomPlayer: NSObject {
    static let shared = CustomPlayer.init()
    var playerLayer: AVPlayerLayer?
    var overlayView: CustomPlayerOverlayView?
    var playerItem: AVPlayerItem?
    var isMuted = false
    var isStopped = false
    var playerView: UIView?
    private let allowedSeekTime: CGFloat = 10.0
    var timeObserver: AnyObject!
    
    override init() {
        playerLayer = AVPlayerLayer.init()
        playerLayer?.player = AVPlayer.init()
    }
    
    deinit {
        playerLayer?.player?.pause()
        overlayView?.playerState = .pause
    }
    
    func playerSetup(in playerSuperView: UIView, url: String) {
        if playerLayer?.player == nil {
            playerLayer = AVPlayerLayer.init()
            playerLayer?.player = AVPlayer.init()
        }
        self.playerLayer?.removeFromSuperlayer()
        self.playerView = playerSuperView
        let dummyURL = URL(string: url)
        self.playerItem = AVPlayerItem(url: (dummyURL!))
        self.playerLayer?.player?.replaceCurrentItem(with: playerItem)
        
        if overlayView == nil {
            overlayView = UIView.fromNib()
            overlayView?.delegate = self
        }
        setUpTracker()
        manageTimeLabel()
        guard let overlayView = overlayView else { return }
        overlayView.frame = playerSuperView.bounds
        overlayView.volumeButton.isHidden = false
        playerView?.addSubview(overlayView)
        playerView?.sendSubviewToBack(overlayView)
        playerView?.layer.insertSublayer(self.playerLayer!, below: overlayView.layer)
        overlayView.isPlayerMuted = isMuted
        playerLayer?.player?.isMuted = isMuted
        playerLayer?.player?.play()
        overlayView.playerState = .playing
        setUpTime()
    }
    
    func playerLayoutSetup() {
        playerLayer?.frame = playerView!.bounds
        playerLayer?.videoGravity = .resizeAspectFill
    }
    
    func setUpTracker() {
        overlayView?.playerSeekBarSlider.addTarget(self, action: #selector(sliderBeganTracking),
                                                   for: .touchDown)
        overlayView?.playerSeekBarSlider.addTarget(self, action: #selector(sliderEndedTracking),
                                                   for: [.touchUpInside, .touchUpOutside])
        overlayView?.playerSeekBarSlider.addTarget(self, action: #selector(sliderValueChanged),
                                                   for: .valueChanged)
    }
    
    @objc func sliderBeganTracking(slider: UISlider) {
        playerLayer?.player?.pause()
    }
    
    @objc func sliderEndedTracking(slider: UISlider) {
        let videoDuration = CMTimeGetSeconds((playerLayer?.player?.currentItem!.duration)!)
        let elapsedTime: Float64 = videoDuration * Float64((overlayView?.playerSeekBarSlider.value)!)
        updateTimeLabel(elapsedTime: elapsedTime, duration: videoDuration)
    }
    
    @objc func sliderValueChanged(slider: UISlider) {
        let seconds : Int64 = Int64(slider.value)
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        
        playerLayer?.player?.seek(to: targetTime)
        playerLayer?.player?.play()
    }
    
    private func updateTimeLabel(elapsedTime: Float64, duration: Float64) {
        overlayView?.minimumTimeLabel.text = self.stringFromTimeInterval(interval: elapsedTime)
    }
    
    private func observeTime(elapsedTime: CMTime) {
        let duration = CMTimeGetSeconds(playerLayer?.player?.currentItem!.duration ?? CMTime())
        let elapsedTime = CMTimeGetSeconds(elapsedTime)
        updateTimeLabel(elapsedTime: elapsedTime, duration: duration)
    }
    
    func setUpTime() {
        let duration : CMTime = (playerLayer?.player?.currentItem!.asset.duration)!
        let seconds : Float64 = CMTimeGetSeconds(duration)
        overlayView?.maximumTimeLabel.text = self.stringFromTimeInterval(interval: seconds)
    }
    
    func stringFromTimeInterval(interval: TimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    func manageTimeLabel() {
        let timeInterval: CMTime = CMTimeMakeWithSeconds(1.0,  preferredTimescale: 100)
        timeObserver = playerLayer?.player!.addPeriodicTimeObserver(forInterval: timeInterval,
                                                                    queue: DispatchQueue.main) { (elapsedTime: CMTime) -> Void in
            if self.playerItem != nil && self.playerLayer?.player?.currentItem?.status == .readyToPlay {
                self.observeTime(elapsedTime: elapsedTime)
                let time : Float64 = CMTimeGetSeconds((self.playerLayer?.player?.currentTime())!);
                self.overlayView?.playerSeekBarSlider.isEnabled = true
                self.overlayView?.playerSeekBarSlider.value = Float ( time )
            }
        } as AnyObject?
        let duration: CMTime = playerItem!.asset.duration
        let seconds: Float64 = CMTimeGetSeconds(duration)
        overlayView?.playerSeekBarSlider.maximumValue = Float(seconds)
        overlayView?.playerSeekBarSlider.isContinuous = true
    }
}

extension CustomPlayer: CustomPlayerOverlayPOCDelegate {
    
    func fullScreenButtonTapped() {
        let orientation = UIDevice.current.orientation
        if orientation == .portrait {
            let value = UIInterfaceOrientation.landscapeLeft.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            self.overlayView?.fullScreenButton.setImage(UIImage(systemName: "rectangle.fill"), for: .normal)
            self.overlayView?.fullScreenButton.tintColor = .green
        } else {
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            self.overlayView?.fullScreenButton.setImage(UIImage(systemName: "rectangle"), for: .normal)
            self.overlayView?.fullScreenButton.tintColor = .white
        }
    }
    
    func forwardButtonTapped() {
        guard let duration  = playerLayer?.player?.currentItem?.duration else{
            return
        }
        let playerCurrentTime = CMTimeGetSeconds((playerLayer?.player?.currentTime())!)
        let newTime = playerCurrentTime + allowedSeekTime
        
        if newTime < CMTimeGetSeconds(duration) {
            
            let time2: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
            playerLayer?.player?.seek(to: time2)
        }
    }
    
    func playBackButtonTapped() {
        let playerCurrentTime = CMTimeGetSeconds((playerLayer?.player?.currentTime())!)
        var newTime = playerCurrentTime - allowedSeekTime
        
        if newTime < 0 {
            newTime = 0
        }
        let time2: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
        playerLayer?.player?.seek(to: time2)
    }
    
    func playPauseButtonTapped() {
        if overlayView?.playerState == .pause {
            overlayView?.playerState = .playing
            playerLayer?.player?.play()
        } else {
            overlayView?.playerState = .pause
            playerLayer?.player?.pause()
        }
    }
    
    func volumeButtonTapped() {
        if overlayView?.isPlayerMuted == true {
            playerLayer?.player?.isMuted = false
        } else {
            playerLayer?.player?.isMuted = true
        }
        overlayView?.isPlayerMuted.toggle()
    }
}
