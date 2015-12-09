//
//  ViewController.swift
//  ScrollTabPageViewController
//
//  Created by EndouMari on 2015/12/06.
//  Copyright © 2015年 EndouMari. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
    }


    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        scrollTabPageViewController.updateLayoutIfNeeded()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }
}


// MARK: - UITableVIewDataSource

extension ViewController: UITableViewDataSource {

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

extension ViewController: UITableViewDelegate {

    func scrollViewDidScroll(scrollView: UIScrollView) {
        scrollTabPageViewController.updateContentViewFrame()
    }
}


// MARK: - ScrollTabPageViewControllerProtocol

extension ViewController: ScrollTabPageViewControllerProtocol {

    var scrollTabPageViewController: ScrollTabPageViewController {
        return parentViewController as! ScrollTabPageViewController
    }

    var scrollView: UIScrollView {
        return tableView
    }
}
