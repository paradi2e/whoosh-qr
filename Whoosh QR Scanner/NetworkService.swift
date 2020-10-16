//
//  NetworkService.swift
//  Whoosh QR Scanner
//
//  Created by Artem Kayumov on 16.10.2020.
//

import Alamofire
import Foundation

class NetworkService {
    
    let headers: HTTPHeaders = [
        "x-api-key": Configuration.apiKey
    ]
    
    let parameters: Parameters = [
        "code": Configuration.scooterNumber
    ]
    
    func request() {
        AF.request(
            Configuration.requestUrl,
            method: .get,
            parameters: parameters,
            headers: headers
        ).responseData { (response) in
            guard let data = response.value else { return }
            do {
                let scooter = try JSONDecoder().decode(Scooter.self, from: data)
                Configuration.scooter.value = scooter
                print(scooter)
            } catch {
                print(error)
            }
        }
    }
}
