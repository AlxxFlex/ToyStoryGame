//
//  NewRecordViewController.swift
//  ToyStoryGame
//
//  Created by Aaron Alejandro Martinez Solis on 27/03/25.
//

import UIKit

class NewRecordViewController: UIViewController {

    @IBOutlet weak var txtNombre: UITextField!
    var puntajeNuevo: Int?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func BtnGuardarRecord(_ sender: Any) {guard let nombre = txtNombre.text, !nombre.isEmpty, let puntaje = puntajeNuevo else { return }
            // Cargar récords actuales
            var records = cargarRecords()

            // Agregar nuevo récord
            let nuevoRecord: [String: Any] = ["nombre": nombre, "puntaje": puntaje]
            records.append(nuevoRecord)

            // Ordenar y limitar a top 5
            records.sort { ($0["puntaje"] as? Int ?? 0) > ($1["puntaje"] as? Int ?? 0) }
            if records.count > 5 {
                records.removeLast()
            }

            // Guardar en el plist
            guardarRecords(records)
            
            // ✅ Regresar al menú después de guardar récord
            irMenu()
        }
    // Copia estas funciones en NewRecordViewController.swift
    func cargarRecords() -> [[String: Any]] {
        guard let path = Bundle.main.path(forResource: "records", ofType: "plist"),
              let data = FileManager.default.contents(atPath: path) else { return [] }
        do {
            if let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [[String: Any]] {
                return plist
            }
        } catch {
            print("Error al leer records.plist: \(error)")
        }
        return []
    }

    func guardarRecords(_ records: [[String: Any]]) {
        guard let path = Bundle.main.path(forResource: "records", ofType: "plist") else { return }
        do {
            let data = try PropertyListSerialization.data(fromPropertyList: records, format: .xml, options: 0)
            try data.write(to: URL(fileURLWithPath: path))
        } catch {
            print("Error al guardar records.plist: \(error)")
        }
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
