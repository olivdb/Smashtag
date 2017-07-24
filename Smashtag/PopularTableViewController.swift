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
            if let context = container?.viewContext {
                let request: NSFetchRequest<Mention> = Mention.fetchRequest()
                request.sortDescriptors = [
                    NSSortDescriptor(key: "type", ascending: true),
                    NSSortDescriptor(key: "count", ascending: false),
                    NSSortDescriptor(key: "keyword", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
                request.predicate = NSPredicate(format: "searchTerm =[c] %@ AND count > 1", searchTerm)
                fetchedResultsController = NSFetchedResultsController(
                    fetchRequest: request,
                    managedObjectContext: context,
                    sectionNameKeyPath: "type",
                    cacheName: nil)
                fetchedResultsController?.delegate = self
                try? fetchedResultsController?.performFetch()
                tableView.reloadData()
            }
        }
    }
    
    private struct StoryboardIdentifiers {
        static let popularMentionCell = "Popular Mention Cell"
        static let searchMentionSegue = "Search Mention"
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardIdentifiers.searchMentionSegue,
            let cell = sender as? UITableViewCell,
            let tweetVC = segue.destination as? TweetTableViewController {
            tweetVC.searchText = cell.textLabel?.text
        }
    }

}
