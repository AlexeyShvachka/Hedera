import Foundation
import ReactiveSwift

class PersistantStorage: Storage{
    // outputs
    public let allWords: Property<[Word]>
    public let remainingToday: Property<[Word]>
    public let totalCountToday: Property<Int>
    // inner
    private let core : DatabaseWrapper
    private var totalCountStorage: PlannedTodayCountStorage

    private let all: MutableProperty<[Word]>
    private let remaining: MutableProperty<[Word]>
    private let total: MutableProperty<Int>

    init(with database: DatabaseWrapper,
         countStorage: PlannedTodayCountStorage) {
        core = database
        totalCountStorage = countStorage
        all = MutableProperty(core.getWords())
        remaining = MutableProperty(core.getRemaining())
        total = MutableProperty(totalCountStorage.plannedToday)
        allWords = Property(all)
        totalCountToday = Property(total)
        remainingToday = Property(remaining)
    }

    //inputs
    @discardableResult public func addWord(_ word: String, with translations: [String]) -> Word{
        if let index = all.value.index(of: Word.mock(from: word) ){
            return all.value[index]
        }
        else{
            let newWord = core.addWord(word, with: translations)
            all.value.append(newWord)
            regularUpdate()
            return newWord
        }
    }

    public func registerTranslation(for userSearch: String, word: String, translations: [String]){
        core.removeWord(userSearch)
        addWord(word, with: translations)
        regularUpdate()
    }

    public func registerFeedback(_ feedback: Bool, for word: String, at date: Date = Date()){
        core.registerFeedback(feedback, for: word, at: date)
        regularUpdate()
    }

    public func regularUpdate(){
        let remaining = core.getRemaining()
        self.all.value = core.getWords()
        self.remaining.value = remaining
        self.total.value = remaining.count
        totalCountStorage.plannedToday = remaining.count
    }

    public func wordForSearch(_ search: String) -> Word?{
        return core.getWordForSearch(search)
    }
}

