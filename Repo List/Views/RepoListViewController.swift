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
    
    var activityIndicator = UIActivityIndicatorView()
    
    var repoListViewModel = RepoListViewModel()
    let segueIdOfDetailsVC = "showDetails"
    
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        removeKeyboardObservers()
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
        NotificationCenter.default.removeObserver(self, forKeyPath: UIResponder.keyboardWillShowNotification.rawValue, context: nil)
        
        NotificationCenter.default.removeObserver(self, forKeyPath: UIResponder.keyboardWillHideNotification.rawValue, context: nil)
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
        self.view.addSubview(activityIndicator)
        self.view.bringSubviewToFront(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    func hideLoader() {
        if activityIndicator.isAnimating {
            activityIndicator.removeFromSuperview()
            activityIndicator.stopAnimating()
        }
    }
    
    func addTableViewFooter(input: Bool) {
        if input {
            let customView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 30))
            customView.backgroundColor = .white
            let label = UILabel(frame: customView.frame)
            label.text = "No more records"
            label.textColor = .gray
            label.textAlignment = .center
            label.font = .italicSystemFont(ofSize: 15)
            customView.addSubview(label)
            self.tableView.tableFooterView = customView
        }
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
        
        if indexPath.row == (repoListViewModel.repoList.count - 1) {
            repoListViewModel.loadMorePages()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.row == (repoListViewModel.repoList.count - 1)) {
            let spinner = UIActivityIndicatorView(style: .gray)
            spinner.startAnimating()
            spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))

            self.tableView.tableFooterView = spinner
            self.tableView.tableFooterView?.isHidden = false
        } else {
            self.tableView.tableFooterView = UIView(frame: .zero)
        }
    }
    
}

extension RepoListViewController: UITableViewDelegate {
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        repoListViewModel.selectedRepo = repoListViewModel.repoList[indexPath.row]
        self.performSegue(withIdentifier: segueIdOfDetailsVC, sender: self)
    }
    
}

extension RepoListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 0 {
            showLoader()
            repoListViewModel.callSearchAPI(query: searchText, isNewRequest: true)
        } else {
            hideLoader()
            repoListViewModel.cancelRequest()
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
