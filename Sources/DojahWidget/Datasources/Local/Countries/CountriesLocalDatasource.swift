//
//  CountriesLocalDatasource.swift
//
//
//  Created by Isaac Iniongun on 01/12/2023.
//

import Foundation
 //import RealmSwift

struct CountriesLocalDatasource: CountriesLocalDatasourceProtocol {
    func saveCountries(_ countries: [DJCountryDB]) throws {
//            let realm = try Realm()
//            try realm.save(items: countries)
        }

        func getCountries() -> [DJCountryDB] {
//            let realm = try! Realm()
//            return realm.getItems()
            return []
        }

        func getCountry(iso2: String) -> DJCountryDB? {
//            let realm = try! Realm()
//            return realm.get(pk: iso2)
            return nil
        }

        func getCountryByName(_ name: String) -> DJCountryDB? {
            //getCountries().first { $0.countryName.insensitiveEquals(name) }
            return nil
        }
}
