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
  }
  // MARK: - Helpers
  func configureController() {
    view.backgroundColor = .blue
    tabBar.backgroundColor = .white
    let map = tabBarNavigationController(unselectedImage: #imageLiteral(resourceName: "map-pin"), selectedImage: #imageLiteral(resourceName: "map-pin"), rootViewController: MapViewController())
    let add = tabBarNavigationController(unselectedImage: #imageLiteral(resourceName: "add-pin"), selectedImage: #imageLiteral(resourceName: "add-pin"), rootViewController: MainViewController())
    let myPage = tabBarNavigationController(unselectedImage: #imageLiteral(resourceName: "mypage-pin"), selectedImage: #imageLiteral(resourceName: "mypage-pin"), rootViewController: myPageVC())

      viewControllers = [map, add, myPage]
  }
  func tabBarNavigationController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController) -> UINavigationController {
    let nav = UINavigationController(rootViewController: rootViewController)
    nav.tabBarItem.image = unselectedImage
    nav.tabBarItem.selectedImage = selectedImage
    nav.navigationBar.tintColor = .systemBlue
    return nav
  }
}
