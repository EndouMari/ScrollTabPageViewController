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

    var pageViewControllers: [UIViewController] = []
    
    // pageViewControllerの更新index
    var updateIndex: Int = 0
    
    var contentsView: ContentsView!
    
    // contentViewの高さ
    let contentViewHeihgt: CGFloat = 280.0
    
    // contentsViewのスクロールの値
    var scrollContentOffsetY: CGFloat = 0.0
    
    var shouldScrollFrame: Bool = true
    var shouldUpdateLayout: Bool = false
    
    
    // tabViewControllerの現在のindex
    var currentIndex: Int? {
        guard let viewController = viewControllers?.first, let index = pageViewControllers.index(of: viewController) else {
            return nil
        }
        return index
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupOutlets()
    }
}


// MARK: - View

extension ScrollTabPageViewController {

    // outletをセットアップ
    func setupOutlets() {
        setupViewControllers()
        setupContentsView()
        setupPageViewController()
    }

    // viewControllerをセットアップ
    // 別々のviewControllerを設定する場合はvc1&2の読み込み内容を変更する
    func setupViewControllers() {
        // viewContrroller
        let sb1 = UIStoryboard(name: "ViewController", bundle: nil)
        let vc1 = sb1.instantiateViewController(withIdentifier: "ViewController")

        // viewContrroller
        let sb2 = UIStoryboard(name: "ViewController", bundle: nil)
        let vc2 = sb2.instantiateViewController(withIdentifier: "ViewController")

        pageViewControllers = [vc1, vc2]
    }

    // pageViewControllerをセットアップする
    func setupPageViewController() {
        dataSource = self
        delegate = self

        // 初回表示のviewControllerをセット
        setViewControllers([pageViewControllers[0]],
            direction: .forward,
            animated: false,
            completion: { [weak self] (completed: Bool) in
                self?.setupContentInset()
            })
    }

    // contentsViewのセットアップ
    func setupContentsView() {
        contentsView = ContentsView(frame: CGRect(x:0.0, y:0.0, width:view.frame.width, height:contentViewHeihgt))
        
        // タブボタンがタップされた時のブロック
        contentsView.tabButtonPressedBlock = { [weak self] (index: Int) in
            guard let uself = self else {
                return
            }
            

            uself.shouldUpdateLayout = true
            uself.updateIndex = index
            let direction: UIPageViewControllerNavigationDirection = (uself.currentIndex! < index) ? .forward : .reverse
            uself.setViewControllers([uself.pageViewControllers[index]],
                direction: direction,
                animated: true,
                completion: { [weak self] (completed: Bool) in
                    guard let uself = self else {
                        return
                    }
                    if uself.shouldUpdateLayout {
                        uself.setupContentOffsetY(index:index, scroll: -uself.scrollContentOffsetY)
                        uself.shouldUpdateLayout = false
                    }
                })
        }

        // スクロールされた時のブロック
        contentsView.scrollDidChangedBlock = { [weak self] (scroll: CGFloat, shouldScrollFrame: Bool) in
            self?.shouldScrollFrame = shouldScrollFrame
            // Y座標を更新する
            self?.updateContentOffsetY(scroll: scroll)
        }
        view.addSubview(contentsView)
    }
}


// MARK: - updateScroll

extension ScrollTabPageViewController {

    func setupContentInset() {
        guard let currentIndex = currentIndex, let vc = pageViewControllers[currentIndex] as? ScrollTabPageViewControllerProtocol else {
            return
        }
        

        let inset = UIEdgeInsetsMake(contentViewHeihgt, 0.0, 0.0, 0.0)
        vc.scrollView.contentInset = inset
        vc.scrollView.scrollIndicatorInsets = inset
    }

    /**
     Y座標をセット(初期表示やページングがされた時)
     - parameter index: ページングのindex
     - parameter scroll: どれだけスクロールしているか
     */
    func setupContentOffsetY(index: Int, scroll: CGFloat) {
        guard let  vc = pageViewControllers[index] as? ScrollTabPageViewControllerProtocol else {
            return
        }

        if scroll == 0.0 {
            vc.scrollView.contentOffset.y = -contentViewHeihgt
        } else if (scroll < contentViewHeihgt - contentsView.segmentedControlHeight.constant) || (vc.scrollView.contentOffset.y <= -contentsView.segmentedControlHeight.constant) {
            vc.scrollView.contentOffset.y = scroll - contentViewHeihgt
        }
    }

