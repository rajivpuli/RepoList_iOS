//
//  RepoListViewController.swift
//  Repo List
//
//  Created by Rajiv Puli on 10/08/21.
//

import UIKit

class RepoListViewController: UIViewController {
    

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var networkStatusView: UIView!
    @IBOutlet weak var networkStatusHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var networkStatusLabel: UILabel!
    
    var activityIndicator = UIActivityIndicatorView()
    
    var repoListViewModel = RepoListViewModel()
    let segueIdOfDetailsVC = "showDetails"
    
    var isDataLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
        searchBar.delegate = self
        bindData()
        addKeyboardObservers()
        addTooBar()
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.setEmptyMessage("Enter input to get results")
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .gray
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        networkStatusChanged(status: NetworkMonitor.shared.isReachable)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NetworkMonitor.shared.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeKeyboardObservers()
    }
    
    func bindData() {
        
        repoListViewModel.errorMessage.bind { [unowned self] in
            guard let errorMessage = $0 else { return }
            //Handle presenting of error message (e.g. UIAlertController)
            DispatchQueue.main.async {
                self.hideLoader()
                let alert = UIAlertController(title: "Response", message: errorMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        repoListViewModel.repoListData.bind{ [unowned self] data in
            guard let result = data else { return }
            DispatchQueue.main.async {
                hideLoader()
                if result.count == 0 {
                    tableView.setEmptyMessage("No results found")
                } else {
                    tableView.restore()
                }
                self.tableView.reloadData()
            }
        }
        
        repoListViewModel.noMoreRecords.bind{ [unowned self] data in
            guard let result = data else { return }
            DispatchQueue.main.async {
                addTableViewFooter(input: result)
            }
        }
    }
    
    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func keyboardWillShow(_ notification:Notification) {

        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {

        if let _ = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    func addTooBar() {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 50))
        toolBar.barStyle = UIBarStyle.default
        toolBar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneButtonTapped))]
        toolBar.sizeToFit()
        searchBar.inputAccessoryView = toolBar
    }
    
    @objc func cancelButtonTapped() {
        
    }
    
    @objc func doneButtonTapped() {
        searchBar.endEditing(true)
    }
    
    func showLoader() {
        activityIndicator.frame = tableView.frame
        activityIndicator.startAnimating()
        activityIndicator.color = .black
        self.view.addSubview(activityIndicator)
        self.view.bringSubviewToFront(activityIndicator)
    }
    
    func hideLoader() {
        if activityIndicator.isAnimating {
            activityIndicator.removeFromSuperview()
            activityIndicator.stopAnimating()
        }
    }
    
    func addTableViewFooter(input: Bool) {
        if input && repoListViewModel.repoList.count > 0{
            let customView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 30))
            customView.backgroundColor = .white
            let label = UILabel(frame: customView.frame)
            label.text = "No more records"
            label.textColor = .gray
            label.textAlignment = .center
            label.font = .italicSystemFont(ofSize: 15)
            customView.addSubview(label)
            self.tableView.tableFooterView = customView
        } else  {
            self.tableView.tableFooterView = UIView(frame: .zero)
        }
    }
    
    func addLoadingFooter() {
        let spinner = UIActivityIndicatorView(style: .gray)
        spinner.startAnimating()
        spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))

        self.tableView.tableFooterView = spinner
        self.tableView.tableFooterView?.isHidden = false
    }

}

extension RepoListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repoListViewModel.repoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "repoCell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = repoListViewModel.repoList[indexPath.row].name
//        cell.detailTextLabel?.text = repoListViewModel.repoList[indexPath.row].owner?.login
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if (indexPath.row == (repoListViewModel.repoList.count - 1)) {
//            let spinner = UIActivityIndicatorView(style: .gray)
//            spinner.startAnimating()
//            spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
//
//            self.tableView.tableFooterView = spinner
//            self.tableView.tableFooterView?.isHidden = false
//        } else {
//            self.tableView.tableFooterView = UIView(frame: .zero)
//        }
    }
    
}

extension RepoListViewController: UITableViewDelegate {
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        repoListViewModel.selectedRepo = repoListViewModel.repoList[indexPath.row]
        self.performSegue(withIdentifier: segueIdOfDetailsVC, sender: self)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        print("scrollViewWillBeginDragging")
        isDataLoading = false
    }
    
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating")
    }
    //Pagination
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("scrollViewDidEndDragging")
        if ((tableView.contentOffset.y + tableView.frame.size.height) >= tableView.contentSize.height)
        {
            if NetworkMonitor.shared.isReachable {
                if !isDataLoading{
                    isDataLoading = true
                    addLoadingFooter()
                    repoListViewModel.loadMorePages()
                }
            }
        }
    }

    
}

extension RepoListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        tableView.restore()
        showLoader()
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.callSearchAPI(_:)), object: searchBar)
        
        if let query = searchBar.text, query.trimmingCharacters(in: .whitespaces) != "" {
            repoListViewModel.loadOfflineData(query: query)
            perform(#selector(self.callSearchAPI(_:)), with: searchBar, afterDelay: DELAY_TO_SEND_REQUEST)
        } else {
            hideLoader()
            repoListViewModel.clearData()
        }
    }

    @objc func reload(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, query.trimmingCharacters(in: .whitespaces) != "" else {
            print("nothing to search")
            return
        }

        print(query)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        repoListViewModel.clearData()
    }
    
    @objc func callSearchAPI(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, query.trimmingCharacters(in: .whitespaces) != "" else {
            print("nothing to search")
            return
        }
        if NetworkMonitor.shared.isReachable {
            repoListViewModel.callSearchAPI(query: query, isNewRequest: true)
        } else {
            hideLoader()
            
        }
    }
    
}

extension RepoListViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdOfDetailsVC {
            if let destVC = segue.destination as? RepoDetailsViewController {
                destVC.repoDetailsViewModel.repoObj = repoListViewModel.selectedRepo
            }
        }
    }
    
}

extension RepoListViewController: NetworkMonitorDelegate {
    
    func networkStatusChanged(status: Bool) {
        DispatchQueue.main.async {
            let currentStatus: NetworkStatus = status ? .online : .offline
            self.networkStatusView.backgroundColor = currentStatus.getColor()
            self.networkStatusLabel.text = currentStatus.getMsg()
            
            if currentStatus == .offline {
                self.networkStatusHeightConstraint.constant = 20
            } else {
                self.view.layoutIfNeeded() // force any pending operations to finish
                UIView.animateKeyframes(withDuration: 0.5, delay: 1.0, options: [], animations: { () -> Void in
                    self.networkStatusHeightConstraint.constant = 0
                    self.view.layoutIfNeeded()
                }, completion: nil)
            }
        }
    }
    
}
