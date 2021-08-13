//
//  RepoDetailsViewController.swift
//  Repo List
//
//  Created by Rajiv Puli on 11/08/21.
//

import UIKit

class RepoDetailsViewController: UIViewController {
    
    @IBOutlet weak var avatarIcon: UIImageView!
    @IBOutlet weak var ownerNameLabel: UILabel!
    @IBOutlet weak var repoNameLabel: UILabel!
    @IBOutlet weak var desciptionLabel: UILabel!
    @IBOutlet weak var contributorsTblView: UITableView!
    @IBOutlet weak var networkStatusView: UIView!
    @IBOutlet weak var networkStatusHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var networkStatusLabel: UILabel!
    
    var repoDetailsViewModel = RepoDetailsViewModel()
    var segueIdToCodeVC = "detailsToCode"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        avatarIcon.layer.cornerRadius = (avatarIcon.frame.height / 2)
        contributorsTblView.dataSource = self
        contributorsTblView.delegate = self
        contributorsTblView.tableFooterView = UIView(frame: .zero)
        bindData()
        if NetworkMonitor.shared.isReachable {
            repoDetailsViewModel.getContributors()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateUI()
        networkStatusChanged(status: NetworkMonitor.shared.isReachable)
        NetworkMonitor.shared.delegate = self
    }
    
    func bindData() {
        
        repoDetailsViewModel.errorMessage.bind { [unowned self] in
            guard let errorMessage = $0 else { return }
            //Handle presenting of error message (e.g. UIAlertController)
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Response", message: errorMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        repoDetailsViewModel.contributorsReponseMsg.bind { [unowned self] in
            guard let message = $0 else { return }
            //Handle presenting of error message (e.g. UIAlertController)
            DispatchQueue.main.async {
                self.addTableViewFooter(msg: message)
            }
        }
        
        repoDetailsViewModel.contributorsData.bind{ [unowned self] data in
            guard let result = data else { return }
            DispatchQueue.main.async {
                if result.count == 0 {
                    contributorsTblView.setEmptyMessage("No results found")
                } else {
                    contributorsTblView.restore()
                }
                self.contributorsTblView.reloadData()
            }
        }
        
    }
    
    func updateUI() {
        ownerNameLabel.text = repoDetailsViewModel.repoObj?.owner?.login
        repoNameLabel.text = repoDetailsViewModel.repoObj?.name
        desciptionLabel.text = repoDetailsViewModel.repoObj?.itemDescription
        
        avatarIcon?.loadThumbnail(urlSting: repoDetailsViewModel.repoObj?.owner?.avatarURL ?? imagePlaceHolder, placeHolder: imagePlaceHolder)
    }
    
    func addTableViewFooter(msg: String) {
        if msg.count > 0 {
            let customView = UIView(frame: CGRect(x: 0, y: 0, width: self.contributorsTblView.frame.size.width, height: 30))
            customView.backgroundColor = .white
            let label = UILabel(frame: customView.frame)
            label.text = msg
            label.textColor = .gray
            label.textAlignment = .center
            label.font = .italicSystemFont(ofSize: 15)
            customView.addSubview(label)
            self.contributorsTblView.tableFooterView = customView
        } else  {
            self.contributorsTblView.tableFooterView = UIView(frame: .zero)
        }
    }
    
    @IBAction func browseCodeTapped(_ sender: UIButton) {
        if NetworkMonitor.shared.isReachable {
            self.performSegue(withIdentifier: segueIdToCodeVC, sender: self)
        }
    }

}

extension RepoDetailsViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdToCodeVC {
            if let destVC = segue.destination as? RepoCodeViewController {
                destVC.repoCodeViewModel.repoURL = repoDetailsViewModel.repoObj?.htmlURL ?? ""
                destVC.repoCodeViewModel.repoName = repoDetailsViewModel.repoObj?.name ?? ""
            }
        }
    }
    
}

extension RepoDetailsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repoDetailsViewModel.contributorsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "repoDetailsCell", for: indexPath) as! ContributorCell
        cell.loadData(owner: repoDetailsViewModel.contributorsList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
}

extension RepoDetailsViewController: UITableViewDelegate {
    
}

extension RepoDetailsViewController: NetworkMonitorDelegate {
    
    func networkStatusChanged(status: Bool) {
        DispatchQueue.main.async { [unowned self] in
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
                if repoDetailsViewModel.contributorsList.count == 0 {
                    repoDetailsViewModel.getContributors()
                }
            }
        }
    }
    
}
