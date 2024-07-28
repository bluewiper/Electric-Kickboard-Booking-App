//
//  MainTabBarController.swift
//  ElecKickBoard
//
//  Created by t2023-m0019 on 7/26/24.
//

import UIKit

class MainTabBarController: UITabBarController {
  // MARK: - LifeCycle
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .red
    configureController()
      
      // a. 네비게이션 바 숨기기 - 적용이 안되서 모달창으로 변경
//      navigationController?.isNavigationBarHidden = true
      
      // 좌측 끝 밀기 제스처 비활성화 - 안먹혀서 모달창으로 변경
//      if let navigationController = self.viewControllers?.first as? UINavigationController {
//          navigationController.interactivePopGestureRecognizer?.isEnabled = false
//      }
  }
  // MARK: - Helpers
  func configureController() {
    view.backgroundColor = .blue
    tabBar.backgroundColor = .white
    let map = tabBarNavigationController(unselectedImage: #imageLiteral(resourceName: "map-pin"), selectedImage: #imageLiteral(resourceName: "map-pin"), rootViewController: MapViewController())
    let add = tabBarNavigationController(unselectedImage: #imageLiteral(resourceName: "pluscircle"), selectedImage: #imageLiteral(resourceName: "pluscircle"), rootViewController: MainViewController())
    let myPage = tabBarNavigationController(unselectedImage: #imageLiteral(resourceName: "user"), selectedImage: #imageLiteral(resourceName: "user"), rootViewController: myPageVC())

      viewControllers = [map, add, myPage]
  }
  func tabBarNavigationController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController) -> UINavigationController {
    let nav = UINavigationController(rootViewController: rootViewController)
    nav.tabBarItem.image = unselectedImage
    nav.tabBarItem.selectedImage = selectedImage
    nav.navigationBar.tintColor = .systemBlue
      
      // 좌측 끝 밀기 제스처 비활성화
      nav.interactivePopGestureRecognizer?.isEnabled = false
      
    return nav
  }
}
