//
//  ContentsView.swift
//  ScrollTabPageViewController
//
//  Created by EndouMari on 2015/12/06.
//  Copyright © 2015年 EndouMari. All rights reserved.
//

import UIKit

class ContentsView: UIView {

    var currentIndex: Int = 0
    var tabButtonPressedBlock: ((_ index: Int) -> Void)?
    var scrollDidChangedBlock: ((_ scroll: CGFloat, _ shouldScroll: Bool) -> Void)?

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
        Bundle.main.loadNibNamed("ContentsView", owner: self, options: nil)
        addSubview(contentView)

        setupConstraints()

        scrollView.delegate = self
        scrollView.scrollsToTop = false
    }
    
}


// MARK: - View

extension ContentsView {

    private func setupConstraints() {
        let topConstraint = NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0)

        let bottomConstraint = NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0)

        let leftConstraint = NSLayoutConstraint(item: contentView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0)

        let rightConstraint = NSLayoutConstraint(item: contentView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0)

        let constraints = [topConstraint, bottomConstraint, leftConstraint, rightConstraint]

        contentView.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(constraints)
    }

    private func randomColor() -> UIColor {
        let red = CGFloat(arc4random_uniform(255)) / 255.0
        let green = CGFloat(arc4random_uniform(255)) / 255.0
        let blue = CGFloat(arc4random_uniform(255)) / 255.0
        
        return UIColor(displayP3Red: red, green: green, blue: blue, alpha: 1.0)
    }

    func updateCurrentIndex(index: Int, animated: Bool) {
        tabButtons[currentIndex].backgroundColor = UIColor.white
        tabButtons[index].backgroundColor = UIColor(red: 0.88, green: 1.0, blue: 0.87, alpha: 1.0)
        currentIndex = index
    }
    
}


// MARK: - UIScrollViewDelegate

extension ContentsView: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0.0 || frame.minY < 0.0 {
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

    @IBAction private func touchButtonTouchUpInside(button: UIButton) {
        containerView.backgroundColor = randomColor()
    }

    @IBAction private func tabButtonTouchUpInside(button: UIButton) {
        tabButtonPressedBlock?(button.tag)
        updateCurrentIndex(index: button.tag, animated: true)
    }
    
}
