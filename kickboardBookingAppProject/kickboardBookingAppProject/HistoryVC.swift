//
//  HistoryVC.swift
//  kickboardBookingAppProject
//
//  Created by 단예진 on 7/24/24.
//

import Foundation
import UIKit

class HistoryVC: UIViewController {
    

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
        textView.textAlignment = .center
        textView.layer.cornerRadius = 10
        textView.layer.borderWidth = 1.4
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    
    // D. 선택한 이용 내역을 포함할 컨테이너 뷰 (추가)
    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        return view
    }()
    
    // MARK: - 컨테이너뷰 UI 구성 : 이용내역
    
    // D. 컨테이너 뷰에 추가할 타이틀 1 (추가)
    let periodTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "이용 내역"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
       return label
    }()
    
    // D. 컨테이너 뷰에 추가할 vertical StackView
    let periodDetailVStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .systemPink // 디버깅용
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // D. vertical StackView에 넣을 horizontal StackView 1 : 킥보드 정보
    let periodDetailHStackView1: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .red // 디버깅용
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // D. horizontal StackView1에 넣을 킥보드 정보 타이틀
    let kickboardInfoTitle: UILabel = {
        let label = UILabel()
        label.text = "킥보드 정보"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // D. horizontal StackView1에 넣을 킥보드 정보
    let kickboardInfo: UILabel = {
        let label = UILabel()
        label.text = "(킥보드 정보)호" // D. 사용자의 킥보드 정보 넣기(데이터 기반)
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // D. vertical StackView에 넣을 horizontal StackView 2 : 탑승 시간
    let periodDetailHStackView2: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .yellow // 디버깅용
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // D. horizontal StackView2에 넣을 이용 시간 타이틀
    let ridingTimeTitle: UILabel = {
        let label = UILabel()
        label.text = "탑승 시간"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // D. horizontal StackView2에 넣을 이용 시간
    let ridingTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "(탑승 시간)분" // D. 사용자의 이용 시간 넣기(데이터 기반)
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // D. vertical StackView에 넣을 horizontal StackView 3 : 탑승 거리
    let periodDetailHStackView3: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .blue // 디버깅용
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // D. horizontal StackView3에 넣을 탑승 거리 타이틀
    let distanceTitle: UILabel = {
        let label = UILabel()
        label.text = "탑승 거리"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // D. horizontal StackView3에 넣을 탑승 거리
    let distanceLabel: UILabel = {
        let label = UILabel()
        label.text = "(탑승 거리)km 이용" // D. 사용자의 이용 시간 넣기(데이터 기반)
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - 컨테이너뷰 UI 구성 : 결제 내역
    
    // D. 컨테이너 뷰에 추가할 타이틀 2 (추가)
    let paymentTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "결제 내역"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
       return label
    }()
    
    // D. 컨테이너 뷰에 추가할 vertical StackView 2
    let paymentDetailVStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .systemPink // 디버깅용
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // D. vertical StackView2에 넣을 horizontal StackView 1 : 결제 내역
    let paymentHStackView1: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .red // 디버깅용
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // D. horizontal StackView1에 넣을 결제 내역 타이틀
    let paymentTitle: UILabel = {
        let label = UILabel()
        label.text = "이용 요금"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // D. horizontal StackView1에 넣을 킥보드 정보
    let paymentDetailLabel: UILabel = {
        let label = UILabel()
        label.text = "(2,000)원" // D. 사용자의 이용 금액 정보 넣기(데이터 기반)
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        title = "이용 내역"
        
        view.addSubview(periodSC)
        
        view.addSubview(periodTV)
        
        
        periodDetailHStackView1.addArrangedSubview(kickboardInfoTitle)
        periodDetailHStackView1.addArrangedSubview(kickboardInfo)
        
        periodDetailHStackView2.addArrangedSubview(ridingTimeTitle)
        periodDetailHStackView2.addArrangedSubview(ridingTimeLabel)
        
        periodDetailHStackView3.addArrangedSubview(distanceTitle)
        periodDetailHStackView3.addArrangedSubview(distanceLabel)
        
        
        periodDetailVStackView.addArrangedSubview(periodDetailHStackView1)
        periodDetailVStackView.addArrangedSubview(periodDetailHStackView2)
        periodDetailVStackView.addArrangedSubview(periodDetailHStackView3)
        
        
        paymentHStackView1.addArrangedSubview(paymentTitle)
        paymentHStackView1.addArrangedSubview(paymentDetailLabel)
        
        view.addSubview(paymentTitleLabel)
        

        paymentDetailVStackView.addArrangedSubview(paymentHStackView1)
        
        
        containerView.addSubview(periodTitleLabel)
        containerView.addSubview(periodDetailVStackView)
        containerView.addSubview(paymentTitleLabel)
        containerView.addSubview(paymentDetailVStackView)
        view.addSubview(containerView)
        
        setUpLayout()
        
        setCurrentDate()
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
        
        // D. 이용 내역 및 결제 내역 포함한 컨테이너 뷰 제약 조건
        containerView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.top.equalTo(periodTV.snp.bottom).offset(40) // D. 날짜 접는 UIView에 연결하기
            $0.height.equalTo(300)
        }
        
        // D. 이용 내역 - 타이틀 제약 조건
        periodTitleLabel.snp.makeConstraints {
            $0.leading.equalTo(containerView).offset(20)
            $0.trailing.equalTo(containerView).offset(-20)
            $0.top.equalTo(containerView.snp.top).offset(20)
        }
        
        // D. 이용 내역 - 스택뷰 제약 조건
        periodDetailVStackView.snp.makeConstraints {
            $0.leading.equalTo(containerView).offset(20)
            $0.trailing.equalTo(containerView).offset(-20)
            $0.top.equalTo(periodTitleLabel.snp.bottom).offset(20)
            $0.height.equalTo(120)
        }
        
        // D. 결제 내역 - 타이틀 제약 조건
        paymentTitleLabel.snp.makeConstraints {
            $0.leading.equalTo(containerView).offset(20)
            $0.trailing.equalTo(containerView).offset(-20)
            $0.top.equalTo(periodDetailVStackView.snp.bottom).offset(20)
        }
        
        // D. 결제 내역 - 스택뷰 제약 조건
        paymentDetailVStackView.snp.makeConstraints {
            $0.leading.equalTo(containerView).offset(20)
            $0.trailing.equalTo(containerView).offset(-20)
            $0.top.equalTo(paymentTitleLabel.snp.bottom).offset(20)
            $0.height.equalTo(40)
        }
    }
    
    // B. 현재 날짜 * 선택한 이용기간에 따라 변경 필요
    private func setCurrentDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentDate = Date()
        let dateString = dateFormatter.string(from: currentDate)
        
        periodTV.text = dateString
    }
}
