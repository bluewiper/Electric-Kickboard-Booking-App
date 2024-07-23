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
    let userID: String
    let password: String
    let nickname: String
    var isUsingScooter: Bool
    var kickboardCode: String
    
    // D. 초기화 메서드
    init(userID: String, password: String, nickname: String, kickboardCode: String, isUsingScooter: Bool = false) {
        self.userID = userID
        self.password = password
        self.nickname = nickname
        self.kickboardCode = kickboardCode
        self.isUsingScooter = isUsingScooter
    }
}

class myPageVC: UIViewController {
        
        // UI 요소 정의 : greetingLabel
        let greetingLabel: UILabel = {
            
            // D. 더미 데이터
            var user = UserInfo(userID: "johnDoe123", password: "securePassword", nickname: "John", kickboardCode: "KFSE123", isUsingScooter: true)
            
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
        
        override func viewDidLoad() {
            super.viewDidLoad()
            // Do any additional setup after loading the view.
            
            view.backgroundColor = .white
            
            // D. 뷰 생성
            view.addSubview(greetingLabel)
            
            setUpLayout()
        }
        
        func setUpLayout() {
            
            // 레이블 제약조건
            greetingLabel.snp.makeConstraints {
                $0.top.equalToSuperview().offset(120)
                $0.leading.equalToSuperview().offset(24)
            }
            
        }
        
    }
