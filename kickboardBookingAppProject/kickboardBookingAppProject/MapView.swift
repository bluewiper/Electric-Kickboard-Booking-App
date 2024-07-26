////
////  MapViewViewController.swift
////  kickboardBookingAppProject
////
////  Created by mac on 7/23/24.
////
//
//import UIKit
//import KakaoMapsSDK
//import SnapKit
//
//
//class MapViewController: UIViewController, MapControllerDelegate {
//    
//    var mapContainer: KMViewContainer?
//    var mapController: KMController?
//    var _observerAdded: Bool
//    var _auth: Bool
//    var _appear: Bool
//    
//    // 초기화 메서드
//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
//        _observerAdded = false
//        _auth = false
//        _appear = false
//        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        _observerAdded = false
//        _auth = false
//        _appear = false
//        super.init(coder: aDecoder)
//    }
//    
//    deinit {
//        mapController?.pauseEngine()
//        mapController?.resetEngine()
//        print("deinit")
//    }
//    
//    
//    // MARK: - UI 생성
//    
//    // 맵뷰 생성
//    private lazy var mapView: KMViewContainer = {
//        let view = KMViewContainer()
//        return view
//    }()
//    
//    // 주소 검색바
//    private var searchBar: UISearchBar = {
//        let searchBar = UISearchBar()
//        searchBar.placeholder = "주소 검색"
//        searchBar.backgroundColor = .white
//        searchBar.layer.cornerRadius = 15
//        searchBar.clipsToBounds = true
//        return searchBar
//    }()
//    
//    // 킥보드 이용중 확인 레이블
//    private var isUsingLabel: UILabel = {
//        let label = UILabel()
//        label.font = .boldSystemFont(ofSize: 15)
//        label.backgroundColor = .lightGray
//        label.text = "이용상태: X"
//        label.textAlignment = .center
//        return label
//    }()
//    
//    // 반납하기 버튼
//    
//    private var returnButton: UIButton = {
//        let button = UIButton()
//        button.setTitle("반납하기", for: .normal)
//        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
//        button.backgroundColor = .lightGray
//        button.layer.cornerRadius = 25
//        return button
//    }()
//    
//    // 현위치 가기 버튼
//    
//    private var locationButton: UIButton = {
//        let button = UIButton()
//        let largeConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold, scale: .large)
//        let largeBoldIcon = UIImage(systemName: "location.fill", withConfiguration: largeConfig)
//        button.setImage(largeBoldIcon, for: .normal)
//        button.backgroundColor = .lightGray
//        button.layer.cornerRadius = 25
//        button.tintColor = .systemBlue
//        return button
//    }()
//    
//    
//    
//    
//    // MARK: - viewDidLoad
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        view.backgroundColor = .white
//        addViews()
//        configureUI()
//        
//        
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        addObservers()
//        _appear = true
//        
//        if mapController?.isEngineActive == false {
//            mapController?.activateEngine()
//        }
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        _appear = false
//        mapController?.pauseEngine()  //렌더링 중지.
//    }
//    
//    override func viewDidDisappear(_ animated: Bool) {
//        removeObservers()
//        mapController?.resetEngine()     //엔진 정지. 추가되었던 ViewBase들이 삭제된다.
//    }
//    
//    
//    
//    // 인증 실패시 호출.
//    func authenticationFailed(_ errorCode: Int, desc: String) {
//        print("error code: \(errorCode)")
//        print("desc: \(desc)")
//        _auth = false
//        switch errorCode {
//        case 400:
//            showToast(self.view, message: "지도 종료(API인증 파라미터 오류)")
//            break;
//        case 401:
//            showToast(self.view, message: "지도 종료(API인증 키 오류)")
//            break;
//        case 403:
//            showToast(self.view, message: "지도 종료(API인증 권한 오류)")
//            break;
//        case 429:
//            showToast(self.view, message: "지도 종료(API 사용쿼터 초과)")
//            break;
//        case 499:
//            showToast(self.view, message: "지도 종료(네트워크 오류) 5초 후 재시도..")
//            
//            // 인증 실패 delegate 호출 이후 5초뒤에 재인증 시도..
//            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//                print("retry auth...")
//                
//                self.mapController?.prepareEngine()
//            }
//            break;
//        default:
//            break;
//        }
//    }
//    
//    
//    // MARK: - addViews
//    func addViews() {
//        //여기에서 그릴 View(KakaoMap, Roadview)들을 추가한다.
//        let defaultPosition: MapPoint = MapPoint(longitude: 126.9137, latitude: 37.5491)
//        //지도(KakaoMap)를 그리기 위한 viewInfo를 생성
//        let mapviewInfo: MapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: defaultPosition, defaultLevel: 17)
//        
//        mapContainer = mapView
//        guard mapContainer != nil else {
//            print("맵 생성 실패")
//            return
//        }
//        
//        //KMController 생성.
//        mapController = KMController(viewContainer: mapContainer!)
//        mapController!.delegate = self
//        
//        mapController?.prepareEngine() //엔진 초기화. 엔진 내부 객체 생성 및 초기화가 진행된다.
//        //KakaoMap 추가.
//        DispatchQueue.main.async {
//            self.mapController?.addView(mapviewInfo)
//        }
//    }
//    
//    
//    
//    // MARK: - configureUI
//    
//    private func configureUI() {
//        [
//            mapView,
//            searchBar,
//            isUsingLabel,
//            returnButton,
//            locationButton
//        ].forEach { view.addSubview($0) }
//        
//        mapView.snp.makeConstraints {
//            $0.edges.equalToSuperview()
//        }
//        
//        searchBar.snp.makeConstraints {
//            $0.centerX.equalToSuperview()
//            $0.top.equalToSuperview().offset(60)
//            $0.leading.trailing.equalToSuperview().inset(20)
//            $0.height.equalTo(30)
//        }
//        
//        isUsingLabel.snp.makeConstraints {
//            $0.top.equalTo(searchBar.snp.bottom).offset(10)
//            $0.leading.equalTo(searchBar)
//            $0.width.equalTo(85)
//            $0.height.equalTo(40)
//        }
//        
//        returnButton.snp.makeConstraints {
//            $0.centerX.equalToSuperview()
//            $0.bottom.equalToSuperview().inset(80)
//            $0.width.equalTo(120)
//            $0.height.equalTo(50)
//        }
//        
//        locationButton.snp.makeConstraints {
//            $0.centerY.equalTo(returnButton)
//            $0.trailing.equalToSuperview().inset(20)
//            $0.height.width.equalTo(50)
//        }
//        
//        
//    }
//    
//    //addView 성공 이벤트 delegate. 추가적으로 수행할 작업을 진행한다.
//    func addViewSucceeded(_ viewName: String, viewInfoName: String) {
//        print("OK") //추가 성공. 성공시 추가적으로 수행할 작업을 진행한다.
//    }
//    
//    //addView 실패 이벤트 delegate. 실패에 대한 오류 처리를 진행한다.
//    func addViewFailed(_ viewName: String, viewInfoName: String) {
//        print("Failed")
//    }
//    
//    //Container 뷰가 리사이즈 되었을때 호출된다. 변경된 크기에 맞게 ViewBase들의 크기를 조절할 필요가 있는 경우 여기에서 수행한다.
//    func containerDidResized(_ size: CGSize) {
//        let mapView: KakaoMap? = mapController?.getView("mapview") as? KakaoMap
//        mapView?.viewRect = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size)   //지도뷰의 크기를 리사이즈된 크기로 지정한다.
//    }
//    
//    func viewWillDestroyed(_ view: ViewBase) {
//        
//    }
//    
//    func addObservers(){
//        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
//        
//        _observerAdded = true
//    }
//    
//    func removeObservers(){
//        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
//        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
//        
//        _observerAdded = false
//    }
//    
//    @objc func willResignActive(){
//        mapController?.pauseEngine()  //뷰가 inactive 상태로 전환되는 경우 렌더링 중인 경우 렌더링을 중단.
//    }
//    
//    @objc func didBecomeActive(){
//        mapController?.activateEngine() //뷰가 active 상태가 되면 렌더링 시작. 엔진은 미리 시작된 상태여야 함.
//    }
//    
//    func showToast(_ view: UIView, message: String, duration: TimeInterval = 2.0) {
//        let toastLabel = UILabel(frame: CGRect(x: view.frame.size.width/2 - 150, y: view.frame.size.height-100, width: 300, height: 35))
//        toastLabel.backgroundColor = UIColor.black
//        toastLabel.textColor = UIColor.white
//        toastLabel.textAlignment = NSTextAlignment.center;
//        view.addSubview(toastLabel)
//        toastLabel.text = message
//        toastLabel.alpha = 1.0
//        toastLabel.layer.cornerRadius = 10;
//        toastLabel.clipsToBounds  =  true
//        
//        UIView.animate(withDuration: 0.4,
//                       delay: duration - 0.4,
//                       options: UIView.AnimationOptions.curveEaseOut,
//                       animations: {
//            toastLabel.alpha = 0.0
//        },
//                       completion: { (finished) in
//            toastLabel.removeFromSuperview()
//        })
//    }
//    
//    
//}
//
//
//
