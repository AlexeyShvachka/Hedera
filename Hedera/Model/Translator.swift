import Foundation
import ReactiveSwift

struct DataModel: Codable {
    struct Head : Codable {}

    struct Text : Codable {
        let text: String
    }

    struct Tr : Codable {
        let text: String
        let pos: String
        let syn: [Text]?
        let mean: [Text]?
        let ex: [AltTranslation]?
    }

    struct AltTranslation: Codable{
        let text: String
        let tr: [Text]?
    }

    struct Def: Codable{
        let text: String
        let pos: String
        let tr: [Tr]?
    }

    let head: Head
    let def: [Def]?
}

extension DataModel {
    var isEmpty: Bool {
        get {
            return def == nil || def!.isEmpty
        }
    }
}

fileprivate func encodedQuery(_ word: String) -> String?{
    let APIBase = "https://dictionary.yandex.net/api/v1/dicservice.json/lookup?key=dict.1.1.20170610T174815Z.a1d2bc2e066864e7.5489d30457da1fc00396b2ae45b207883171aa42&lang=cs-en&text="
    let query = APIBase + word
    return  query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
}


protocol TranslationProvider {
    func getTranslation(ofWord word: String) -> SignalProducer<DataModel, TranslationError>
}


class TranslationError: Error{}

class Translator : TranslationProvider{
    let decoder = JSONDecoder()
    let session = URLSession.shared

    func getTranslation(ofWord word: String) -> SignalProducer<DataModel, TranslationError> {
        if word.isEmpty {
            return SignalProducer<DataModel, TranslationError>.empty
        }

        guard let query = encodedQuery(word),
            let requestURL = URL(string: query)
            else{
                return SignalProducer<DataModel, TranslationError>.empty
            }

        return URLSession.shared.reactive.data(with: URLRequest(url: requestURL))
        .map{ (data, _) -> DataModel in
            return try! self.decoder.decode(DataModel.self, from: data)
        }.mapError{ _ in
            return TranslationError()
        }
    }
}

