//
//  SceneDelegate.swift
//  TaskShare
//
//  Created by Stacey Moore on 8/16/21.
//

import CloudKit
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    

    func sceneDidDisconnect(_ scene: UIScene) {}

    
    func sceneDidBecomeActive(_ scene: UIScene) {}

    
    func sceneWillResignActive(_ scene: UIScene) {}

    
    func sceneWillEnterForeground(_ scene: UIScene) {}

    
    func sceneDidEnterBackground(_ scene: UIScene) {

        //TODO: Create reference to saveContext in CoreDataHelper and call here.
//        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    

    func windowScene(_ windowScene: UIWindowScene, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        let sharedStore = CoreDataHelper.shared.sharedPersistentStore
        let container = CoreDataHelper.shared.persistentContainer

        container.acceptShareInvitations(from: [cloudKitShareMetadata], into: sharedStore, completion: nil)
    }
}

