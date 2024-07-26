//
//  SplashViewController.swift
//  kickboardBookingAppProject
//
//  Created by arthur on 7/23/24.
//

import UIKit

class SplashViewController: UIViewController {
    
    let logoImageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "kickgoing")
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()

    }
    
    private func setUpUI() {
        view.backgroundColor = .white
        
        view.addSubview(logoImageView)
        
        // A.splash UI
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.topAnchor),
            logoImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            logoImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            logoImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // A.2초 뒤에 메인 로그인 페이지로 이동 / UI 비동기 처리 
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.showMainScreen()
        }
    }
    
    // 모달창 메인 페이지로 이동
    private func showMainScreen() {
        let loginVC = LoginViewController()
        let navigationVC = UINavigationController(rootViewController: loginVC)
        navigationVC.modalPresentationStyle = .fullScreen
        self.present(navigationVC, animated: true, completion: nil)
    }

}
