//
//  SnackBarVC.swift
//  TaskShare
//
//  Created by Stacey Moore on 10/27/21.
//

import UIKit

class SnackBarVC: UIViewController {

    let containerView = TSContainerView()
    let label = UILabel()
    let imageView = UIImageView()
    
    var snackMessage: String?
    var snackImage: UIImage?
    
    init(message: String, image: UIImage) {
        super.init(nibName: nil, bundle: nil)
        self.snackMessage = message
        self.snackImage = image
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureContainerView()
        configureImageView()
        configureLabel()
    }

    
    func configureContainerView() {
        view.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            containerView.heightAnchor.constraint(equalToConstant: 44),
            containerView.widthAnchor.constraint(equalToConstant: 160)
        ])
    }
    
    
    func configureImageView() {
        containerView.addSubview(imageView)
        
        imageView.clipsToBounds = true
        imageView.image = snackImage
        imageView.tintColor = .systemGreen
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            imageView.heightAnchor.constraint(equalToConstant: 20),
            imageView.widthAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func configureLabel() {
        containerView.addSubview(label)
        
        label.textAlignment = .left
        label.textColor = .label
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.text = snackMessage
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 5),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -5),
            label.heightAnchor.constraint(equalToConstant: 39)
            
        ])
    }
}
