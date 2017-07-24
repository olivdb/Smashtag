//
//  MentionTableViewController.swift
//  Smashtag
//
//  Created by Olivier van den Biggelaar on 19/07/2017.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit
import Twitter
import SafariServices

class MentionTableViewController: UITableViewController {
    
    var tweet: Twitter.Tweet? {
        didSet {
            title = tweet?.user.name
            initMentionSections()
            tableView.reloadData()
        }
    }
    
    @IBAction func toRootViewController(_ sender: UIBarButtonItem) {
        navigationController?.popToRootViewController(animated: true)
    }

    
    private func initMentionSections() {
        mentionSections = []
        guard let tweet = tweet else { return }
        if !tweet.media.isEmpty {
            let mentions = tweet.media.map { MentionItem.image($0.url, $0.aspectRatio) }
            mentionSections.append(MentionSection(title: SectionTitles.images, mentions: mentions))
        }
        if !tweet.hashtags.isEmpty {
            let mentions = tweet.hashtags.map { MentionItem.keyword($0.keyword) }
            mentionSections.append(MentionSection(title: SectionTitles.hashtags, mentions: mentions))
        }
        var mentions = [MentionItem.keyword("@\(tweet.user.screenName)")]
        if !tweet.userMentions.isEmpty {
            mentions += tweet.userMentions.map { MentionItem.keyword($0.keyword) }
        }
        mentionSections.append(MentionSection(title: SectionTitles.users, mentions: mentions))
        if !tweet.urls.isEmpty {
            let mentions = tweet.urls.map { MentionItem.keyword($0.keyword) }
            mentionSections.append(MentionSection(title: SectionTitles.urls, mentions: mentions))
        }
    }
    
    private struct MentionSection {
        let title: String
        let mentions: [MentionItem]
    }
    private enum MentionItem {
        case image(URL, Double)
        case keyword(String)
    }
    private var mentionSections = [MentionSection]()
    private struct SectionTitles {
        static let images = "Images"
        static let hashtags = "Hashtags"
        static let users = "User Mentions"
        static let urls = "URLs"
    }
    private struct StoryboardIdentifiers {
        static let imageCell = "Image"
        static let keywordCell = "Mention"
        
        static let searchMentionSegue = "Search Mention"
        static let showImageSegue = "Show Image"
        static let showWebViewSegue = "Show Web View"
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return mentionSections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mentionSections[section].mentions.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return mentionSections[section].title
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch mentionSections[indexPath.section].mentions[indexPath.row] {
        case .image(let url, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: StoryboardIdentifiers.imageCell, for: indexPath)
            if let imageCell = cell as? ImageTableViewCell {
                imageCell.imageURL = url
            }
            return cell
        case .keyword(let text):
            let cell = tableView.dequeueReusableCell(withIdentifier: StoryboardIdentifiers.keywordCell, for: indexPath)
            cell.textLabel?.text = text
            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch mentionSections[indexPath.section].mentions[indexPath.row] {
        case .image(_, let aspectRatio):
            return tableView.bounds.width / CGFloat(aspectRatio)
        case .keyword(_):
            return UITableViewAutomaticDimension
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == StoryboardIdentifiers.searchMentionSegue,
            let tvCell = sender as? UITableViewCell,
            let searchVC = segue.destination as? TweetTableViewController,
            let keyword = tvCell.textLabel?.text {
            searchVC.searchText = keyword
        } else if segue.identifier == StoryboardIdentifiers.showImageSegue,
            let itvCell = sender as? ImageTableViewCell,
            let iVC = segue.destination as? ImageViewController {
            iVC.imageURL = itvCell.imageURL
        } else if segue.identifier == StoryboardIdentifiers.showWebViewSegue,
            let tvCell = sender as? UITableViewCell,
            let webVC = segue.destination as? WebViewController,
            let urlString = tvCell.textLabel?.text {
            webVC.url = URL(string: urlString)
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == StoryboardIdentifiers.searchMentionSegue,
            let tvCell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: tvCell) {
            if mentionSections[indexPath.section].title == SectionTitles.urls {
                performSegue(withIdentifier: StoryboardIdentifiers.showWebViewSegue, sender: sender)
                return false
            }
        }
        return true
    }
 
    /*override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if mentionSections[indexPath.section].title == SectionTitles.urls,
            case let .keyword(stringURL) = mentionSections[indexPath.section].mentions[indexPath.row],
            let url = URL(string: stringURL) {
            /*
             if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
            */
            /*
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true)
            */
        }
    }*/
}
