//
//  Server.swift
//  y_project
//
//  Created by Volodymyr Orlov on 11/12/18.
//  Copyright © 2018 Volodymyr Orlov. All rights reserved.
//

import Foundation

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
    
    func getUser(_ user: User) {
        
        guard let baseURL = self.baseURL else {
            return
        }
        
        guard let endpointUrl = URL(string: "\(baseURL)/test-endpoint?id=\(user.id)") else {
            return
        }
        
        var json = [String:Any]()
        json["uid"] = user.id
        json["name"] = user.name
        
        do {
            
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            
            var request = URLRequest(url: endpointUrl)
            request.httpMethod = "GET"
            request.httpBody = data
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
                
                let result = json["user-id"] as? String
                
                print(json)
                
            }
            
            task.resume()
            
        }catch{
            
        }
        
    }
    
}
