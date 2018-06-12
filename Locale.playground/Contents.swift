//: Playground - noun: a place where people can play

import Foundation

// Returns emoji flag for given iso country code
func flag(country: String) -> String {
    assert(country.count == 2)
    let base: UInt32 = UnicodeScalar("🇦").value - UnicodeScalar("A").value
    var flagString = ""

    let scalars = country.uppercased().unicodeScalars
    for scalar in scalars {
        let flagScalar = UnicodeScalar(base + scalar.value)!
        flagString.unicodeScalars.append(flagScalar)
    }
    return flagString
}

//flag(country: "pl")
//flag(country: "us")
//flag(country: "de")
//flag(country: "fr")
//flag(country: "gb")
//flag(country: "ru")

class LanguageFlagsResolver {

    private typealias LanguageCode = String
    private typealias CountryCode = String

    private lazy var locales: [Locale] = Locale.availableIdentifiers/*.filter { $0.count == 2 }*/.map(Locale.init)
    private var countryCodesCache = [LanguageCode: [CountryCode]]()

    func flags(forLanguage language: String) -> [String] {
        return countryCodes(forLanguageCode: language).map(flag)
    }

    private func countryCodes(forLanguageCode languageCode: LanguageCode) -> [CountryCode] {
        if let countryCodes = countryCodesCache[languageCode] {
            return countryCodes
        }

        let countryCodes = locales
            .filter { $0.languageCode == languageCode }
            .flatMap { $0.regionCode }
            .filter { $0.count == 2 }

        countryCodesCache[languageCode] = countryCodes

        return countryCodes
    }
}

let resolver = LanguageFlagsResolver()

print(resolver.flags(forLanguage: "pol"))

Locale.current.localizedString(forLanguageCode: "pol")

flag(country: "cn")

