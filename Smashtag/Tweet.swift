//
//  Tweet.swift
//  Smashtag
//
//  Created by Olivier van den Biggelaar on 24/07/2017.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit
import CoreData
import Twitter

class Tweet: NSManagedObject {

    class func findOrCreateTweet(matching tweetInfo: Twitter.Tweet,
                                 with searchTerm: String,
                                 in context: NSManagedObjectContext) throws -> Tweet
    {
        let request: NSFetchRequest<Tweet> = Tweet.fetchRequest()
        request.predicate = NSPredicate(format: "unique = %@ AND searchTerm =[c] %@",
                                        tweetInfo.identifier,
                                        searchTerm)
        
        let matches = try context.fetch(request)
        if matches.count > 0 {
            assert(matches.count == 1, "Tweet.findOrCreateTweet -- database inconsistency")
            return matches[0]
        }
        
        return try createTweet(matching: tweetInfo, with: searchTerm, in: context)
    }
    
    class func createNotExistingTweets(from newTweets: [Twitter.Tweet],
                                       with searchTerm: String,
                                       in context: NSManagedObjectContext) throws
    {
        let newTweetIds = newTweets.map { $0.identifier }
        let request: NSFetchRequest<Tweet> = Tweet.fetchRequest()
        request.predicate = NSPredicate(format: "searchTerm = %@ AND unique IN %@",
                                        searchTerm, newTweetIds)
        let existingTweetIds = try context.fetch(request).map { $0.unique }

        for tweet in newTweets {
            if !existingTweetIds.contains(where: { $0 == tweet.identifier } ) {
                _ = try createTweet(matching: tweet, with: searchTerm, in: context)
            }
        }
    }
    
    private class func createTweet(matching tweetInfo: Twitter.Tweet,
                             with searchTerm: String,
                             in context: NSManagedObjectContext) throws -> Tweet
    {
        let tweet = Tweet(context: context)
        tweet.unique = tweetInfo.identifier
        tweet.searchTerm = searchTerm.lowercased()
        let mentionKeywords = (tweetInfo.hashtags + tweetInfo.userMentions).map { $0.keyword }
        for mentionKeyword in mentionKeywords {
            _ = try Mention.updateOrCreateMention(for: tweet,
                                                  withKeyword: mentionKeyword,
                                                  andSearchTerm: searchTerm,
                                                  in: context)
        }
        return tweet
    }
    
    override func prepareForDeletion() {
        if let mentions = mentions as? Set<Mention> {
            for mention in mentions {
                mention.count -= 1
                if let mentionTweets = mention.tweets as? Set<Tweet> {
                    if mentionTweets.filter({ !$0.isDeleted }).isEmpty {
                        self.managedObjectContext?.delete(mention)
                    }
                }
            }
        }
    }
    
    class func deleteOldTweets(in context: NSManagedObjectContext) throws {
        // We will delete all tweets for searchTerms that are no longer in RecentSearches.searches
        let request: NSFetchRequest<Tweet> = Tweet.fetchRequest()
        let searchTermsToKeep = RecentSearches.searches.map { $0.lowercased() }
        request.predicate = NSPredicate(format: "NOT(searchTerm IN %@)", searchTermsToKeep)
        if let tweetsToDelete = try? context.fetch(request) {
            for tweet in tweetsToDelete {
                context.delete(tweet)
            }
            print("Deleted \(tweetsToDelete.count) old tweet(s)")
            try context.save()
        }
    }
    
}
