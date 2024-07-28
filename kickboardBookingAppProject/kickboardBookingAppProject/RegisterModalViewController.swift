//
//  RegisterModalViewController.swift
//  ElecKickBoard
//
//  Created by t2023-m0019 on 7/26/24.
//

import UIKit
import CoreData

protocol KickboardRegisterDelegate: AnyObject {
    func showKickboardMarker(at location: CGPoint)
    func didRegisterKickboard(latitude: Double, longitude: Double, code: String, battery: String, fee: String)
}

class RegisterModalViewController: UIViewController {
    
    var latitude: Double!
    var longitude: Double!
    let batteryData = (1...100).map { "\($0)%"}
    let feeData = ["50원", "100원", "150원", "200원"]
    let batteryPicker = UIPickerView()
    var selectedBattery: String?
    var selectedFee: String?
    
    let codeTextField = UITextField()
    
    weak var delegate: KickboardRegisterDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    func setupUI() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissModal))
        view.addGestureRecognizer(tapGestureRecognizer)
        
        // stackView1: 위도, 경도
        let stackView1 = UIStackView()
        stackView1.axis = .vertical
        stackView1.distribution = .fillEqually
        stackView1.spacing = 1
        view.addSubview(stackView1)
        stackView1.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(80) // 높이 조정
        }
        
        // 위도
        let latitudeStackView = UIStackView()
        latitudeStackView.axis = .horizontal
        latitudeStackView.distribution = .fillEqually
        stackView1.addArrangedSubview(latitudeStackView)
        
        let latitudeLabel = UILabel()
        latitudeLabel.text = "위도"
        latitudeLabel.textAlignment = .center
        latitudeStackView.addArrangedSubview(latitudeLabel)
        
        let latitudeValueLabel = UILabel()
        latitudeValueLabel.text = "\(latitude ?? 0.0)"
        latitudeValueLabel.textAlignment = .center
        latitudeStackView.addArrangedSubview(latitudeValueLabel)
        
        // 경도
        let longitudeStackView = UIStackView()
        longitudeStackView.axis = .horizontal
        longitudeStackView.distribution = .fillEqually
        stackView1.addArrangedSubview(longitudeStackView)
        
        let longitudeLabel = UILabel()
        longitudeLabel.text = "경도"
        longitudeLabel.textAlignment = .center
        longitudeStackView.addArrangedSubview(longitudeLabel)
        
        let longitudeValueLabel = UILabel()
        longitudeValueLabel.text = "\(longitude ?? 0.0)"
        longitudeValueLabel.textAlignment = .center
        longitudeStackView.addArrangedSubview(longitudeValueLabel)
        
        // stackView2: 코드 레이블과 텍스트 필드
        let stackView2 = UIStackView()
        stackView2.axis = .horizontal
        stackView2.distribution = .fillEqually
        stackView2.spacing = 1
        view.addSubview(stackView2)
        stackView2.snp.makeConstraints { make in
            make.top.equalTo(stackView1.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(30)
        }
        
        let codeStackView = UIStackView()
        codeStackView.axis = .horizontal
        codeStackView.distribution = .fillEqually
        codeStackView.addArrangedSubview(codeStackView)
        
        let codeLabel = UILabel()
        codeLabel.text = "킥보드 코드"
        codeLabel.textAlignment = .center
        stackView2.addArrangedSubview(codeLabel)
        
//        let codeTextField = UITextField()
        let codePlaceholder = NSAttributedString(string: "랜덤 코드: \(RegisterModalViewController.randomCodeName())", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        codeTextField.attributedPlaceholder = codePlaceholder
        codeTextField.borderStyle = .roundedRect
        codeTextField.textAlignment = .center
        codeStackView.addArrangedSubview(codeTextField)
        
        codeTextField.textAlignment = .center
        stackView2.addArrangedSubview(codeTextField)
        
        // stackView3: 배터리 잔량, 분당 요금
        let stackView3 = UIStackView()
        stackView3.axis = .vertical
        stackView3.distribution = .fillEqually
        stackView3.spacing = 1
        view.addSubview(stackView3)
        stackView3.snp.makeConstraints { make in
            make.top.equalTo(stackView2.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(200) // 높이 조정
        }
        
        // 배터리 잔량
        let batteryStackView = UIStackView()
        batteryStackView.axis = .horizontal
        batteryStackView.distribution = .fillEqually
        stackView3.addArrangedSubview(batteryStackView)
        
        let batteryLabel = UILabel()
        batteryLabel.text = "배터리 잔량"
        batteryLabel.textAlignment = .center
        batteryStackView.addArrangedSubview(batteryLabel)
        
        let batteryPicker = UIPickerView()
        batteryPicker.tag = 0
        batteryPicker.delegate = self
        batteryPicker.dataSource = self
        batteryStackView.addArrangedSubview(batteryPicker)
        
        // 분당 요금
        let feeStackView = UIStackView()
        feeStackView.axis = .horizontal
        feeStackView.distribution = .fillEqually
        stackView3.addArrangedSubview(feeStackView)
        
        let feeLabel = UILabel()
        feeLabel.text = "분당 요금"
        feeLabel.textAlignment = .center
        feeStackView.addArrangedSubview(feeLabel)
        
        let feePicker = UIPickerView()
        feePicker.tag = 1
        feePicker.delegate = self
        feePicker.dataSource = self
        feeStackView.addArrangedSubview(feePicker)
        
        // 완료 버튼
        let completeButton = UIButton(type: .system)
        completeButton.setTitle("완료", for: .normal)
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        view.addSubview(completeButton)
        completeButton.snp.makeConstraints { make in
            make.top.equalTo(stackView3.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
            make.width.equalTo(100)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
        }
    }
    
    
    static func randomCodeName() -> String {
        let alphabets = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let numbers = "0123456789"
        
        let randomAlphabets = String((0..<2).map { _ in alphabets.randomElement()! })
        let randomNumbers = String((0..<4).map { _ in numbers.randomElement()! })
        
        return randomAlphabets + randomNumbers
    }
    
    @objc private func dismissModal() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func createHorizontalStackView(leftText: String, rightText: String? = nil, rightView: UIView? = nil) -> UIStackView {
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        
        let leftLabel = UILabel()
        leftLabel.text = leftText
        stackView.addArrangedSubview(leftLabel)
        
        if let rightText = rightText {
            let rightLabel = UILabel()
            rightLabel.text = rightText
            stackView.addArrangedSubview(rightLabel)
            rightLabel.snp.makeConstraints { make in
                make.width.equalTo(stackView.snp.width).multipliedBy(0.8)
            }
        } else if let rightView = rightView {
            stackView.addArrangedSubview(rightView)
            rightView.snp.makeConstraints { make in
                make.width.equalTo(stackView.snp.width).multipliedBy(0.8)
            }
        }
        
        leftLabel.snp.makeConstraints { make in
            make.width.equalTo(stackView.snp.width).multipliedBy(0.2)
        }
        
        return stackView
    }
    
    
    func createPickerView(tag: Int) -> UIPickerView {
        let pickerView = UIPickerView()
        pickerView.tag = tag
        return pickerView
    }
    
    @objc func completeButtonTapped() {
        let code = codeTextField.text ?? ""
        let battery = selectedBattery ?? batteryData[0]
        let fee = selectedFee ?? feeData[0]
//        CoreDataHelper.shared.createKickboard(id: code, latitude: latitude, longitude: longitude, battery: battery, fee: fee)
        delegate?.didRegisterKickboard(latitude: latitude, longitude: longitude, code: code, battery: battery, fee: fee)
        
        dismiss(animated: true) {
            let alert = UIAlertController(title: "등록 완료", message: "등록이 완료되었습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            self.delegate?.showKickboardMarker(at: CGPoint(x: self.latitude, y: self.longitude))
        }
    }
}

extension RegisterModalViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView.tag == 0 ? batteryData.count : feeData.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerView.tag == 0 ? batteryData[row] : feeData[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            selectedBattery = batteryData[row]
        } else {
            selectedFee = feeData[row]
        }
    }
    
}
