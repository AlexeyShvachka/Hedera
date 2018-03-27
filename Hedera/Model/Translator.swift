import Foundation
import ReactiveSwift

class TranslationError: Error{}

class Translator : TranslationProvider{
    private let decoder = JSONDecoder()
    private let session = URLSession.shared

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

    fileprivate func encodedQuery(_ word: String) -> String?{
        let APIBase = "https://dictionary.yandex.net/api/v1/dicservice.json/lookup?key=dict.1.1.20170610T174815Z.a1d2bc2e066864e7.5489d30457da1fc00396b2ae45b207883171aa42&lang=cs-ru&text="
        let query = APIBase + word
        return  query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
}

