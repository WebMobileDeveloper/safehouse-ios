//
//  recordingViewController.swift
//  SafehouseChild
//
//  Created by Delicious on 10/5/17.
//  Copyright © 2017 Delicious. All rights reserved.
//

import UIKit
import AVFoundation


class playingViewController: UIViewController, AVAudioPlayerDelegate {
    
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var progress: UIProgressView!
    
    var audioPlayer:AVAudioPlayer!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stateLabel.text = "Audio loading ... "
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateAudioMeter(_:)), userInfo: nil, repeats: true)
        let audioUrl = user.emergencyRequests[0].audio_url
        let url = URL(string: audioUrl)!
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                showAlert(target: self, message: "We can't find any audio file.", title: "Alert", hander: {
                    self.dismiss(animated: true, completion: nil);
                })
                return
            }
            guard let data = data, error == nil else { return }
            do {
                try self.audioPlayer = AVAudioPlayer(data: data, fileTypeHint: AVFileTypeAppleM4A)
                self.audioPlayer.delegate = self
                self.audioPlayer.prepareToPlay()
                self.audioPlayer.volume = 5.0
                self.audioPlayer.play()
                DispatchQueue.main.async {
                    self.stateLabel.text = "Your child's voice is playing now."
                }
            } catch _ as NSError {
                showAlert(target: self, message: "We can't find any audio file.", title: "Alert", hander: {
                    self.dismiss(animated: true, completion: nil);
                })
            }
        }
        task.resume()
    }
    override func viewWillAppear(_ animated: Bool) {
        user.currVC = self
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.dismiss(animated: true, completion: nil);
    }
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        showAlert(target: self, message: "Error was occured during audio file palying.", title: "Error", hander: {
            self.dismiss(animated: true, completion: nil);
        })
    }
    func updateAudioMeter(_ timer:Timer) {
        guard  let player = audioPlayer else {
            return
        }
        if  player.isPlaying {
            let total = player.duration;
            let f = player.currentTime / total;
            progress.progress=Float(f);
            player.updateMeters()
        }
    }
   
}

