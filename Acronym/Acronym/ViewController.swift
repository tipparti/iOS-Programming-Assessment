//
//  ViewController.swift
//  Acronym
//
//  Created by Naina Sai Tipparti on 3/10/17.
//  Copyright © 2017 Naina Sai Tipparti. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController {
    
    // 1
    let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
    // 2
    var dataTask: URLSessionDataTask?
    
    // MARK: Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var searchResults = [Words]()
    
    lazy var tapRecognizer: UITapGestureRecognizer = {
        var recognizer = UITapGestureRecognizer(target:self, action: #selector(ViewController.dismissKeyboard))
        return recognizer
    }()
    
    lazy var downloadsSession: URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "bgSessionConfiguration")
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
    }()
    
    // MARK: View controller methods

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        _ = self.downloadsSession
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Keyboard dismissal
    
    func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
    // MARK: Handling Search Results
    
    // This helper method helps parse response JSON NSData into an array of Track objects.
    func updateSearchResults(_ data: Data?) {
        searchResults.removeAll()
        do {
        if let data = data, case let response = try JSONSerialization.jsonObject(with: data, options:[])  {
                
                // Get the results array
                if let array: NSArray = response as? NSArray {
                    if (array.count>0){
                        let result = array.object(at: 0) as! NSDictionary
                        let jsonArray = result.value(forKey: "lfs") as! NSArray
                        print( jsonArray)
                        for listDictonary in jsonArray as [AnyObject] {
                            if let listDictonary = listDictonary as? [String: AnyObject]{
                                // Parse the search result
                                print(listDictonary)
                                let name = listDictonary["lf"] as? String
                                let freq = listDictonary["freq"] as! Int
                                let since = listDictonary["since"] as! Int
                                searchResults.append(Words(name: name, freq: freq, since: since))
                            } else {
                                print("Not a dictionary")
                            }
                        }
                    }
                } else {
                    print("Results key not found in dictionary")
                }
            } else {
                print("JSON Error")
            }
        } catch let error as NSError {
            print("Error parsing results: \(error.localizedDescription)")
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.setContentOffset(CGPoint.zero, animated: false)
        }
    }
}

// MARK: - NSURLSessionDelegate

extension ViewController: URLSessionDelegate {
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            if let completionHandler = appDelegate.backgroundSessionCompletionHandler {
                appDelegate.backgroundSessionCompletionHandler = nil
                DispatchQueue.main.async(execute: {
                    completionHandler()
                })
            }
        }
    }
}

// MARK: - UISearchBarDelegate

extension ViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
        ProgressBar.show(delegate: self)

        if !searchBar.text!.isEmpty {
            // 1
            if dataTask != nil {
                dataTask?.cancel()
            }
            // 2
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            // 3
            let expectedCharSet = CharacterSet.urlQueryAllowed
            let searchTerm = searchBar.text!.addingPercentEncoding(withAllowedCharacters: expectedCharSet)!
            // 4
            let url = URL(string: "http://www.nactem.ac.uk/software/acromine/dictionary.py?sf=\(searchTerm)")
            // 5
            dataTask = defaultSession.dataTask(with: url!, completionHandler: {
                data, response, error in
                // 6
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                // 7
                if let error = error {
                    print(error.localizedDescription)
                } else if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        self.updateSearchResults(data)
                        ProgressBar.hide(delegate: self)
                    }
                }
            })
            // 8
            dataTask?.resume()
        }
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        view.addGestureRecognizer(tapRecognizer)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        view.removeGestureRecognizer(tapRecognizer)
    }
}

// MARK: UITableViewDataSource

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordCell", for: indexPath) as! WordCell
        
        let list = searchResults[indexPath.row]
            // Configure title and artist labels
            cell.titleLabel.text = list.name
            cell.artistLabel.text = "Frequency: \(list.freq) | Since: \(list.since)"
        return cell
    }
}

// MARK: UITableViewDelegate

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62.0
    }
    
}


