//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Gowtham Namuru on 27/03/25.
//

import UIKit
import LeadEssentialFeed

final class FeedViewModel {

    typealias Observer<T> = (T) -> Void

    private var feedLoader: FeedLoader

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    var onLoadingStateChange: Observer<Bool>?
    var onFeedLoad: Observer<[FeedImage]>?

    func loadFeed() {
        onLoadingStateChange?(true)
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            self?.onLoadingStateChange?(false)
        }
    }
}
