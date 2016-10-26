import UIKit
import MapKit
import Foundation

class CustomizedAnnotation: MKPointAnnotation
{
    var img: String?
}

class BackTableVC: UITableViewController
{
    var tableArray = [String]()
    
    override func viewDidLoad()
    {
        tableArray = ["Hospitals"]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return tableArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableArray[indexPath.row], for: indexPath) as UITableViewCell
        cell.textLabel?.text = tableArray[indexPath.row]
        return cell
    }
}

class CustomCell: UITableViewCell
{
    @IBOutlet weak var nomeFantasia: UILabel!
}

class RESTHelper
{
    static func annotationsFromAPI(caminho: String, callback: @escaping (_ pontos: JSON) -> ())
    {
        let url = URL(string: caminho)
        let task = URLSession.shared.dataTask(with: url!)
        { (data, response, error) in
            if let theData = data
            {
                let json = JSON(data: theData)
                callback(json)
            }
        }
        task.resume()
    }
}

class MapHelper
{
    static func imgForCallout(pinName: String, pinImage: String) -> String
    {
        if (pinName.lowercased().contains("bar") && pinImage == "pin")
        {
            return "cocktail"
        }
        else if ((pinName.lowercased().contains("museu") || pinName.lowercased().contains("biblioteca")) && pinImage == "pin")
        {
            return "museum"
        }
        else if ((pinName.lowercased().contains("parque") || pinName.contains("Quinta") || pinName.lowercased().contains("campo") || pinName.lowercased().contains("floresta") || pinName.lowercased().contains("bosque")) && pinImage == "pin")
        {
            return "park"
        }
        else if ((pinName.lowercased().contains("maraca") || pinName.lowercased().contains("estádio")) && pinImage == "pin")
        {
            return "maraca"
        }
        else if ((pinName.contains("G.R.E.S") || pinName.contains("Samb")) && pinImage == "pin")
        {
            return "carnival"
        }
        return "right"
    }
    
    static func metroFromAPI(json: JSON, mapa: MKMapView)
    {
        for pins in json["features"].array!
        {
            let mpin = CustomizedAnnotation()
            mpin.title = pins["properties"]["estacao"].string
            mpin.img = "estacao"
            
            if let metroLat = pins["properties"]["latitude"].string, let metroLon = pins["properties"]["longitude"].string
            {
                if let doubleMetroLat = Double(metroLat), let doubleMetroLon = Double(metroLon)
                {
                    mpin.coordinate.latitude = doubleMetroLat
                    mpin.coordinate.longitude = doubleMetroLon
                }
            }
            
            DispatchQueue.main.async
            {
                    mapa.addAnnotation(mpin)
            }
        }
    }
    
    static func pontosFromAPI(json: JSON, mapa: MKMapView)
    {
        for pins in json.array!
        {
            let cpin = CustomizedAnnotation()
            cpin.title = pins["PLACE"].string
            cpin.subtitle = pins["ADDRESS"].string
            cpin.img = "pin"
            
            if let stringLat = pins["LATITUDE"].string, let stringLon = pins["LONGITUDE"].string
            {
                if let doubleLat = Double(stringLat), let doubleLon = Double(stringLon)
                {
                    cpin.coordinate.latitude = doubleLat
                    cpin.coordinate.longitude = doubleLon
                }
            }
            DispatchQueue.main.async
            {
                mapa.addAnnotation(cpin)
            }
        }
    }
}
