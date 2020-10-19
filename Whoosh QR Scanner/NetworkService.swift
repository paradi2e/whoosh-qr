//
//  NetworkService.swift
//  Whoosh QR Scanner
//
//  Created by Artem Kayumov on 16.10.2020.
//

import Alamofire
import Foundation

class NetworkService {
    
    private let headers: HTTPHeaders = [
        "x-api-key": Configuration.apiKey
    ]
    
    private let getInfoPath: String = "/challenge/getinfo"
    
    func request(_ scotterNumber: String) {
        let url = Configuration.baseUrl + getInfoPath
        AF.request(
            url,
            method: .get,
            parameters: ["code": scotterNumber],
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
