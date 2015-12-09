//
//  ScrollTabPageViewController.swift
//  ScrollTabPageViewController
//
//  Created by EndouMari on 2015/12/04.
//  Copyright © 2015年 EndouMari. All rights reserved.
//

import UIKit

protocol ScrollTabPageViewControllerProtocol {
    var scrollTabPageViewController: ScrollTabPageViewController { get }
    var scrollView: UIScrollView { get }
}

class ScrollTabPageViewController: UIPageViewController {

    private let contentViewHeihgt: CGFloat = 280.0
    private let tabViewHeight: CGFloat = 44.0
    private var pageViewControllers: [UIViewController] = []
    private var contentsView: ContentsView!
    private var scrollContentOffsetY: CGFloat = 0.0
    private var shouldScrollFrame: Bool?
    private var shouldUpdateLayout: Bool = false
    private var currentIndex: Int? {
        guard let viewController = viewControllers?.first, index = pageViewControllers.indexOf(viewController) else {
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

    private func setupOutlets() {
        setupViewControllers()
        setupContentsView()
        setupPageViewController()
    }

    private func setupViewControllers() {
        let sb1 = UIStoryboard(name: "ViewController", bundle: nil)
        let vc1 = sb1.instantiateViewControllerWithIdentifier("ViewController")

        let sb2 = UIStoryboard(name: "ViewController", bundle: nil)
        let vc2 = sb2.instantiateViewControllerWithIdentifier("ViewController")

        pageViewControllers = [vc1, vc2]
    }

    private func setupPageViewController() {
        dataSource = self
        delegate = self

        setViewControllers([pageViewControllers[0]],
            direction: .Forward,
            animated: false,
            completion: { [weak self] (completed: Bool) in
                self?.setupContentInset()
            })
    }

    private func setupContentsView() {
        contentsView = ContentsView(frame: CGRectMake(0.0, 0.0, view.frame.width, contentViewHeihgt))
        contentsView.tabButtonPressedBlock = { [weak self] (index: Int) in
            guard let uself = self else {
                return
            }

            uself.shouldUpdateLayout = true
            let direction: UIPageViewControllerNavigationDirection = (uself.currentIndex < index) ? .Forward : .Reverse
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

    private func setupContentInset() {
        guard let currentIndex = currentIndex, vc = pageViewControllers[currentIndex] as? ScrollTabPageViewControllerProtocol else {
            return
        }

        let inset = UIEdgeInsetsMake(contentViewHeihgt, 0.0, 0.0, 0.0)
        vc.scrollView.contentInset = inset
        vc.scrollView.scrollIndicatorInsets = inset
    }

    private func setupContentOffsetY(index: Int, scroll: CGFloat) {
        guard let  vc = pageViewControllers[index] as? ScrollTabPageViewControllerProtocol else {
            return
        }

        if scroll == 0.0 {
            vc.scrollView.contentOffset.y = -contentViewHeihgt
        } else if (scroll < contentViewHeihgt - tabViewHeight) || (vc.scrollView.contentOffset.y <= -tabViewHeight) {
            vc.scrollView.contentOffset.y = -(contentViewHeihgt - scroll)
        }
    }

    private func updateContentView(scroll: CGFloat) {
        if shouldScrollFrame == false {
            shouldScrollFrame = nil
        } else {
            contentsView.frame.origin.y = scroll
            scrollContentOffsetY = scroll
            shouldScrollFrame = nil
        }
    }

    private func updateContentOffsetY(scroll: CGFloat) {
        if let currentIndex = currentIndex, vc = pageViewControllers[currentIndex] as? ScrollTabPageViewControllerProtocol {
            vc.scrollView.contentOffset.y += scroll
        }
    }

    func updateContentViewFrame() {
        guard let currentIndex = currentIndex, vc = pageViewControllers[currentIndex] as? ScrollTabPageViewControllerProtocol else {
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
            guard let currentIndex = currentIndex else {
                return
            }

            let vc = pageViewControllers[currentIndex] as? ScrollTabPageViewControllerProtocol
            let shouldSetupContentOffsetY = vc?.scrollView.contentInset.top != contentViewHeihgt

            let scroll = scrollContentOffsetY
            setupContentInset()
            setupContentOffsetY(currentIndex, scroll: -scroll)
            shouldUpdateLayout = shouldSetupContentOffsetY
        }
    }
}


// MARK: - UIPageViewControllerDateSource

extension ScrollTabPageViewController: UIPageViewControllerDataSource {

    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {

        guard var index = pageViewControllers.indexOf(viewController) else {
            return nil
        }

        index++

        if index >= 0 && index < pageViewControllers.count {
            return pageViewControllers[index]
        }
        return nil
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {

        guard var index = pageViewControllers.indexOf(viewController) else {
            return nil
        }

        index--

        if index >= 0 && index < pageViewControllers.count {
            return pageViewControllers[index]
        }
        return nil
    }
}


// MARK: - UIPageViewControllerDelegate

extension ScrollTabPageViewController: UIPageViewControllerDelegate {

    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        if let vc = pendingViewControllers.first, index = pageViewControllers.indexOf(vc) {
            let scroll = scrollContentOffsetY
            setupContentOffsetY(index, scroll: -scroll)
        }
    }

    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let _ = previousViewControllers.first, currentIndex = currentIndex else {
            return
        }

        let vc = pageViewControllers[currentIndex] as? ScrollTabPageViewControllerProtocol
        let shouldSetupContentOffsetY = vc?.scrollView.contentInset.top != contentViewHeihgt
        setupContentInset()

        if shouldSetupContentOffsetY == true {
            setupContentOffsetY(currentIndex, scroll: -scrollContentOffsetY)
        }

        if currentIndex >= 0 && currentIndex < contentsView.tabButtons.count {
            contentsView.updateCurrentIndex(currentIndex, animated: false)
        }
    }
}
