//
//  AjustesModalViewController.swift
//  ToyStoryGame
//
//  Created by Aaron Alejandro Martinez Solis on 25/03/25.
//

import UIKit

class AjustesModalViewController: UIViewController {

    @IBOutlet weak var btnToggleMusica: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        if juegoViewController?.backgroundMusicPlayer?.isPlaying == true {
            btnToggleMusica.setImage(UIImage(systemName: "speaker.wave.2.fill"), for: .normal)
        } else {
            btnToggleMusica.setImage(UIImage(systemName: "speaker.slash.fill"), for: .normal)
        }

        // Do any additional setup after loading the view.
    }
    
    var juegoViewController: JuegoViewController?

    @IBAction func toggleMusica(_ sender: UIButton) {
        guard let juegoVC = juegoViewController else { return }

            if juegoVC.backgroundMusicPlayer?.isPlaying == true {
                juegoVC.backgroundMusicPlayer?.pause()
                juegoVC.musicaActiva = false
                sender.setImage(UIImage(systemName: "speaker.slash.fill"), for: .normal)
            } else {
                juegoVC.backgroundMusicPlayer?.play()
                juegoVC.musicaActiva = true
                sender.setImage(UIImage(systemName: "speaker.wave.2.fill"), for: .normal)
            }

            dismiss(animated: true)
    }
    @IBAction func reiniciarGame(_ sender: Any) {
        guard let juegoVC = juegoViewController else { return }
            dismiss(animated: true) {
                if juegoVC.puntajeAcumulado > 0 {
                    juegoVC.verificarNuevoRecordDesdeAjustes(puntaje: juegoVC.puntajeAcumulado) {
                        juegoVC.reiniciarJuego()
                    }
                } else {
                    juegoVC.reiniciarJuego()
                }
            }
    }
    @IBAction func irMenu(_ sender: Any) {
        guard let juegoVC = juegoViewController else { return }

        
        dismiss(animated: true) {
            if juegoVC.puntajeAcumulado > 0 {
                juegoVC.verificarNuevoRecord(puntaje: juegoVC.puntajeAcumulado)
            }

            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let menuVC = storyboard.instantiateViewController(withIdentifier: "MenuView")
            menuVC.modalPresentationStyle = .fullScreen
            juegoVC.present(menuVC, animated: true, completion: nil)
        }
    }

}
