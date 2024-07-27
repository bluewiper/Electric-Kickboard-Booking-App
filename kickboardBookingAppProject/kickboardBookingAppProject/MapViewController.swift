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

struct Place {
    let name: String
    let latitude: Double
    let longitude: Double
}

class MapViewController: UIViewController, MapControllerDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    
    
    private lazy var mapView: KMViewContainer = {
        let view = KMViewContainer()
        return view
    }()
    
    private var locationManager = CLLocationManager()
    // 검색 결과를 저장할 배열
    private var searchResults = [Place]() // 검색 결과를 저장할 배열
    private var searchResultPois: [Poi] = []
    private var hasGeneratedRandomPois = false // 랜덤 POI가 생성되었는지 여부를 추적
    private var poiIDs: [Poi: String] = [:]
    
    private var isKickboardInUse = false {
        didSet {
            updateKickboardUsageStatus()
        }
    }
    // 스타일 정보를 저장하기 위한 Dictionary
    private var poiStyles: [Poi: String] = [:]
    
    
    // 주소 검색바
    private var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "주소 검색"
        searchBar.backgroundColor = .white
        searchBar.layer.cornerRadius = 15
        searchBar.clipsToBounds = true
        return searchBar
    }()
    
    // 검색 결과를 보여줄 테이블 뷰
    private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        return tableView
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
        button.isUserInteractionEnabled = false
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
        button.addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
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
        
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell") // 셀 등록
        
        // 반납하기 버튼 이벤트 추가
        returnButton.addTarget(self, action: #selector(returnButtonTapped), for: .touchUpInside)
        
        // 맵뷰에 터치 이벤트 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMapTap(_:)))
        mapView.addGestureRecognizer(tapGesture)
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
        
        // 지도 초기화 완료 후 위치 정보 가져오기
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.updateLocationToCurrentPosition()
        }
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
            locationButton,
            tableView
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
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
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
        
        // 랜덤 POI 생성 (최초 한 번만 생성)
        if !hasGeneratedRandomPois {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if let currentLocation = self.locationManager.location {
                    print("Generating random POI near location after view initialized") // 로그 추가
                    self.createRandomPoiNearLocation(coordinate: currentLocation.coordinate)
                    self.hasGeneratedRandomPois = true
                }
            }
        }
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
    
    @objc func locationButtonTapped() {
        // 랜덤 POI 생성 로직을 제거
        if let currentLocation = locationManager.location {
            let position = MapPoint(longitude: currentLocation.coordinate.longitude, latitude: currentLocation.coordinate.latitude)
            if let mapView = mapController?.getView("mapview") as? KakaoMap {
                mapView.moveCamera(CameraUpdate.make(target: position, zoomLevel: 17, mapView: mapView))
            }
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
    
    
    // MARK: - searchBar
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            fetchSearchSuggestions(query: searchText)
        } else {
            searchResults.removeAll()
            tableView.reloadData()
            tableView.isHidden = true
        }
    }
    
    func fetchSearchSuggestions(query: String) {
        let apiKey = "9f8f33a1c0ab59c1e407115394bed294"
        let urlString = "https://dapi.kakao.com/v2/local/search/keyword.json?query=\(query)"
        
        var request = URLRequest(url: URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!)
        request.setValue("KakaoAK \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching search suggestions: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let documents = json["documents"] as? [[String: Any]] {
                    self.searchResults = documents.compactMap {
                        guard let name = $0["place_name"] as? String,
                              let x = $0["x"] as? String,
                              let y = $0["y"] as? String,
                              let longitude = Double(x),
                              let latitude = Double(y) else {
                            return nil
                        }
                        return Place(name: name, latitude: latitude, longitude: longitude)
                    }
                } else {
                    self.searchResults = [] // 검색 결과가 없을 경우 빈 배열 설정
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.tableView.isHidden = false
                }
            } catch {
                print("Error parsing search suggestions: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(searchResults.count, 1) // 최소 1개의 셀을 반환합니다.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if searchResults.isEmpty {
            cell.textLabel?.text = "검색 결과가 없습니다."
            cell.textLabel?.textColor = .gray
            cell.selectionStyle = .none // 선택 불가능하게 설정
        } else {
            cell.textLabel?.text = searchResults[indexPath.row].name
            cell.textLabel?.textColor = .black
            cell.selectionStyle = .default // 선택 가능하게 설정
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !searchResults.isEmpty else { return } // 검색 결과가 없을 때 선택 불가능하게 합니다.
        
        let selectedPlace = searchResults[indexPath.row]
        searchBar.text = selectedPlace.name
        tableView.isHidden = true
        
        let position = MapPoint(longitude: selectedPlace.longitude, latitude: selectedPlace.latitude)
        
        removeSearchResultPois() // 기존 검색 결과 POI 제거
        
        if let mapView = mapController?.getView("mapview") as? KakaoMap {
            mapView.moveCamera(CameraUpdate.make(target: position, zoomLevel: 17, mapView: mapView))
            createSearchResultPoi(at: position)
        }
    }
    
    
    // MARK: - LocationManager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let coordinate = location.coordinate
        let position = MapPoint(longitude: coordinate.longitude, latitude: coordinate.latitude)
        
        // 현재 위치 콘솔 출력
        print("Current location: \(coordinate.latitude), \(coordinate.longitude)")
        
        // 현재 위치 POI 생성
        createCurrentLocationPoi(at: position)
        
        // 모든 POI를 추가한 후 지도 이동
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

            DispatchQueue.main.async {
                self.locationManager(self.locationManager, didUpdateLocations: [currentLocation])
            }
        }
    }
    
    
    
    //MARK: - POI
    
    func createPoiStyle() {
        guard let mapView = mapController?.getView("mapview") as? KakaoMap else {
            return
        }
        let labelManager = mapView.getLabelManager()
        
        // 현위치 POI 스타일 정의
        let currentLocationImage = UIImage(systemName: "figure.wave")
        guard let currentLocationIcon = currentLocationImage?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal) else {
            return
        }
        let currentLocationPoiIconStyle = PoiIconStyle(symbol: currentLocationIcon, anchorPoint: CGPoint(x: 0.5, y: 1.0))
        let currentLocationPerLevelStyle = PerLevelPoiStyle(iconStyle: currentLocationPoiIconStyle, level: 0)
        let currentLocationPoiStyle = PoiStyle(styleID: "currentLocation", styles: [currentLocationPerLevelStyle])
        labelManager.addPoiStyle(currentLocationPoiStyle)
        
        // 검색 결과 POI 스타일 정의
        let searchResultImage = UIImage(systemName: "mappin")
        guard let searchResultIcon = searchResultImage?.withTintColor(.systemRed, renderingMode: .alwaysOriginal) else {
            return
        }
        let searchResultPoiIconStyle = PoiIconStyle(symbol: searchResultIcon, anchorPoint: CGPoint(x: 0.5, y: 1.0))
        let searchResultPerLevelStyle = PerLevelPoiStyle(iconStyle: searchResultPoiIconStyle, level: 0)
        let searchResultPoiStyle = PoiStyle(styleID: "searchResult", styles: [searchResultPerLevelStyle])
        labelManager.addPoiStyle(searchResultPoiStyle)
        
        // 랜덤 POI 스타일 정의
        let randomPoiImage = UIImage(systemName: "bicycle.circle.fill")
        guard let randomPoiIcon = randomPoiImage?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal) else {
            print("Failed to create random POI icon") // 로그 추가
            return
        }
        let randomPoiIconStyle = PoiIconStyle(symbol: randomPoiIcon, anchorPoint: CGPoint(x: 0.5, y: 1.0))
        let randomPoiPerLevelStyle = PerLevelPoiStyle(iconStyle: randomPoiIconStyle, level: 0)
        let randomPoiStyle = PoiStyle(styleID: "randomPoi", styles: [randomPoiPerLevelStyle])
        labelManager.addPoiStyle(randomPoiStyle)
        print("Random POI style added successfully") // 로그 추가
    }
    
    func createLabelLayer() { // 레이어생성
        guard let mapView = mapController?.getView("mapview") as? KakaoMap else { return }
        let labelManager = mapView.getLabelManager()
        let layer = LabelLayerOptions(layerID: "poiLayer", competitionType: .none, competitionUnit: .symbolFirst, orderType: .rank, zOrder: 10001)
        let _ = labelManager.addLabelLayer(option: layer)
    }
    
    func createCurrentLocationPoi(at position: MapPoint) {
        guard let mapView = mapController?.getView("mapview") as? KakaoMap else {
            print("Map view is nil")
            return
        }
        let labelManager = mapView.getLabelManager()
        guard let layer = labelManager.getLabelLayer(layerID: "poiLayer") else {
            print("POI layer is nil")
            return
        }
        
        let options = PoiOptions(styleID: "currentLocation", poiID: "currentLocationPoi")
        if let poi = layer.addPoi(option: options, at: position) {
            let coordinate = position.wgsCoord
            print("Current location POI added at \(coordinate.latitude), \(coordinate.longitude)")
            poi.show()
        } else {
            print("Failed to add current location POI")
        }
    }
    
    func createSearchResultPoi(at position: MapPoint) {
        guard let mapView = mapController?.getView("mapview") as? KakaoMap else {
            print("Map view is nil")
            return
        }
        let labelManager = mapView.getLabelManager()
        guard let layer = labelManager.getLabelLayer(layerID: "poiLayer") else {
            print("POI layer is nil")
            return
        }
        
        let uniquePoiID = UUID().uuidString // 고유한 ID 생성
        let options = PoiOptions(styleID: "searchResult", poiID: uniquePoiID)
        if let poi = layer.addPoi(option: options, at: position) {
            let coordinate = position.wgsCoord
            print("Search result POI added at \(coordinate.latitude), \(coordinate.longitude)")
            poi.show()
            searchResultPois.append(poi) // 생성된 POI를 배열에 추가
        } else {
            print("Failed to add search result POI")
        }
    }
    
    // 랜덤 위치에 포이 생성
    func createRandomPoiNearLocation(coordinate: CLLocationCoordinate2D) {
        guard let mapView = mapController?.getView("mapview") as? KakaoMap else {
            print("Map view is nil")
            return
        }
        guard !hasGeneratedRandomPois else { return } // 이미 생성된 경우 리턴

        for _ in 1...5 {
            let randomDistance = Double.random(in: 10...500) // 10에서 500미터 사이의 랜덤 거리
            let randomAngle = Double.random(in: 0...(2 * .pi)) // 0에서 2파이 사이의 랜덤 각도
            
            let deltaLat = (randomDistance / 111000) * cos(randomAngle)
            let deltaLon = (randomDistance / (111000 * cos(coordinate.latitude * .pi / 180))) * sin(randomAngle)
            
            let randomLat = coordinate.latitude + deltaLat
            let randomLon = coordinate.longitude + deltaLon
            
            let position = MapPoint(longitude: randomLon, latitude: randomLat)
            print("Random location: \(randomLat), \(randomLon)") // 랜덤 위치 콘솔 출력
            print("Calling createRandomPoi") // 로그 추가
            createRandomPoi(at: position)
        }

        hasGeneratedRandomPois = true // 생성 완료 플래그 설정
    }

    private var kickboardCount = 0
    
    private var poiNames: [Poi: String] = [:]
    
    private var rentedKickboard: Poi?

    func createRandomPoi(at position: MapPoint) {
        guard let mapView = mapController?.getView("mapview") as? KakaoMap else {
            print("Map view is nil")
            return
        }
        let labelManager = mapView.getLabelManager()
        guard let layer = labelManager.getLabelLayer(layerID: "poiLayer") else {
            print("POI layer is nil")
            return
        }
        
        let uniquePoiID = UUID().uuidString
        let options = PoiOptions(styleID: "randomPoi", poiID: uniquePoiID)
        if let poi = layer.addPoi(option: options, at: position) {
            let coordinate = position.wgsCoord
            kickboardCount += 1 // 순서 증가
            poiStyles[poi] = "randomPoi"
            let kickboardName = "\(kickboardCount)번 킥보드"
            poiNames[poi] = kickboardName // 이름 저장
            poiIDs[poi] = uniquePoiID // ID 저장
            print("\(kickboardName) POI added at \(coordinate.latitude), \(coordinate.longitude)") // 로그 출력
            poi.show()
        } else {
            print("Failed to add random POI")
        }
    }
    
    func removeSearchResultPois() {
        guard let mapView = mapController?.getView("mapview") as? KakaoMap else {
            return
        }
        let labelManager = mapView.getLabelManager()
        for poi in searchResultPois {
            poi.hide() // POI를 숨깁니다.
            // POI를 제거하는 다른 방법이 없다면 숨기는 것만으로 충분할 수 있습니다.
        }
        searchResultPois.removeAll() // 배열을 비웁니다.
    }
    
    // MARK: - 킥보드 이용 상태
    private func updateKickboardUsageStatus() {
        isUsingLabel.text = isKickboardInUse ? "이용상태: O" : "이용상태: X"
        returnButton.isEnabled = isKickboardInUse
        returnButton.isUserInteractionEnabled = isKickboardInUse // 상태에 따라 사용자 상호작용 설정
        returnButton.backgroundColor = isKickboardInUse ? .systemBlue : .lightGray
        isUsingLabel.backgroundColor = isKickboardInUse ? #colorLiteral(red: 0.05629429966, green: 0.8279358745, blue: 0.3545475006, alpha: 1) : .lightGray // 레이블 색상 변경
    }
    
    private func showPOIAlert(for poi: Poi) {
        guard let poiName = poiNames[poi] else { return }
        let alert = UIAlertController(title: poiName, message: "대여하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "예", style: .default, handler: { _ in
            self.isKickboardInUse = true
            self.rentedKickboard = poi // 대여 중인 킥보드 저장
            poi.hide() // 대여 중인 킥보드 숨기기
            self.updateKickboardUsageStatus()
        }))
        alert.addAction(UIAlertAction(title: "아니오", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func returnButtonTapped() {
        let alert = UIAlertController(title: "반납 완료", message: "반납이 완료되었습니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            self.isKickboardInUse = false
            if let rentedKickboard = self.rentedKickboard {
                rentedKickboard.show() // 숨겨진 킥보드 보이게 하기
                self.movePoiToMapCenter(poi: rentedKickboard) // POI를 카메라 정중앙으로 이동
                self.rentedKickboard = nil // 대여 중인 킥보드 초기화
            }
            self.updateKickboardUsageStatus()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    // POI를 카메라 정중앙으로 이동시키는 함수
    private func movePoiToMapCenter(poi: Poi) {
        if let mapView = mapController?.getView("mapview") as? KakaoMap {
            // KakaoMap의 중심 좌표를 얻어옴
            let centerPoint = CGPoint(x: mapView.viewRect.midX, y: mapView.viewRect.midY)
            let centerPosition = mapView.getPosition(centerPoint)
            
            let labelManager = mapView.getLabelManager()
            let layer = labelManager.getLabelLayer(layerID: "poiLayer")
            
            // 기존 POI 제거
            if let poiID = poiIDs[poi] {
                layer?.removePoi(poiID: poiID)
            }
            
            // 새로운 POI 생성
            let uniquePoiID = UUID().uuidString
            let poiOptions = PoiOptions(styleID: poiStyles[poi] ?? "", poiID: uniquePoiID)
            if let newPoi = layer?.addPoi(option: poiOptions, at: centerPosition) {
                newPoi.show()
                poiStyles[newPoi] = poiStyles[poi]
                poiNames[newPoi] = poiNames[poi]
                poiIDs[newPoi] = uniquePoiID // 새 POI의 ID 저장
            }
        }
    }

    
    @objc private func handleMapTap(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: mapView)
        if let mapPoint = getPosition(point) {
            if let nearestPOI = touchedPOI(mapPoint.wgsCoord, 0.0001) { // 감지 범위를 줄임
                poiTouched(nearestPOI)
            }
        }
    }

    private func poiTouched(_ poi: Poi) {
        if !isKickboardInUse {
            showPOIAlert(for: poi)
        }
    }

    private func getPosition(_ point: CGPoint) -> MapPoint? {
        let mapView: KakaoMap? = mapController?.getView("mapview") as? KakaoMap
        return mapView?.getPosition(point)
    }

    private func touchedPOI(_ coord: GeoCoordinate, _ dist: Double) -> Poi? {
        if let map = mapController?.getView("mapview") as? KakaoMap {
            let manager = map.getLabelManager()
            let layer = manager.getLabelLayer(layerID: "poiLayer")
            guard let pois = layer?.getAllPois() else { return nil }
            var touchedPois: [Poi : Double] = [:]
            for poi in pois {
                // 저장된 스타일 정보를 사용하여 랜덤 POI만 필터링
                if poiStyles[poi] == "randomPoi" {
                    let latDist = (coord.latitude - poi.position.wgsCoord.latitude)
                    let longDist = (coord.longitude - poi.position.wgsCoord.longitude)
                    let powDist = latDist * latDist + longDist * longDist
                    let distWithPoi = sqrt(powDist)
                    if distWithPoi < dist {
                        touchedPois[poi] = distWithPoi
                    }
                }
            }
            if touchedPois.isEmpty { return nil }
            return touchedPois.sorted(by: { $0.value < $1.value }).first?.key
        }
        return nil
    }
    
}

