import UIKit
import MapKit
import CoreLocation

class Atlas: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate
{
    @IBOutlet weak var appTitle: UILabel!
    @IBOutlet weak var menu: UIBarButtonItem!
    @IBOutlet weak var mapa: MKMapView!
    let locationManager = CLLocationManager()
    
    //Estações de metrô
    let metro = "http://dadosabertos.rio.rj.gov.br/metro/api/v1/GeoJSON/Estacoes.cfm?token=40A22AF7-A9C6-86D6-E211ABA64BF73830&filter="
    
    //Pontos turísticos do Rio de Janeiro
    let pontos = "http://dadosabertos.rio.rj.gov.br/PontosTuristicosV2/api/v1/rest/PontosTuristicosV2.cfm?token=277B41FC-DFDD-8C38-0FE2BC8053FC129D&pretty=false&filter="
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        makeConfigs()
        
        RESTHelper.annotationsFromAPI(caminho: pontos)
        { json in
            MapHelper.pontosFromAPI(json: json, mapa: self.mapa)
        }
        
        RESTHelper.annotationsFromAPI(caminho: metro)
        { json in
            MapHelper.metroFromAPI(json: json, mapa: self.mapa)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        let location = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        
        let span = MKCoordinateSpanMake(0.02, 0.02)
        
        let region = MKCoordinateRegionMake(location, span)
        mapa.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if !(annotation is CustomizedAnnotation)
        {
            return nil
        }
        
        let reuseId = "test"
        
        var anView = mapa.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if anView == nil
        {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView!.canShowCallout = true
        }
        else
        {
            anView!.annotation = annotation
        }
        
        let pinImage = (annotation as! CustomizedAnnotation).img!
    
        anView!.image = UIImage(named: pinImage)
        
        let calloutImg = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        
        
        if let pinName = (annotation as! MKPointAnnotation).title
        {
            calloutImg.setImage(UIImage(named: MapHelper.imgForCallout(pinName: pinName, pinImage: pinImage)), for: .normal)
        }
        
        anView?.leftCalloutAccessoryView = calloutImg
        anView!.frame.size = CGSize(width: 35, height: 35)
        
        return anView
    }
    
    @IBAction func mapChanger(_ sender: AnyObject)
    {
        switch sender.selectedSegmentIndex
        {
        case 0:
            mapa.mapType = .standard
        case 1:
            mapa.mapType = .satellite
        case 2:
            mapa.mapType = .hybrid
        default:
            break;
        }
    }
    
    func makeConfigs()
    {
        menu.target = self.revealViewController()
        menu.action = #selector(SWRevealViewController.revealToggle(_:))
        
        self.locationManager.delegate = self
        self.locationManager.distanceFilter = 15.0
        
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        mapa.userLocation.title = "You are here"
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        mapa.showsUserLocation = true
        mapa.mapType = .hybrid
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
}
