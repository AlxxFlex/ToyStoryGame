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
    var musicaActiva = true
    var tiempoTranscurrido = 0
    var temporizador: Timer?
    var puntajeAcumulado = 0
    var intentosFallidos = 0
    var reiniciandoJuego = false
    var perdioAlHacerRecord = false
    
    @IBOutlet weak var VidasLbl: UILabel!
    @IBOutlet weak var PuntosLbl: UILabel!
    @IBOutlet weak var TimeLbl: UILabel!
    @IBOutlet weak var stackTeclado: UIStackView!
    @IBOutlet weak var stackLineas: UIStackView!
    @IBOutlet weak var ahorcadoImageView: UIImageView!
 
    let palabrasToyStory = [
        "AVENTURA", "ANIMADOR", "BALCONES", "CAMPEON", "CENIZAS",
        "DESAFIO", "DIAGRAMA", "DOMINIOS", "ESFERICO", "ESTORNOS",
        "FANTASMA", "FLECHAZO", "FUGITIVO", "GLACIAL", "GUERRERO",
        "HERENCIA", "HISTORIA", "ILUSION", "IMPERIOS", "JARDINES",
        "JORNADAS", "JUGUETES", "LABERINT", "LENGUAJE", "LUZBELIA",
        "MAGNOLIA", "MISTERIO", "MONTAÑAS", "NOVEDOSA", "OBSTACULO",
        "OCULTADO", "ORGULLOS", "PELIGROS", "PIRATAS", "POLITICA",
        "PRIMAVERA", "PROYECTO", "QUIMERAS", "RAZONADO", "REGISTRO",
        "RELIQUIA", "REQUIERO", "SAGRARIO", "SECRETOS", "SILENCIO",
        "TRADICION", "TURMALINA", "UNIFORME", "VENCIDOS", "VIGILADO"
    ]
    
    var palabraSecreta = ""
    var letrasAdivinadas: [String] = []
    var vidas = 3 {
        didSet {
            actualizarImagenAhorcado()
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        playBackgroundMusic()
        iniciarJuego()
        actualizarVidas()
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: Notification.Name("AppDidEnterBackground"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: Notification.Name("AppWillEnterForeground"), object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if musicaActiva && backgroundMusicPlayer?.isPlaying == false {
            backgroundMusicPlayer?.play()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if perdioAlHacerRecord {
            mostrarAlertaFinal()
            perdioAlHacerRecord = false
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        backgroundMusicPlayer?.stop()
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func ajustesBoton(_ sender: Any) {
        performSegue(withIdentifier: "sgAjustes", sender: self)
    }
    // MARK: - Iniciar Juego
    func iniciarJuego() {
        palabraSecreta = palabrasToyStory.randomElement()!
        letrasAdivinadas = []
        intentosFallidos = 0
        tiempoTranscurrido = 0
        mostrarLineas()
        crearTeclado()
        actualizarImagenAhorcado()
        actualizarVidas()
        iniciarTemporizador()
        actualizarPuntaje()
    }
    func actualizarVidas() {
        VidasLbl.text = "Vidas: \(vidas)"
    }
        
        
    func actualizarImagenAhorcado() {
        let intentosUsados = intentosFallidos
        ahorcadoImageView.image = UIImage(named: "ahorcado_\(intentosUsados)")
    }

    func mostrarLineas() {
        stackLineas.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let longitud = palabraSecreta.count
        let maxPorFila = 7
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
                let puntajeFinal = calcularPuntaje(palabra: palabraSecreta, tiempo: tiempoTranscurrido, errores: intentosFallidos)
                puntajeAcumulado += puntajeFinal
                actualizarPuntaje()
                iniciarJuego()
            }
        } else {
            intentosFallidos += 1
            reproducirOof()
            actualizarImagenAhorcado()
            if intentosFallidos >= 5 {
                vidas -= 1
                intentosFallidos = 0
                actualizarVidas()
                if vidas == 0 {
                    detenerTemporizador()
                    verificarNuevoRecordAntesDeAlerta()
                } else {
                    mostrarAlertaIntentosFallidos()
                }
            }
        }
    }
    
    func actualizarPuntaje() {
        PuntosLbl.text = "Puntaje: \(puntajeAcumulado)"
    }
    
    func verificarNuevoRecordAntesDeAlerta() {
        var records = cargarRecords()
        records.sort { ($0["puntaje"] as? Int ?? 0) > ($1["puntaje"] as? Int ?? 0) }
        
        if records.count < 5 || puntajeAcumulado > (records.last?["puntaje"] as? Int ?? 0) {
            mostrarPantallaNuevoRecord(puntaje: puntajeAcumulado)
        } else {
            mostrarAlertaFinal()
        }
    }
    
    func verificarNuevoRecord(puntaje: Int) {
        if reiniciandoJuego {
            return
        }
        
        var records = cargarRecords()
        records.sort { ($0["puntaje"] as? Int ?? 0) > ($1["puntaje"] as? Int ?? 0) }
        if records.count < 5 || puntaje > (records.last?["puntaje"] as? Int ?? 0) {
            mostrarPantallaNuevoRecord(puntaje: puntaje)
        } else {
            mostrarAlertaFinal()
        }
    }

    func mostrarAlertaIntentosFallidos() {
        let alerta = UIAlertController(
            title: "Fallaste",
            message: "Perdiste 1 vida al no adivinar la palabra '\(palabraSecreta)'.",
            preferredStyle: .alert
        )
        
        alerta.addAction(UIAlertAction(title: "Continuar", style: .default, handler: { _ in
            self.iniciarJuego()
        }))
        
        present(alerta, animated: true, completion: nil)
    }
    func mostrarPantallaNuevoRecord(puntaje: Int) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let recordVC = storyboard.instantiateViewController(withIdentifier: "NewRecordViewController") as? NewRecordViewController {
            recordVC.puntajeNuevo = puntaje
            recordVC.modalPresentationStyle = .fullScreen
            recordVC.completionHandler = { [weak self] in
                guard let self = self else { return }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if self.perdioAlHacerRecord {
                        self.mostrarAlertaFinal()
                    } else {
                        self.reiniciarJuego() 
                    }
                }
            }
            
            present(recordVC, animated: true, completion: nil)
        }
    }
    func mostrarAlertaFinal() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if self.presentedViewController == nil {
                let alerta = UIAlertController(title: "Perdiste", message: "Tu puntaje fue: \(self.puntajeAcumulado)", preferredStyle: .alert)
                
                alerta.addAction(UIAlertAction(title: "🔁 Reintentar", style: .default, handler: { _ in
                    self.reiniciarJuego()
                }))
                
                alerta.addAction(UIAlertAction(title: "🏠 Ir al menú", style: .cancel, handler: { _ in
                    self.irMenuPrincipal()
                }))
                
                self.present(alerta, animated: true, completion: nil)
            } else {
                print("⚠️ Alerta no presentada porque hay otra vista activa.")
            }
        }
    }
    func reiniciarJuego() {
        reiniciandoJuego = true
        puntajeAcumulado = 0
        vidas = 3
        actualizarVidas()
        iniciarJuego()
        reiniciandoJuego = false
    }
    func irMenuPrincipal() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let menuVC = storyboard.instantiateViewController(withIdentifier: "MenuView")
        menuVC.modalPresentationStyle = .fullScreen
        present(menuVC, animated: true, completion: nil)
    }
    func verificarNuevoRecordDesdeAjustes(puntaje: Int, completion: @escaping () -> Void) {
        if reiniciandoJuego {
            completion()
            return
        }
        var records = cargarRecords()
        records.sort { ($0["puntaje"] as? Int ?? 0) > ($1["puntaje"] as? Int ?? 0) }
        if records.count < 5 || puntaje > (records.last?["puntaje"] as? Int ?? 0) {
            mostrarPantallaNuevoRecord(puntaje: puntaje)
        } else {
            completion()
        }
    }
    // MARK: - Temporizador
    func iniciarTemporizador() {
        tiempoTranscurrido = 0
        temporizador?.invalidate()
        
        temporizador = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tiempoTranscurrido += 1
            self?.TimeLbl.text = "\(self?.tiempoTranscurrido ?? 0) s"
        }
    }
    
    func detenerTemporizador() {
        temporizador?.invalidate()
        temporizador = nil
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
        if musicaActiva {
            backgroundMusicPlayer?.play()
        }
    }
    // MARK: - PLIST - GUARDAR RECORDS

    
    func obtenerRutaPlist() -> URL? {
        
        if let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("records.plist") {
            return path
        }
        return nil
    }
  

    func cargarRecords() -> [[String: Any]] {
        guard let url = obtenerRutaPlist(),
              FileManager.default.fileExists(atPath: url.path),
              let data = FileManager.default.contents(atPath: url.path) else {
            print("No se encontró el archivo records.plist en Document Directory")
            return []
        }
        
        do {
            if let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [[String: Any]] {
                print("Datos cargados: \(plist)")
                return plist
            }
        } catch {
            print("Error al leer records.plist: \(error)")
        }
        
        return []
    }
    
    
    // MARK: - CALCULAR PUNTAJE
    func calcularPuntaje(palabra: String, tiempo: Int, errores: Int) -> Int {
        var puntaje = 0
        
        
        switch palabra.count {
        case 5...6:
            puntaje += 10
        case 7...8:
            puntaje += 15
        case 9...10:
            puntaje += 20
        default:
            puntaje += 5
        }
        
        
        switch errores {
        case 0:
            puntaje += 10
        case 1:
            puntaje += 5
        case 2:
            puntaje += 2
        default:
            puntaje += 0
        }
        
        
        if tiempo < 10 {
            puntaje += 10
        } else if tiempo <= 20 {
            puntaje += 5
        }
        
        return puntaje
    }

    
    // MARK: - SEGUE PARA NUEVO RECORD Y AJUSTES
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sgnewrecord",
           let destino = segue.destination as? NewRecordViewController,
           let puntaje = sender as? Int {
            destino.puntajeNuevo = puntaje
        }
        
        if segue.identifier == "sgAjustes",
           let destino = segue.destination as? AjustesModalViewController {
            destino.juegoViewController = self
        }
    }
}
