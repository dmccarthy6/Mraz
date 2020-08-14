//  Created by Dylan  on 5/1/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit
import MapKit

enum Alerts {
    // MARK: - Types
    /// These are used for our Message Title's & Alerts
    enum AlertMessage: String {
        case genericErrorMessage = "Looks like something went wrong."
        case userDeniedNotifications = "This application works best when you allow notifications. To enable go into Settings -> Mraz -> Notifications and toggle 'Allow Notifications'"
        
        ///CloudKit Status Messages
        case available = "User is logged in"
        case noAccountOrCouldNotDetermine = "Could not find iCloud stats. Please try logging into iCloud again."
        case restricted = "Could not connect to iCloud. Looks like your settings are restricted"
    }
    
    enum AlertTitle: String {
        case genericErrorTitle = "Error"
        case iCloudError = "iCloud Error"
        case notificationsDenied = "Notifications Denied"
    }
    
    // MARK: - Properties
    static private var mrazSettings: MrazSettings {
        return MrazSettings()
    }
    static private var suppressCloudKitEnabledError: Bool {
        return mrazSettings.readBool(for: .suppressCloudKitError)
    }
    
    // MARK: - Generic Alerts
    static func showAlert(_ viewController: UIViewController,
                          title: AlertTitle,
                          message: AlertMessage) {
        let alertController = UIAlertController(title: title.rawValue,
                                                message: message.rawValue,
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - CloudKit Alerts
    static func cloudKitAlert(title: AlertTitle, message: AlertMessage) {
        if !suppressCloudKitEnabledError {
            DispatchQueue.main.async {
                let alertController = UIAlertController(title: title.rawValue,
                                                        message: message.rawValue,
                                                        preferredStyle: .alert)
                /// OK Button
                let okButton = CloudKitPromptButtonType.okButton
                let okButtonAction = UIAlertAction(title: okButton.rawValue,
                                                   style: okButton.actionStyle()) { (_) in
                    okButton.performAction()
                }
                /// Don't Show Again Action
                let dontShowAgainButton = CloudKitPromptButtonType.dontShowAgain
                let dontShowAgainAction = UIAlertAction(title: dontShowAgainButton.rawValue,
                                                        style: dontShowAgainButton.actionStyle()) { (_) in
                    dontShowAgainButton.performAction()
                }
                alertController.addAction(okButtonAction)
                alertController.addAction(dontShowAgainAction)
                
//                if let appDel = UIApplication.shared.delegate, let window = appDel.window!, let rootVC = window.rootViewController {
//                    rootVC.present(alertController, animated: true, completion: nil)
//                }
            }
        }
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
        
        let directionsAction = UIAlertAction(title: "Directions", style: .default) { (action) in
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

/*
 <wpt lat="38.723438" lon="-121.084084"> </gpx>
 <wpt lat="38.710252" lon="-121.086191"> </gpx>
 */
