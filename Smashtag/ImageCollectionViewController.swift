//
//  ImageCollectionViewController.swift
//  Smashtag
//
//  Created by Olivier van den Biggelaar on 20/07/2017.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit
import Twitter

class Cache: NSCache<NSURL, NSData> {
    subscript(key: URL) -> Data? {
        get {
            return object(forKey: key as NSURL) as Data?
        }
        set {
            if let data = newValue {
                setObject(data as NSData, forKey: key as NSURL,
                          cost: data.count / 1024)
            } else {
                removeObject(forKey: key as NSURL)
            }
        }
    }
}

class ImageCollectionViewController: UICollectionViewController {

    fileprivate struct TweetMedia {
        let tweet: Twitter.Tweet
        let media: Twitter.MediaItem
    }
    
    // Public API
    var tweets = [Tweet]() {
        didSet {
            tweetMedias = tweets.flatMap { tweet in
                tweet.media.map { TweetMedia(tweet: tweet, media: $0) }
            }
        }
    }
    
    fileprivate var tweetMedias = [TweetMedia]()
    private let cache = Cache()
    
    // MARK: - Layout & Gesture
    
    var scale: CGFloat = 1 {
        didSet {
            collectionView?.collectionViewLayout.invalidateLayout()
        }
    }
    
    func zoom(_ gesture: UIPinchGestureRecognizer) {
        if gesture.state == .changed {
            scale *= gesture.scale
            gesture.scale = 1.0
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupLayout()
    }
    private var layoutFlow = UICollectionViewFlowLayout()
    private func setupLayout() {
        // FlowLayout
        layoutFlow.minimumInteritemSpacing = Constants.minimumInteritemSpacing
        layoutFlow.minimumLineSpacing = Constants.minimumLineSpacing
        layoutFlow.sectionInset = Constants.sectionInset
        layoutFlow.itemSize = predefinedSize
        
        collectionView?.collectionViewLayout = layoutFlow
    }
    fileprivate var predefinedSize: CGSize {
        return CGSize(width: predefinedWidth, height: predefinedWidth)
    }
    fileprivate var predefinedWidth: CGFloat {
        return ((collectionView?.bounds.width)! -
            Constants.minimumInteritemSpacing * (Constants.columnCountFlowLayout - 1.0) -
            Constants.sectionInsetThickness * 2.0) / Constants.columnCountFlowLayout
    }

    fileprivate struct Constants {
        static let columnCountFlowLayout: CGFloat = 3
        
        static let minimumLineSpacing: CGFloat = 2
        static let minimumInteritemSpacing: CGFloat = 2
        static let sectionInsetThickness: CGFloat = 2
        static let sectionInset = UIEdgeInsets(
            top: sectionInsetThickness,
            left: sectionInsetThickness,
            bottom: sectionInsetThickness,
            right: sectionInsetThickness
        )
        static let minItemWidth: CGFloat = 60
    }
    
    private struct StoryboardIdentifiers {
        static let imageCell = "Image Cell"
        static let showTweetSegue = "Show Tweet"
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.addGestureRecognizer(
            UIPinchGestureRecognizer(target: self,
                                     action: #selector(ImageCollectionViewController.zoom(_:))
            )
        )
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardIdentifiers.showTweetSegue,
            let tweetTVC = segue.destination as? TweetTableViewController,
            let cell = sender as? UICollectionViewCell,
            let index = collectionView?.indexPath(for: cell)?.row {
            tweetTVC.insertTweets([tweetMedias[index].tweet])
        }
    }
 

    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return tweetMedias.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoryboardIdentifiers.imageCell, for: indexPath)
        if let imageCell = cell as? ImageCollectionViewCell {
            imageCell.imageURL = tweetMedias[indexPath.row].media.url
            imageCell.cache = cache
        }
        return cell
    }

}

// MARK: UICollectionViewDelegateFlowLayout

extension ImageCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let predefinedArea = predefinedWidth * predefinedWidth * scale
        let aspect = CGFloat(tweetMedias[indexPath.row].media.aspectRatio)
        let maxItemWidth = collectionView.bounds.width - 2 * Constants.sectionInsetThickness
        let itemWidth = min(max(sqrt(predefinedArea * aspect), Constants.minItemWidth), maxItemWidth)
        let itemHeight = itemWidth / aspect
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
}
