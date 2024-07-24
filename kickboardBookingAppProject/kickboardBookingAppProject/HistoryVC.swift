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
        textView.text = "2024-07-24" // B. 선택한 이용기간에 따라 변경
        textView.textAlignment = .center
        textView.layer.cornerRadius = 10
        textView.layer.borderWidth = 1.4
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        title = "이용 내역"
        
        view.addSubview(periodSC)
        view.addSubview(periodTV)
        
        setUpLayout()
    }
    
    func setUpLayout() {
        
        periodSC.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(300)
            $0.height.equalTo(40)
        }
        
        periodTV.snp.makeConstraints {
            $0.top.equalTo(periodSC.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(300)
            $0.height.equalTo(40)
        }
        
    }


}
