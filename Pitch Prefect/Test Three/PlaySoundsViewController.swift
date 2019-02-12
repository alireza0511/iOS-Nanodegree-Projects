//
//  PlaySoundsViewController.swift
//  Test Three
//
//  Created by Alireza Jazzb on 6/3/18.
//  Copyright © 2018 Alireza Jazzb. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {

    // MARK: Outlets
    
    @IBOutlet weak var snailButton: UIButton!
    @IBOutlet weak var chipmunkButton: UIButton!
    @IBOutlet weak var rabbitButton: UIButton!
    @IBOutlet weak var vaderButton: UIButton!
    @IBOutlet weak var echoButton: UIButton!
    @IBOutlet weak var reverbButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!

    var recordedAudioURL: URL!
    
    var audioFile:AVAudioFile!
    var audioEngine:AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var stopTimer: Timer!
    
    enum ButtonType: Int {
        case slow = 0, fast, chipmunk, vader, echo, reverb
    }
    // MARK: Actions
    
    @IBAction func playSoundForButton(_ sender: UIButton) {
        switch(ButtonType(rawValue: sender.tag)!) {
        case .slow:
            playSound(rate: 0.5)
        case .fast:
            playSound(rate: 1.5)
        case .chipmunk:
            playSound(pitch: 1000)
        case .vader:
            playSound(pitch: -1000)
        case .echo:
            playSound(echo: true)
        case .reverb:
            playSound(reverb: true)
        }
        
        configureUI(.playing)
    }
    
    @IBAction func stopButtonPressed(_ sender: AnyObject) {
        configureUI(.notPlaying)
        stopButton.isEnabled = false
        audioPlayerNode.stop()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudio()
        
        fixingUI(buttonForFixing: snailButton)
        fixingUI(buttonForFixing: chipmunkButton)
        fixingUI(buttonForFixing: rabbitButton)
        fixingUI(buttonForFixing: vaderButton)
        fixingUI(buttonForFixing: echoButton)
        fixingUI(buttonForFixing: reverbButton)
        fixingUI(buttonForFixing: stopButton)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureUI(.notPlaying)
    }

    func fixingUI(buttonForFixing: UIButton) {
        buttonForFixing.contentMode = .center
        buttonForFixing.imageView?.contentMode = .scaleAspectFit
    }
   

}
