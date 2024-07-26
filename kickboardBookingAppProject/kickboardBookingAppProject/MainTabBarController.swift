//
//  MainTabBarController.swift
//  kickboardBookingAppProject
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
    let map = tabBarNavigationController(unselectedImage: #imageLiteral(resourceName: "mappin"), selectedImage: #imageLiteral(resourceName: "mappin"), rootViewController: MapTabBarController())
    let add = tabBarNavigationController(unselectedImage: #imageLiteral(resourceName: "pluscircle"), selectedImage: #imageLiteral(resourceName: "pluscircle"), rootViewController: AddTabBarController())
    let myPage = tabBarNavigationController(unselectedImage: #imageLiteral(resourceName: "user"), selectedImage: #imageLiteral(resourceName: "user"), rootViewController: MyPageTabBarController())

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
