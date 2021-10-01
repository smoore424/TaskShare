//
//  MyCell.swift
//  TaskShare
//
//  Created by Stacey Moore on 9/30/21.
//

import UIKit

class MyCell: UICollectionViewCell {

    @IBOutlet var imageView: UIImageView!
    
    static let identifier = "MyCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let unselectedView = UIImageView(frame: bounds)
        unselectedView.image = UIImage(systemName: "circle.fill")
        self.backgroundView = unselectedView
        
        let selectedView = UIImageView(frame: bounds)
        selectedView.image = UIImage(systemName: "smallcircle.fill.circle.fill")
        selectedView.backgroundColor = .systemBackground
        self.selectedBackgroundView = selectedView
    }

    func showSelection() {
        imageView.alpha = 1.0
    }
    
    func hideSelection() {
        imageView.alpha = 0.0
    }
    
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

}

