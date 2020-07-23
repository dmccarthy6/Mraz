//  Created by Dylan  on 7/14/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit

final class MrazOnboardingPageViewController: UIViewController, NotificationManager, LocationManager {
    // MARK: - Properties
    var didFinishOnboarding: EmptyClosure?
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPageIndicatorTintColor = .systemBlue
        pageControl.pageIndicatorTintColor = .systemGray
        pageControl.currentPage = 0
        return pageControl
    }()
    private var pageContainer: UIPageViewController!
    private var dataSource = OnboardingModel.data
    private var pages = [UIViewController]()
    private var currentIndex: Int?
    private var pendingIndex: Int?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        layoutPageControl()
        setupPageViewControllers()
    }
    
    private func layoutPageControl() {
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.topAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -25),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    private func setupPageViewControllers() {
        setupPages()
        pageContainer = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageContainer.dataSource = self
        pageContainer.delegate = self
        pageContainer.setViewControllers([pages[0]], direction: .forward, animated: true, completion: nil)
        view.addSubview(pageContainer.view)
        view.bringSubviewToFront(pageControl)
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
    }
    
    private func setupPages() {
        for page in 0..<dataSource.count {
            if page == 0 {
                createAgeVerificationVC()
            }
            let viewController = configureOnboardingViewController(at: page)
            setButtonActions(on: viewController.onBoardingView)
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
        pages.append(ageVerifViewController)
    }
    
    /// Configure the Onboarding View controller that is bing added to the page view
    private func configureOnboardingViewController(at index: Int) -> MrazOnboardingViewController {
        let currentVal = dataSource[index]
        let title = currentVal.title
        let viewDescription = currentVal.description
        let viewImage = currentVal.image
        let onboardingVC = MrazOnboardingViewController()
        let onboardingView = onboardingVC.onBoardingView
        onboardingView.configureOnboardingScreen(title: title,
                                                 descriptionText: viewDescription.rawValue,
                                                 image: viewImage)
        onboardingView.setButton(agreeHidden: currentVal.agreeButtonHidden,
                                 denyHidden: currentVal.denyButtonHidden,
                                 skipHidden: currentVal.isSkipHidden,
                                 showAppHidden: currentVal.showAppButtonHidden)
        onboardingView.configureButton(addButtonTitle: currentVal.acceptBtnTitle,
                                       denyButtonTitle: currentVal.denyBtnTitle)
        return onboardingVC
    }
    
    // MARK: - Button Functions
    /// Set the button actions for onboarding view buttons
    private func setButtonActions(on view: MrazOnboardingView) {
        view.didTapOpenAppButton = { [weak self] in
            let mrazSettings = MrazSettings()
            mrazSettings.set(true, for: .didFinishOnboarding)
            self?.dismissOnboardingView()
        }
        
        view.didTapDenyButton = { [weak self] in
            DispatchQueue.main.async {
                Alerts.showAlert(self!, title: .notificationsDenied, message: .userDeniedNotifications)
                self?.pageContainer.goToNextPage()
            }
        }
        
        view.didTapAcceptButton = { [weak self] in
            self?.requestUserNotifications()
            self?.requestAuthAndSetUpGeofencingRegion()
        }
        
        view.didTapSkipButton = { [ weak self] in
            DispatchQueue.main.async {
                self?.pageContainer.goToNextPage()
                self?.incrementPageControl()
            }
        }
    }
    
    private func requestUserNotifications() {
        self.requestUserAuthForNotifications { (result) in
            switch result {
            case .success(let granted):
                if granted {
                    DispatchQueue.main.async {
                        self.pageContainer.goToNextPage()
                        self.incrementPageControl()
                    }
                }
            case .failure(let error):
                print("Error Authenticating Notifications: \(error.localizedDescription)")
            }
        }
    }
    
    private func requestAuthAndSetUpGeofencingRegion() {
        self.requestAuthorizationFromUser()
        self.createGeofencingRegionAndNotify()
    }
    
    /// Increment the page control current page value by 1 forward.
    private func incrementPageControl() {
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

// MARK: - Page View Controller Extension -- Page Control
extension UIPageViewController {
    /// Safely jump to the next ViewController in the flow(if any).
    func goToNextPage() {
        guard let currentVC = self.viewControllers?.first else { return }
        guard let nextViewController = dataSource?.pageViewController(self, viewControllerAfter: currentVC) else { return }
        setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)
    }
    
    /// Safely return to previous ViewController in the flow(if any).
    func goToPreviousPage() {
        guard let currentVC = self.viewControllers?.first else { return }
        guard let previousViewController = dataSource?.pageViewController(self, viewControllerBefore: currentVC) else { return }
        setViewControllers([previousViewController], direction: .forward, animated: true, completion: nil)
    }
}
