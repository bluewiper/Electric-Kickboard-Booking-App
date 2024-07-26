//
//  HistoryVC.swift
//  kickboardBookingAppProject
//
//  Created by 단예진 on 7/24/24.
//

import Foundation
import UIKit
import SnapKit


// D. 킥보드 이용내역을 위한 더미 데이터
struct TestHistory {
    let dateString: String
    let kickboardInfo: String
    let ridingTime: String
    let distance: String
    let payment: String
}


class HistoryVC: UIViewController {
    
    // D. 헤더 : 섹션의 접힘 상태를 저장할 배열
    var sectionIsExpanded: [Bool] = []
    
    var histories: [TestHistory] = []
    
    // D. 이용 기간 단위를 보여줄 세그먼트 바
    let periodSC: UISegmentedControl = {
        let items = ["10일", "20일", "30일"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()
    
    // D. 선택한 이용 기간을 보여주는 텍스트 뷰
    let periodTV: UITextView = {
        let textView = UITextView()
        // 텍스트뷰 텍스트 버티컬 정렬
        textView.textContainerInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
        textView.text = ""
        textView.textAlignment = .center
        textView.layer.cornerRadius = 10
        textView.layer.borderWidth = 1.4
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    // MARK: - D. 이용 기간을 보여줄 텍스트뷰 및 더보기 UI 구성
    private let tableView: UITableView = {
        let tableView = UITableView()
        //        tableView.backgroundColor = .lightGray
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(HistoryCell.self, forCellReuseIdentifier: "HistoryCell")
        return tableView
    }()
    
    
    private var containerViewHeightConstraint: Constraint?
    private let expandedHeight: CGFloat = 200
    private let collapsedHeight: CGFloat = 0
    
    
    // D. 이용 내역이 없을 때 상태 알림 라벨
    let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "이용 내역이 없습니다."
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // D. 이용 내역이 없을 때 이용하러 가기 버튼
    lazy var bookingButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("이용하러 가기", for: .normal)
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemRed.cgColor
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        button.addTarget(self, action: #selector(bookingButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        navigationItem.title = "이용 내역"
        
        view.addSubview(periodSC)
        
        view.addSubview(periodTV)
        
        // D. 더미데이터로 4개 넣어놓음
        histories.append(TestHistory(dateString: "07월 24일", kickboardInfo: "킥보드 1", ridingTime: "30분", distance: "5km", payment: "2000원"))
        histories.append(TestHistory(dateString: "07월 25일", kickboardInfo: "킥보드 2", ridingTime: "30분", distance: "5km", payment: "2000원"))
        histories.append(TestHistory(dateString: "07월 26일", kickboardInfo: "킥보드 3", ridingTime: "60분", distance: "10km", payment: "4000원"))
        histories.append(TestHistory(dateString: "08월 10일", kickboardInfo: "킥보드 4", ridingTime: "10분", distance: "2km", payment: "1000원"))
        
        // D. 테이블 뷰 델리게이트와 데이터 소스
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CustomSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: CustomSectionHeaderView.headerViewID)
        
        // D. 헤더 : 초기 섹션 상태 설정 (모든 섹션이 접혀있지 않은 상태)
        sectionIsExpanded = Array(repeating: false, count: numberOfSections(in: tableView))
        
        
        view.addSubview(statusLabel)
        
        view.addSubview(bookingButton)
        
        // D. 테이블 뷰 및 버튼 뷰 생성
        view.addSubview(tableView)
        
        setUpLayout()
        
        setCurrentDate()
        
        updateUI()
        
    }
    
    func setUpLayout() {
        
        // D. 이용기간 세그먼트 컨트롤 제약 조건
        periodSC.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.centerX.equalToSuperview()
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.height.equalTo(50)
        }
        
        // D. 이용기간 텍스트 뷰 제약 조건
        periodTV.snp.makeConstraints {
            $0.top.equalTo(periodSC.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.height.equalTo(50)
        }
        
        // D. 테이블 뷰 제약 조건
        tableView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.top.equalTo(periodTV.snp.bottom).offset(20)
            $0.bottom.equalToSuperview().offset(-20)
        }
        
        
        statusLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(periodTV.snp.bottom).offset(200)
        }
        
        bookingButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(80)
            $0.trailing.equalToSuperview().offset(-80)
            $0.top.equalTo(statusLabel.snp.bottom).offset(30)
            $0.height.equalTo(50)
            
        }
    }
    
    // D. 현재 날짜 * 선택한 이용기간에 따라 변경 필요 -> updataDate로 만들어서 세그먼트 컨트롤이랑 연결하기
    private func setCurrentDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentDate = Date()
        let dateString = dateFormatter.string(from: currentDate)
        
        periodTV.text = dateString
    }
    
    
    func updateUI() {
        // 이용 여부에 따른 업데이트
        if user.isUsingScooter {
            statusLabel.isHidden = true
            bookingButton.isHidden = true
        } else {
            statusLabel.isHidden = false
            bookingButton.isHidden = false
        }
        
        // 이용 내역 유무에 따른 업데이트
        if user.hasHistory {
            statusLabel.isHidden = true
            bookingButton.isHidden = true
        } else {
            statusLabel.isHidden = false
            bookingButton.isHidden = false
        }
    }
    
    
    @objc func bookingButtonTapped() {
        // 지도 화면으로 이동
    }
    
}

extension HistoryVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionIsExpanded[section] ? 1 : 0 // D. 임의의 수
    }
    
    // D. 헤더 관련
    func numberOfSections(in tableView: UITableView) -> Int {
        return histories.count // <- 4개
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! HistoryCell
        
        // D. cell에 보여질 history 데이터를 가져오기
        let history = histories[indexPath.section]
        
        // D. history 정보를 가지고 cell의 내용을 채워줌
        cell.kickboardInfo.text = history.kickboardInfo
        
        return cell
    }
    
    // 커스텀 헤더뷰
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: CustomSectionHeaderView.headerViewID) as? CustomSectionHeaderView else {
            return nil
        }
        
        // D. histories 에 section 번째의 데이터를 가지고 와서 history 변수에 저장
        let history = histories[section]
        
        // 커스텀 헤더 뷰 제목
        // D. history 에는 dateString, kickboardInfo 가 들어가 있음
        // D. history에 있는 dateString을 header Title에 대입
        headerView.headerTitle.text = history.dateString
        
        // D. 헤더 확장에 따라 화살표 이미지 변경
        headerView.updateHeader(isExpanded: sectionIsExpanded[section])
        
        // D. 헤더뷰를 위해 탭했을 경우 제스처 인식
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleHeaderTap(_:)))
        headerView.addGestureRecognizer(tapGestureRecognizer)
        headerView.tag = section
        
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        40
    }
    
    @objc func handleHeaderTap(_ sender: UITapGestureRecognizer) {
        guard let section = sender.view?.tag else { return }
        
        // D. 섹션의 접힘 상태를 반전
        sectionIsExpanded[section].toggle()
        
        // D. 테이블 뷰 업데이트
        tableView.reloadSections(IndexSet(integer: section), with: .automatic)
    }
}
