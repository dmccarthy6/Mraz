//  Created by Dylan  on 7/11/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

/*
 Local notification sent when a beer comes on tap that a user has marked as a favorite. 
 */
struct FavoriteBeerNotifications: NotificationManager {
    // MARK: - Properties
    let beer: Beers
    
    // MARK: -
    func checkStatusSendNotification() {
        checkCurrentAuthorizationStatus { (result) in
            switch result {
            case .success(let authorized): self.sendBeerOnTapLocalNotification()
            case .failure(let error): print(error.localizedDescription)
            }
        }
    }
    
    func sendBeerOnTapLocalNotification() {
        notificationContent.title = "Mraz Brewing Company"
        notificationContent.sound = notificationSound
        
        if let favoriteBeer = beer.name {
            notificationContent.subtitle = "\(favoriteBeer) is on tap!"
            notificationContent.body = "\(favoriteBeer) is now on tap. Come by the tasting room to get yours before it runs out!"
        } else {
            notificationContent.subtitle = "We just tapped one of your favorite beers."
        }
        
        currentNotificationCenter.add(notificationRequest) { (error) in
            if let error = error {
                print("Error adding Local Notification: \(error.localizedDescription)")
            }
        }
    }
}
