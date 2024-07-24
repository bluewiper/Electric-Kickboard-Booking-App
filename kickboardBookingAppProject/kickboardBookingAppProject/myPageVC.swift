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

class myPageVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // UI 요소 정의 : greetingLabel
    let greetingLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .left
        label.font = .boldSystemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
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
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    let centerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    let timeTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.numberOfLines = 0
        label.textAlignment = .right
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.textAlignment = .right
        return label
    }()
    
    lazy var returnButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .red
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.addTarget(self, action: #selector(returnButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // 테이블 뷰 메뉴 아이템
    let menuItems = ["이용 내역", "회원정보 변경", "운전면허증(업데이트 예정)", "로그아웃"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = .white
        
        // D. 뷰 생성
        view.addSubview(greetingLabel)
        
        view.addSubview(containerView)
        containerView.addSubview(statusLabel)
        containerView.addSubview(centerLabel)
        containerView.addSubview(timeTitleLabel)
        containerView.addSubview(timeLabel)
        containerView.addSubview(returnButton)
        
        view.addSubview(tableView)
        
        setUpLayout()
        updateUI()
        setUpTableView()
    }
    
    func setUpLayout() {
        
        // 레이블 제약조건(닉네임을 포함한 환영인사 라벨)
        greetingLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(120)
            $0.leading.equalToSuperview().offset(24)
        }
        
        // 컨테이너 뷰 제약조건
        containerView.snp.makeConstraints {
            $0.top.equalTo(greetingLabel.snp.bottom).offset(30)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.height.equalTo(150)
        }
        
        // 컨테이너 뷰에 포함된 상태 레이블 제약 조건
        statusLabel.snp.makeConstraints {
            $0.top.equalTo(containerView.snp.top).offset(16)
            $0.leading.equalTo(containerView.snp.leading).offset(16)
        }
        
        // 이용 시간 타이틀 레이블 제약 조건
        timeTitleLabel.snp.makeConstraints {
            $0.top.equalTo(statusLabel.snp.bottom).offset(10)
            $0.trailing.equalTo(containerView.snp.trailing).offset(-16)
        }
        
        // 이용 시간 레이블 제약 조건
        timeLabel.snp.makeConstraints {
            $0.top.equalTo(timeTitleLabel.snp.bottom).offset(10)
            $0.trailing.equalTo(containerView.snp.trailing).offset(-16)
        }
        
        // 중앙 라벨 제약 조건
        centerLabel.snp.makeConstraints {
            $0.top.equalTo(containerView).offset(50)
            $0.centerX.equalTo(containerView)
        }
        
        // 반납 버튼 레이블 제약 조건
        returnButton.snp.makeConstraints {
            $0.leading.equalTo(containerView.snp.leading)
            $0.trailing.equalTo(containerView.snp.trailing)
            $0.bottom.equalTo(containerView.snp.bottom)
            $0.height.equalTo(50)
        }
        
        // 테이블 뷰 레이블 제약 조건
        tableView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalTo(containerView.snp.bottom).offset(40)
            $0.bottom.equalToSuperview()
        }
        
    }
    
    // 이용 여부에 따른 라벨 및 버튼 텍스트 업데이트하는 메서드
    func updateUI() {
        
        if user.isUsingScooter {
            greetingLabel.text = "\(user.nickname)님\n헬멧을 꼭 써주세요!"
            statusLabel.text = "\(user.kickboardCode)호 이용중"
            timeTitleLabel.text = "이용시간"
            timeLabel.text = "2024.07.22. 18:00 26분째"
            centerLabel.text = ""
            returnButton.setTitle("반납 하기", for: .normal)
            centerLabel.isHidden = true
            statusLabel.isHidden = false
            timeTitleLabel.isHidden = false
            timeLabel.isHidden = false
        } else {
            greetingLabel.text = "\(user.nickname)님\n오늘도 달려볼까요?"
            statusLabel.text = ""
            timeTitleLabel.text = ""
            timeLabel.text = ""
            centerLabel.text = "이용중인 킥보드가 없어요."
            returnButton.setTitle("이용하러 가기", for: .normal)
            centerLabel.isHidden = false
            statusLabel.isHidden = true
            timeTitleLabel.isHidden = true
            timeLabel.isHidden = true
        }
    }
    
    // 이용내역 등 안내 테이블 뷰
    func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = menuItems[indexPath.row]
        return cell
    }
    
    @objc func returnButtonTapped() {
        // 반납 버튼 클릭 시 동작
        print("반납 하기 버튼 클릭됨")
    }
    
}
