//
//  LoginView.swift
//  kickboardBookingAppProject
//
//  Created by arthur on 7/24/24.
//

import UIKit
import SnapKit

class LoginView: UIView {
    
    let bossImageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "bear")
        return image
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "웰컴 투 Kick Going!"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 30)
        return label
    }()
    
    let emailID: UITextField = {
        let emailID = UITextField()
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 20)
        ]
        emailID.attributedPlaceholder = NSAttributedString(string: "email 입력해주세요.", attributes: placeholderAttributes)
        emailID.textColor = .white
        emailID.font = .boldSystemFont(ofSize: 20)
        emailID.backgroundColor = .systemGray
        emailID.layer.cornerRadius = 5
        emailID.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: emailID.frame.height))
        emailID.leftViewMode = .always
        emailID.autocapitalizationType = .none //대문자 변경 없이
        return emailID
    }()
    
    let password: UITextField = {
        let password = UITextField()
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize:20)
        ]
        password.attributedPlaceholder = NSAttributedString(string: "password 입력해주세요", attributes: placeholderAttributes)
        password.textColor = .white
        password.font = .boldSystemFont(ofSize: 20)
        password.backgroundColor = .systemGray
        password.layer.cornerRadius = 5
        password.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: password.frame.height))
        password.leftViewMode = .always
        password.isSecureTextEntry = true // 텍스트 안보이게 설정
        password.autocapitalizationType = .none //대문자 변경 없이
        return password
    }()
    
    let togglePasswordVisibilityButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "eye"), for: .normal)
        button.tintColor = .gray
        return button
    }()
    
    let checkStacView: UIStackView = {
        let stacView = UIStackView()
        stacView.axis = .horizontal
        stacView.distribution = .fill
        stacView.spacing = 5
        stacView.clipsToBounds = true
        return stacView
    }()
    
    let rememberCheckBox: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("☐", for: .normal)
        button.setTitle("☑", for: .selected)
        return button
    }()
    
    let rememberLabel: UILabel = {
        let label = UILabel()
        label.text = "로그인 정보 저장"
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .white
        return label
    }()
    
    
    let stacView: UIStackView = {
        let stacView = UIStackView()
        stacView.axis = .horizontal
        stacView.distribution = .fillEqually
        stacView.spacing = 40
        stacView.clipsToBounds = true
        return stacView
    }()
    
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign in", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        return button
    }()
    
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        
        
        [
            bossImageView,
            nameLabel,
            emailID,
            password,
            checkStacView,
            stacView
        ].forEach { addSubview($0) }
        
        // A. 토글 버튼 패스워트 오른쪽에 추가
        password.rightView = togglePasswordVisibilityButton
        password.rightViewMode = .always
        
        [
            rememberCheckBox,
            rememberLabel
        ].forEach { checkStacView.addArrangedSubview($0) }
        
        [
            signUpButton,
            loginButton,
        ].forEach { stacView.addArrangedSubview($0) }
        
        bossImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(500)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(450)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(30)
        }
        
        emailID.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().inset(30)
            $0.height.equalTo(40)
        }
        
        password.snp.makeConstraints {
            $0.top.equalTo(emailID.snp.bottom).offset(5)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().inset(30)
            $0.height.equalTo(40)
        }
        
        togglePasswordVisibilityButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        
        checkStacView.snp.makeConstraints {
            $0.top.equalTo(password.snp.bottom).offset(5)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().inset(190)
            $0.height.equalTo(40)
        }
        
        rememberCheckBox.addTarget(self, action: #selector(toggleRemember), for: .touchUpInside)
        
        stacView.snp.makeConstraints {
            $0.top.equalTo(checkStacView.snp.bottom).offset(30)
            $0.leading.equalToSuperview().offset(60)
            $0.trailing.equalToSuperview().inset(60)
            $0.height.equalTo(50)
        }

    }
    
    @objc private func toggleRemember() {
        rememberCheckBox.isSelected.toggle()
    }
    
    @objc private func togglePasswordVisibility() {
        password.isSecureTextEntry.toggle()
        let imageName = password.isSecureTextEntry ? "eye" : "eye.slash"
        togglePasswordVisibilityButton.setImage(UIImage(systemName: imageName), for: .normal )
    }
}


extension LoginView: UITextFieldDelegate {
    
    // A. UITextFieldDelegate 메서드 구현
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameLabel {
            emailID.becomeFirstResponder()
        } else if textField == emailID {
            password.becomeFirstResponder()
        }
        
        return true
    }
}
