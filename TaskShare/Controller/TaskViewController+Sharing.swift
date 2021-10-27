//
//  TaskViewController+Sharing.swift
//  TaskShare
//
//  Created by Stacey Moore on 10/23/21.
//

import CloudKit
import CoreData
import UIKit

extension TaskViewController: UICloudSharingControllerDelegate {

    @objc func shareGroup() {
        
        guard let group = self.selectedGroup else { fatalError("Cannot share without a group")}
        
        let container = CoreDataHelper.shared.persistentContainer
        
        let cloudSharingController = UICloudSharingController {
            (controller, completion: @escaping (CKShare?, CKContainer?, Error?) -> Void) in
            container.share([group], to: nil) { objectIDs, share, container, error in
                if let actualShare = share {
                    group.managedObjectContext?.performAndWait {
                        actualShare[CKShare.SystemFieldKey.title] = group.title
                        
                    }
                }
                completion(share, container, error)
            }
        }
        cloudSharingController.delegate = self
        
       present(cloudSharingController, animated: true)
    }
    
    func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
        fatalError("Failed to save share \(error)")
    }
    
    func itemTitle(for csc: UICloudSharingController) -> String? {
        guard let title = selectedGroup?.title else {
            return ""
        }
        return title
    }
}
