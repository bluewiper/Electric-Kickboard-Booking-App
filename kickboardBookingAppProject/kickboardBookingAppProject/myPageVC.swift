//
//  myPageVC.swift
//  kickboardBookingAppProject
//
//  Created by 단예진 on 7/23/24.
//

import Foundation
import UIKit
import SnapKit

// MARK: - 더미데이터 : UserInfo Model

struct UserInfo {
    let loginID: String
    let password: String
    let nickname: String
    var isUsingScooter: Bool
    var kickboardCode: String
    
    // D. 초기화 메서드
    init(userID: String, password: String, nickname: String, kickboardCode: String, isUsingScooter: Bool = false) {
        self.loginID = userID
        self.password = password
        self.nickname = nickname
        self.kickboardCode = kickboardCode
        self.isUsingScooter = isUsingScooter
    }
}

// D. 더미 데이터
var user = UserInfo(userID: "johnDoe123", password: "securePassword", nickname: "John", kickboardCode: "KFSE123", isUsingScooter: true)

class myPageVC: UIViewController {
    
    // UI 요소 정의 : greetingLabel
    let greetingLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .left
        label.font = .boldSystemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        // D. 이용 여부에 따른 라벨 텍스트 변화를 주는 조건문
        if user.isUsingScooter {
            label.text = "\(user.nickname)님\n헬멧을 꼭 써주세요!"
        } else {
            label.text = "\(user.nickname)님\n오늘도 달려볼까요?"
        }
        return label
    }()
    
    // MARK: - UI 요소: 이용 상태 안내 박스
    
    // UI 요소 선언
    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        return view
    }()
    
    let statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        // 이용 시간: 만약 이용중이 아닐 경우 빈 공간
        label.text = "\(user.kickboardCode)호 이용중"
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        // 이용시간: 만약 이용중이 아닐 경우 빈 공간 * 이용 등록 시간이 필요함(해라님과 협업)
        label.text = "이용시간\n2024.07.22. 18:00 26분째"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 2
        label.textAlignment = .right
        return label
    }()
    
    lazy var returnButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("반납 하기", for: .normal)
        button.backgroundColor = .red
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.addTarget(self, action: #selector(returnButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = .white
        
        // D. 뷰 생성
        view.addSubview(greetingLabel)
        
        view.addSubview(containerView)
        containerView.addSubview(statusLabel)
        containerView.addSubview(timeLabel)
        containerView.addSubview(returnButton)
        
        setUpLayout()
    }
    
    func setUpLayout() {
        
        // 레이블 제약조건(닉네임을 포함한 환영인사 라벨)
        greetingLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(120)
            $0.leading.equalToSuperview().offset(24)
        }
        
        // 컨테이너 뷰 제약조건
        containerView.snp.makeConstraints {
            $0.top.equalTo(greetingLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.height.equalTo(150)
        }
        
        // 컨테이너 뷰에 포함된 상태 레이블 제약 조건
        statusLabel.snp.makeConstraints {
            $0.top.equalTo(containerView.snp.top).offset(16)
            $0.leading.equalTo(containerView.snp.leading).offset(16)
        }
        
        // 이용 시간 레이블 제약 조건
        timeLabel.snp.makeConstraints {
            $0.top.equalTo(statusLabel.snp.bottom).offset(10)
            $0.trailing.equalTo(containerView.snp.trailing).offset(-16)
        }
        
        // 반납 버튼 레이블 제약 조건
        returnButton.snp.makeConstraints {
            $0.leading.equalTo(containerView.snp.leading)
            $0.trailing.equalTo(containerView.snp.trailing)
            $0.bottom.equalTo(containerView.snp.bottom)
            $0.height.equalTo(50)
        }
        
    }
    
    @objc func returnButtonTapped() {
        // 반납 버튼 클릭 시 동작
        print("반납 하기 버튼 클릭됨")
    }
    
}
