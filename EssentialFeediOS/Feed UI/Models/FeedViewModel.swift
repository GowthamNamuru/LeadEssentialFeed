//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Gowtham Namuru on 27/03/25.
//

import UIKit
import LeadEssentialFeed

final class FeedViewModel {
    private var feedLoader: FeedLoader

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    var onChange: ((FeedViewModel) -> Void)?
    var onFeedLoad: (([FeedImage]) -> Void)?

    var isLoading: Bool = false {
        didSet {
            onChange?(self)
        }
    }


    func loadFeed() {
        isLoading = true
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            self?.isLoading = false
        }
    }
}
