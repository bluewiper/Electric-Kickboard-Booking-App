//
//  SignUpViewController.swift
//  kickboardBookingAppProject
//
//  Created by arthur on 7/23/24.
//

import UIKit
import SnapKit

class SignUpViewController: UIViewController {
    
    private let signUpView = SignUpView()
    
    override func loadView() {
        view = signUpView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        setUpAction()
        
        // a. 키보드 노티피케이션 설정
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        // B. 텍스트 필드에 대리자 설정
        [signUpView.nameLabel, signUpView.emailID, signUpView.password, signUpView.phoneNumberTextField].forEach {
            $0.delegate = self
        }
        
        // 화면을 터치하면 키보드를 내리도록 설정
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setUpAction() {
        signUpView.signUpButton.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
    }
    
    @objc private func handleSignUp() {
        guard let email = signUpView.emailID.text, isValidEmail(email),
              let password = signUpView.password.text, isValidPassword(password),
              signUpView.admitCheckBox.isSelected else {
            let alert = UIAlertController(title: "Error", message: "모든 필드를 올바르게 입력해주세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true  , completion: nil)
            return
        }
        
        // 유효성 검사 통과 시 로그인 모델 객체 생성
        let loginModel = LoginModel(emailID: email, password: password)
        
        /* 로그인 모델 객체를 json 데이터로 인코딩
         인코딩 한 이유는 UserDefaults 사용된 정의 구조체를 저장하고 불러오기 위해서
         UserDefaults는 기본적으로 문자열, 숫자, 불리언 값, 배열, 딕셔너리 등 단순 데이터 타입을 저장할 수 있습니다. 
         그러나 사용자 정의 타입인 구조체를 저장하려면 이를 변환하여 저장할 필요해서 사용
         UserDefaults는 구조체와 같은 복잡한 데이터 타입을 직접 저장할 수 없어서 */
        if let encoded = try? JSONEncoder().encode(loginModel) {
            UserDefaults.standard.set(encoded, forKey: "loginModel")
        }
        
        // 가입 완료 후 로그인 화면으로 이동
        navigationController?.popViewController(animated: true)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return  NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = "^.*(?=^.{8,16}$)(?=.*\\d)(?=.*[a-zA-Z])(?=.*[!@#$%^&+=]).*$"
        return  NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
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

extension SignUpViewController: UITextFieldDelegate {
    
    // A. UITextFieldDelegate 메서드 구현
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == signUpView.nameLabel {
            signUpView.emailID.becomeFirstResponder()
        } else if textField == signUpView.emailID {
            signUpView.password.becomeFirstResponder()
        } else if textField == signUpView.password {
            signUpView.phoneNumberTextField.becomeFirstResponder()
        } else {
            signUpView.phoneNumberTextField.resignFirstResponder()
        }
        return true
    }
}

// 현재 활성화된 텍스트 필드를 찾기 위한 확장 메서드
extension UIView {
    func findFirstResponder() -> UIResponder? {
        if self.isFirstResponder {
            return self
        }
        for subview in subviews {
            if let responder = subview.findFirstResponder() {
                return responder
            }
        }
        return nil
    }
}
