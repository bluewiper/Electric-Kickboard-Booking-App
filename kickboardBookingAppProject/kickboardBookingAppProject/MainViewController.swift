//
//  ViewController.swift
//  ElecKickBoard
//
//  Created by t2023-m0019 on 7/25/24.
//
import UIKit
import SnapKit
import CoreLocation


class MainViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
//    var mapContainer: KMViewContainer?
//    var mapController: KMController?
    var latitude: Double!
    var longitude: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestWhenInUseAuthorization()
        setupView()
        setLocation()
        setNavigation()
    }
    @objc func buttonTapped() {
        locationManager.startUpdatingLocation()
        guard let latitude = locationManager.location?.coordinate.latitude else { return }
        guard let longitude = locationManager.location?.coordinate.longitude else { return }
        
    }
    

}
extension MainViewController {
    private func setupView() {
        let kakaoMapVC = Map2ViewController()
        addChild(kakaoMapVC)
        view.addSubview(kakaoMapVC.view)
        kakaoMapVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        kakaoMapVC.didMove(toParent: self)
    }
    
    private func setLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func setNavigation() {
        title = "지도"
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .bold),
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
    }
}
