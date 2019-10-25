//
//  ViewController.swift
//  DiffableDemo
//
//  Created by Ben Scheirman on 10/22/19.
//  Copyright © 2019 Fickle Bits. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
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
    
    private var groupedEpisodes: [String : [Episode]] = [:] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: loadingIndicator)
        refresh()
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return groupedEpisodes.keys.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sortedSections = groupedEpisodes.keys.sorted()
        return sortedSections[section]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sortedSections = groupedEpisodes.keys.sorted()
        return groupedEpisodes[sortedSections[section]]?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let sortedSections = groupedEpisodes.keys.sorted()
        if let episodesGroup = groupedEpisodes[sortedSections[indexPath.section]] {
            let episode = episodesGroup[indexPath.row]
            cell.textLabel?.text = episode.title
        } else {
            cell.textLabel?.text = "?"
        }
        
        return cell
    }
}

