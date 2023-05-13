//
//  CustomPlayerViewController.swift
//  PlayerDemo
//
//  Created by Vartika Singh on 11/01/22.
//

import UIKit

class CustomPlayerViewController: UIViewController {
    
    @IBOutlet weak var playerContainer: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerNotification()
        CustomPlayer.shared.playerSetup(in: playerContainer, url: "http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8")
//        CustomPlayer.shared.playerSetup(in: playerContainer, url: "https://multiplatform-f.akamaihd.net/i/multi/april11/sintel/sintel-hd_,512x288_450_b,640x360_700_b,768x432_1000_b,1024x576_1400_m,.mp4.csmil/master.m3u8")
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeNotification()
        if CustomPlayer.shared.playerLayer?.player != nil {
            CustomPlayer.shared.playerLayer?.player?.pause()
            CustomPlayer.shared.overlayView?.playerState = .pause
            CustomPlayer.shared.playerLayer?.player = nil
        }
    }
    
    override func viewDidLayoutSubviews() {
        CustomPlayer.shared.playerLayoutSetup()
    }
    
    private func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(foregroundAudioHandling), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(backgroundAudioHandling), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    private func removeNotification() {
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc private func orientationDidChange() {
        let orientation = UIDevice.current.orientation
        if orientation == .portrait {
            self.navigationController?.isNavigationBarHidden = false
            CustomPlayer.shared.overlayView?.fullScreenButton.setImage(UIImage(systemName: "rectangle"), for: .normal)
            CustomPlayer.shared.overlayView?.fullScreenButton.tintColor = .white
        } else {
            self.navigationController?.isNavigationBarHidden = true
            CustomPlayer.shared.overlayView?.fullScreenButton.setImage(UIImage(systemName: "rectangle.fill"), for: .normal)
            CustomPlayer.shared.overlayView?.fullScreenButton.tintColor = .green
        }
    }
    
    @objc private func backgroundAudioHandling() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            CustomPlayer.shared.playerLayer?.player?.pause()
            CustomPlayer.shared.overlayView?.playerState = .pause
        }
    }
    
    @objc private func foregroundAudioHandling() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            CustomPlayer.shared.playerLayer?.player?.play()
            CustomPlayer.shared.overlayView?.playerState = .playing
        }
    }
    
}
