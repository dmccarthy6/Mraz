//  Created by Dylan  on 5/1/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit
import MapKit

enum Alerts {
    // MARK: - Types
    /// These are used for our Message Title's & Alerts
    enum AlertMessage: String {
        case userNotLoggedIn = "Log into iCloud to receive beer updates and get current on tap beers. \n \n Tap 'Settings' below -> 'Sign in to your iPhone' -> Enter your Apple ID and password."
    }
    
    enum AlertTitle: String {
        case iCloudError = "iCloud"
    }
    
    // MARK: - Properties
    static fileprivate var mrazSettings: MrazSettings {
        return MrazSettings()
    }
    static private var suppressCloudKitEnabledError: Bool {
        return mrazSettings.readBool(for: .suppressCloudKitError)
    }
    
    // MARK: - CloudKit Alerts
   /// CloudKit Action Sheet called in View Controller Extension
    static func buildCloudKitAlertController(with title: AlertTitle, message: AlertMessage, popoverDelegate: UIPopoverPresentationControllerDelegate) -> UIAlertController? {
        if !suppressCloudKitEnabledError {
            let alertController = UIAlertController(title: title.rawValue,
                                                    message: message.rawValue,
                                                    preferredStyle: .actionSheet)
            // Open settings to toggle CloudKit
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) in
                guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
                let userCanOpenSettings = UIApplication.shared.canOpenURL(settingsURL)
                if userCanOpenSettings {
                    UIApplication.shared.open(settingsURL, options: [:]) { (success) in
                        if success { print("User opened settings") }
                    }
                }
            }
            /// Don't Show Again Action
            let dontShowAgainButton = CloudKitPromptButtonType.dontShowAgain
            let dontShowAgainAction = UIAlertAction(title: dontShowAgainButton.rawValue,
                                                    style: dontShowAgainButton.actionStyle()) { (_) in
                dontShowAgainButton.performAction()
            }
            
            alertController.addAction(settingsAction)
            alertController.addAction(dontShowAgainAction)
            
            if let popoverController = alertController.popoverPresentationController {
                popoverController.delegate = popoverDelegate
                
            }
            return alertController
        }
        return nil
    }
    
    static func cloudKitErrorAlert(_ error: CloudKitStatusError) {
        let alertController = UIAlertController(title: "iCloud Error",
                                                message: error.localizedDescription,
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        if let appDel = UIApplication.shared.delegate,
            let window = appDel.window!,
            let rootVC = window.rootViewController {
            rootVC.present(alertController, animated: true, completion: nil)
        }
    }
    
    /// Action sheet presented when the user taps a MKAnnotation on the Map Screen.
    static func showRestaurantActionSheet(_ viewController: UIViewController,
                                          location: CLLocationCoordinate2D,
                                          title: String?,
                                          annotation: MKAnnotationView) {
        let actionSheet = UIAlertController(title: nil,
                                            message: nil,
                                            preferredStyle: .actionSheet)
        
        let directionsAction = UIAlertAction(title: "Directions", style: .default) { (_) in
            Contact.contact(contactType: .directions, value: title ?? "", coordinate: location)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        actionSheet.addAction(directionsAction)
        actionSheet.addAction(cancelAction)
        if let alertPopover = actionSheet.popoverPresentationController {
            alertPopover.sourceView = annotation
        }
        viewController.present(actionSheet, animated: true, completion: nil)
    }
    
}

//CloudKit Button Type
enum CloudKitPromptButtonType: String {
    case okButton = "OK"
    case dontShowAgain = "Don't Show Again"
    
    private var mrazSettings: MrazSettings {
        return MrazSettings()
    }
    
    func performAction() {
        switch self {
        case .okButton: break
        case .dontShowAgain: mrazSettings.set(true, for: .suppressCloudKitError)
        }
    }
    
    func actionStyle() -> UIAlertAction.Style {
        switch self {
        case .dontShowAgain: return .destructive
        default: return .default
        }
    }
}
