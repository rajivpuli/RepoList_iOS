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
    
    var repoDetailsViewModel = RepoDetailsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        avatarIcon.layer.cornerRadius = (avatarIcon.frame.height / 2)
        contributorsTblView.dataSource = self
        contributorsTblView.delegate = self
        contributorsTblView.tableFooterView = UIView(frame: .zero)
        bindData()
        repoDetailsViewModel.getContributors()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateUI()
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
        desciptionLabel.text = repoDetailsViewModel.repoObj?.description
        
        avatarIcon?.loadThumbnail(urlSting: repoDetailsViewModel.repoObj?.owner?.avatarURL ?? "", placeHolder: "")
    }
    
    @IBAction func browseCodeTapped(_ sender: UIButton) {
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "repoDetailsCell", for: indexPath)
        cell.textLabel?.text = repoDetailsViewModel.contributorsList[indexPath.row].login
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
}

extension RepoDetailsViewController: UITableViewDelegate {
    
}
