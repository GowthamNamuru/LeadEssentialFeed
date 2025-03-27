//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Gowtham Namuru on 27/03/25.
//

import UIKit
import LeadEssentialFeed

final class FeedImageViewModel {
    private var model: FeedImage
    private var imageLoader: FeedImageDataLoader
    private var task: FeedImageDataLoaderTask?

    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }

    var description: String? {
        model.description
    }

    var location: String? {
        model.location
    }

    var hasLocation: Bool {
        model.location != nil
    }

    var onImageLoad: ((UIImage) -> Void)?
    var onImageLoadingStateChange: ((Bool) -> Void)?
    var onShouldRetryImageLoadStateChange: ((Bool) -> Void)?

    func loadImageData() {
        onImageLoadingStateChange?(true)
        onShouldRetryImageLoadStateChange?(false)
        task = imageLoader.loadImageData(from: model.url, completion: { [weak self] result in
            if let image = (try? result.get()).flatMap(UIImage.init) {
                self?.onImageLoad?(image)
            } else {
                self?.onShouldRetryImageLoadStateChange?(true)
            }
            self?.onImageLoadingStateChange?(false)
        })
    }

    func cancelImageDataLoad() {
        task?.cancel()
        task = nil
    }
}
