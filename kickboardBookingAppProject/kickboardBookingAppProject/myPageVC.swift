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
    var hasHistory: Bool
    var rentalStartTime: Date? // 대여 시작 시간 추가
    var feePerMinute: Int? // 추가된 필드

    init(userID: String, password: String, nickname: String, kickboardCode: String, isUsingScooter: Bool = false, hasHistory: Bool = false, rentalStartTime: Date? = nil, feePerMinute: Int? = nil) {
        self.loginID = userID
        self.password = password
        self.nickname = nickname
        self.kickboardCode = kickboardCode
        self.isUsingScooter = isUsingScooter
        self.hasHistory = hasHistory
        self.rentalStartTime = rentalStartTime
        self.feePerMinute = feePerMinute
    }
}

// 테이블 뷰 메뉴아이템 데이터
enum MenuItem: String, CaseIterable {
    case history = "이용 내역"
    case logout = "로그아웃"
}

// D. 더미 데이터
//var user = UserInfo(userID: "johnDoe123", password: "securePassword", nickname: "John", kickboardCode: "KFSE123", isUsingScooter: false, hasHistory: true)

var user = UserInfo(userID: "johnDoe123", password: "securePassword", nickname: "John", kickboardCode: "KFSE123", isUsingScooter: false, hasHistory: true, rentalStartTime: nil)

class myPageVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // D. UI 요소 정의 : greetingLabel
    let greetingLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .left
        label.font = .boldSystemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - UI 요소: 이용 상태 안내 박스
    
    // D. UI 요소 선언
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
    
    // 이용시간 레이블
    let timeTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.numberOfLines = 0
        label.textAlignment = .right
        return label
    }()
    
    // 이용 금액 레이블로 대체
    let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.numberOfLines = 0
        label.textAlignment = .right
