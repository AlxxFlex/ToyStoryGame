//
//  RecordsViewController.swift
//  ToyStoryGame
//
//  Created by Aaron Alejandro Martinez Solis on 26/03/25.
//

import UIKit

class RecordsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    
    var records: [[String: Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        copiarPlistSiEsNecesario()
        records = cargarRecords()
        tableView.delegate = self
        tableView.dataSource = self
        configurarTabla()
    }
    
    func configurarTabla() {
        tableView.backgroundColor = UIColor.darkGray
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
    }
    func obtenerRutaPlist() -> URL? {
        
        if let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("records.plist") {
            return path
        }
        return nil
    }
    func copiarPlistSiEsNecesario() {
            let fileManager = FileManager.default
            guard let urlDestino = obtenerRutaPlist() else {
                print("No se pudo obtener la ruta del plist para copiarlo.")
                return
            }
            if fileManager.fileExists(atPath: urlDestino.path) {
                print("records.plist ya existe en Document Directory.")
                return
            }
            if let urlOrigen = Bundle.main.url(forResource: "records", withExtension: "plist") {
                do {
                    try fileManager.copyItem(at: urlOrigen, to: urlDestino)
                    print("records.plist copiado correctamente a Document Directory.")
                } catch {
                    print("Error al copiar records.plist: \(error.localizedDescription)")
                }
            } else {
                print("No se encontró records.plist en el Bundle.")
            }
        }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(records.count, 5)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "RecordCell")
        
        let record = records[indexPath.row]
        let nombre = record["nombre"] as? String ?? "Desconocido"
        let puntaje = record["puntaje"] as? Int ?? 0
        
        
        cell.textLabel?.text = "\(indexPath.row + 1). \(nombre)"
        cell.detailTextLabel?.text = "Puntaje: \(puntaje)"
        
        
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 22)
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.textAlignment = .center
        
        
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 18)
        cell.detailTextLabel?.textColor = UIColor.lightGray
        cell.detailTextLabel?.textAlignment = .center
        
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.darkGray
        bgColorView.layer.masksToBounds = true
        cell.backgroundView = bgColorView
        
        
        cell.contentView.layer.borderColor = UIColor.darkGray.cgColor
        cell.contentView.layer.borderWidth = 0
        cell.contentView.layer.cornerRadius = 0
        cell.contentView.backgroundColor = UIColor.darkGray
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
    func cargarRecords() -> [[String: Any]] {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("records.plist"),
              let data = FileManager.default.contents(atPath: url.path) else {
            print("No se encontró records.plist")
            return []
        }
        
        do {
            if let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [[String: Any]] {
                
                return plist.sorted { ($0["puntaje"] as? Int ?? 0) > ($1["puntaje"] as? Int ?? 0) }
            }
        } catch {
            print("Error al leer records.plist: \(error)")
        }
        
        return []
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        records = cargarRecords()
        tableView.reloadData()
    }
}
