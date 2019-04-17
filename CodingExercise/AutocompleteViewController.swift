//
//  AutocompleteViewController.swift
//  CodingExercise
//
//  Copyright © 2018 slack. All rights reserved.
//

import UIKit

struct Constants {
    static let textFieldPlaceholder = "Search"
    static let cellNibName = "UserTableViewCell"
    static let cellIdentifier = "Cell"
    static let cellRowHeight: CGFloat = 44.0
    static let leftSpacing: CGFloat = 20.0
    static let bottomSpacing: CGFloat = 10.0
    static let rightSpacing: CGFloat = -20.0
}

class AutocompleteViewController: UIViewController {
    private var viewModel: AutocompleteViewModelInterface

    init(viewModel: AutocompleteViewModelInterface) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let searchTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.placeholder = Constants.textFieldPlaceholder
        textField.accessibilityLabel = Constants.textFieldPlaceholder
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let searchResultsTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Constants.cellRowHeight
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView()
        return tableView
    }()

    private let contentView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        searchTextField.delegate = self
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)

        searchResultsTableView.dataSource = self
        searchResultsTableView.delegate = self

        viewModel.delegate = self
        setupSubviews()
        self.viewModel.getBlacklist()
        

    }

    private func setupSubviews() {
        contentView.addSubview(searchTextField)
        contentView.addSubview(searchResultsTableView)
        let userCell = UINib(nibName: Constants.cellNibName, bundle: nil)
        searchResultsTableView.register(userCell, forCellReuseIdentifier: Constants.cellIdentifier)
        view.addSubview(contentView)
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            contentView.leftAnchor.constraint(equalTo: view.leftAnchor),
            contentView.rightAnchor.constraint(equalTo: view.rightAnchor),
            contentView.topAnchor.constraint(equalTo: view.centerYAnchor, constant: view.frame.height/(-8)),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: Constants.bottomSpacing * -1),

            searchTextField.topAnchor.constraint(equalTo: contentView.topAnchor),
            searchTextField.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Constants.leftSpacing),
            searchTextField.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: Constants.rightSpacing),

            searchResultsTableView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: Constants.bottomSpacing),
            searchResultsTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            searchResultsTableView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Constants.leftSpacing),
            searchResultsTableView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: Constants.rightSpacing)
            ])
    }
}

extension AutocompleteViewController: UITextFieldDelegate {
    @objc func textFieldDidChange(textField: UITextField) {
        viewModel.updateSearchText(text: searchTextField.text)
    }
}

extension AutocompleteViewController: AutocompleteViewModelDelegate {
    func usersDataUpdated() {
        searchResultsTableView.reloadData()
    }
    
    func popAlertWithTitle(title:String) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
        
    }
}

extension AutocompleteViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as! UserTableViewCell
        let username = viewModel.username(at: indexPath.row)

        cell.userDisplayNameLabel?.text = username.display_name
        cell.accessibilityLabel = username.display_name
        
        cell.userNameLabel.text = username.username
        cell.userImage.downloaded(from: username.avatar_url)
        return cell
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.usernamesCount()
    }
}

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        if let imageFromCache = imageCache.object(forKey: url.absoluteString as AnyObject){
            //            getting data from cache
            self.image = (imageFromCache as! UIImage)
            return
        }else{
            contentMode = mode
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard
                    let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                    let data = data, error == nil,
                    let image = UIImage(data: data)
                    else { return }
                DispatchQueue.main.async() {
                    self.image = image
                    imageCache.setObject(image, forKey: url.absoluteString as AnyObject)
                }
                }.resume()
        }
    }
    
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}

