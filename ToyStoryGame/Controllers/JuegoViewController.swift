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
    
    @IBOutlet weak var PuntosLbl: UILabel!
    @IBOutlet weak var TimeLbl: UILabel!
    @IBOutlet weak var stackTeclado: UIStackView!
    @IBOutlet weak var stackLineas: UIStackView!
    @IBOutlet weak var ahorcadoImageView: UIImageView!
 
    let palabrasToyStory = [
        "ARBOL","ADIOS","ALERTA","LARGO","MALDICION","TERMO"
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: Notification.Name("AppDidEnterBackground"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: Notification.Name("AppWillEnterForeground"), object: nil)
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
        vidas = 3
        tiempoTranscurrido = 0
        mostrarLineas()
        crearTeclado()
        actualizarImagenAhorcado()
        iniciarTemporizador()
        actualizarPuntaje()
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
                // Si adivina la palabra, actualiza puntaje y continúa con otra palabra
                let puntajeFinal = calcularPuntaje(palabra: palabraSecreta, tiempo: tiempoTranscurrido, errores: 3 - vidas)
                puntajeAcumulado += puntajeFinal
                actualizarPuntaje()
                iniciarJuego()
            }
        } else {
            vidas -= 1
            reproducirOof()
            
            if vidas == 0 {
                detenerTemporizador()
                verificarNuevoRecordAntesDeAlerta()
            }
        }
    }
    
    // Actualizar puntaje en pantalla
    func actualizarPuntaje() {
        PuntosLbl.text = "Puntaje: \(puntajeAcumulado)"
    }
    
    func verificarNuevoRecordAntesDeAlerta() {
        var records = cargarRecords()
        
        // Ordenar récords para comparar con el menor
        records.sort { ($0["puntaje"] as? Int ?? 0) > ($1["puntaje"] as? Int ?? 0) }
        
        // Verifica si es nuevo récord
        if records.count < 5 || puntajeAcumulado > (records.last?["puntaje"] as? Int ?? 0) {
            mostrarPantallaNuevoRecord(puntaje: puntajeAcumulado)
        } else {
            mostrarAlertaFinal()
        }
    }
    
    // Verificación de récord
    func verificarNuevoRecord(puntaje: Int) {
        var records = cargarRecords()
        
        // Ordenar de mayor a menor para comparar con el menor
        records.sort { ($0["puntaje"] as? Int ?? 0) > ($1["puntaje"] as? Int ?? 0) }
        
        // Si hay menos de 5 récords o el puntaje supera el menor
        if records.count < 5 || puntaje > (records.last?["puntaje"] as? Int ?? 0) {
            mostrarPantallaNuevoRecord(puntaje: puntaje)
        } else {
            mostrarAlertaFinal()
        }
    }
    
    // Mostrar pantalla para nuevo récord
    func mostrarPantallaNuevoRecord(puntaje: Int) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let recordVC = storyboard.instantiateViewController(withIdentifier: "NewRecordViewController") as? NewRecordViewController {
            recordVC.puntajeNuevo = puntaje
            recordVC.modalPresentationStyle = .fullScreen
            present(recordVC, animated: true, completion: nil)
        }
    }

    
    // Alerta cuando pierdes
    func mostrarAlertaFinal() {
        let alerta = UIAlertController(title: "Perdiste", message: "Tu puntaje fue: \(puntajeAcumulado)", preferredStyle: .alert)
        
        alerta.addAction(UIAlertAction(title: "🔁 Reintentar", style: .default, handler: { _ in
            self.reiniciarJuego()
        }))
        
        alerta.addAction(UIAlertAction(title: "🏠 Ir al menú", style: .cancel, handler: { _ in
            self.irMenuPrincipal()
        }))
        
        present(alerta, animated: true, completion: nil)
    }

    // ✅ Reiniciar juego correctamente
    func reiniciarJuego() {
        puntajeAcumulado = 0
        iniciarJuego()
    }

    // ✅ Ir al menú después de perder
    func irMenuPrincipal() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let menuVC = storyboard.instantiateViewController(withIdentifier: "MenuView")
        menuVC.modalPresentationStyle = .fullScreen
        present(menuVC, animated: true, completion: nil)
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

    // ✅ Obtener ruta de records.plist en Document Directory
    func obtenerRutaPlist() -> URL? {
        // Obtener ruta del directorio Document Directory
        if let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("records.plist") {
            return path
        }
        return nil
    }
    func mostrarRutaPlist() {
        if let url = obtenerRutaPlist() {
            print("📂 Ruta de records.plist: \(url.path)")
        } else {
            print("❌ No se pudo obtener la ruta del plist")
        }
    }

    // ✅ Cargar récords desde records.plist
    func cargarRecords() -> [[String: Any]] {
        // Copiar el archivo si no existe en Document Directory
        copiarPlistSiEsNecesario()
        
        guard let url = obtenerRutaPlist(),
              FileManager.default.fileExists(atPath: url.path),
              let data = FileManager.default.contents(atPath: url.path) else {
            print("❌ No se encontró el archivo records.plist en Document Directory")
            return []
        }
        
        do {
            if let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [[String: Any]] {
                print("📚 Datos cargados: \(plist)")
                return plist
            }
        } catch {
            print("❌ Error al leer records.plist: \(error)")
        }
        
        return []
    }

    // ✅ Guardar récords en records.plist
    func guardarRecords(_ records: [[String: Any]]) {
        guard let url = obtenerRutaPlist() else {
            print("❌ No se pudo obtener la ruta para guardar records.plist")
            return
        }
        
        do {
            let data = try PropertyListSerialization.data(fromPropertyList: records, format: .xml, options: 0)
            try data.write(to: url)
            print("✅ Datos guardados correctamente en: \(url.path)")
            mostrarRutaPlist() // ✅ Verifica la ruta después de guardar
        } catch {
            print("❌ Error al guardar records.plist: \(error)")
        }
    }
    // ✅ Copiar records.plist desde el Bundle si no existe en Document Directory
    func copiarPlistSiEsNecesario() {
        let fileManager = FileManager.default
        guard let urlDestino = obtenerRutaPlist(),
              !fileManager.fileExists(atPath: urlDestino.path) else {
            return
        }
        
        // Obtener ruta del plist en el Bundle
        if let urlOrigen = Bundle.main.url(forResource: "records", withExtension: "plist") {
            do {
                try fileManager.copyItem(at: urlOrigen, to: urlDestino)
                print("✅ records.plist copiado correctamente a Document Directory")
            } catch {
                print("❌ Error al copiar records.plist: \(error)")
            }
        } else {
            print("❌ No se encontró records.plist en el Bundle")
        }
    }
    
    // MARK: - CALCULAR PUNTAJE
    func calcularPuntaje(palabra: String, tiempo: Int, errores: Int) -> Int {
        var puntaje = 0
        
        // Puntos base por longitud
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
        
        // Bonificación por errores
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
        
        // Bonificación por tiempo
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
