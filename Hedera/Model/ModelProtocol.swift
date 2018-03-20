import Foundation
import ReactiveSwift

protocol StorageInput {
    @discardableResult func addWord(_ word: String, with translations: [String]) -> Word
    func registerFeedback(_ feedback: Bool, for word: String, at date: Date)
}

protocol StorageOutput {
    var allWords: Property<[Word]> {get}
    var remainingToday: Property<[Word]> {get}
    var totalCountToday: Property<Int> {get}
    func wordForSearch(_ search: String) -> Word?
}

typealias Storage = StorageInput & StorageOutput

protocol Checker {
    func add(_ userSearch: String)
    var words: Property<[String]> {get}
}

protocol TranslationProvider {
    func getTranslation(ofWord word: String) -> SignalProducer<DataModel, TranslationError>
}

protocol PhaseManager {
    func get(for word: Word, wasGuessed: Bool) -> (Date, Phase)
    var newWordDue: Date {get}
    var newWordPhase: Phase {get}
}

//Protocols for comunication inside model layer only
protocol PlannedTodayCountStorage {
    var plannedToday: Int {get set}
}

protocol DatabaseWrapperInput {
    func addWord(_ word: String, with translations: [String]) -> Word
    func registerFeedback(_ feedback: Bool, for word: String, at date: Date)
    func removeWord(_ word: String)
}

protocol DatabaseWrapperOutput {
    func getWords() -> [Word]
    func getRemaining() -> [Word]
    func getTranslations(of word: String) -> [String]
    func getWordForSearch(_ search: String) -> Word?
}

typealias DatabaseWrapper = DatabaseWrapperOutput & DatabaseWrapperInput
