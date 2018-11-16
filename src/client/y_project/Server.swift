import Foundation
import CoreLocation

class Server {
    
    var baseURL: String!
    
    init(baseURL: String){
        self.baseURL = baseURL
    }
    
    func updateUser(_ user: User) {
        
        guard let baseURL = self.baseURL else {
            return
        }
        
        guard let endpointUrl = URL(string: "\(baseURL)/user") else {
            return
        }
        
        var json = [String:Any]()
        json["userid"] = user.id
        json["firstname"] = user.name
        
        do {
        
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            
            var request = URLRequest(url: endpointUrl)
            request.httpMethod = "POST"
            request.httpBody = data
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
                
                guard error == nil else {
                    print("returning error")
                    return
                }
                
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                    return
                }
                
                print(statusCode)
                
            }
            
            task.resume()
            
        }catch{
            
        }
        
    }
    
    func syncUser(_ userID: String, completion: @escaping (String, String) -> ()) {
        
        guard let baseURL = self.baseURL else {
            return
        }
        
        guard let endpointUrl = URL(string: "\(baseURL)/user/\(userID)") else {
            return
        }
        
        do {
            
            var request = URLRequest(url: endpointUrl)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
                
                guard error == nil else {
                    print("returning error")
                    return
                }
                
                guard let content = data else {
                    print("not returning data")
                    return
                }
                
                
                guard let json = (try? JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers)) as? [String: Any] else {
                    print("Not containing JSON")
                    return
                }
                
                guard let name = json["name"] as? String else {
                    return
                }
                
                completion(userID, name)
                
            }
            
            task.resume()
            
        }catch{
        }
        
    }
    
    func reportLocation(_ userID: String, _ location: CLLocation) {
        
        guard let baseURL = self.baseURL else {
            return
        }
        
        guard let endpointUrl = URL(string: "\(baseURL)/location/\(userID)") else {
            return
        }
        
        var json = [String:Any]()
        json["longtitude"] = location.coordinate.longitude
        json["latitude"] = location.coordinate.latitude
        
        do {
            
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            
            var request = URLRequest(url: endpointUrl)
            request.httpMethod = "POST"
            request.httpBody = data
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
                
                guard error == nil else {
                    print("returning error")
                    return
                }
                
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                    return
                }
                
                print(statusCode)
                
            }
            
            task.resume()
            
        }catch{
        }
        
    }
    
}
