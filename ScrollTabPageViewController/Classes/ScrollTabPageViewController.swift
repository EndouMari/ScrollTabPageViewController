//
//  ScrollTabPageViewController.swift
//  ScrollTabPageViewController
//
//  Created by EndouMari on 2015/12/04.
//  Copyright © 2015年 EndouMari. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


protocol ScrollTabPageViewControllerProtocol {
    var scrollTabPageViewController: ScrollTabPageViewController { get }
    var scrollView: UIScrollView { get }
}

class ScrollTabPageViewController: UIPageViewController {

    fileprivate let contentViewHeihgt: CGFloat = 280.0
    fileprivate let tabViewHeight: CGFloat = 44.0
    fileprivate var pageViewControllers: [UIViewController] = []
    fileprivate var contentsView: ContentsView!
    fileprivate var scrollContentOffsetY: CGFloat = 0.0
    fileprivate var shouldScrollFrame: Bool = true
    fileprivate var shouldUpdateLayout: Bool = false
    fileprivate var updateIndex: Int = 0
    fileprivate var currentIndex: Int? {
        guard let viewController = viewControllers?.first, let index = pageViewControllers.index(of: viewController) else {
            return nil
        }
        return index
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupOutlets()
    }
}


// MARK: - View

extension ScrollTabPageViewController {

    fileprivate func setupOutlets() {
        setupViewControllers()
        setupContentsView()
        setupPageViewController()
    }

    fileprivate func setupViewControllers() {
        let sb1 = UIStoryboard(name: "ViewController", bundle: nil)
        let vc1 = sb1.instantiateViewController(withIdentifier: "ViewController")

        let sb2 = UIStoryboard(name: "ViewController", bundle: nil)
        let vc2 = sb2.instantiateViewController(withIdentifier: "ViewController")

        pageViewControllers = [vc1, vc2]
    }

    fileprivate func setupPageViewController() {
        dataSource = self
        delegate = self

        setViewControllers([pageViewControllers[0]],
            direction: .forward,
            animated: false,
            completion: { [weak self] (completed: Bool) in
                self?.setupContentInset()
            })
    }

    fileprivate func setupContentsView() {
        contentsView = ContentsView(frame: CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: contentViewHeihgt))
        contentsView.tabButtonPressedBlock = { [weak self] (index: Int) in
            guard let uself = self else {
                return
            }

            uself.shouldUpdateLayout = true
            uself.updateIndex = index
            let direction: UIPageViewControllerNavigationDirection = (uself.currentIndex < index) ? .forward : .reverse
            uself.setViewControllers([uself.pageViewControllers[index]],
                direction: direction,
                animated: true,
                completion: { [weak self] (completed: Bool) in
                    guard let uself = self else {
                        return
                    }
                    if uself.shouldUpdateLayout {
                        uself.setupContentOffsetY(index, scroll: -uself.scrollContentOffsetY)
                        uself.shouldUpdateLayout = false
                    }
                })
        }

        contentsView.scrollDidChangedBlock = { [weak self] (scroll: CGFloat, shouldScrollFrame: Bool) in
            self?.shouldScrollFrame = shouldScrollFrame
            self?.updateContentOffsetY(scroll)
        }
        view.addSubview(contentsView)
    }
}


// MARK: - updateScroll

extension ScrollTabPageViewController {

    fileprivate func setupContentInset() {
        guard let currentIndex = currentIndex, let vc = pageViewControllers[currentIndex] as? ScrollTabPageViewControllerProtocol else {
            return
        }

        let inset = UIEdgeInsetsMake(contentViewHeihgt, 0.0, 0.0, 0.0)
        vc.scrollView.contentInset = inset
        vc.scrollView.scrollIndicatorInsets = inset
    }

    fileprivate func setupContentOffsetY(_ index: Int, scroll: CGFloat) {
        guard let  vc = pageViewControllers[index] as? ScrollTabPageViewControllerProtocol else {
            return
        }

        if scroll == 0.0 {
            vc.scrollView.contentOffset.y = -contentViewHeihgt
        } else if (scroll < contentViewHeihgt - tabViewHeight) || (vc.scrollView.contentOffset.y <= -tabViewHeight) {
            vc.scrollView.contentOffset.y = scroll - contentViewHeihgt
        }
    }

    fileprivate func updateContentView(_ scroll: CGFloat) {
        if shouldScrollFrame {
            contentsView.frame.origin.y = scroll
            scrollContentOffsetY = scroll
        }
        shouldScrollFrame = true
    }

    fileprivate func updateContentOffsetY(_ scroll: CGFloat) {
        if let currentIndex = currentIndex, let vc = pageViewControllers[currentIndex] as? ScrollTabPageViewControllerProtocol {
            vc.scrollView.contentOffset.y += scroll
        }
    }

    func updateContentViewFrame() {
        guard let currentIndex = currentIndex, let vc = pageViewControllers[currentIndex] as? ScrollTabPageViewControllerProtocol else {
            return
        }

        if vc.scrollView.contentOffset.y >= -tabViewHeight {
            let scroll = contentViewHeihgt - tabViewHeight
            updateContentView(-scroll)
            vc.scrollView.scrollIndicatorInsets.top = tabViewHeight
        } else {
            let scroll = contentViewHeihgt + vc.scrollView.contentOffset.y
            updateContentView(-scroll)
            vc.scrollView.scrollIndicatorInsets.top = -vc.scrollView.contentOffset.y
        }
    }

    func updateLayoutIfNeeded() {
        if shouldUpdateLayout {
            let vc = pageViewControllers[updateIndex] as? ScrollTabPageViewControllerProtocol
            let shouldSetupContentOffsetY = vc?.scrollView.contentInset.top != contentViewHeihgt
            
            let scroll = scrollContentOffsetY
            setupContentInset()
            setupContentOffsetY(updateIndex, scroll: -scroll)
            shouldUpdateLayout = shouldSetupContentOffsetY
        }
    }
}


// MARK: - UIPageViewControllerDateSource

extension ScrollTabPageViewController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {

        guard var index = pageViewControllers.index(of: viewController) else {
            return nil
        }

        index += 1

        if index >= 0 && index < pageViewControllers.count {
            return pageViewControllers[index]
        }
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

        guard var index = pageViewControllers.index(of: viewController) else {
            return nil
        }

        index -= 1

        if index >= 0 && index < pageViewControllers.count {
            return pageViewControllers[index]
        }
        return nil
    }
}


// MARK: - UIPageViewControllerDelegate

extension ScrollTabPageViewController: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if let vc = pendingViewControllers.first, let index = pageViewControllers.index(of: vc) {
            shouldUpdateLayout = true
            updateIndex = index
        }

    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let _ = previousViewControllers.first, let currentIndex = currentIndex else {
            return
        }

        if shouldUpdateLayout {
            setupContentInset()
            setupContentOffsetY(currentIndex, scroll: -scrollContentOffsetY)
        }

        if currentIndex >= 0 && currentIndex < contentsView.tabButtons.count {
            contentsView.updateCurrentIndex(currentIndex, animated: false)
        }
    }
}
