//
//  CountriesLocalDatasource.swift
//
//
//  Created by Isaac Iniongun on 01/12/2023.
//

import Foundation
import RealmSwift

struct CountriesLocalDatasource: CountriesLocalDatasourceProtocol {
    private let realm = try! Realm()
    
    func saveCountries(_ countries: [DJCountryDB]) throws {
        try realm.save(items: countries)
    }
    
    func getCountries() -> [DJCountryDB] {
        realm.getItems()
    }
    
    func getCountry(iso2: String) -> DJCountryDB? {
        realm.get(pk: iso2)
    }
    
    func getCountryByName(_ name: String) -> DJCountryDB? {
        getCountries().first { $0.countryName.insensitiveEquals(name) }
    }
}
