//
//  UIImageView+Animations.swift
//  EssentialFeediOS
//
//  Created by Gowtham Namuru on 09/06/25.
//

import UIKit

extension UIImageView {
    func setImageAnimated(_ newImage: UIImage?) {
        image = newImage
        guard newImage != nil else {
            return
        }

        alpha = 0
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
}