    /**
     contentViewを更新
     - parameter scroll: 移動した分の座標
     */
    func updateContentView(scroll: CGFloat) {
        if shouldScrollFrame {
            contentsView.frame.origin.y = scroll
            scrollContentOffsetY = scroll
        }
        shouldScrollFrame = true
    }

    /**
     Y座標を更新
     - parameter scroll: 移動した分の座標
     */
    func updateContentOffsetY(scroll: CGFloat) {
        if let currentIndex = currentIndex, let vc = pageViewControllers[currentIndex] as? ScrollTabPageViewControllerProtocol {
            vc.scrollView.contentOffset.y += scroll
        }
    }

    func updateContentViewFrame() {
        guard let currentIndex = currentIndex, let vc = pageViewControllers[currentIndex] as? ScrollTabPageViewControllerProtocol else {
            return
        }

        if vc.scrollView.contentOffset.y >= -contentsView.segmentedControlHeight.constant {
            let scroll = contentViewHeihgt - contentsView.segmentedControlHeight.constant
            updateContentView(scroll: -scroll)
            vc.scrollView.scrollIndicatorInsets.top = contentsView.segmentedControlHeight.constant
        } else {
            let scroll = contentViewHeihgt + vc.scrollView.contentOffset.y
            updateContentView(scroll: -scroll)
            vc.scrollView.scrollIndicatorInsets.top = -vc.scrollView.contentOffset.y
        }
    }

    func updateLayoutIfNeeded() {
        if shouldUpdateLayout {
            let vc = pageViewControllers[updateIndex] as? ScrollTabPageViewControllerProtocol
            let shouldSetupContentOffsetY = vc?.scrollView.contentInset.top != contentViewHeihgt
            
            setupContentInset()
            setupContentOffsetY(index: updateIndex, scroll: -scrollContentOffsetY)
            shouldUpdateLayout = shouldSetupContentOffsetY
        }
    }
}


// MARK: - UIPageViewControllerDateSource

extension ScrollTabPageViewController: UIPageViewControllerDataSource {

    /**
     1つ目のviewControllerに戻った時の処理
     - parameter pageViewController: pageViewController
     - parameter viewController: 現在表示されている2つ目のviewController
     - returns: 1つ目に戻った時に表示されるviewController
     */
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            
            guard var index = pageViewControllers.index(of: viewController) else {
                return nil
            }
            
            index = index - 1
            
            if index >= 0 && index < pageViewControllers.count {
                return pageViewControllers[index]
            }
            return nil
    }
    
    /**
     2つ目のviewControllerに進んだ時の処理
     - parameter pageViewController: pageViewController
     - parameter viewController: 現在表示されている1つ目のviewController
     - returns: 2つ目に進んだ時に表示されるviewController
     */
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {

        guard var index = pageViewControllers.index(of: viewController) else {
            return nil
        }

        index = index + 1

        if index >= 0 && index < pageViewControllers.count {
            return pageViewControllers[index]
        }
        return nil
    }
}


// MARK: - UIPageViewControllerDelegate

extension ScrollTabPageViewController: UIPageViewControllerDelegate {

    /**
     pageViewControllerで別のviewControllerに遷移する時の処理
     - parameter pageViewController: pageViewController
     - parameter pagingViewControllers: これから遷移しようとしているviewController
     */
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if let vc = pendingViewControllers.first, let index = pageViewControllers.index(of: vc) {
            shouldUpdateLayout = true
            updateIndex = index
        }
    }

    /**
     pageViewControllerのアニメーションが終わった時の処理
     - parameter pageViewController: pageViewController
     - parameter fisnished: アニメーション完了のBOOL値
     - parameter previousViewControllers: 遷移前のviewController
     - parameter completed: 遷移完了のBOOL値
     */
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let _ = previousViewControllers.first, let currentIndex = currentIndex else {
            return
        }

        if shouldUpdateLayout {
            setupContentInset()
            setupContentOffsetY(index: currentIndex, scroll: -scrollContentOffsetY)
        }

        if currentIndex >= 0 && currentIndex < contentsView.segmentedControl.numberOfSegments {
            contentsView.updateCurrentIndex(index: currentIndex, animated: false)
        }
    }
}
