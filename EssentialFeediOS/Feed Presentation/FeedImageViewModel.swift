//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Gowtham Namuru on 27/03/25.
//

//import UIKit
import LeadEssentialFeed

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool

    var hasLocation: Bool {
        location != nil
    }
}
