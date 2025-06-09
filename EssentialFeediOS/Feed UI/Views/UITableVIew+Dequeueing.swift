//
//  UITableVIew+Dequeueing.swift
//  EssentialFeediOS
//
//  Created by Gowtham Namuru on 09/06/25.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
