//
//  NewRecordViewController.swift
//  ToyStoryGame
//
//  Created by Aaron Alejandro Martinez Solis on 27/03/25.
//

import UIKit

class NewRecordViewController: UIViewController {

    var completionHandler: (() -> Void)?
    @IBOutlet weak var txtNombre: UITextField!
    var puntajeNuevo: Int?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func BtnGuardarRecord(_ sender: Any) {guard let nombre = txtNombre.text, !nombre.isEmpty, let puntaje = puntajeNuevo else { return }
        
        var records = cargarRecords()
        let nuevoRecord: [String: Any] = ["nombre": nombre, "puntaje": puntaje]
        records.append(nuevoRecord)
        records.sort { ($0["puntaje"] as? Int ?? 0) > ($1["puntaje"] as? Int ?? 0) }
        if records.count > 5 {
            records.removeLast()
        }
        guardarRecords(records)
        if let juegoVC = presentingViewController as? JuegoViewController {
            if juegoVC.vidas == 0 {
                juegoVC.perdioAlHacerRecord = true
            } else {
                juegoVC.perdioAlHacerRecord = false
            }
            completionHandler?()
            if juegoVC.musicaActiva {
                juegoVC.backgroundMusicPlayer?.play()
            }
        }
        dismiss(animated: true, completion: nil)
    }
        
    func cargarRecords() -> [[String: Any]] {
        copiarPlistSiEsNecesario()
        
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
    func copiarPlistSiEsNecesario() {
        let fileManager = FileManager.default
        guard let urlDestino = obtenerRutaPlist(),
              !fileManager.fileExists(atPath: urlDestino.path) else {
            return
        }
        
        
        if let urlOrigen = Bundle.main.url(forResource: "records", withExtension: "plist") {
            do {
                try fileManager.copyItem(at: urlOrigen, to: urlDestino)
                print("records.plist copiado correctamente a Document Directory")
            } catch {
                print("Error al copiar records.plist: \(error)")
            }
        } else {
            print("No se encontró records.plist en el Bundle")
        }
    }

    func guardarRecords(_ records: [[String: Any]]) {
        guard let url = obtenerRutaPlist() else {
            print("No se pudo obtener la ruta para guardar records.plist")
            return
        }
        
        do {
            let data = try PropertyListSerialization.data(fromPropertyList: records, format: .xml, options: 0)
            try data.write(to: url)
            print(" Datos guardados correctamente en: \(url.path)")
        } catch {
            print(" Error al guardar records.plist: \(error)")
        }
    }
    func obtenerRutaPlist() -> URL? {
        
        if let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("records.plist") {
            return path
        }
        return nil
    }
    @objc func irMenu() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let menuVC = storyboard.instantiateViewController(withIdentifier: "MenuView")
        menuVC.modalPresentationStyle = .fullScreen
        present(menuVC, animated: true, completion: nil)
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
