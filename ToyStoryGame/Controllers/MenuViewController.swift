//
//  MenuViewController.swift
//  ToyStoryGame
//
//  Created by Aaron Alejandro Martinez Solis on 25/03/25.
//

import UIKit
import AVFoundation

class MenuViewController: UIViewController {
    
    var backgroundMusicPlayer: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        playBackgroundMusic()

        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: Notification.Name("AppDidEnterBackground"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: Notification.Name("AppWillEnterForeground"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        backgroundMusicPlayer?.stop()
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Música
    
    func playBackgroundMusic() {
        if let path = Bundle.main.path(forResource: "Strange Things (Instrumental Version _ Remastered 2015)-yt.savetube.me", ofType: "mp3") {
            let url = URL(fileURLWithPath: path)
            do {
                backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
                backgroundMusicPlayer?.numberOfLoops = -1
                backgroundMusicPlayer?.play()
            } catch {
                print("No se pudo reproducir la música de fondo: \(error)")
            }
        }
    }
    
    @objc func appDidEnterBackground() {
        backgroundMusicPlayer?.pause()
    }

    @objc func appWillEnterForeground() {
        backgroundMusicPlayer?.play()
    }

}
