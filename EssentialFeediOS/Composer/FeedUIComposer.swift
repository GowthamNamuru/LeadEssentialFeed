//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Gowtham Namuru on 24/03/25.
//

import LeadEssentialFeed

final public class FeedUIComposer {
    private init() {}

    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let viewModel = FeedViewModel(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(viewModel: viewModel)
        let feedController = FeedViewController(refreshController: refreshController)
        viewModel.onFeedLoad = adaptFeedImageToFeedImageCellController(forwardingTo: feedController, loader: imageLoader)
        return feedController
    }

    private static func adaptFeedImageToFeedImageCellController(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> (([FeedImage]) -> Void) {
        return { [weak controller] feed in
            controller?.tableModel = feed.map { model in
                FeedImageCellController(model: model, imageLoader: loader)
            }
        }
    }
}
