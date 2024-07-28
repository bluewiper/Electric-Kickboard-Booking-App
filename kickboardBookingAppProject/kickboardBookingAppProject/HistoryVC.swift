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
    var filteredHistories: [TestHistory] = [] // 필터링된 내역을 저장할 배열
    
    // D. 이용 기간 단위를 보여줄 세그먼트 바
    lazy var periodSC: UISegmentedControl = {
        let items = ["10일", "20일", "30일"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
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
        return textView
    }()
    
    // MARK: - D. 이용 기간을 보여줄 텍스트뷰 및 더보기 UI 구성
    private let tableView: UITableView = {
        let tableView = UITableView()
        //        tableView.backgroundColor = .lightGray
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
        
        setupView()
        setupTableView()
        setUpLayout()
        setCurrentDate()
        updateUI()
        
    }
    
    func setupView() {
        
        view.addSubview(periodSC)
        view.addSubview(periodTV)
        view.addSubview(statusLabel)
        view.addSubview(bookingButton)
        
    }
    
    func setupTableView() {
        histories.append(TestHistory(dateString: "06월 19일", kickboardInfo: "TL1485", ridingTime: "25분", distance: "3.4km", payment: "2500원"))
        histories.append(TestHistory(dateString: "06월 30일", kickboardInfo: "CI1480", ridingTime: "40분", distance: "5.2km", payment: "4000원"))
        histories.append(TestHistory(dateString: "07월 08일", kickboardInfo: "TL1485", ridingTime: "35분", distance: "4.7km", payment: "3500원"))
        histories.append(TestHistory(dateString: "07월 12일", kickboardInfo: "ZE1361", ridingTime: "50분", distance: "6.5km", payment: "5000원"))
        histories.append(TestHistory(dateString: "07월 17일", kickboardInfo: "QJ0831", ridingTime: "20분", distance: "2.8km", payment: "2000원"))
        histories.append(TestHistory(dateString: "07월 19일", kickboardInfo: "FD0215", ridingTime: "45분", distance: "6.0km", payment: "4500원"))
        histories.append(TestHistory(dateString: "07월 22일", kickboardInfo: "QJ0831", ridingTime: "30분", distance: "4.0km", payment: "3000원"))
        histories.append(TestHistory(dateString: "07월 24일", kickboardInfo: "FD0215", ridingTime: "55분", distance: "7.1km", payment: "5500원"))
        histories.append(TestHistory(dateString: "07월 27일", kickboardInfo: "CI1480", ridingTime: "15분", distance: "2.0km", payment: "1500원"))
        histories.append(TestHistory(dateString: "07월 29일", kickboardInfo: "FD0215", ridingTime: "60분", distance: "8.0km", payment: "6000원"))
        
        filteredHistories = histories // 초기값으로 전체 histories 할당
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CustomSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: CustomSectionHeaderView.headerViewID)
        
        sectionIsExpanded = Array(repeating: false, count: numberOfSections(in: tableView))
        
        view.addSubview(tableView)
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
    
    // D. 세그먼트 컨트롤 초기 설정 : 현재 날짜
    private func setCurrentDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentDate = Date()
        let dateString = dateFormatter.string(from: currentDate)
        
        periodTV.text = dateString
    }
    
    // D. 세그먼트 컨트롤에서 선택된 기간 단위에 따라 이용기간을 업데이트 하는 메서드
    func updateDateRange(days: Int) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let calendar = Calendar.current
        let currentDate = Date()
        
        if let pastDate = calendar.date(byAdding: .day, value: -days, to: currentDate) {
            let pastDateString = dateFormatter.string(from: pastDate)
            let currentDateString = dateFormatter.string(from: currentDate)
            periodTV.text = "\(pastDateString) ~ \(currentDateString)"
            
            filteredHistories = histories.filter { history in
                if let historyDate = dateFormatter.date(from: "2024-" + history.dateString.replacingOccurrences(of: "월", with: "-").replacingOccurrences(of: "일", with: "")) {
                    return historyDate >= pastDate && historyDate <= currentDate
                }
                return false
            }
            
            sectionIsExpanded = Array(repeating: false, count: filteredHistories.count)
            tableView.reloadData()
        }
    }
    
    @objc func segmentChanged(_ sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
        // D. 선택된 인덱스에 따른 동작 처리
        switch selectedIndex {
        case 0:
            updateDateRange(days: 10)
        case 1:
            updateDateRange(days: 20)
        case 2:
            updateDateRange(days: 30)
        default:
            break
        }
        
    }
    
    func updateUI() {
        // D. 이용 여부에 따른 업데이트
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
            statusLabel.isHidden = true
            bookingButton.isHidden = true
            
        } else {
            statusLabel.isHidden = false
            bookingButton.isHidden = false
            statusLabel.isHidden = false
            bookingButton.isHidden = false
            tableView.isHidden = true
        }
    }
    
    
    @objc func bookingButtonTapped() {
        // D. 지도 화면으로 이동
    }
    
}
extension HistoryVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionIsExpanded[section] ? 1 : 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filteredHistories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! HistoryCell
        let history = filteredHistories[indexPath.section]
        cell.configure(with: history)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: CustomSectionHeaderView.headerViewID) as? CustomSectionHeaderView else {
            return nil
        }
        
        let history = filteredHistories[section]
        headerView.headerTitle.text = history.dateString
        headerView.updateHeader(isExpanded: sectionIsExpanded[section])
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleHeaderTap(_:)))
        headerView.addGestureRecognizer(tapGestureRecognizer)
        headerView.tag = section
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    @objc func handleHeaderTap(_ sender: UITapGestureRecognizer) {
        guard let section = sender.view?.tag else { return }
        
        sectionIsExpanded[section].toggle()
        
        tableView.reloadSections(IndexSet(integer: section), with: .automatic)
    }
}

