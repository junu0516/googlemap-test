import UIKit
import GoogleMaps
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    private var locationManager: CLLocationManager = CLLocationManager()
    
    private lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.numberOfLines = 3
        label.textAlignment = .left
        label.text = "탭한 위치 표시\n위도:\n경도:"
        return label
    }()
    
    private lazy var rangeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.numberOfLines = 4
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 13)
        label.text = "좌측 상단:\n우측 상단:\n좌측 하단:\n우측 하단:"
        return label
    }()
    
    private lazy var locationChangeButton: UIButton = {
        let button = UIButton()
        button.setTitle("현재 위치로 이동하기", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .lightGray
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.moveToCurrentLocation()
        }), for: .touchDown)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.text = "구글맵 테스트"
        return label
    }()
    
    private let mapBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var mapView: GMSMapView = {
        let camera = GMSCameraPosition.camera(withLatitude: 37.490864, longitude: 127.033406, zoom: 16)
        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    private var markers: [GMSMarker] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        addViews()
        setLayout()
        configureMap()
    }
    
    private func addViews() {
        view.addSubview(titleLabel)
        view.addSubview(locationLabel)
        view.addSubview(rangeLabel)
        view.addSubview(locationChangeButton)
        view.addSubview(mapBackgroundView)
        mapBackgroundView.addSubview(mapView)
    }
    
    private func setLayout() {
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.05).isActive = true
        
        locationChangeButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        locationChangeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        locationChangeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        locationChangeButton.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.05).isActive = true
        
        locationLabel.topAnchor.constraint(equalTo: locationChangeButton.bottomAnchor).isActive = true
        locationLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15).isActive = true
        locationLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        locationLabel.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.1).isActive = true
        
        rangeLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor).isActive = true
        rangeLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15).isActive = true
        rangeLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        rangeLabel.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.12).isActive = true
        
        mapBackgroundView.topAnchor.constraint(equalTo: rangeLabel.bottomAnchor, constant: 10).isActive = true
        mapBackgroundView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        mapBackgroundView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        mapBackgroundView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        mapView.topAnchor.constraint(equalTo: mapBackgroundView.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: mapBackgroundView.bottomAnchor).isActive = true
        mapView.leadingAnchor.constraint(equalTo: mapBackgroundView.leadingAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: mapBackgroundView.trailingAnchor).isActive = true
    }
    
    private func configureMap() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        addMarker(coordinate: mapView.camera.target, title: "코드스쿼드", snippet: "코드스쿼드")
    }
    
    private func moveToCurrentLocation() {
        if markers.count >= 2 { markers.popLast()?.map = nil }
        guard let coordinate = locationManager.location?.coordinate else { return }
        let camera = GMSCameraPosition(target: coordinate, zoom: 16)
        mapView.camera = camera
        
        addMarker(coordinate: coordinate, title: "현재 위치", snippet: "현재 위치")
    }
    
    //위치값 입력받아서, 해당 위치에 마커 추가
    private func addMarker(coordinate: CLLocationCoordinate2D, title: String, snippet: String) {
        let marker = GMSMarker()
        marker.position = coordinate
        marker.title = title
        marker.snippet = snippet
        marker.map = mapView
        markers.append(marker)
    }
}

extension ViewController: GMSMapViewDelegate {
    
    //터치한 지점의 좌표값 출력
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        locationLabel.text = "탭한 위치 표시\n위도:\(coordinate.latitude)\n경도:\(coordinate.longitude)"
    }
    
    //사용자 동작에 따른 위치값 변화 감지
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        let topLeft = mapView.projection.visibleRegion().farLeft
        let topRight = mapView.projection.visibleRegion().farRight
        let bottomleft = mapView.projection.visibleRegion().nearLeft
        let bottomRight = mapView.projection.visibleRegion().nearRight
        rangeLabel.text = "좌측 상단:\(topLeft.longitude),\(topLeft.latitude)\n우측 상단:\(topRight.longitude),\(topRight.latitude)\n좌측 하단:\(bottomleft.longitude),\(bottomleft.latitude)\n우측 하단:\(bottomRight.longitude),\(bottomRight.latitude)"
    }
}
