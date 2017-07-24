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
                                 for searchTerm: String,
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
}
