import Foundation
import CoreData
import ReactiveSwift
import Result

protocol PlannedTodayCountStorage {
    var plannedToday: Int {get set}
}

extension UserDefaults: PlannedTodayCountStorage{
    var plannedToday: Int {
        get{
            return UserDefaults.standard.integer(forKey: "TodaysTotal")
        }
        set{
            UserDefaults.standard.set(newValue, forKey: "TodaysTotal")
        }
    }
}

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

typealias  Storage = StorageInput & StorageOutput

class PersistantStorage: Storage{
//    static let shared = PersistantStorage()
    // outputs
    let allWords: Property<[Word]>
    let remainingToday: Property<[Word]>
    let totalCountToday: Property<Int>
    // inner
    private let all: MutableProperty<[Word]>
    private let remaining: MutableProperty<[Word]>
    private let total: MutableProperty<Int>

    private let core : DatabaseWrapper
    private var totalCountStorage: PlannedTodayCountStorage
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
    @discardableResult func addWord(_ word: String, with translations: [String]) -> Word{
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

    func registerTranslation(for userSearch: String, word: String, translations: [String]){
        core.removeWord(userSearch)
        addWord(word, with: translations)
        regularUpdate()
    }

    func registerFeedback(_ feedback: Bool, for word: String, at date: Date = Date()){
        core.registerFeedback(feedback, for: word, at: date)
        regularUpdate()
    }

    func regularUpdate(){
        let remaining = core.getRemaining()
        self.all.value = core.getWords()
        self.remaining.value = remaining
        self.total.value = remaining.count
        totalCountStorage.plannedToday = remaining.count
    }

    func wordForSearch(_ search: String) -> Word?{
        return core.getWordForSearch(search)
    }
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

class CoreDataWrapper: DatabaseWrapper{
    private let context: NSManagedObjectContext
    private let phaseManager: PhaseManager

    func createWordFrom(_ definition: Definition) -> Word {
        let lambda : () -> [String] = {(definition.translations!.allObjects as! [Translation]).map{$0.text!}}
        return Word(definition, context: lambda )
    }

    init(_ context: NSManagedObjectContext,
         _ phaseManager: PhaseManager) {
        self.context = context
        self.phaseManager = phaseManager
    }

    @discardableResult func addWord(_ word: String, with translations: [String]) -> Word {
        let definition = createDefinition(from: word)
        for translation in translations{
            let translationInDatabase = findOrCreateTranslation(from: translation)
            translationInDatabase.addToOrigins(definition)
            definition.addToTranslations(translationInDatabase)
            definition.best = findOrCreateTranslation(from: translations[0])
        }
        try! context.save()
        return createWordFrom(definition)
    }

    func removeWord(_ word: String){
        guard let storedWord = findDefinition(for: word) else {return}
        context.delete(storedWord)
        try! context.save()
    }

    func getTranslations(of word: String) -> [String] {
        let definition = findDefinition(for: word)
        let translations = definition?.translations?.allObjects as! [Translation]
        let s = translations.map{$0.text!}
        return s
    }

    func getWords() -> [Word]{
        let definitionRequest: NSFetchRequest<Definition> = Definition.fetchRequest()
        return try! context.fetch(definitionRequest).map{createWordFrom($0)}
    }

    func getRemaining() -> [Word]{
        let request: NSFetchRequest<Definition> = Definition.fetchRequest()
        let predicate = NSPredicate(format:"%@ >= willShow", NSDate())
        let sortedByGroup = NSSortDescriptor(key: #keyPath(Definition.folder), ascending: true)
        let sortByDate = NSSortDescriptor(key: #keyPath(Definition.willShow), ascending: true)
        request.predicate = predicate
        request.sortDescriptors = [sortedByGroup, sortByDate]
        return try! context.fetch(request).map{createWordFrom($0)}
    }

    func registerFeedback(_ wasGuessed: Bool, for word: String, at time: Date) {
        if let definition = self.findDefinition(for: word),
            definition.lastUpdate! < time {
            definition.lastUpdate = .now
            let (newDueDate, newFolder) = phaseManager.get(for: createWordFrom(definition), wasGuessed: wasGuessed)
            definition.folder = newFolder.rawValue
            definition.willShow = newDueDate
            try! context.save()
        }
    }

    func getWordForSearch(_ search: String) -> Word?{
        if let definition = findDefinition(for: search) {
            return createWordFrom(definition)
        }
        return nil
    }
}


extension CoreDataWrapper{
    private func findDefinition(for word: String) -> Definition? {
        let request : NSFetchRequest<Definition>  = Definition.fetchRequest()
        request.predicate = NSPredicate(format: "text =[cd] %@", word)

        let matches = try! context.fetch(request)
        return matches.first
    }

    private func findOrCreateTranslation(from translation: String) -> Translation {
        let request : NSFetchRequest<Translation>  = Translation.fetchRequest()
        request.predicate = NSPredicate(format: "text =[cd] %@", translation)

        let matches = try! context.fetch(request)
        if let foundTranslation = matches.first {
            return foundTranslation
        }
        else{
            let createdTranslation = Translation(context: context)
            createdTranslation.text = translation
            return createdTranslation
        }
    }

    private func createDefinition(from word: String) -> Definition{
        let defint = Definition(context: context)
        defint.added = .now
        defint.lastUpdate = .now
        defint.willShow = phaseManager.newWordDue
        defint.text = word
        defint.folder = phaseManager.newWordPhase.rawValue
        try! context.save()
        return defint
    }
}

extension Word {
    init(_ definition: Definition, context translationProvider: @escaping ()->[String]){
        self.text = definition.text!
        self.added = definition.added!
        self.willShow = definition.willShow!
        self.folder = Phase(rawValue: definition.folder)!
        self.bestTranslation = definition.best?.text ?? ""
        self.translationsProvider = translationProvider
    }
}

extension Phase{
    var next: Phase{
        switch self {
        case .learned:
            return .learned
        default:
            return Phase(rawValue: self.rawValue + 1)!
        }
    }

    var previous: Phase{
        switch self {
        case .fresh:
            return .fresh
        default:
            return Phase(rawValue: self.rawValue - 1)!
        }
    }
}


