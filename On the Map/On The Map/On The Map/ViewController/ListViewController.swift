//
//  ListViewController.swift
//  On The Map
//
//  Created by Alireza Jazzb on 10/22/18.
//  Copyright © 2018 JazzB. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController {
    /*
    SUGGESTION
    If there is no data, I encourage you to show No Data Found text or an Empty Icon on the TableView. Check out this article
    
    www.benmeline.com/ios-empty-table-view-with-swift/
    */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Reload table data
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentDataSource.sharedInstance.studentLocations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get cell type
        let listCell = tableView.dequeueReusableCell(withIdentifier: ParseClient.StoryBoardIdentifiers.listCellReuseIdentifier) as UITableViewCell?
        
        // Setup cell
        listCell?.textLabel?.text = "\(StudentDataSource.sharedInstance.studentLocations[indexPath.row].firstName) \(StudentDataSource.sharedInstance.studentLocations[indexPath.row].lastName)"
        listCell?.detailTextLabel?.text = "\(StudentDataSource.sharedInstance.studentLocations[indexPath.row].mapString)"
        
        return listCell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect row:
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let mediaURL = URL(string: StudentDataSource.sharedInstance.studentLocations[indexPath.row].mediaURL), UIApplication.shared.canOpenURL(mediaURL) {
            UIApplication.shared.open(mediaURL, options: [:], completionHandler: nil)
        } else {
            showAlert(viewController: self, title: ParseClient.ErrorStrings.error, message: "This student location contains no valid URL to display", actionTitle: ParseClient.ErrorStrings.dismiss)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ParseClient.ListViewConstante.tableDefaultHeight
    }
    
    // MARK: TableViewVC singleton shared instance
    class func sharedInstance () -> ListViewController {
        struct Singleton {
            static let sharedInstance = ListViewController()
        }
        return Singleton.sharedInstance
    }
}
