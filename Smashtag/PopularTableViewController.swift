//
//  PopularTableViewController.swift
//  Smashtag
//
//  Created by Olivier van den Biggelaar on 24/07/2017.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit
import CoreData

class PopularTableViewController: FetchedResultsTableViewController {

    var searchTerm: String? { didSet { updateUI() } }
    var container: NSPersistentContainer?
        = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
        { didSet { updateUI() } }
    
    private func updateUI() {
        if let searchTerm = searchTerm {
            title = "Popular mentions for \(searchTerm)"
        }
    }
    
    private struct StoryboardIdentifiers {
        static let popularMentionCell = "Popular Mention Cell"
    }
    
    var fetchedResultsController: NSFetchedResultsController<Mention>?
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StoryboardIdentifiers.popularMentionCell, for: indexPath)
        
        if let mention = fetchedResultsController?.object(at: indexPath) {
            cell.textLabel?.text = mention.keyword
            cell.detailTextLabel?.text = "\(mention.count) tweet\((mention.count > 1 ? "s" : ""))"
        }
        
        return cell
    }

}
