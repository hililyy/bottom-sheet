//
//  ViewController.swift
//  BottomSheet
//
//  Created by 강조은 on 2023/10/27.
//

import UIKit

class ViewController: UIViewController {
    
    let button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("열려랍", for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .lightGray
        initSubView()
        initConstraints()
        initTarget()
    }
    
    func initSubView() {
        view.addSubview(button)
    }
    
    func initConstraints() {
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func initTarget() {
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    @objc func buttonTapped() {
        let bottomSheetVC = BottomSheetViewController(contentVC: UIViewController())
        self.present(bottomSheetVC, animated: false)
    }
}
