//
//  ContentsView.swift
//  ScrollTabPageViewController
//
//  Created by EndouMari on 2015/12/06.
//  Copyright © 2015年 EndouMari. All rights reserved.
//

import UIKit

class ContentsView: UIView {

    // 選択されているtabボタンのindex
    var currentIndex: Int = 0
    
    
    
    var tabButtonPressedBlock: ((_ index: Int) -> Void)?
    var scrollDidChangedBlock: ((_ scroll: CGFloat, _ shouldScroll: Bool) -> Void)?

    // スクロール開始時点の初期値
    var scrollStart: CGFloat = 0.0

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var segmentedControlHeight: NSLayoutConstraint!
    let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!

        sharedInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        sharedInit()
    }
    
    
    private func sharedInit() {
        Bundle.main.loadNibNamed("ContentsView", owner: self, options: nil)
        addSubview(contentView)

        self.setupConstraints()

        scrollView.delegate = self
        scrollView.scrollsToTop = false
    }
}


// MARK: - View

extension ContentsView {

    // 制約を更新
    func setupConstraints() {
        let topConstraint = NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0)

        let bottomConstraint = NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0)

        let leftConstraint = NSLayoutConstraint(item: contentView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0)

        let rightConstraint = NSLayoutConstraint(item: contentView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0)

        let constraints = [topConstraint, bottomConstraint, leftConstraint, rightConstraint]

        contentView.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(constraints)
    }

    /**
     ランダムな色を取得
     - returns: ランダムな色
     */
    func randomColor() -> UIColor {
        let red = CGFloat(arc4random_uniform(255)) / 255.0
        let green = CGFloat(arc4random_uniform(255)) / 255.0
        let blue = CGFloat(arc4random_uniform(255)) / 255.0
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    /**
     tabボタンのindex番号を更新
     - parameter index: 更新しようとしているindex番号
     - parameter animated: アニメーションするかのBOOL
     */
    func updateCurrentIndex(index: Int, animated: Bool) {
        segmentedControl.selectedSegmentIndex = index
        currentIndex = index
    }
}


// MARK: - UIScrollViewDelegate

extension ContentsView: UIScrollViewDelegate {

    /**
     contentsViewでのスクロールを検知
     - parameter scrollView: scrollView
     */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > statusBarHeight {
            scrollDidChangedBlock?(scrollView.contentOffset.y, true)
            scrollView.contentOffset.y = statusBarHeight
        } else if scrollView.contentOffset.y > 0.0 {
            scrollDidChangedBlock?(scrollView.contentOffset.y, true)
            scrollView.contentOffset.y = 0.0
        } else if frame.minY < 0.0 {
            scrollDidChangedBlock?(scrollView.contentOffset.y, true)
            scrollView.contentOffset.y = 0.0
        } else {
            let scroll = scrollView.contentOffset.y - scrollStart
            scrollDidChangedBlock?(scroll, false)
            scrollStart = scrollView.contentOffset.y
        }
    }
}


// MARK: - IBAction

extension ContentsView {
    @IBAction private func touchButtonTouchUpInside(_ sender: UIButton) {
        containerView.backgroundColor = randomColor()
    }
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        tabButtonPressedBlock?(sender.selectedSegmentIndex)
        updateCurrentIndex(index: sender.selectedSegmentIndex, animated: true)
    }
}
