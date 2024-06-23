import UIKit
import SnapKit
import Alamofire
import CoreLocation

class WeatherViewController: UIViewController {
    
    let dateLabel = UILabel()
    let locationButton = UIButton()
    let locationLabel = UILabel()
    let uploadButton = UIButton()
    let refreshButton = UIButton()
    let temperatureLabel = PaddedLabel()
    let humidityLabel = PaddedLabel()
    let windSpeedLabel = PaddedLabel()
    let weatherIcon = UIImageView()
    let helloLabel = PaddedLabel()
    let apiKey = APIKey.weatherKey
    var location = "Seoul"
    
    var locationManager: CLLocationManager!
    var currentLatitude: Double?
    var currentLongitude: Double?
    var isFetching = false
    let geocoder = CLGeocoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureUI()
        configureLayout()
        fetchWeatherData()
        setupLocationManager()
    }
    
    func configureHierarchy() {
        view.addSubview(dateLabel)
        view.addSubview(locationButton)
        view.addSubview(locationLabel)
        view.addSubview(uploadButton)
        view.addSubview(refreshButton)
        view.addSubview(temperatureLabel)
        view.addSubview(humidityLabel)
        view.addSubview(windSpeedLabel)
        view.addSubview(weatherIcon)
        view.addSubview(helloLabel)
    }
    
    func configureUI() {
        view.backgroundColor = .orange

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM월 dd일 HH시 mm분"
        let currentDate = Date()
        let dateString = dateFormatter.string(from: currentDate)
        dateLabel.text = dateString
        dateLabel.textColor = .white
        dateLabel.font = .systemFont(ofSize: 15)

        locationButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
        locationButton.tintColor = .white
        locationButton.configuration = .plain()
        locationButton.imageView?.snp.makeConstraints { make in
            make.width.height.equalTo(25)
        }

        locationLabel.text = "서울, 신림동"
        locationLabel.textColor = .white
        locationLabel.font = .systemFont(ofSize: 20)

        uploadButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        uploadButton.tintColor = .white

        refreshButton.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        refreshButton.tintColor = .white

        configureLabel(temperatureLabel, cornerRadius: 5)
        configureLabel(humidityLabel)
        configureLabel(windSpeedLabel)
        
        weatherIcon.contentMode = .scaleAspectFit
        weatherIcon.backgroundColor = .white
        weatherIcon.layer.cornerRadius = 10

        helloLabel.textColor = .black
        helloLabel.font = .systemFont(ofSize: 15)
        helloLabel.backgroundColor = .white
        helloLabel.clipsToBounds = true
        helloLabel.layer.cornerRadius = 10
        helloLabel.textInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        helloLabel.text = "오늘도 행복한 하루 되세요"
    }

    
    func configureLayout() {
        dateLabel.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(30)
        }
        locationButton.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(20)
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(30)
            make.width.equalTo(30)
        }
        locationLabel.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(20)
            make.leading.equalTo(locationButton.snp.trailing).offset(10)
        }
        uploadButton.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(20)
            make.trailing.equalTo(refreshButton.snp.leading).offset(-20)
            make.height.equalTo(20)
            make.width.equalTo(20)
        }
        refreshButton.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(20)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(20)
            make.width.equalTo(20)
        }
        temperatureLabel.snp.makeConstraints { make in
            make.top.equalTo(locationButton.snp.bottom).offset(20)
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(40)
        }
        humidityLabel.snp.makeConstraints { make in
            make.top.equalTo(temperatureLabel.snp.bottom).offset(10)
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(40)
        }
        windSpeedLabel.snp.makeConstraints { make in
            make.top.equalTo(humidityLabel.snp.bottom).offset(10)
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(40)
        }
        weatherIcon.snp.makeConstraints { make in
            make.top.equalTo(windSpeedLabel.snp.bottom).offset(20)
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.width.height.equalTo(100)
        }
        helloLabel.snp.makeConstraints { make in
            make.top.equalTo(weatherIcon.snp.bottom).offset(10)
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(40)
        }
    }
    
    func configureLabel(_ label: PaddedLabel, textColor: UIColor = .black, fontSize: CGFloat = 15, backgroundColor: UIColor = .white, cornerRadius: CGFloat = 10, textInsets: UIEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)) {
        label.textColor = textColor
        label.font = .systemFont(ofSize: fontSize)
        label.backgroundColor = backgroundColor
        label.clipsToBounds = true
        label.layer.cornerRadius = cornerRadius
        label.textInsets = textInsets
    }

    
    func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func fetchWeatherData() {
        guard !isFetching else { return }
        isFetching = true
        
        let url = APIURL.weatherURL
        let parameters: [String: String] = [
            "q": location,
            "appid": apiKey
        ]
        
        AF.request(url, parameters: parameters).responseDecodable(of: WeatherResponse.self) { response in
            self.isFetching = false
            switch response.result {
            case .success(let data):
                self.updateWeatherData(data)
                print(data)
            case .failure(let error):
                print("Error fetching weather data: \(error)")
            }
        }
    }
    
    func updateWeatherData(_ data: WeatherResponse) {
        DispatchQueue.main.async {
            self.temperatureLabel.text = "지금은 \(data.main.temp)°C에요"
            self.humidityLabel.text = "\(data.main.humidity)만큼 습해요"
            self.windSpeedLabel.text = "\(data.wind.speed)m/s의 바람이 불어요"
            
            if let iconUrl = URL(string: "https://openweathermap.org/img/wn/\(data.weather.first?.icon ?? "")@2x.png") {
                self.weatherIcon.load(url: iconUrl)
            }
        }
    }
    
    func updateLocationLabel(_ placemark: CLPlacemark) {
        DispatchQueue.main.async {
            if let locality = placemark.locality, let subLocality = placemark.subLocality {
                self.locationLabel.text = "\(locality), \(subLocality)"
            } else if let locality = placemark.locality {
                self.locationLabel.text = locality
                self.location = locality
            } else {
                self.locationLabel.text = "Unknown location"
            }
        }
    }
}

extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLatitude = location.coordinate.latitude
            currentLongitude = location.coordinate.longitude
            
            geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                if let error = error {
                    print("Reverse geocode failed: \(error.localizedDescription)")
                } else if let placemark = placemarks?.first {
                    self.updateLocationLabel(placemark)
                }
            }
            
            fetchWeatherData()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error.localizedDescription)")
    }
}
