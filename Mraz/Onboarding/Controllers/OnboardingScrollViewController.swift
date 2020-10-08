//  Created by Dylan  on 7/14/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit
import os.log

final class MrazOnboardingPageViewController: UIViewController {
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
    private var settings = MrazSettings()
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

    // MARK: - Page View Controller
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
    }

    private func populateOnboardingVC(at index: Int, buttonTitle: String, buttonType: ButtonType) {
        let onboardingVC = MrazOnboardingViewController()
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
    private func incrementPage() {
        pageContainer.goToNextPage()
        self.pageControl.currentPage = pageControl.currentPage + 1
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

// MARK: - Dismiss View Delegate Methods
extension MrazOnboardingPageViewController: DismissViewDelegate {
    func dismissOnboardingViews() {
        settings.set(true, for: .didFinishOnboarding)
        self.dismiss(animated: true, completion: nil)
    }
}
