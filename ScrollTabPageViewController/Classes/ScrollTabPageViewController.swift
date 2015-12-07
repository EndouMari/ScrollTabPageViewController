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
    func setupContentInset()
    func setupContentOffsetY(scroll: CGFloat)
    func updateContentOffsetY(scroll: CGFloat)
}

class ScrollTabPageViewController: UIPageViewController {

    static let contentViewHeihgt: CGFloat = 280.0
    static let tabViewHeight: CGFloat = 44.0
    var shouldScrollFrame: Bool?
    var scrollContentOffsetY: CGFloat = 0.0

    private var pageViewControllers: [UIViewController] = []
    private var contentsView: ContentsView!
    private var currentIndex: Int? {
        if let viewController = viewControllers?.first {
            let index = indexOfViewController(viewController)
            return index
        }
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupOutlets()
    }
}


// View

extension ScrollTabPageViewController {
    private func setupOutlets() {
        setupViewControllers()
        setupPageViewController()
        setupContentsView()
    }

    private func setupViewControllers() {
        let sb1 = UIStoryboard(name: "TableViewController", bundle: nil)
        let vc1 = sb1.instantiateViewControllerWithIdentifier("TableViewController")
        let sb2 = UIStoryboard(name: "TableViewController", bundle: nil)
        let vc2 = sb2.instantiateViewControllerWithIdentifier("TableViewController")

        pageViewControllers = [vc1, vc2]
    }

    private func setupPageViewController() {
        dataSource = self
        delegate = self

        setViewControllers([pageViewControllers[0]],
            direction: .Forward,
            animated: false,
            completion: nil)
    }

    private func setupContentsView() {
        contentsView = ContentsView(frame: CGRectMake(0.0, 0.0, view.frame.width, 280.0))
        contentsView.tabButtonPressedBlock = { [weak self] (index: Int) in
            if let uself = self {
                let direction: UIPageViewControllerNavigationDirection = uself.currentIndex < index ? .Forward : .Reverse
                uself.setViewControllers([uself.pageViewControllers[index]],
                    direction: direction,
                    animated: true,
                    completion: { [weak self] (completed: Bool) in
                        if let uself = self {
                            if let vc = uself.pageViewControllers[index] as? ScrollTabPageViewControllerProtocol {
                                let scroll = uself.scrollContentOffsetY
                                vc.setupContentOffsetY(-scroll)
                            }
                        }
                    })
            }
        }

        contentsView.scrollDidChangedBlock = { [weak self] (scroll: CGFloat, shouldScrollFrame: Bool) in
            self?.shouldScrollFrame = shouldScrollFrame
            if let currentIndex = self?.currentIndex, vc = self?.pageViewControllers[currentIndex] as? ScrollTabPageViewControllerProtocol {
                vc.updateContentOffsetY(scroll)
            }
        }
        view.addSubview(contentsView)
    }

    func updateContentView(scroll: CGFloat) {
        if shouldScrollFrame == false {
            shouldScrollFrame = nil
            return
        }

        shouldScrollFrame = nil
        contentsView.frame.origin.y = scroll
        scrollContentOffsetY = scroll
    }
}


// UIPageViewControllerDateSource

extension ScrollTabPageViewController: UIPageViewControllerDataSource {
    private func indexOfViewController(viewController: UIViewController) -> Int {
        return (pageViewControllers as NSArray).indexOfObject(viewController)
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var index: Int = indexOfViewController(viewController)

        if index == NSNotFound { return nil }

        index++

        if index < pageViewControllers.count {
            return pageViewControllers[index]
        }
        return nil
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var index: Int = indexOfViewController(viewController)

        if index == NSNotFound { return nil }

        index--
        if index >= 0  {
            return pageViewControllers[index]
        }
        return nil
    }
}


// UIPageViewControllerDelegate

extension ScrollTabPageViewController: UIPageViewControllerDelegate {

    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        if let vc = pendingViewControllers.first as? ScrollTabPageViewControllerProtocol {
            let scroll = scrollContentOffsetY
            vc.setupContentOffsetY(-scroll)
        }
    }

    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if previousViewControllers.first != nil {
            if let currentIndex = currentIndex where contentsView.tabButtons.count > currentIndex {
                contentsView.updateCurrentIndex(currentIndex, animated: false)
            }
        }
    }
}
