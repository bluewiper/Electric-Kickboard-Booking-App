//
//  MapViewController.swift
//  ElecKickBoard
//
//  Created by t2023-m0019 on 7/25/24.
//
import UIKit
import KakaoMapsSDK
import SnapKit

class Map2ViewController: UIViewController {
    
    static let defaultViewName: String = "mapview"
    
    required init?(coder aDecoder: NSCoder) {
        _observerAdded = false
        _auth = false
        _appear = false
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        _observerAdded = false
        _auth = false
        _appear = false
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    deinit {
        mapController?.pauseEngine()
        mapController?.resetEngine()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapContainer = KMViewContainer()
        view.addSubview(mapContainer!)
        mapContainer?.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        mapController = KMController(viewContainer: mapContainer!)
        mapController?.delegate = self
//        
//        let currentLocation = CLLocationCoordinate2D(latitude: 37.402001, longitude: 127.108678)
//        addCurrentLocationMarker(at: currentLocation)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        mapContainer?.addGestureRecognizer(longPressGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
        _appear = true
        if mapController?.isEnginePrepared == false {
            mapController?.prepareEngine()
        }
        
        if mapController?.isEngineActive == false {
            mapController?.activateEngine()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _appear = false
        mapController?.pauseEngine()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeObservers()
        mapController?.resetEngine()
    }
    
    func authenticationSucceeded() {
        if _auth == false {
            _auth = true
        }
        
        if _appear && mapController?.isEngineActive == false {
            mapController?.activateEngine()
        }
    }
    
    func authenticationFailed(_ errorCode: Int, desc: String) {
        print("error code: \(errorCode)")
        print("desc: \(desc)")
        _auth = false
        switch errorCode {
        case 400:
            showToast(self.view, message: "파라미터 오류")
        case 401:
            showToast(self.view, message: "인증 키 오류")
        case 403:
            showToast(self.view, message: "API 인증 권한 오류")
        case 429:
            showToast(self.view, message: "API 사용쿼터 초과")
        case 499:
            showToast(self.view, message: "네트워크 오류")
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                print("재시도")
                self.mapController?.prepareEngine()
            }
        default:
            break
        }
    }
    
    func viewInit(viewName: String) {
        print("OK")
        createLabelLayer(viewName: viewName)
        createPoiStyle(viewName: viewName)
        createPoi(viewName: viewName)
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        _observerAdded = true
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        _observerAdded = false
    }
    
    @objc func willResignActive() {
        mapController?.pauseEngine()
    }
    
    @objc func didBecomeActive() {
        mapController?.activateEngine()
    }
    
    func showToast(_ view: UIView, message: String, duration: TimeInterval = 2.0) {
        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor.black
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        
        view.addSubview(toastLabel)
        toastLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-100)
            make.width.equalTo(300)
            make.height.equalTo(35)
        }
        
        UIView.animate(withDuration: 0.4, delay: duration - 0.4, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }) { _ in
            toastLabel.removeFromSuperview()
        }
    }
    
    var mapContainer: KMViewContainer?
    var mapController: KMController?
    var _observerAdded: Bool
    var _auth: Bool
    var _appear: Bool
    var longPressCenter: CGPoint?
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let location = gestureRecognizer.location(in: mapContainer)
            showRegisterAlert(at: location) // 호출부
        }
    }
    
    func showRegisterAlert(at location: CGPoint) { // 함수 정의된 곳, 함수가 정의되어야 호출할 수 있다.
        let alert = UIAlertController(title: nil, message: "킥보드 등록", preferredStyle: .actionSheet)
        let registerAction = UIAlertAction(title: "이 위치에 킥보드 등록하기", style: .default) { _ in
            self.showRegisterModal(at: location)
        }
        alert.addAction(registerAction)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func showRegisterModal(at location: CGPoint) { // 정의
        let modalVC = RegisterModalViewController()
        modalVC.latitude = location.x
        modalVC.longitude = location.y
        modalVC.delegate = self
        
        modalVC.modalPresentationStyle = .pageSheet
        if let sheet = modalVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.preferredCornerRadius = 20
        }
        present(modalVC, animated: true, completion: nil)
    }
    
