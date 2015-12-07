//
//  ContentsView.swift
//  ScrollTabPageViewController
//
//  Created by EndouMari on 2015/12/06.
//  Copyright © 2015年 EndouMari. All rights reserved.
//

import UIKit

class ContentsView: UIView {
    var tabButtonPressedBlock: (Int -> Void)?
    var currentIndex: Int = 0
    var scrollDidChangedBlock: ((scroll: CGFloat, shouldScroll: Bool) -> Void)?

    private var scrollStart: CGFloat = 0.0

    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet var tabButtons: [UIButton]!

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!

        sharedInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }

    private func sharedInit() {
        NSBundle.mainBundle().loadNibNamed("ContentsView", owner: self, options: nil)
        addSubview(contentView)
        setupConstraints()

        scrollView.delegate = self
        scrollView.scrollsToTop = false
    }
}


// View

extension ContentsView {
    private func setupConstraints() {
        let topConstraint = NSLayoutConstraint(item: contentView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0.0)

        let bottomConstraint = NSLayoutConstraint(item: contentView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0.0)

        let leftConstraint = NSLayoutConstraint(item: contentView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1.0, constant: 0.0)

        let rightConstraint = NSLayoutConstraint(item: contentView, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1.0, constant: 0.0)

        let constraints = [topConstraint, bottomConstraint, leftConstraint, rightConstraint]

        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints(constraints)
    }

    func updateCurrentIndex(index: Int, animated: Bool) {
        tabButtons[currentIndex].backgroundColor = UIColor.whiteColor()
        tabButtons[index].backgroundColor = UIColor(red: 0.88, green: 1.0, blue: 0.87, alpha: 1.0)
        currentIndex = index
    }

    private func randomColor() -> UIColor {
        let red: Float = Float(arc4random_uniform(100)) * 0.01
        let green: Float = Float(arc4random_uniform(100)) * 0.01
        let blue: Float = Float(arc4random_uniform(100)) * 0.01

        return UIColor(colorLiteralRed: red, green: green, blue: blue, alpha: 1.0)
    }
}


// UIScrollViewDelegate 

extension ContentsView: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0.0 || self.frame.minY < 0.0 {
            scrollDidChangedBlock?(scroll: scrollView.contentOffset.y, shouldScroll: true)
            scrollView.contentOffset.y = 0.0
        } else {
            let scroll = scrollView.contentOffset.y - scrollStart
            scrollDidChangedBlock?(scroll: scroll, shouldScroll: false)
            scrollStart = scrollView.contentOffset.y
        }
    }
}


// IBAction

extension ContentsView {

    @IBAction private func touchButtonTouchUpInside(button: UIButton) {
        containerView.backgroundColor = randomColor()
    }


    @IBAction func tabButtonTouchUpInside(button: UIButton) {
        tabButtonPressedBlock?(button.tag)
        updateCurrentIndex(button.tag, animated: true)
    }
}
