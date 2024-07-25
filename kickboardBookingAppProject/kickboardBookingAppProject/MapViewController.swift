//
//  MapViewController.swift
//  KickboardApp
//
//  Created by iOSClimber on 7/22/24.
//

import UIKit
import SnapKit
import KakaoMapsSDK
import CoreLocation

class MapViewController: UIViewController, MapControllerDelegate, CLLocationManagerDelegate {
    
    private lazy var mapView: KMViewContainer = {
        let view = KMViewContainer()
        return view
    }()
    
    private var locationManager = CLLocationManager()
    
    // 주소 검색바
    private var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "주소 검색"
        searchBar.backgroundColor = .white
        searchBar.layer.cornerRadius = 15
        searchBar.clipsToBounds = true
        return searchBar
    }()
    
    // 킥보드 이용중 확인 레이블
    private var isUsingLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 15)
        label.backgroundColor = .lightGray
        label.text = "이용상태: X"
        label.textAlignment = .center
        return label
    }()
    
    // 반납하기 버튼
    
    private var returnButton: UIButton = {
        let button = UIButton()
        button.setTitle("반납하기", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 25
        return button
    }()
    
    // 현위치 가기 버튼
    
    private var locationButton: UIButton = {
        let button = UIButton()
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .bold, scale: .large)
        let largeBoldIcon = UIImage(systemName: "scope", withConfiguration: largeConfig)
        button.setImage(largeBoldIcon, for: .normal)
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 25
        button.tintColor = .systemBlue
        return button
    }()
    
    func addViews() {
        // KakaoMap을 추가하기 위한 viewInfo를 생성합니다.
        let defaultPosition: MapPoint = MapPoint(longitude: 127.0678, latitude: 37.2040) // 기본 위치는 설정하지만 사용하지 않을 예정입니다.
        let mapviewInfo: MapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: defaultPosition, defaultLevel: 17)
        
        mapContainer = mapView
        guard mapContainer != nil else {
            print("맵 생성 실패")
            return
        }
        
        // KMController를 생성합니다.
        mapController = KMController(viewContainer: mapContainer!)
        mapController!.delegate = self
        
        mapController?.prepareEngine() // 엔진 초기화. 엔진 내부 객체 생성 및 초기화가 진행됩니다.
        
        // KakaoMap을 추가합니다.
        DispatchQueue.main.async {
            self.mapController?.addView(mapviewInfo)
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        _observerAdded = false
        _auth = false
        _appear = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        _observerAdded = false
        _auth = false
        _appear = false
        super.init(coder: aDecoder)
    }
    
    deinit {
        mapController?.pauseEngine()
        mapController?.resetEngine()
    }
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        addViews()
        
        // Location Manager 설정
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addObservers()
        _appear = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if mapController == nil {
            addViews()
        }
        mapController?.activateEngine()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        _appear = false
        mapController?.pauseEngine()  //렌더링 중지.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        removeObservers()
        mapController?.resetEngine()
        //엔진 정지. 추가되었던 ViewBase들이 삭제된다.
        
    }
    
    // 인증 실패시 호출.
    func authenticationFailed(_ errorCode: Int, desc: String) {
        print("error code: \(errorCode)")
        print("desc: \(desc)")
        _auth = false
        switch errorCode {
        case 400:
            showToast(self.view, message: "지도 종료(API인증 파라미터 오류)")
            break
        case 401:
            showToast(self.view, message: "지도 종료(API인증 키 오류)")
            break
        case 403:
            showToast(self.view, message: "지도 종료(API인증 권한 오류)")
            break
        case 429:
            showToast(self.view, message: "지도 종료(API 사용쿼터 초과)")
            break
        case 499:
            showToast(self.view, message: "지도 종료(네트워크 오류) 5초 후 재시도..")
            
            // 인증 실패 delegate 호출 이후 5초뒤에 재인증 시도..
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                print("retry auth...")
                
                self.mapController?.prepareEngine()
            }
            break
        default:
            break
        }
    }
    
    
    
    // MARK: - configureUI
    
    private func configureUI() {
        [
            mapView,
            searchBar,
            isUsingLabel,
            returnButton,
            locationButton
        ].forEach { view.addSubview($0) }
        
        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        searchBar.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(60)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(30)
        }
        
        isUsingLabel.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(10)
            $0.leading.equalTo(searchBar)
            $0.width.equalTo(85)
            $0.height.equalTo(40)
        }
        
        returnButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(80)
            $0.width.equalTo(120)
            $0.height.equalTo(50)
        }
        
        locationButton.snp.makeConstraints {
            $0.centerY.equalTo(returnButton)
            $0.trailing.equalToSuperview().inset(20)
            $0.height.width.equalTo(50)
        }
        
        
    }
    
    
    //addView 성공 이벤트 delegate. 추가적으로 수행할 작업을 진행한다.
    func addViewSucceeded(_ viewName: String, viewInfoName: String) {
        print("OK")
        createPoiStyle()
        createLabelLayer()
        
        // 지도 초기화 완료 후 위치 정보 가져오기
        updateLocationToCurrentPosition()
    }

    
    //addView 실패 이벤트 delegate. 실패에 대한 오류 처리를 진행한다.
    func addViewFailed(_ viewName: String, viewInfoName: String) {
        print("Failed")
    }
    
    //Container 뷰가 리사이즈 되었을때 호출된다. 변경된 크기에 맞게 ViewBase들의 크기를 조절할 필요가 있는 경우 여기에서 수행한다.
    func containerDidResized(_ size: CGSize) {
        let mapView: KakaoMap? = mapController?.getView("mapview") as? KakaoMap
        mapView?.viewRect = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size)   //지도뷰의 크기를 리사이즈된 크기로 지정한다.
        
    }
    
    func viewWillDestroyed(_ view: ViewBase) {
    }
    
    func addObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        _observerAdded = true
    }
    
    func removeObservers(){
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        
        _observerAdded = false
    }
    
    @objc func willResignActive(){
        mapController?.pauseEngine()  //뷰가 inactive 상태로 전환되는 경우 렌더링 중인 경우 렌더링을 중단.
    }
    
    @objc func didBecomeActive() {
        if let mapController = mapController {
            mapController.activateEngine()
        }
    }
    
    func mapControllerDidChangeZoomLevel(_ mapController: KakaoMapsSDK.KMController, zoomLevel: Double) {
        print("Zoom level changed to: \(zoomLevel)")
    }
    
    //authenticationFailed 메서드에서 인증 실패 시 사용자에게 피드백되는 부분
    func showToast(_ view: UIView, message: String, duration: TimeInterval = 2.0) {
        let toastLabel = UILabel(frame: CGRect(x: view.frame.size.width/2 - 150, y: view.frame.size.height-100, width: 300, height: 35))
        toastLabel.backgroundColor = UIColor.black
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = NSTextAlignment.center
        view.addSubview(toastLabel)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds  =  true
        
        UIView.animate(withDuration: 0.4,
                       delay: duration - 0.4,
                       options: .curveEaseOut,
                       animations: {
            toastLabel.alpha = 0.0
        },
                       completion: { (finished) in
            toastLabel.removeFromSuperview()
        })
    }
    
    var mapContainer: KMViewContainer?
    var mapController: KMController?
    var _observerAdded: Bool = false
    var _auth: Bool = false
    var _appear: Bool = false
    
    
    // MARK: - LocationManager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let coordinate = location.coordinate
        let position = MapPoint(longitude: coordinate.longitude, latitude: coordinate.latitude)
        
        // 현재 위치 콘솔 출력
        print("Current location: \(coordinate.latitude), \(coordinate.longitude)")
        
        createPoi(at: position)
        
        if let mapView = mapController?.getView("mapview") as? KakaoMap {
            mapView.moveCamera(CameraUpdate.make(target: position, zoomLevel: 17, mapView: mapView))
        }
        
        manager.stopUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            print("Location authorized")
            locationManager.startUpdatingLocation()
            updateLocationToCurrentPosition()
        case .restricted, .denied:
            showToast(self.view, message: "위치 서비스 사용 권한이 거부되었습니다.")
        default:
            break
        }
    }
    
    // 현재 위치를 지도에 반영하는 메서드
    func updateLocationToCurrentPosition() {
        DispatchQueue.global().async {
            guard CLLocationManager.locationServicesEnabled() else {
                DispatchQueue.main.async {
                    self.showToast(self.view, message: "위치 서비스가 비활성화되어 있습니다.")
                }
                return
            }

            guard let currentLocation = self.locationManager.location else {
                DispatchQueue.main.async {
                    self.showToast(self.view, message: "현재 위치를 가져올 수 없습니다.")
                }
                return
            }

            let coordinate = currentLocation.coordinate
            let position = MapPoint(longitude: coordinate.longitude, latitude: coordinate.latitude)
            
            // 현재 위치 콘솔 출력
            print("Update location to current position: \(coordinate.latitude), \(coordinate.longitude)")
            
            self.createPoi(at: position)
            
            DispatchQueue.main.async {
                if let mapView = self.mapController?.getView("mapview") as? KakaoMap {
                    mapView.moveCamera(CameraUpdate.make(target: position, zoomLevel: 17, mapView: mapView))
                }
            }
        }
    }
    
    
    
    //MARK: - POI
    
    func createPoiStyle() { // 보이는 스타일 정의
        guard let mapView = mapController?.getView("mapview") as? KakaoMap else {
            return
        }
        let labelManager = mapView.getLabelManager()
        
        let originalImage = UIImage(systemName: "person.fill")
        guard let image = originalImage?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal) else {
                return
            }
        
        let icon = PoiIconStyle(symbol: image, anchorPoint: CGPoint(x: 0.5, y: 1.0))
        let perLevelStyle = PerLevelPoiStyle(iconStyle: icon, level: 0)
        let poiStyle = PoiStyle(styleID: "blue", styles: [perLevelStyle])
        labelManager.addPoiStyle(poiStyle)
    }
    
    func createLabelLayer() { // 레이어생성
        guard let mapView = mapController?.getView("mapview") as? KakaoMap else { return }
        let labelManager = mapView.getLabelManager()
        let layer = LabelLayerOptions(layerID: "poiLayer", competitionType: .none, competitionUnit: .symbolFirst, orderType: .rank, zOrder: 10001)
        let _ = labelManager.addLabelLayer(option: layer)
    }
    
    func createPoi(at position: MapPoint) {
        guard let mapView = mapController?.getView("mapview") as? KakaoMap else {
            print("Map view is nil")
            return
        }
        let labelManager = mapView.getLabelManager()
        guard let layer = labelManager.getLabelLayer(layerID: "poiLayer") else {
            print("POI layer is nil")
            return
        }
        
        let options = PoiOptions(styleID: "blue", poiID: "bluePoi")
        if let poi = layer.addPoi(option: options, at: position) {
            let coordinate = position.wgsCoord
            print("POI added at \(coordinate.latitude), \(coordinate.longitude)")
            poi.show()
        } else {
            print("Failed to add POI")
        }
    }
    
    
    
}
