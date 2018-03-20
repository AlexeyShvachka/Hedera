import Foundation
import CoreData
import ReactiveSwift
import Result

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

class CoreDataWrapper{
    private let context: NSManagedObjectContext
    private let phaseManager: PhaseManager

    init(_ context: NSManagedObjectContext,
         _ phaseManager: PhaseManager) {
        self.context = context
        self.phaseManager = phaseManager
    }
}

extension CoreDataWrapper: DatabaseWrapperInput{
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

    func removeWord(_ word: String){
        guard let storedWord = findDefinition(for: word) else {return}
        context.delete(storedWord)
        try! context.save()
    }
}

extension CoreDataWrapper: DatabaseWrapperOutput{
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

    func getWordForSearch(_ search: String) -> Word?{
        if let definition = findDefinition(for: search) {
            return createWordFrom(definition)
        }
        return nil
    }
}

extension CoreDataWrapper{
    private func createWordFrom(_ definition: Definition) -> Word {
        let lambda : () -> [String] = {(definition.translations!.allObjects as! [Translation]).map{$0.text!}}
        return Word(definition, context: lambda )
    }

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


