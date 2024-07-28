//
//  LoginViewController.swift
//  kickboardBookingAppProject
//
//  Created by arthur on 7/23/24.
//

import UIKit
import SnapKit

class LoginViewController: UIViewController {
    
    private let loginView = LoginView()
    
    override func loadView() {
        view = loginView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        setupAction()
        checkAutoLogin()
        
        // a. 키보드 노티피케이션 설정
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // B. 텍스트 필드에 대리자 설정
        [ loginView.emailID, loginView.password ].forEach {
            $0.delegate = self
        }
        
        // 화면을 터치하면 키보드를 내리도록 설정
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupAction() {
        loginView.loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        loginView.signUpButton.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
    }
    
    private func checkAutoLogin() {
//        // 로그인 정보 저장 여부 확인
//        let isAutoLoginEnabled = UserDefaults.standard.bool(forKey: "로그인 정보 저장")
        
        // 저장된 로그인 정보가 있고, 자동 로그인 활성화된 경우
        if let data = UserDefaults.standard.data(forKey: "loginModel"),
           let loginModel = try? JSONDecoder().decode(LoginModel.self, from: data),
           UserDefaults.standard.bool(forKey: "로그인 정보 저장") {
            // a. 자동 로그인 처리
            let alert = UIAlertController(title: "Auto Login", message: "Welcome Back, \(loginModel.emailID)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .default, handler: { _ in
                self.navigateToHome()
            }))
            alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion:  nil)
        }
    }
    
    @objc private func handleLogin() {
        guard let email = loginView.emailID.text, isValidEmail(email),
              let password = loginView.password.text, isValidPassword(password) else {
            shakeView(loginView)
            return
        }
        
        if let data = UserDefaults.standard.data(forKey: "loginModel"),
           let loginModel = try? JSONDecoder().decode(LoginModel.self, from: data),
           email == loginModel.emailID && password == loginModel.password {
            if loginView.rememberCheckBox.isSelected {
                UserDefaults.standard.set(true, forKey: "로그인 정보 저장")
            } else {
                UserDefaults.standard.set(false, forKey: "로그인 정보 저장")
            }
            
            // 이메일과 비밀번호 초기화
            loginView.emailID.text = ""
            loginView.password.text = ""
            navigateToHome()
            
        } else {
            shakeView(loginView)
            let alert = UIAlertController(title: "Error", message: "ID or password", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    // a.틀리면 텍스트 흔들리게 하기
    private func shakeView(_ view: UIView) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.values = [-10, 10, -10, 10, -5, 5, -5, 5, 0]
        animation.duration = 0.6
        view.layer.add(animation, forKey: "shake")
        // 진동추가
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    @objc private func handleSignUp() {
        let signUpVC = SignUpViewController()
        navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = "^.*(?=^.{8,16}$)(?=.*\\d)(?=.*[a-zA-Z])(?=.*[!@#$%^&+=]).*$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    
    private func navigateToHome() {
        let homeVC = MainTabBarController()
//        navigationController?.pushViewController(homeVC, animated: true)
        homeVC.modalPresentationStyle = .fullScreen // 전체 화면으로 표시
        self.present(homeVC, animated: true, completion: nil)
    }
    
    // a. 키보드가 나타날 때 호출되는 메서드
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height
        
        // 현재 활성화된 텍스트 필드가 키보드에 가려지는 경우
        if let activeField = view.findFirstResponder() as? UITextField,
           view.convert(activeField.frame, from: activeField.superview).maxY > (view.frame.height - keyboardHeight) {
            view.frame.origin.y = -keyboardHeight / 4
        }
    }
    
    // a. 키보드가 사라질 때 호출되는 메서드
    @objc private func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    // 화면을 터치하면 키보드를 내리기 위한 메서드
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

extension LoginViewController: UITextFieldDelegate {
    
    // A. UITextFieldDelegate 메서드 구현
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == loginView.emailID {
            loginView.password.becomeFirstResponder()
        } else if textField == loginView.password {
            textField.resignFirstResponder()
        }
        return true
    }
}

// 현재 활성화된 텍스트 필드를 찾기 위한 확장 메서드
extension UIView {
    func findResponder() -> UIResponder? {
        if self.isFirstResponder {
            return self
        }
        for subview in subviews {
            if let responder = subview.findResponder() {
                return responder
            }
        }
        return nil
    }
}

