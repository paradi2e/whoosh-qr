//
//  Configuration.swift
//  Whoosh QR Scanner
//
//  Created by Artem Kayumov on 16.10.2020.
//

import Foundation

struct Configuration {
    static let apiKey = "zJouBcMNMLaG5WhE6LyWMav1vMuFON896ucKSjIm"
    static let filterString = "https://whoosh.app.link/scooter?scooter_code="
    static let baseUrl = "https://api.whoosh.bike"
    static let scooter = Observable<Scooter?>(nil)
}
