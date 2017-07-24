//
//  SmashTweetTableViewController.swift
//  Smashtag
//
//  Created by Olivier van den Biggelaar on 24/07/2017.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit
import Twitter
import CoreData

class SmashTweetTableViewController: TweetTableViewController {

    var container: NSPersistentContainer? =
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    override func insertTweets(_ newTweets: [Twitter.Tweet]) {
        super.insertTweets(newTweets)
        updateDatabase(with: newTweets)
    }
    
    private func updateDatabase(with newTweets: [Twitter.Tweet]) {
        
    }

}
