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
        if let searchText = self.searchText {
            container?.performBackgroundTask { [weak self] (context) in
                /*** One by one tweet loading -- inefficient
                for tweetInfo in newTweets {
                    _ = try? Tweet.findOrCreateTweet(matching: tweetInfo, with: searchText, in: context)
                }
                ***/
                try? Tweet.createNotExistingTweets(from: newTweets, with: searchText, in: context)
                
                try? context.save()
                self?.printDBStatistics()
            }
        }
    }
    
    private func printDBStatistics() {
        if let context = container?.viewContext {
            context.perform {
                if let tweetCount = try? context.count(for: Tweet.fetchRequest()) {
                    print("\(tweetCount) tweets")
                }
                if let mentionCount = try? context.count(for: Mention.fetchRequest()) {
                    print("\(mentionCount) mentions")
                }
            }
        }
    }

}
