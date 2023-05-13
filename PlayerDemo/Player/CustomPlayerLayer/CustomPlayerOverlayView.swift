//
//  CustomPlayerOverlayView.swift
//  PlayerDemo
//
//  Created by Vartika Singh on 10/01/22.
//

import UIKit

protocol CustomPlayerOverlayPOCDelegate {
    func playPauseButtonTapped()
    func volumeButtonTapped()
    func forwardButtonTapped()
    func playBackButtonTapped()
    func fullScreenButtonTapped()
}

class CustomPlayerOverlayView: UIView {
    @IBOutlet weak var playPause: UIButton!
    @IBOutlet weak var playPauseIdentifier: UIButton!
    @IBOutlet weak var volumeButton: UIButton!
    @IBOutlet weak var playBackButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var minimumTimeLabel: UILabel!
    @IBOutlet weak var maximumTimeLabel: UILabel!
    @IBOutlet weak var playerSeekBarSlider: UISlider!
    @IBOutlet weak var fullScreenButton: UIButton!
    @IBOutlet weak var controlView: UIView!
    var delegate: CustomPlayerOverlayPOCDelegate?
    var timer: Timer?

    var isPlayerMuted = false {
        didSet {
            let image = isPlayerMuted ? UIImage(systemName: "speaker.slash.fill") : UIImage(systemName: "speaker.fill")
            volumeButton.setImage(image, for: .normal)
        }
    }
    
    var playerState = CurrentPlayerState.pause {
        didSet {
            switch self.playerState {
            case .playing:
                playPause.isHidden = false
                volumeButton.isHidden = false
                playBackButton.isHidden = false
                forwardButton.isHidden = false
                controlView.isHidden = false
                timer?.invalidate()
                timer = nil
                timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.removeControls), userInfo: nil, repeats: false)
                self.playPause.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                break
                
            case .pause:
                playPause.isHidden = false
                volumeButton.isHidden = false
                playBackButton.isHidden = false
                forwardButton.isHidden = false
                controlView.isHidden = false
                self.playPause.setImage(UIImage(systemName: "play.fill"), for: .normal)
                break
            }
        }
    }
    
    override func awakeFromNib() {
        playPause.isHidden = false
        volumeButton.isHidden = false
        playBackButton.isHidden = false
        forwardButton.isHidden = false
        controlView.isHidden = false
    }
    
    @IBAction func mainControlButtonTapped(_ sender: Any) {
        timer?.invalidate()
        timer = nil
        playPause.isHidden.toggle()
        volumeButton.isHidden.toggle()
        playBackButton.isHidden.toggle()
        forwardButton.isHidden.toggle()
        controlView.isHidden.toggle()
        if !playPause.isHidden && !volumeButton.isHidden {
            timer?.invalidate()
            timer = nil
            timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.removeControls), userInfo: nil, repeats: false)
        }
    }
    
    @objc func removeControls() {
        playPause.isHidden = true
        volumeButton.isHidden = true
        playBackButton.isHidden = true
        forwardButton.isHidden = true
        controlView.isHidden = true
        print("Hiding Controls")
    }
    
    @IBAction func playPauseButtonTapped(_ sender: Any) {
        delegate?.playPauseButtonTapped()
    }
    
    @IBAction func volumeButtonTapped(_ sender: Any) {
        delegate?.volumeButtonTapped()
    }

    @IBAction func playBackButtonAction(_ sender: Any) {
        delegate?.playBackButtonTapped()
    }
    
    @IBAction func fullScreenbuttonAction(_ sender: Any) {
        delegate?.fullScreenButtonTapped()
    }
    
    @IBAction func forwardButtonAction(_ sender: Any) {
        delegate?.forwardButtonTapped()
    }
}
