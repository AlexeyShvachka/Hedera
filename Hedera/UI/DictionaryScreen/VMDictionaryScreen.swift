import Foundation
import ReactiveSwift
import Result


enum DictionaryEntity{
    case regular(Word)
    case waitng(String)

    public func contains(_ search: String) -> Bool {
        if search.isEmpty { return true}
        switch self {
        case .regular(let word):
            return word.text.localizedCaseInsensitiveContains(search) || word.bestTranslation.localizedCaseInsensitiveContains(search)
        case .waitng(let word):
            return word.localizedCaseInsensitiveContains(search)
        }
    }
}

class VMDictionaryScreen{
    let enteties: Property<[DictionaryEntity]>
    let searchString = MutableProperty<String>("")

    init(storage: StorageOutput,
         checker: TranslationChecker){
        enteties =  storage.allWords
            .combineLatest(with: checker.words)
            .map{ (translated, waiting) in
              return waiting.map{DictionaryEntity.waitng($0)} +       translated.map{DictionaryEntity.regular($0)}}
            .combineLatest(with: searchString)
            .map{(elements, userSearch) in
                return elements.filter{$0.contains(userSearch)}}
    }
}
