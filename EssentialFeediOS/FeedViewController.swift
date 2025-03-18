//
//  FeedViewController.swift
//  
//
//  Created by Gowtham Namuru on 18/03/25.
//

import UIKit
import LeadEssentialFeed

final public class FeedViewController: UITableViewController {
    private var viewIsAppearing: ((FeedViewController) -> Void)?
    private var loader: FeedLoader?
    public convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        viewIsAppearing = { vc in
            vc.load()

            vc.viewIsAppearing = nil
        }
    }

    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)

        viewIsAppearing?(self)
    }

    @objc private func load() {
        refreshControl?.beginRefreshing()
        loader?.load { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
}
