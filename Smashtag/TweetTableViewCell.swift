//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by CS193p Instructor on 2/8/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewCell: UITableViewCell
{
    // outlets to the UI components in our Custom UITableViewCell
    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    @IBOutlet weak var tweetUserLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!

    // public API of this UITableViewCell subclass
    // each row in the table has its own instance of this class
    // and each instance will have its own tweet to show
    // as set by this var
    var tweet: Twitter.Tweet? { didSet { updateUI() } }
    
    // whenever our public API tweet is set
    // we just update our outlets using this method
    private func updateUI() {
        tweetTextLabel?.text = tweet?.text
        tweetUserLabel?.text = tweet?.user.description
        
        highlightMentions()
        
        if let profileImageURL = tweet?.user.profileImageURL {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let urlContent = try? Data(contentsOf: profileImageURL)
                if let imageData = urlContent, profileImageURL == self?.tweet?.user.profileImageURL {
                    DispatchQueue.main.async {
                        self?.tweetProfileImageView?.image = UIImage(data: imageData)
                    }
                }
            }
        } else {
            tweetProfileImageView?.image = nil
        }
        
        if let created = tweet?.created {
            let formatter = DateFormatter()
            if Date().timeIntervalSince(created) > 24*60*60 {
                formatter.dateStyle = .short
            } else {
                formatter.timeStyle = .short
            }
            tweetCreatedLabel?.text = formatter.string(from: created)
        } else {
            tweetCreatedLabel?.text = nil
        }
    }
    
    private func highlightMentions() {
        func paint(_ mentions: [Twitter.Mention]?, with color: UIColor) {
            if let mentions = mentions {
                for mention in mentions {
                    if let attributedText = tweetTextLabel?.attributedText {
                        let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
                        mutableAttributedText.addAttributes([NSForegroundColorAttributeName: color], range: mention.nsrange)
                        tweetTextLabel?.attributedText = mutableAttributedText
                    }
                }
            }
        }
        paint(tweet?.hashtags, with: UIColor.blue)
        paint(tweet?.urls, with: UIColor.red)
        paint(tweet?.userMentions, with: UIColor.purple)
    }
}
