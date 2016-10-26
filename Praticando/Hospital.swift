import Foundation
import UIKit

struct Hospital
{
    var nomefantasia: String? = nil
    var logradouro: String? = nil
    var numero: Int? = nil
    var bairro: String? = nil
    var telefone: String? = nil
    var email: String? = nil
    var latitude: Double? = nil
    var longitude: Double? = nil
}

class SpecificHospital: UIViewController
{
    var local = Hospital()
    
    
    @IBOutlet weak var hospitalName: UILabel!
    @IBOutlet weak var hospitalAddress: UILabel!
    @IBOutlet weak var hospitalPhone: UILabel!
    @IBOutlet weak var hospitalEmail: UILabel!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        hospitalName.text = local.nomefantasia!
        
        if let telefone = local.telefone, let email = local.email
        {
            hospitalPhone.text = telefone
            hospitalEmail.text = email
        }
        
        if let endereco = local.logradouro, let numero = local.numero, let bairro = local.bairro
        {
            hospitalAddress.text = "ADDRESS: \(endereco),\(numero) - \(bairro)"
        }
    }
}   

class HospitalList: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    
    var hospitals: [Hospital] = []
    var local = Hospital()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if let path = Bundle.main.path(forResource: "hospitals", ofType: "json")
        {
            let data = NSData(contentsOf: URL(fileURLWithPath: path))
            let json = JSON(data: data as! Data)
            
            for hospital in json["DATA"].array!
            {
                local.nomefantasia = hospital[3].string
                local.logradouro = hospital[4].string
                local.numero = hospital[5].int
                local.bairro = hospital[7].string
                local.telefone = hospital[9].string
                local.email = hospital[11].string
                local.latitude = hospital[12].double
                local.longitude = hospital[13].double
                //
                hospitals.append(local)
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CustomCell
        if cell == nil {}
        else
        {
            cell?.nomeFantasia.text = hospitals[indexPath.row].nomefantasia
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return hospitals.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        local = hospitals[indexPath.row]
        performSegue(withIdentifier: "hospital", sender: local)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if (segue.identifier == "hospital")
        {
            let destino = segue.destination as! SpecificHospital
            destino.local = sender as! Hospital
        }
    }
}
