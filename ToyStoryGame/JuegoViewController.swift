//
//  JuegoViewController.swift
//  ToyStoryGame
//
//  Created by Aaron Alejandro Martinez Solis on 25/03/25.
//

import UIKit
import AVFoundation

class JuegoViewController: UIViewController {
    
    var sonidoOof: AVAudioPlayer?
    var backgroundMusicPlayer: AVAudioPlayer?
    
    @IBOutlet weak var stackTeclado: UIStackView!
    @IBOutlet weak var stackLineas: UIStackView!
    @IBOutlet weak var ahorcadoImageView: UIImageView!
    var palabraSecreta = "ADIVINANZA"
        var letrasAdivinadas: [String] = []
        var vidas = 3 {
            didSet {
                actualizarImagenAhorcado()
            }
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            playBackgroundMusic()
            mostrarLineas()
            crearTeclado()
            actualizarImagenAhorcado()
            
            NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: Notification.Name("AppDidEnterBackground"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: Notification.Name("AppWillEnterForeground"), object: nil)
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            backgroundMusicPlayer?.stop()
            NotificationCenter.default.removeObserver(self)
        }

        func actualizarImagenAhorcado() {
            ahorcadoImageView.image = UIImage(named: "ahorcado_\(3 - vidas)")
        }

        func mostrarLineas() {
            stackLineas.arrangedSubviews.forEach { $0.removeFromSuperview() }

            let longitud = palabraSecreta.count
            let maxPorFila = 7 // Si hay más de esto, se hace 2 filas

            // Divide letras en 1 o 2 filas
            let letras = Array(palabraSecreta)
            let mitad = letras.count / 2 + letras.count % 2

            let filas: [[Character]]
            if letras.count <= maxPorFila {
                filas = [letras]
            } else {
                filas = [
                    Array(letras[..<mitad]),
                    Array(letras[mitad...])
                ]
            }

            for fila in filas {
                let lineaStack = UIStackView()
                lineaStack.axis = .horizontal
                lineaStack.alignment = .center
                lineaStack.distribution = .equalSpacing
                lineaStack.spacing = 8

                for letra in fila {
                    let label = UILabel()
                    label.text = letrasAdivinadas.contains(String(letra)) ? String(letra) : "_"
                    label.font = UIFont.monospacedDigitSystemFont(ofSize: 32, weight: .bold)
                    label.textAlignment = .center
                    label.textColor = .white

                    let ancho: CGFloat = letras.count > 8 ? 24 : (letras.count > 5 ? 28 : 36)
                    label.widthAnchor.constraint(equalToConstant: ancho).isActive = true
                    label.heightAnchor.constraint(equalToConstant: 44).isActive = true

                    lineaStack.addArrangedSubview(label)
                }

                stackLineas.addArrangedSubview(lineaStack)
            }
        }

        func crearTeclado() {
            stackTeclado.arrangedSubviews.forEach { $0.removeFromSuperview() }

            let letras = Array("ABCDEFGHIJKLMNÑOPQRSTUVWXYZ")
            var fila = UIStackView()
            fila.axis = .horizontal
            fila.distribution = .fillEqually
            fila.spacing = 6

            for (index, letra) in letras.enumerated() {
                if index % 7 == 0 && index != 0 {
                    stackTeclado.addArrangedSubview(fila)
                    fila = UIStackView()
                    fila.axis = .horizontal
                    fila.distribution = .fillEqually
                    fila.spacing = 6
                }

                let boton = UIButton(type: .system)
                boton.setTitle(String(letra), for: .normal)
                boton.titleLabel?.font = UIFont(name: "Menlo-Bold", size: 20)
                boton.setTitleColor(.systemPurple, for: .normal)
                boton.backgroundColor = .black
                boton.layer.cornerRadius = 10
                boton.layer.borderWidth = 2
                boton.layer.borderColor = UIColor.systemPurple.cgColor
                boton.translatesAutoresizingMaskIntoConstraints = false
                boton.widthAnchor.constraint(equalToConstant: 45).isActive = true
                boton.heightAnchor.constraint(equalToConstant: 45).isActive = true

                boton.addTarget(self, action: #selector(letraTocada(_:)), for: .touchUpInside)
                fila.addArrangedSubview(boton)
            }

            stackTeclado.addArrangedSubview(fila)
            stackTeclado.alignment = .center
            stackTeclado.distribution = .equalCentering
        }
        @objc func letraTocada(_ sender: UIButton) {
            guard let letra = sender.titleLabel?.text else { return }
            
            sender.isEnabled = false
            sender.setTitleColor(.systemRed, for: .disabled)
            sender.layer.borderColor = UIColor.systemRed.cgColor

            procesarLetra(letra)
        }
        func procesarLetra(_ letra: String) {
            if palabraSecreta.contains(letra) {
                letrasAdivinadas.append(letra)
                mostrarLineas()

                if palabraSecreta.allSatisfy({ letrasAdivinadas.contains(String($0)) }) {
                    mostrarAlerta(titulo: "¡Ganaste!", mensaje: "Has adivinado la palabra.")
                }

            } else {
                vidas -= 1
                reproducirOof()
                if vidas == 0 {
                    mostrarAlerta(titulo: "Perdiste", mensaje: "La palabra era \(palabraSecreta).")
                }
            }
        }

        func mostrarAlerta(titulo: String, mensaje: String) {
            let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)

            alerta.addAction(UIAlertAction(title: "🔁 Reintentar", style: .default, handler: { _ in
                self.reiniciarJuego()
            }))

            alerta.addAction(UIAlertAction(title: "🏠 Ir al menú", style: .cancel, handler: { _ in
                self.navigationController?.popViewController(animated: true)
                // o self.dismiss(animated: true)
            }))

            present(alerta, animated: true, completion: nil)
        }
        func reiniciarJuego() {
            palabraSecreta = ["GATO", "HELADO", "LIMÓN", "AVIÓN", "PERRO", "ADIVINANZA"].randomElement()!
            letrasAdivinadas = []
            vidas = 3
            mostrarLineas()

            for fila in stackTeclado.arrangedSubviews {
                if let stackFila = fila as? UIStackView {
                    for boton in stackFila.arrangedSubviews {
                        if let btn = boton as? UIButton {
                            btn.isEnabled = true
                            btn.setTitleColor(.systemPurple, for: .normal)
                            btn.layer.borderColor = UIColor.systemPurple.cgColor
                        }
                    }
                }
            }
        }
    
    // MARK: - Sonidos
    
    func reproducirOof() {
        guard let url = Bundle.main.url(forResource: "ROBLOX Oof Sound Effect", withExtension: "mp3") else {
            print("no se encontró")
            return
        }
        
        do {
            sonidoOof = try AVAudioPlayer(contentsOf: url)
            sonidoOof?.volume = 1.0
            sonidoOof?.play()
        } catch {
            print("error: \(error)")
        }
    }
    
    func playBackgroundMusic() {
        if let path = Bundle.main.path(forResource: "juego", ofType: "mp3") {
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
