//
//  Mention.swift
//  Smashtag
//
//  Created by Olivier van den Biggelaar on 24/07/2017.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit
import CoreData

class Mention: NSManagedObject {
    class func updateOrCreateMention(for tweet: Tweet,
                                     withKeyword keyword: String,
                                     andSearchTerm searchTerm: String,
                                     in context: NSManagedObjectContext) throws -> Mention
    {
        let request: NSFetchRequest<Mention> = Mention.fetchRequest()
        request.predicate = NSPredicate(format: "keyword =[c] %@ AND searchTerm =[c] %@",
                                        keyword,
                                        searchTerm)
        let matches = try context.fetch(request)
        
        if matches.count > 0 {
            assert(matches.count == 1, "updateOrCreateMention -- database inconsistency")
            let mention = matches[0]
            if let tweetsSet = mention.tweets as? Set<Tweet>, !tweetsSet.contains(tweet) {
                mention.addToTweets(tweet)
                mention.count += 1
            }
            return mention
        }
        
        let mention = Mention(context: context)
        mention.keyword = keyword.lowercased()
        mention.type = keyword.hasPrefix("#") ? "Hashtags" : "Users"
        mention.searchTerm = searchTerm.lowercased()
        mention.addToTweets(tweet)
        mention.count = 1
        return mention
    }
}