//extension HistoryVC: UITableViewDataSource, UITableViewDelegate {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return sectionIsExpanded[section] ? 1 : 0 // D. 임의의 수
//    }
//
//    // D. 헤더 관련
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return histories.count // <- 4개
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! HistoryCell
//
//        // D. cell에 보여질 history 데이터를 가져오기
//        let history = histories[indexPath.section]
//
//        // D. history 정보를 가지고 cell의 내용을 채워줌
//        cell.kickboardInfo.text = history.kickboardInfo
//
//        return cell
//    }
//
//    // D. 커스텀 헤더뷰
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: CustomSectionHeaderView.headerViewID) as? CustomSectionHeaderView else {
//            return nil
//        }
//
//        // D. histories 에 section 번째의 데이터를 가지고 와서 history 변수에 저장
//        let history = histories[section]
//
//        // D. 커스텀 헤더 뷰 제목
//        // D. history 에는 dateString, kickboardInfo 가 들어가 있음
//        // D. history에 있는 dateString을 header Title에 대입
//        headerView.headerTitle.text = history.dateString
//
//        // D. 헤더 확장에 따라 화살표 이미지 변경
//        headerView.updateHeader(isExpanded: sectionIsExpanded[section])
//
//        // D. 헤더뷰를 위해 탭했을 경우 제스처 인식
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleHeaderTap(_:)))
//        headerView.addGestureRecognizer(tapGestureRecognizer)
//        headerView.tag = section
//
//        return headerView
//    }
//
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        40
//    }
//
//    @objc func handleHeaderTap(_ sender: UITapGestureRecognizer) {
//        guard let section = sender.view?.tag else { return }
//
//        // D. 섹션의 접힘 상태를 반전
//        sectionIsExpanded[section].toggle()
//
//        // D. 테이블 뷰 업데이트
//        tableView.reloadSections(IndexSet(integer: section), with: .automatic)
//    }
//}
