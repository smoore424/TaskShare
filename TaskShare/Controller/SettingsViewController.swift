//
//  SettingsViewController.swift
//  TaskShare
//
//  Created by Stacey Moore on 9/30/21.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var saveButton: TSButton!
    
    let colors = Colors.shared
    
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.set(backgroundColor: colors.getCurrentColor(), title: "Save")
        colors.setSelectedColor()
        setColors()
        setCollectionView()
    }
    
    
    //MARK: - Save Button
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        defaults.set(colors.selectedColorIndex, forKey: "color")
        colors.setSelectedColor()
        self.tabBarController?.tabBar.tintColor = colors.getCurrentColor()
        //call snack
        self.presentSnackOnMainThread(message: "Theme Saved", image: UIImage(systemName: "checkmark.circle")!)
    }
}


//MARK: - Setting the View
extension SettingsViewController {
    
    func setCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 44, height: 44)
        collectionView.collectionViewLayout = layout
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MyCell.nib(), forCellWithReuseIdentifier: MyCell.identifier)
        collectionView.selectItem(at: IndexPath(item: colors.selectedColorIndex, section: 0), animated: true, scrollPosition: .bottom)
    }
    
    
    func setColors() {
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: colors.getCurrentColor()]
        saveButton.backgroundColor = colors.getCurrentColor()
        saveButton.tintColor = .white
    }
}


//MARK: - CollectionView DataSource
extension SettingsViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.colorOptions.count
    }
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCell.identifier, for: indexPath) as! MyCell
        cell.tintColor = colors.colorOptions[indexPath.item]
        
        return cell
    }
}


//MARK: - CollectionView Delegate
extension SettingsViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if let cell = collectionView.cellForItem(at: indexPath) as? MyCell {
            cell.showSelection()
        }
        colors.selectedColorIndex = indexPath.item
        setColors()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? MyCell {
            cell.hideSelection()
        }
    }
}