//    func addCurrentLocationMarker(at location: CLLocationCoordinate2D) {
//        guard let mapView = mapController?.getView("mapview") as? KakaoMap else {
//            return
//        }
//        let mapPoint = MapPoint(longitude: location.longitude, latitude: location.latitude)
//        let labelManager = mapView.getLabelManager()
//        guard let layer = labelManager.getLabelLayer(layerID: "PoiLayer") else {
//            return
//        }
//        let poiOption = PoiOptions(styleID: "currentLocation")
//        poiOption.rank = 0
//        poiOption.clickable = true
//        let poi = layer.addPoi(option: poiOption, at: mapPoint, callback: { _ in
//            print("Current location POI clicked")
//        })
//        poi?.show()
//    }
    
    @objc func moveToPointLocation() {
        let lo = 127.028406
        let la = 37.194402
        let mapView = mapController?.getView("mapview") as! KakaoMap
        let cameraUpdate: CameraUpdate = CameraUpdate.make(target: MapPoint(longitude: lo, latitude: la), zoomLevel: 15, mapView: mapView)
        mapView.animateCamera(cameraUpdate: cameraUpdate, options: CameraAnimationOptions(autoElevation: true, consecutive: true, durationInMillis: 500))
    }

    func createPoiStyle(viewName: String) {
        guard let mapView = mapController?.getView(viewName) as? KakaoMap else {
            return
        }
        
        let labelManager = mapView.getLabelManager()
        let image = #imageLiteral(resourceName: "marker")
        let currentLocationimage = UIImage(systemName: "figure.wave")
//        guard let currentLocationIcon = currentLocationImage?.withTintColor(.systemBlue, renderingMode: .alwyasOriginal) else {
//            return
//        }
//        let currentLocationPoiIconStyle = PoiIconStyle(symbol: currentLocationIcon, AnchorPoint: CGPoint(x: 0.5, y: 1.0))
//        let currentLocationPerLeavelStyle = PerLevelPoiStyle(iconStyle: currentLocationIcon, level: 0)
//        let currentLocationPoiStyle = PoiStyle(styleID: "currentLocation", styles: [currentLocationPerLevelStyle])
//        labelManager.addPoiStyle(currentLocationPoiStyle)
        let icon = PoiIconStyle(symbol: image, anchorPoint: CGPoint(x: 0.5, y: 1.0))
        let perLevelStyle = PerLevelPoiStyle(iconStyle: icon, level: 0)
        let poiStyle = PoiStyle(styleID: "PerLevelStyle", styles: [perLevelStyle])
        labelManager.addPoiStyle(poiStyle)
    }
    
    func createLabelLayer(viewName: String) {
        guard let mapView = mapController?.getView(viewName) as? KakaoMap else { return }
        let labelManager = mapView.getLabelManager()
        let layer = LabelLayerOptions(layerID: "PoiLayer", competitionType: .none, competitionUnit: .poi, orderType: .rank, zOrder: 10001)
        let _ = labelManager.addLabelLayer(option: layer)
    }
    
    func createPoi(viewName: String) {
        // 여기서 초기 생성 마크를 다룸. 초기 생성 마크가 없도록 주석처리.
//        let view = mapController?.getView(viewName) as! KakaoMap
//        let manager = view.getLabelManager()
//        let layer = manager.getLabelLayer(layerID: "PoiLayer")
//        let poiOption = PoiOptions(styleID: "PerLevelStyle")
//        poiOption.rank = 0
//        poiOption.clickable = true
//        let poi1 = layer?.addPoi(option: poiOption, at: MapPoint(longitude: 127.108678, latitude: 37.402001), callback: {(_ poi: (Poi?)) -> Void in
//            print("POI클릭")
//        }
//        )
//        
//        poi1?.show()
    }
}

extension Map2ViewController: KickboardRegisterDelegate {
    func didRegisterKickboard(latitude: Double, longitude: Double, code: String, battery: String, fee: String) {
        print("킥보드 등록 완료 - 위도 \(latitude), 경도 \(longitude), 코드 \(code), 베터리 \(battery), 요금 \(fee)")
    }
    
    func showKickboardMarker(at location: CGPoint) {
        print("마커표시")
        createMarker(viewPoint: location)
    }
    
    func createMarker(viewPoint: CGPoint) {
        let view = mapController?.getView(Map2ViewController.defaultViewName) as! KakaoMap
        let mapPoint = view.getPosition(viewPoint)
        let manager = view.getLabelManager()
        let layer = manager.getLabelLayer(layerID: "PoiLayer")
        let poiOption = PoiOptions(styleID: "PerLevelStyle")
        poiOption.rank = 0
        poiOption.clickable = true
        let poi1 = layer?.addPoi(option: poiOption, at: mapPoint, callback: {(_ poi: (Poi?)) -> Void in
            print("POI클릭")
        }
        )

        poi1?.show()
    }
}

extension Map2ViewController: MapControllerDelegate {
    
    func addViews() {
        let defaultPosition = MapPoint(longitude: 127.028406, latitude: 37.194402)
        let mapviewInfo = MapviewInfo(viewName: Map2ViewController.defaultViewName, viewInfoName: "map", defaultPosition: defaultPosition, defaultLevel: 7)
        mapController?.addView(mapviewInfo)
    }
    
    func addViewSucceeded(_ viewName: String, viewInfoName: String) {

        guard let mapView = mapController?.getView(viewName) as? KakaoMap else {
            print("Failed to get KakaoMap view")
            return
        }
        
        guard let mapContainer = mapContainer else {
            print("mapContainer is nil")
            return
        }
        
        mapView.viewRect = mapContainer.bounds
        moveToPointLocation()
        viewInit(viewName: viewName)

    }
    
    func addViewFailed(_ viewName: String, viewInfoName: String) {
        print("실패")
    }
    
    func containerDidResized(_ size: CGSize) {
        let mapView = mapController?.getView("mapview") as? KakaoMap
        mapView?.viewRect = CGRect(origin: .zero, size: size)
    }
    
}
