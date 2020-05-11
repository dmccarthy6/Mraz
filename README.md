# Mraz

![iOS](https://camo.githubusercontent.com/be4ac65adac5e6b3d4471f37169496f617e7a544/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f506c6174666f726d2d694f532d6c69676874677265792e737667) ![Swift](https://camo.githubusercontent.com/e92bf630e2a25eeecfe64818a7a3ff05b862bfb8/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f5377696674253230352e302d627269676874677265656e2e737667)
## Description:
Mraz Brewery is located in El Dorado Hills, CA and brews delicious beer. I developed this application in conjunction with the brewery to enhance the user experience at the brewery. Since they have different beers on tap all the time there is a list of all beers provided by the brewery where users can tap on a star to 'favorite' the beer or beers that they enjoy. This way you can remember when one of your favorite beers are on tap! There is a also a screen that shows a Map with restaurants local to the brewery that enables users to select a restaurant and get the website, phone numer and directions to that location. 

## 
***
## Technologies: 
* **UICollectionView:** Used UICollection views with new DiffableDataSource to display list of the brewery's beers and to display the on tap beer list. 
* **UITabBarController:** Application is built on UITabBarController to display the different screens.
* **Core Data:** Core Data used for local persistence. This is used to save your favorite beers that the user has selected on the beers screen.
* **CloudKit:** Used CloudKit's public database to store the brewery's beers and to update the on tap list.
* **MapKit:** MapKit used to display restaurants close by the brewery and provides the restaurants website, phone number, and directions to the restaurant. 
* **Push Notifications:** Push Notifications are used to display Geofencing notifications to the user, as well as through CloudKit silent push notifications.
* **Geofencing:** Users that have the application downloaded will get a local notification within a half-mile of the brewery suggesting that they come inside for a beer!
* **Programatic UI:** Built the UI programatically without the use of Xib's or Storyboards.

***
## About This Project: 
- **Why did I make Mraz?** I wanted to make this application to give customers of Mraz easy access to the information that is most important to them. This application will provide quick access to the beers currently on tap at the brewery, a full list of beers, and a screen where customers can find local restaurants to order food. The brewery does have a website but I believe this application will allow customers to quickly access this information in one place.

- **What have I learned so far?** 
* While the brewery has a website, they do not have any public api to access their data. The beer list and the on tap list are updated periodically, and without a way to fetch those changes I ran into a hurdle. I decided to use the CloudKit public database to hold the data so I was able to change or add any data needed and keep the user's applications up to date. 
* I learned and used some new frameworks include CLLocation and MapKit. I really enjoyed digging into these frameworks and getting using them to work with this application.
 
- **Whats Next?** 
  * Updating the application to include CloudKit fetching. 
  * Improving the code quality and implementing UnitTests to ensure code quality throughout development.
  * Some UI Improvements and updates for iOS 13.

***
## Screenshots:
![Mraz Home](images/HomeGithub.png) ![Beer List](images/BeersGithub.png) ![Food Map](images/MapGithub.png)

![Ritual LogIn Screen](images/RitualGithub.png)

***
## Requirements:
* iOS 13.0+
* Xcode 10+
***
## About The Developer:
I am an iOS Developer from Northern CA. I focus on writing applications in Swift and Objective-C. To learn more about me, you can check out my [portfolio](https://dylanmccarthyios.com).
***



