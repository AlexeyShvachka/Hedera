import Foundation
import ReactiveSwift
import Result

enum StateToShow {
    case loading
    case added(Word)
    case addedForLater(String)
    case alreadyInDatabase(Word)
    case networkError
    case translated(String, [String])
    case empty
}

struct TranslationViewModel {
    let word: String
    let translations: [String]
}

class VMWordAdd {
    //Dependencies
    private let translator: TranslationProvider
    private let database: Storage
    private let checker: TranslationChecker
    
    private let state = MutableProperty<StateToShow>(.empty)
    private let definition = MutableProperty<String>("")
    private let translations = MutableProperty<[String]>([])
    public let userSearch = MutableProperty<String>("")
    public let stateToObserve: Property<StateToShow>

    public func saveCurrent(){
        let search = userSearch.value
        switch stateToObserve.value {
        case .loading, .networkError:
            checker.add(userSearch.value)
            userSearch.value = ""
            state.value = .addedForLater(search)
        case .translated(let word, let translations):
            var wordInDatabase: Word!
            if word.isEmpty {
                wordInDatabase = database.addWord(search, with: [])
            }
            wordInDatabase = database.addWord(word, with: translations)
            userSearch.value = ""
            state.value = .added(wordInDatabase)
        default:
            return
        }
    }

    init(translator: TranslationProvider,
         database : Storage,
         checker: TranslationChecker) {
        self.checker = checker
        self.translator = translator
        self.database = database
        stateToObserve = Property(state)
        state <~ userSearch.signal
            .skipRepeats()
            .flatMap(.latest) {
                [weak self] (search) ->  SignalProducer<StateToShow, NoError> in

            if search.isEmpty{
                return SignalProducer<StateToShow, NoError>(value: .empty)
            }

            //Check if word alredy in dictionary
            let fetchedWord = database.wordForSearch(search)
            if  let wordFromDictionary = fetchedWord {
                return SignalProducer<StateToShow, NoError>(value: .alreadyInDatabase(wordFromDictionary))
            }
            else {
                //trying to get actual translation
                let translationResponse =  self!.translator.getTranslation(ofWord: search).materialize()
                    .take(first: 1)         // we want to ignore 'completed' event once we got 'value'
                    .map{ event -> StateToShow in
                        switch event {
                        case .completed:
                            return .translated(search, [])
                        case .failed(_), .interrupted:
                            return .networkError
                        case .value(let dataModel):
                            guard let strongSelf = self else {
                                return .empty
                            }

                            if dataModel.definition.isNilOrEmpty {
                                strongSelf.definition.value = search
                            }
                            else{
                                strongSelf.definition.value = dataModel.definition ?? search
                            }
                            strongSelf.translations.value = dataModel.translations ?? []

                            return .translated(strongSelf.definition.value,
                                               strongSelf.translations.value)
                        }
                    }
                let loading: SignalProducer<StateToShow, NoError> = SignalProducer(value: .loading)
                // loading state will always be emited first and then result of translation
                return loading.concat(translationResponse)
            }
        }
    }
}

extension DataModel{
    var translations: [String]? {
        get {
            if let defArray = self.def{
                if !defArray.isEmpty{
                    return self.def?[0].tr?.map{$0.text}
                }
            }
            return []
        }
    }
    var definition: String?  {
        get{
            if (self.def ?? []).isEmpty {
                return ""
            }
            else{
                return def![0].text
            }
        }
    }
}
