//
//  CustomSectionHeaderView.swift
//  kickboardBookingAppProject
//
//  Created by 단예진 on 7/26/24.
//

import Foundation
import UIKit
import SnapKit

// D. 이용 내역이 있는 유저의 데이터를 담을 테이블의 커스텀 섹션 헤더

class CustomSectionHeaderView: UITableViewHeaderFooterView {
    
    static let headerViewID = "HistoryHeaderView"
    
    let headerTitle: UILabel = {
        let label = UILabel()
        label.text = "07월 24일" // 사용자 히스토리 내 등록 일자로 변경
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    let headerImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.down")
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let hStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.backgroundColor = .lightGray
        stackView.distribution = .fill
        return stackView
    }()
    
    override init(reuseIdentifier: String?) {
            super.init(reuseIdentifier: reuseIdentifier)
            setupHeaderView()
            configureLayout()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }
    
    func setupHeaderView() {
        
        hStackView.addArrangedSubview(headerTitle)
        hStackView.addArrangedSubview(headerImage)
        
        contentView.addSubview(hStackView)
        
    }
    
    func configureLayout() {
        
        headerTitle.snp.makeConstraints {
            $0.leading.equalTo(hStackView.snp.leading)
        }
        
        headerImage.snp.makeConstraints {
            $0.trailing.equalTo(hStackView.snp.trailing).offset(20)
            $0.width.height.equalTo(20)
        }
        
        hStackView.snp.makeConstraints {
            $0.leading.trailing.equalTo(contentView)
            $0.top.bottom.equalTo(contentView)
        }
    }
    
    // D. 섹션 상태에 따라 이미지를 업데이트하는 메소드
    func updateHeader(isExpanded: Bool) {
        headerImage.image = UIImage(systemName: isExpanded ? "chevron.up" : "chevron.down")
    }
}
