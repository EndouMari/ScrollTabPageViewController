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


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        scrollTabPageViewController.updateLayoutIfNeeded()
    }
    
}


// MARK: - UITableVIewDataSource

extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        cell.textLabel?.text = String(indexPath.row)
        return cell
    }
    
}


// MARK: - UIScrollViewDelegate

extension ViewController: UITableViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollTabPageViewController.updateContentViewFrame()
    }
    
}


// MARK: - ScrollTabPageViewControllerProtocol

extension ViewController: ScrollTabPageViewControllerProtocol {

    var scrollTabPageViewController: ScrollTabPageViewController {
        return parent as! ScrollTabPageViewController
    }

    var scrollView: UIScrollView {
        return tableView
    }
    
}
