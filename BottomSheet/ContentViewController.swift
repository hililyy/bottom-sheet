//
//  ContentViewController.swift
//  BottomSheet
//
//  Created by 강조은 on 2023/11/03.
//

import UIKit

class ContentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    let contentView = ContentView()
    var isInitPositionZero = false
    var isFlag = false
    var isMinus = false
    var lastScrollYposition: CGFloat = 0
    override func loadView() {
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.tableView.dataSource = self
        contentView.tableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = contentView.tableView.dequeueReusableCell(withIdentifier: "ContentTableViewCell", for: indexPath) as? ContentTableViewCell else { return UITableViewCell() }
        cell.titleLabel.text = "text\(indexPath.row)"
        return cell
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isFlag = false
        
        if scrollView.contentOffset.y <= 0 {
            isInitPositionZero = true
            
        } else {
            isInitPositionZero = false
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        lastScrollYposition = scrollView.contentOffset.y
        
        if isInitPositionZero && !isFlag {
            isFlag = true
            if lastScrollYposition <= 0 {
                
                isMinus = true
            } else {
                isMinus = false
            }
        }
        
        if isMinus {
            view.isUserInteractionEnabled = false
        }
    }
}

// MARK: - ContentView
class ContentView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
        initSubviews()
        initConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.register(ContentTableViewCell.self, forCellReuseIdentifier: "ContentTableViewCell")
        return tableView
    }()
    
    func initUI() {
        backgroundColor = .white
    }
    
    func initSubviews() {
        addSubview(tableView)
    }
    
    func initConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leftAnchor.constraint(equalTo: leftAnchor),
            tableView.rightAnchor.constraint(equalTo: rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}


// MARK: - ContentTableViewCell
class ContentTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUI()
        initSubviews()
        initConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let titleLabel = UILabel()
    
    func initUI() {
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    func initSubviews() {
        contentView.addSubview(titleLabel)
    }
    
    func initConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
            titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
}
