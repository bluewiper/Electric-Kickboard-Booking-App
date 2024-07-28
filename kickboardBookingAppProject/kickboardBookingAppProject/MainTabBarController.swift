//
//  MainTabBarController.swift
//  ElecKickBoard
//
//  Created by t2023-m0019 on 7/26/24.
//

import UIKit

class MainTabBarController: UITabBarController/* UITabBarControllerDelegate*/ {
  // MARK: - LifeCycle
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .red
    configureController()
    // a. 추가한 사항 - 위쪽에 델리게이트 선언합 UITabBarControllerDelegate
//    delegate = self
      
  }
  // MARK: - Helpers
  func configureController() {
    view.backgroundColor = .blue
    tabBar.backgroundColor = .white
    let map = tabBarNavigationController(unselectedImage: #imageLiteral(resourceName: "mappin"), selectedImage: #imageLiteral(resourceName: "mappin"), rootViewController: MapViewController())
    let add = tabBarNavigationController(unselectedImage: #imageLiteral(resourceName: "add-pin"), selectedImage: #imageLiteral(resourceName: "add-pin"), rootViewController: MainViewController())
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
    // a.추가 사항 UITabBarControllerDelegate 메서드
//    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        // add 탭을 선택했을 때 RegisterModalViewController 표시
//        if let navController = viewController as? UINavigationController,
//           navController.viewControllers.first is MainViewController {
//            let registerVC = RegisterModalViewController()
//            registerVC.modalPresentationStyle = .pageSheet
//            if let sheet = registerVC.sheetPresentationController {
//                sheet.detents = [.medium(), .large()]
//                sheet.preferredCornerRadius = 20
//            }
//            navController.present(registerVC, animated: true, completion: nil)
//        }
//    }
}
