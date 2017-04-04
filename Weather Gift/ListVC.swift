//
//  ListVC.swift
//  Weather Gift
//
//  Created by John Gallaugher on 2/11/17.
//  Copyright © 2017 Gallaugher. All rights reserved.
//

import UIKit
import GooglePlaces

class ListVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    
    
    var locationsArray = [WeatherLocation]()
    var currentPage = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToPageVC" {
            let controller = segue.destination as! PageVC
            currentPage = (tableView.indexPathForSelectedRow?.row)!
            controller.currentPage = currentPage
            controller.locationsArray = locationsArray
        }
    }
    
    // MARK: - IBActions
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        if tableView.isEditing == true {
            tableView.setEditing(false, animated: true)
            editBarButton.title = "Edit"
            addBarButton.isEnabled = true
        } else {
            tableView.setEditing(true, animated: true)
            editBarButton.title = "Done"
            addBarButton.isEnabled = false
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    // MARK: - UserDefaults
    
    func saveUserDefaults() {
        var locationsDefaultsArray = [WeatherUserDefault]()
        // The superclass locationsDefaultsArray takes only the subset of data in
        // the subclass locationsArray
        locationsDefaultsArray = locationsArray
        let locationsData = NSKeyedArchiver.archivedData(withRootObject: locationsDefaultsArray)
        UserDefaults.standard.set(locationsData, forKey: "locationsData")
    }
}

extension ListVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // The number of rows returned will be the count of the locationsArray
        return locationsArray.count
    }
    
    // Called each time the app needs to create a cell on screen
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get a reusable cell and fill it with data that should be on the screen
        // Make sure that the identifier below is the same as the one you added
        // in the cell's "Identity" property in the attribute inspector
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
        // Add data to the cell. Standard cells have an unseen textLabel object
        cell.textLabel?.text = locationsArray[indexPath.row].name
        // Return the properly updated cell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    // MARK:- tableView Editing Functions
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            locationsArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveUserDefaults()
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // First make a copy of the item that you are going to move
        let itemToMove = locationsArray[sourceIndexPath.row]
        // Delete item from teh original location (pre-move)
        locationsArray.remove(at: sourceIndexPath.row)
        // Insert item into the "to", post-move, location
        locationsArray.insert(itemToMove, at: destinationIndexPath.row)
        saveUserDefaults()
    }
    
    // MARK:- tableView Code to Freeze the First Cell. No deleting or moving
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return (indexPath.row == 0 ? false : true )
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 {
            return false
        } else {
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if proposedDestinationIndexPath.row == 0 {
            return sourceIndexPath
        } else {
            return proposedDestinationIndexPath
        }
    }
    
    func updateTable(place: GMSPlace) {
        let newLocation = WeatherLocation()
        newLocation.name = place.name
        let lat = place.coordinate.latitude
        let long = place.coordinate.longitude
        newLocation.coordinates = "\(lat),\(long)"
        locationsArray.append(newLocation)
        tableView.reloadData()
        saveUserDefaults()
    }
}

extension ListVC: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        dismiss(animated: true, completion: nil)
        updateTable(place: place)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
