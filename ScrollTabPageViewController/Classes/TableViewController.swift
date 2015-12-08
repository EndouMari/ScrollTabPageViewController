//
//  TableViewController.swift
//  ScrollTabPageViewController
//
//  Created by EndouMari on 2015/12/06.
//  Copyright © 2015年 EndouMari. All rights reserved.
//

import UIKit

class TableViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    private var shouldUpdateContentOffsetY = true
    private var scrollStartPositionY: CGFloat = 0.0

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tableView.dataSource = self
        tableView.delegate = self

        setupContentInset()

        scrollTabPageViewController.shouldScrollFrame = false

        if shouldUpdateContentOffsetY {
            setupContentOffsetY(-scrollTabPageViewController.scrollContentOffsetY)
            shouldUpdateContentOffsetY = false
        }
    }
}


// MARK: - UITableVIewDataSource

extension TableViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "Cell")
        cell.textLabel?.text = String(indexPath.row)
        return cell
    }
}


// MARK: - UIScrollViewDelegate

extension TableViewController: UITableViewDelegate {

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= -ScrollTabPageViewController.tabViewHeight {
            let scroll = ScrollTabPageViewController.contentViewHeihgt - ScrollTabPageViewController.tabViewHeight
            scrollTabPageViewController.updateContentView(-scroll)
            scrollView.scrollIndicatorInsets.top = ScrollTabPageViewController.tabViewHeight
        } else {
            let scroll = ScrollTabPageViewController.contentViewHeihgt + scrollView.contentOffset.y
            scrollTabPageViewController.updateContentView(-scroll)
            let scrollInsetTop = scrollStartPositionY - scroll
            scrollStartPositionY = scroll
            scrollView.scrollIndicatorInsets.top += scrollInsetTop
        }
    }
}


// MARK: - ScrollTabPageViewControllerProtocol

extension TableViewController: ScrollTabPageViewControllerProtocol {

    var scrollTabPageViewController: ScrollTabPageViewController {
        return parentViewController as! ScrollTabPageViewController
    }

    func setupContentInset() {
        let inset = UIEdgeInsetsMake(ScrollTabPageViewController.contentViewHeihgt, 0.0, 0.0, 0.0)
        tableView.contentInset = inset
        tableView.scrollIndicatorInsets = inset
    }

    func updateContentOffsetY(scroll: CGFloat) {
        tableView.contentOffset.y += scroll
    }

    func setupContentOffsetY(scroll: CGFloat) {
        if scroll == 0.0 {
            tableView.contentOffset.y = -ScrollTabPageViewController.contentViewHeihgt
        } else if (scroll < ScrollTabPageViewController.contentViewHeihgt - ScrollTabPageViewController.tabViewHeight) || (tableView.contentOffset.y <= -ScrollTabPageViewController.tabViewHeight) {
            tableView.contentOffset.y = -(ScrollTabPageViewController.contentViewHeihgt - scroll)
        }
    }
}
