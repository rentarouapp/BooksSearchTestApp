//
//  StoreTableViewController.swift
//  BookSearchMoyaMap
//
//  Created by uejo on 2020/05/08.
//  Copyright © 2020 uejo. All rights reserved.
//

import UIKit
import MapKit

extension MKPlacemark {
    var address: String {
        let components = [self.administrativeArea, self.locality, self.thoroughfare, self.subThoroughfare]
        return components.compactMap { $0 }.joined(separator: "")
    }
}

struct Map {
    enum Result<T> {
        case success(T)
        case failure(Error)
    }
    
    static func search(query: String, region: MKCoordinateRegion? = nil, completionHandler: @escaping (Result<[MKMapItem]>) -> Void) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        if let region = region {
            request.region = region
        }
        
        MKLocalSearch(request: request).start { (response, error) in
            if let error = error {
                completionHandler(.failure(error))
                return
            }
            
            completionHandler(.success(response?.mapItems ?? []))
        }
    }
    
}

class StoreTableViewController: UITableViewController {
    
    var longitude: Double?
    var latitude: Double?
    
    var basho = [String]()
    var jusho = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = 120
        
            let coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
            let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000.0, longitudinalMeters: 1000.0)
            
            Map.search(query: "本屋", region: region) { (result) in
                switch result {
                case .success(let mapItems):
                    
                for map in mapItems {
                        print("name: \(map.name ?? "no name")")
                        self.basho.append(map.name!)
                        print("coodinate: \(map.placemark.coordinate.latitude) \(map.placemark.coordinate.latitude)")
                        print("address \(map.placemark.address)")
                        self.jusho.append(map.placemark.address)
                    }
                    
                case .failure(let error):
                    print("error \(error.localizedDescription)")
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.basho.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "storeCell", for: indexPath) as? StoreTableViewCell else {
            return UITableViewCell()
        }
        
        cell.storeNameLabel.text = "\(self.basho[indexPath.row])"
        cell.placeLabel.text = "\(self.jusho[indexPath.row])"

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
