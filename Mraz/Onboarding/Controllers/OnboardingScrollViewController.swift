//  Created by Dylan  on 7/14/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit
import os.log

final class MrazOnboardingPageViewController: UIViewController, NotificationManager, LocationManager {
    // MARK: - Properties
    let mrazLog = OSLog(subsystem: MrazSyncConstants.subsystemName, category: String(describing: MrazOnboardingViewController.self))
    var didFinishOnboarding: EmptyClosure?
    private lazy var pageContainer: UIPageViewController = {
        let pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageVC.dataSource = self
        pageVC.delegate = self
        return pageVC
    }()
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPageIndicatorTintColor = .systemBlue
        pageControl.pageIndicatorTintColor = .systemGray
        pageControl.currentPage = 0
        return pageControl
    }()
<<<<<<< Updated upstream
    private var pageContainer: UIPageViewController!
=======
    private var settings = MrazSettings()
>>>>>>> Stashed changes
    private var dataSource = OnboardingModel.data
    private var pages = [UIViewController]()
    private var currentIndex: Int?
    private var pendingIndex: Int?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        self.verifyUsersAge()
        setupPageViewControllers()
    }
    
    // MARK: - Configure View
    private func configurePageControl() {
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.topAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -25),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    private func setupPageViewControllers() {
        createViewControllers()
        pageContainer.setViewControllers([pages[0]], direction: .forward, animated: true, completion: nil)
        view.addSubview(pageContainer.view)
        setUpPageControl()
    }
    
    private func setUpPageControl() {
        configurePageControl()
        view.bringSubviewToFront(pageControl)
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
    }
<<<<<<< Updated upstream
    
    private func setupPages() {
        for page in 0..<dataSource.count {
            if page == 0 {
                createAgeVerificationVC()
            }
            let viewController = configureOnboardingViewController(at: page)
            setButtonActions(for: page, on: viewController.onBoardingView)
            pages.append(viewController)
        }
    }
    
    private func createAgeVerificationVC() {
        let ageVerifViewController = AgeVerificationViewController()
        ageVerifViewController.ageHasBeenVerified = { [weak self] in
            DispatchQueue.main.async {
                self?.pageContainer.goToNextPage()
                self?.incrementPageControl()
            }
        }
        ageVerifViewController.userNotOfAge = { [weak self] in
            self?.resetPageViewController()
        }
        pages.append(ageVerifViewController)
    }
    
    private func resetPageViewController() {
        let ofAgeVC = pages[0]
        pages = [ofAgeVC]
        pageControl.numberOfPages = 1
        pageControl.currentPage = 1
=======

    // MARK: - Create View Controllers
    private func createViewControllers() {
        let pagesCount = dataSource.count
        
        for pageNum in 0..<pagesCount {
            switch pageNum {
            case 0:
                populateOnboardingVC(at: pageNum, buttonTitle: "Accept", buttonType: .notifications)
            case 1:
                populateOnboardingVC(at: pageNum, buttonTitle: "Accept", buttonType: .geofencing)
            case 2:
                populateOnboardingVC(at: pageNum, buttonTitle: "Open", buttonType: .launch)
            default: ()
            }
        }
>>>>>>> Stashed changes
    }
 
    private func populateOnboardingVC(at index: Int, buttonTitle: String, buttonType: ButtonType) {
        let onboardingVC = MrazOnboardingViewController()
<<<<<<< Updated upstream
        let onboardingView = onboardingVC.onBoardingView
        onboardingView.setData(title: title, buttonTitle: currentVal.actionButtonTitle, description: viewDescription.rawValue, image: viewImage)
        return onboardingVC
    }
    
    // MARK: - Button Functions
    /// Set the button actions for onboarding view buttons
    private func setButtonActions(for page: Int, on view: MrazOnboardingView) {
        view.actionButtonTapped = { [weak self] in
            if page == 0 {
                self?.showNotifications()
                view.nextButton(isEnabled: true, isHidden: false)
            } else if page == 1 {
                self?.dismissOnboardingView()
            } 
        }
        
        view.nextButtonTapped = { [weak self] in
            self?.handleNextPage()
        }
    }
    
    // MARK: - Helpers
    private func showNotifications() {
        requestUserAuthForNotifications { (result) in
            switch result {
            case .success(let granted):
                if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            case .failure(let error):
                print("Error requesting notifications: \(error.localizedDescription)")
            }
        }
        checkUsersLocationAuth()
    }
    
    private func handleNextPage() {
        pageContainer.goToNextPage()
        incrementPageControl()
    }
    
=======
        let modelObject = dataSource[index]
        onboardingVC.configureOnboardingView(title: modelObject.title,
                                             description: modelObject.description.rawValue,
                                             image: modelObject.image!,
                                             buttonTitle: buttonTitle,
                                             buttonType: buttonType)
        pages.append(onboardingVC)
        onboardingVC.onBoardingView.dismissDelegate = self
    }
    
    // MARK: - Helpers
>>>>>>> Stashed changes
    /// Increment the page control current page value by 1 forward.
    private func incrementPage() {
        pageContainer.goToNextPage()
        let currentPageInt = pageControl.currentPage
        self.pageControl.currentPage = currentPageInt + 1
    }
    
    // MARK: - Dismiss View
    /// Dismiss the onboarding flow
    func dismissOnboardingView() {
        self.dismiss(animated: true)
    }
}

// MARK: - PageViewController Data Source Methods
extension MrazOnboardingPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = pages.firstIndex(of: viewController) {
            if index > 0 {
                return pages[index - 1]
            } else {
                return nil
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = pages.firstIndex(of: viewController) {
            if index < pages.count - 1 {
                return pages[index + 1]
            } else {
                return nil
            }
        }
        return nil
    }
}

// MARK: - PageViewController Delegate Methods
extension MrazOnboardingPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        pendingIndex = pages.firstIndex(of: pendingViewControllers.first!)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            currentIndex = pendingIndex
            if let index = currentIndex {
                pageControl.currentPage = index
            }
        }
    }
}

// MARK: - Dismiss View Delegate Methods
extension MrazOnboardingPageViewController: DismissViewDelegate {
    func dismissOnboardingViews() {
        self.settings.set(true, for: .didFinishOnboarding)
        self.dismiss(animated: true, completion: nil)
    }
}
