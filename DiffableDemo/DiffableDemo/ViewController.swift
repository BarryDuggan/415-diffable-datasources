//
//  ViewController.swift
//  DiffableDemo
//
//  Created by Ben Scheirman on 10/22/19.
//  Copyright © 2019 Fickle Bits. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    typealias Section = String

    private lazy var loadingIndicator : UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.style = .medium
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // keep a local copy of downloaded data to speed up refreshing for the demo
    private var _downloadedEpisodes: [Episode]?

    private var episodes: [Episode] = [] {
        didSet {
            groupedEpisodes = episodes.reduce([:], { (groups, episode) -> [String: [Episode]] in
                var newGroups = groups
                let tagGroup = episode.tags.sorted().first ?? "xxx No group xxx"
                newGroups[tagGroup] = (groups[tagGroup] ?? []) + [episode]
                return newGroups
            })
        }
    }

    private var datasource: UITableViewDiffableDataSource<Section, Episode>!
    private var snapshot: NSDiffableDataSourceSnapshot<Section, Episode>!
    
    private var groupedEpisodes: [String : [Episode]] = [:] {
        didSet {
            snapshot = NSDiffableDataSourceSnapshot()
            let sections = groupedEpisodes.keys.sorted()
            snapshot.appendSections(sections)

            for section in sections {
                let group = groupedEpisodes[section]!
                snapshot.appendItems(group, toSection: section)
            }

            datasource.apply(snapshot)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: loadingIndicator)
        configureDatasource()
        refresh()
    }

    private func configureDatasource() {
        datasource = UITableViewDiffableDataSource(tableView: tableView,
                                                   cellProvider: { (tableView, indexPath, episode) -> UITableViewCell? in
                                                    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                                                    cell.textLabel?.text = episode.title
                                                    return cell
        })

        // Uncomment this to restore the stock header view behavior
        // tableView.dataSource = self
    }
    
    private func showLoading() {
        loadingIndicator.startAnimating()
    }
    
    private func hideLoading() {
        loadingIndicator.stopAnimating()
    }
    
    @IBAction func refresh() {
        if _downloadedEpisodes == nil {
            showLoading()
            API.fetchEpisodes { episodes in
                self._downloadedEpisodes = episodes
                self.hideLoading()
                self.episodes = self.munge(episodes)
            }
        } else {
            self.episodes = self.munge(_downloadedEpisodes!)
        }
    }

    private func munge(_ episodes: [Episode]) -> [Episode] {
        return episodes.filter { _ in Bool.random() }.shuffled()
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let section = groupedEpisodes.keys.sorted()[section]
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.backgroundColor = .systemGray5
        label.text = section
        return label
    }

    // Uncomment these to restore the stock header view behavior
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        let section = groupedEpisodes.keys.sorted()[section]
//        return section
//    }
//
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return datasource.numberOfSections(in: tableView)
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return datasource.tableView(tableView, numberOfRowsInSection: section)
//    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return datasource.tableView(tableView, cellForRowAt: indexPath)
    }
}

