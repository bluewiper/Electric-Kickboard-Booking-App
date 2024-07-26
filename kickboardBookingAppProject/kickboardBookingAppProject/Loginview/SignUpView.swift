//
//  signUpView.swift
//  kickboardBookingAppProject
//
//  Created by arthur on 7/24/24.
//

import UIKit
import SnapKit

class SignUpView: UIView {
    
    let signUpLabel: UILabel = {
        let label = UILabel()
        label.text = "회원가입"
        label.font = .boldSystemFont(ofSize: 40)
        label.textColor = .black
        return label
    }()
    
    let nameLabel: UITextField = {
        let name = UITextField()
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.gray,
            .font: UIFont.systemFont(ofSize: 20)
        ]
        name.attributedPlaceholder = NSAttributedString(string: "성 이름", attributes: placeholderAttributes)
        name.textColor = .black
        name.font = .boldSystemFont(ofSize: 20)
        name.layer.borderWidth = 1
        name.layer.borderColor = UIColor.gray.cgColor
        name.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        name.layer.cornerRadius = 5
        name.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: name.frame.height))
        name.leftViewMode = .always
        name.autocorrectionType = .no // 자동 교정 비활성화
        name.spellCheckingType = .no // 철자 검사 비활성화
        return name
    }()

    
    let emailID: UITextField = {
        let emailID = UITextField()
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.gray,
            .font: UIFont.systemFont(ofSize: 20)
        ]
        emailID.attributedPlaceholder = NSAttributedString(string: "email76@naver.com.", attributes: placeholderAttributes)
        emailID.textColor = .black
        emailID.font = .boldSystemFont(ofSize: 20)
        emailID.layer.borderWidth = 1
        emailID.layer.borderColor = UIColor.gray.cgColor
        emailID.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        emailID.layer.cornerRadius = 5
        emailID.autocapitalizationType = .none
        emailID.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: emailID.frame.height))
        emailID.leftViewMode = .always
        return emailID
    }()
    
    let password: UITextField = {
        let password = UITextField()
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.gray,
            .font: UIFont.systemFont(ofSize:20)
        ]
        password.attributedPlaceholder = NSAttributedString(string: "password 입력해주세요", attributes: placeholderAttributes)
        password.textColor = .black
        password.layer.borderWidth = 1
        password.layer.borderColor = UIColor.gray.cgColor
        password.font = .boldSystemFont(ofSize: 20)
        password.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        password.layer.cornerRadius = 5
        password.autocapitalizationType = .none //대문자 변경 없이
        password.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: password.frame.height))
        password.leftViewMode = .always
        password.isSecureTextEntry = true // 텍스트 안보이게 설정
        return password
    }()
    
    let togglePasswordVisibilityButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "eye"), for: .normal)
        button.tintColor = .gray
        return button
    }()
    
    let phoneNumberTextField: UITextField = {
        let phoneNumber = UITextField()
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.gray,
            .font: UIFont.systemFont(ofSize:20)
        ]
        phoneNumber.attributedPlaceholder = NSAttributedString(string: "핸드폰번호를 입력해주세요", attributes: placeholderAttributes)
        phoneNumber.textColor = .black
        phoneNumber.layer.borderWidth = 1
        phoneNumber.layer.borderColor = UIColor.gray.cgColor
        phoneNumber.font = .boldSystemFont(ofSize: 20)
        phoneNumber.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        phoneNumber.layer.cornerRadius = 5
        // 플레이스 홀드 뛰우기
        phoneNumber.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: phoneNumber.frame.height))
        phoneNumber.leftViewMode = .always
        phoneNumber.isSecureTextEntry = true // 텍스트 안보이게 설정
        return phoneNumber
    }()
    
    let togglePhoneNumberVisibilityButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "eye"), for: .normal)
        button.tintColor = .gray
        return button
    }()
    
    let checkStacView: UIStackView = {
        let stacView = UIStackView()
        stacView.axis = .horizontal
        stacView.distribution = .fill // 내부 요소가 전체 공간을 채우지 않도록 함
        stacView.spacing = 5
        stacView.clipsToBounds = true
        return stacView
    }()
    
    let admitCheckBox: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("☐", for: .normal)
        button.setTitle("☑", for: .selected)
        return button
    }()
    
    let admitLabel: UILabel = {
        let label = UILabel()
        label.text = "개인 정보 이용에 동의"
        label.font = .boldSystemFont(ofSize: 15)
        label.textColor = .black
        return label
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
        super .init(frame: frame)
        
        setUpView()

        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        
        [
            signUpLabel, nameLabel, emailID,
            password, phoneNumberTextField, checkStacView, signUpButton
        ].forEach { addSubview($0) }
    
        [
            admitCheckBox,
            admitLabel
        ].forEach { checkStacView.addArrangedSubview($0) }
        
        // A. 토글 버튼 패스워트 오른쪽에 추가
        password.rightView = togglePasswordVisibilityButton
        password.rightViewMode = .always
        
        // A. 토글 버튼 패스워트 오른쪽에 추가
        phoneNumberTextField.rightView = togglePhoneNumberVisibilityButton
        phoneNumberTextField.rightViewMode = .always
        
        signUpLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(200)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(signUpLabel.snp.bottom).offset(30)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().inset(30)
            $0.height.equalTo(40)
        }
        
        emailID.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(5)
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

        phoneNumberTextField.snp.makeConstraints {
            $0.top.equalTo(password.snp.bottom).offset(5)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().inset(30)
            $0.height.equalTo(40)
        }
        
        togglePhoneNumberVisibilityButton.addTarget(self, action: #selector(togglePhoneNumberVisibility), for: .touchUpInside)
        
        checkStacView.snp.makeConstraints {
            $0.top.equalTo(phoneNumberTextField.snp.bottom).offset(5)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().inset(190)
            $0.height.equalTo(40)
        }
        
        signUpButton.snp.makeConstraints {
            $0.top.equalTo(checkStacView.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().inset(30)
            $0.height.equalTo(50)
        }

        
        admitCheckBox.addTarget(self, action: #selector(toggleTerms), for: .touchUpInside)
        
    }
    
    @objc private func toggleTerms() {
        admitCheckBox.isSelected.toggle()
    }
    
    @objc private func togglePasswordVisibility() {
        password.isSecureTextEntry.toggle()
        let imageName = password.isSecureTextEntry ? "eye" : "eye.slash"
        togglePasswordVisibilityButton.setImage(UIImage(systemName: imageName), for: .normal )
    }
    
    @objc private func togglePhoneNumberVisibility() {
        phoneNumberTextField.isSecureTextEntry.toggle()
        let imageNumber = phoneNumberTextField.isSecureTextEntry ? "eye" : "eye.slash"
        togglePhoneNumberVisibilityButton.setImage(UIImage(systemName: imageNumber), for: .normal )
    }
    
}

