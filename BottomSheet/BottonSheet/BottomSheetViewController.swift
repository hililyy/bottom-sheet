//
//  BottomSheetViewController.swift
//  BottomSheet
//
//  Created by 강조은 on 2023/10/27.
//

import UIKit

final class BottomSheetViewController: UIViewController {
    
    private let bottomSheetView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        return view
    }()
    
    private let dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.0
        return view
    }()
    
    private let dragIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 3
        return view
    }()
    
    private var contentVC: UIViewController
    private var bottomSheetViewTopConstraint: NSLayoutConstraint!
    private lazy var bottomSheetPanStartingTopConstant: CGFloat = fullPositionMinTopConstant
    var fullPositionMinTopConstant: CGFloat = 30.0
    var halfPositionViewHeight: CGFloat = 400
    
    init(contentVC: UIViewController) {
        self.contentVC = contentVC
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initSubView()
        initConstraints()
        initGesture()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showBottomSheet()
    }
    
    private func initSubView() {
        view.addSubview(dimmedView)
        view.addSubview(bottomSheetView)
        view.addSubview(dragIndicatorView)
        addChild(contentVC)
        bottomSheetView.addSubview(contentVC.view)
        contentVC.didMove(toParent: self)
    }
    
    private func getTopSafeArea() -> CGFloat {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first(where: { $0.isKeyWindow }),
           let root = window.rootViewController {
            return root.view.safeAreaInsets.top
        }
        
        return 0
    }
    
    private func initConstraints() {
        dimmedView.translatesAutoresizingMaskIntoConstraints = false
        bottomSheetView.translatesAutoresizingMaskIntoConstraints = false
        dragIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        contentVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        bottomSheetViewTopConstraint = bottomSheetView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: UIScreen.main.bounds.size.height - getTopSafeArea())
        
        NSLayoutConstraint.activate([
            dimmedView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            bottomSheetViewTopConstraint,
            bottomSheetView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            bottomSheetView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            bottomSheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            dragIndicatorView.bottomAnchor.constraint(equalTo: bottomSheetView.topAnchor, constant: -10),
            dragIndicatorView.widthAnchor.constraint(equalToConstant: 60),
            dragIndicatorView.heightAnchor.constraint(equalToConstant: dragIndicatorView.layer.cornerRadius * 2),
            dragIndicatorView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            contentVC.view.topAnchor.constraint(equalTo: bottomSheetView.topAnchor),
            contentVC.view.leadingAnchor.constraint(equalTo: bottomSheetView.leadingAnchor),
            contentVC.view.trailingAnchor.constraint(equalTo: bottomSheetView.trailingAnchor),
            contentVC.view.bottomAnchor.constraint(equalTo: bottomSheetView.bottomAnchor)
        ])
    }
    
    private func initGesture() {
        let dimmedTap = UITapGestureRecognizer(target: self, action: #selector(dimmedViewTapped(_:)))
        dimmedView.addGestureRecognizer(dimmedTap)
        dimmedView.isUserInteractionEnabled = true
        
        let viewPan = UIPanGestureRecognizer(target: self, action: #selector(viewPanned(_:)))
        viewPan.delaysTouchesBegan = false
        viewPan.delaysTouchesEnded = false
        view.addGestureRecognizer(viewPan)
    }
    
    @objc private func dimmedViewTapped(_ tapRecognizer: UITapGestureRecognizer) {
        hideBottomSheetAndGoBack()
    }
    
    @objc private func viewPanned(_ panGestureRecognizer: UIPanGestureRecognizer) {
        let translation = panGestureRecognizer.translation(in: view)
        let dragSpeed = panGestureRecognizer.velocity(in: view)
        
        switch panGestureRecognizer.state {
        case .began:
            bottomSheetPanStartingTopConstant = bottomSheetViewTopConstraint.constant
            
        case .changed:
            if bottomSheetPanStartingTopConstant + translation.y > fullPositionMinTopConstant {
                bottomSheetViewTopConstraint.constant = bottomSheetPanStartingTopConstant + translation.y
            }
            
            dimmedView.alpha = dimAlphaWithBottomSheetTopConstraint(value: bottomSheetViewTopConstraint.constant)
            
        case .ended:
            if dragSpeed.y > 1500 {
                hideBottomSheetAndGoBack()
                return
            }
            
            if dragSpeed.y < -1500 {
                showBottomSheet(atState: .full)
                return
            }
            
            setupViewPositionAtDragFinished()
            
        default:
            break
        }
    }
    
    private func showBottomSheet(atState: BottomSheetViewPosition = .half) {
        if atState == .half {
            let safeAreaHeight: CGFloat = view.safeAreaLayoutGuide.layoutFrame.height
            let bottomPadding: CGFloat = view.safeAreaInsets.bottom
            bottomSheetViewTopConstraint.constant = safeAreaHeight + bottomPadding - halfPositionViewHeight
        } else {
            bottomSheetViewTopConstraint.constant = fullPositionMinTopConstant
        }
        
        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       options: .curveEaseIn,
                       animations: {
            self.dimmedView.alpha = self.dimAlphaWithBottomSheetTopConstraint(value: self.bottomSheetViewTopConstraint.constant)
            self.view.layoutIfNeeded()
        })
    }
    
    private func hideBottomSheetAndGoBack() {
        let safeAreaHeight = view.safeAreaLayoutGuide.layoutFrame.height
        let bottomPadding = view.safeAreaInsets.bottom
        
        bottomSheetViewTopConstraint.constant = safeAreaHeight + bottomPadding
        
        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       options: .curveEaseIn,
                       animations: {
            self.dimmedView.alpha = 0.0
            self.view.layoutIfNeeded()
        }) { _ in
            if self.presentingViewController != nil {
                self.dismiss(animated: false)
            }
        }
    }
    
    private func setupViewPositionAtDragFinished() {
        let safeAreaHeight = view.safeAreaLayoutGuide.layoutFrame.height
        let bottomPadding = view.safeAreaInsets.bottom
        let defaultPadding = safeAreaHeight + bottomPadding - halfPositionViewHeight
        
        let nearestState = getNearest(to: bottomSheetViewTopConstraint.constant,
                                      positionConstraintsToTop: [fullPositionMinTopConstant,
                                                                 defaultPadding,
                                                                 safeAreaHeight + bottomPadding])
        
        switch nearestState {
        case .full:
            showBottomSheet(atState: .full)
            
        case .half:
            showBottomSheet(atState: .half)
            
        case .empty:
            hideBottomSheetAndGoBack()
        }
    }
    
    private func getNearest(to number: CGFloat, positionConstraintsToTop values: [CGFloat]) -> BottomSheetViewPosition {
        guard let nearestValue = values.min(by: { abs(number - $0) < abs(number - $1) }) else { return .full }
        
        switch nearestValue {
        case values[0]:
            return .full
            
        case values[1]:
            return .half
            
        default:
            return .empty
        }
    }
    
    private func dimAlphaWithBottomSheetTopConstraint(value: CGFloat) -> CGFloat {
        let fullDimAlpha: CGFloat = 0.7
        
        let safeAreaHeight = view.safeAreaLayoutGuide.layoutFrame.height
        let bottomPadding = view.safeAreaInsets.bottom
        
        let fullDimPosition = (safeAreaHeight + bottomPadding - halfPositionViewHeight) / 2
        let noDimPosition = safeAreaHeight + bottomPadding
        
        if value < fullDimPosition {
            return fullDimAlpha
        }
        if value > noDimPosition {
            return 0.0
        }
        
        return fullDimAlpha * (1 - ((value - fullDimPosition) / (noDimPosition - fullDimPosition)))
    }
}
