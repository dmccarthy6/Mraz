//  Created by Dylan  on 7/14/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit

final class MrazOnboardingPageViewController: UIViewController {
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
    private var settings = MrazSettings()
    private var pageContainer: UIPageViewController!
    private var dataSource = OnboardingModel.data
    private var pages = [UIViewController]()
    private var currentIndex: Int?
    private var pendingIndex: Int?
    private var notificationManager = LocalNotificationManger()
    private var locationManager = LocationManager()
    
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
            setButtonActions(for: page, on: viewController.onBoardingView)
            pages.append(viewController)
        }
    }
    
    private func createAgeVerificationVC() {
        let ageVerifViewController = AgeVerificationViewController()
        ageVerifViewController.ageHasBeenVerified = { [weak self] in
            DispatchQueue.main.async {
                self?.settings.set(true, for: .userIsOfAge)
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
        pageControl.numberOfPages = 0
        pageControl.currentPage = 0
    }
    
    /// Configure the Onboarding View controller that is bing added to the page view
    private func configureOnboardingViewController(at index: Int) -> MrazOnboardingViewController {
        let currentVal = dataSource[index]
        let title = currentVal.title
        let viewDescription = currentVal.description
        let viewImage = currentVal.image
        let onboardingVC = MrazOnboardingViewController()
        let onboardingView = onboardingVC.onBoardingView
        onboardingView.setData(title: title, buttonTitle: currentVal.actionButtonTitle, description: viewDescription.rawValue, image: viewImage)
        onboardingView.nextButton(isEnabled: currentVal.nextBtnEnabled ?? true, isHidden: currentVal.nextBtnHidden ?? false)
        return onboardingVC
    }
    
    // MARK: - Button Functions
    /// Set the button actions for onboarding view buttons
    private func setButtonActions(for page: Int, on view: MrazOnboardingView) {
        view.actionButtonTapped = { [weak self] in
            if page == 0 {
                self?.notificationManager.promptUserForLocalNotifications()
            } else if page == 1 {
                self?.locationManager.promptUserForLocationAuth()
            } else if page == 2 {
                view.dismissOnboardingView(from: self!)
            }
        }
        view.nextButtonTapped = { [weak self] in
            self?.handleNextPage()
        }
    }
    
    // MARK: - Helpers
    private func handleNextPage() {
        pageContainer.goToNextPage()
        incrementPageControl()
    }
    
    /// Increment the page control current page value by 1 forward.
    private func incrementPageControl() {
        let currentPageInt = pageControl.currentPage
        self.pageControl.currentPage = currentPageInt + 1
    }
}

// MARK: - PageViewController Data Source Methods
extension MrazOnboardingPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = pages.firstIndex(of: viewController) {
            if index > 0 {
                return pages[index - 1]
            } else {
                return nil
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
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
    func pageViewController(_ pageViewController: UIPageViewController,
                            willTransitionTo pendingViewControllers: [UIViewController]) {
        pendingIndex = pages.firstIndex(of: pendingViewControllers.first!)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            currentIndex = pendingIndex
            if let index = currentIndex {
                pageControl.currentPage = index
            }
        }
    }
}