//        label.text = "이용요금"
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
    
    // MARK: - UI 요소: 테이블 뷰 및 메뉴아이템
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // 테이블 뷰 메뉴 아이템
    let menuItems: [MenuItem] = MenuItem.allCases
    
    //    override func viewDidLoad() {
    //        super.viewDidLoad()
    //        // Do any additional setup after loading the view.
    //
    //        view.backgroundColor = .white
    //
    //        // D. 뷰 생성
    //        view.addSubview(greetingLabel)
    //
    //        view.addSubview(containerView)
    //        containerView.addSubview(statusLabel)
    //        containerView.addSubview(centerLabel)
    //        containerView.addSubview(timeTitleLabel)
    //        containerView.addSubview(timeLabel)
    //        containerView.addSubview(returnButton)
    //
    //        view.addSubview(tableView)
    //
    //        setUpLayout()
    //        updateUI()
    //        setUpTableView()
    //    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        setUpTableView()
        updateRentalStatusFromMapView()
        updateUI()
        
        // 알림 등록
        NotificationCenter.default.addObserver(self, selector: #selector(handleKickboardStatusChanged(notification:)), name: NSNotification.Name("KickboardStatusChanged"), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("KickboardStatusChanged"), object: nil)
    }

 
    @objc func handleKickboardStatusChanged(notification: Notification) {
        if let userInfo = notification.userInfo,
           let isInUse = userInfo["isInUse"] as? Bool {
            user.isUsingScooter = isInUse
            if isInUse, let kickboardID = userInfo["kickboardID"] as? String, let rentalStartTime = userInfo["rentalStartTime"] as? Date, let feePerMinute = userInfo["feePerMinute"] as? Int {
                user.kickboardCode = kickboardID
                user.rentalStartTime = rentalStartTime
                user.feePerMinute = feePerMinute
                startRentalTimer()
            } else {
                user.kickboardCode = ""
                user.rentalStartTime = nil
                user.feePerMinute = nil
                rentalTimer?.invalidate()
                rentalTimer = nil
            }
            updateUI()
        }
        if let userInfo = notification.userInfo,
           let elapsedTime = userInfo["elapsedTime"] as? TimeInterval,
           let fee = userInfo["fee"] as? Int {
            let formattedTime = formattedElapsedTime(elapsedTime)
            timeTitleLabel.text = "이용 시간: \(formattedTime)"
            timeLabel.text = "이용 금액: \(fee)원"
        }
    }

    private func calculateFee(for elapsedTime: TimeInterval) -> Int {
        let totalMinutes = Int(ceil(elapsedTime / 60))
        return totalMinutes * (user.feePerMinute ?? 0)
    }

    private func formattedElapsedTime(_ elapsedTime: TimeInterval) -> String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d분 %02d초", minutes, seconds)
    }
    
    private var rentalTimer: Timer?

    private func startRentalTimer() {
        rentalTimer?.invalidate()
        rentalTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateRentalTime), userInfo: nil, repeats: true)
    }

    @objc private func updateRentalTime() {
        guard let rentalStartTime = user.rentalStartTime else { return }
        let elapsedTime = Date().timeIntervalSince(rentalStartTime)
        let formattedTime = formattedElapsedTime(elapsedTime)
        let fee = calculateFee(for: elapsedTime)

        // 날짜 포맷 설정
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일 HH시 mm분"
        let rentalStartTimeString = dateFormatter.string(from: rentalStartTime)
        
        // 경과 시간 문자열 생성
        let elapsedTimeString = String(format: "%02d분 %02d초", Int(elapsedTime) / 60, Int(elapsedTime) % 60)
        
        // 레이블에 표시
        timeTitleLabel.text = "\(rentalStartTimeString) ~ \(elapsedTimeString) 이용중"
        timeLabel.text = "이용 금액: \(fee)원"

        // 1분마다 요금 업데이트
        if Int(elapsedTime) % 60 == 0 {
            NotificationCenter.default.post(name: NSNotification.Name("KickboardUsageUpdated"), object: nil, userInfo: ["elapsedTime": elapsedTime, "fee": fee])
        }
    }
    
    @objc func updateRentalStatusFromMapView() {
        let rentalStatus = MapViewController().getRentalStatus()
        user.isUsingScooter = rentalStatus.isInUse
        user.kickboardCode = rentalStatus.kickboardID ?? ""
        updateUI()
    }
    
    // D. 마이페이지의 첫 번째 페이지 제약 조건
    func setUpLayout() {
        
        // D. 레이블 제약조건(닉네임을 포함한 환영인사 라벨)
        greetingLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(120)
            $0.leading.equalToSuperview().offset(24)
        }
        
        // D. 컨테이너 뷰 제약조건
        containerView.snp.makeConstraints {
            $0.top.equalTo(greetingLabel.snp.bottom).offset(30)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.height.equalTo(150)
        }
        
        // D. 컨테이너 뷰에 포함된 상태 레이블 제약 조건
        statusLabel.snp.makeConstraints {
            $0.top.equalTo(containerView.snp.top).offset(16)
            $0.leading.equalTo(containerView.snp.leading).offset(16)
        }
        
        // D. 이용 시간 타이틀 레이블 제약 조건
        timeTitleLabel.snp.makeConstraints {
            $0.top.equalTo(statusLabel.snp.bottom).offset(10)
            $0.trailing.equalTo(containerView.snp.trailing).offset(-16)
        }
        
        // D. 이용 시간 레이블 제약 조건
        timeLabel.snp.makeConstraints {
            $0.top.equalTo(timeTitleLabel.snp.bottom).offset(10)
            $0.trailing.equalTo(containerView.snp.trailing).offset(-16)
        }
        
        // D. 중앙 라벨 제약 조건
        centerLabel.snp.makeConstraints {
            $0.top.equalTo(containerView).offset(50)
            $0.centerX.equalTo(containerView)
        }
        
        // D. 반납 버튼 레이블 제약 조건
        returnButton.snp.makeConstraints {
            $0.leading.equalTo(containerView.snp.leading)
            $0.trailing.equalTo(containerView.snp.trailing)
            $0.bottom.equalTo(containerView.snp.bottom)
            $0.height.equalTo(50)
        }
        
        // D. 테이블 뷰 레이블 제약 조건
        tableView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalTo(containerView.snp.bottom).offset(40)
            $0.bottom.equalToSuperview()
        }
        
    }
    
    // D. 이용 여부에 따른 라벨 및 버튼 텍스트 업데이트하는 메서드
    func updateUI() {
        if user.isUsingScooter {
            greetingLabel.text = "\(user.nickname)님\n헬멧을 꼭 써주세요!"
            statusLabel.text = "\(user.kickboardCode)호 이용중"
            timeTitleLabel.text = ""
            centerLabel.text = ""
            returnButton.setTitle("반납 하기", for: .normal)
            centerLabel.isHidden = true
            statusLabel.isHidden = false
            timeTitleLabel.isHidden = false
            timeLabel.isHidden = false
            startRentalTimer() // 타이머 시작
            // 초기 이용 금액 설정
            if let feePerMinute = user.feePerMinute {
                timeLabel.text = "이용 금액: \(feePerMinute)원"
            }
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
            rentalTimer?.invalidate() // 타이머 중지
        }
    }
    
    // D. 이용내역 등 안내 테이블 뷰
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
        let menuItem = menuItems[indexPath.row]
        cell.textLabel?.text = menuItem.rawValue
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let loginVC = LoginViewController()
        let selectedItem = menuItems[indexPath.row]
        
        if selectedItem == .history {
            navigationController?.pushViewController(HistoryVC(), animated: true)
            
        } else if selectedItem == .logout {
            
            // D. 자동 로그인 설정만 비활성화하는 메서드 호출
            disableAutoLogin()
            
            loginVC.hidesBottomBarWhenPushed = true  // D. 로그아웃 시 탭바를 숨기는 메서드
            
            if let navigationController = navigationController {
                navigationController.setViewControllers([loginVC], animated: true)
                
            } else {
                print("로그아웃 전환 실패")
            }
        }
        // D. 마이페이지 목록 선택 후 복귀 했을 때 선택 전으로 초기화
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func returnButtonTapped() {
        // 반납 버튼 클릭 시 동작
        
        if let tabBarController = self.tabBarController {
              tabBarController.selectedIndex = 0
            }
        print("반납 하기 버튼 클릭됨")
    }
    
    // D. 자동 로그인 설정만 비활성화하는 메서드
    private func disableAutoLogin() {
        UserDefaults.standard.set(false, forKey: "로그인 정보 저장")
    }
    
}

extension Notification.Name {
    static let kickboardReturned = Notification.Name("kickboardReturned")
}
