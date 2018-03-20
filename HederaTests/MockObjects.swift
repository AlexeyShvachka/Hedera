import CoreData
import ReactiveSwift
@testable import Hedera

class InMemoryCountProvider: PlannedTodayCountStorage{
    var plannedToday: Int = 5
}


func setUpInMemoryStorage() -> Storage {
    let databaseWrapper = CoreDataWrapper(setUpInMemoryManagedObjectContext(),
                                          ImidiateSpaceManager())
    return PersistantStorage(with: databaseWrapper,
                                    countStorage: InMemoryCountProvider())

}

/* Copied from https://www.andrewcbancroft.com/2015/01/13/unit-testing-model-layer-core-data-swift/ */
func setUpInMemoryManagedObjectContext() -> NSManagedObjectContext {
    print("Set Up is called")
    let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main])!

    let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)

    do {
        try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
    } catch {
        print("Adding in-memory persistent store failed")
    }

    let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator

    return managedObjectContext
}


class ImidiateSpaceManager: PhaseManager{
    func get(for word: Word, wasGuessed: Bool) -> (Date, Phase) {
        if wasGuessed {
            return (.tommorow, word.folder.next)
        }
        else {
            return (.tommorow, word.folder)
        }
    }

    let newWordDue = Date() - 1.hours

    let newWordPhase: Phase = .fresh
}


class DummyTranslator: TranslationProvider{
    func getTranslation(ofWord word: String) -> SignalProducer<DataModel, TranslationError> {
        return  SignalProducer<DataModel, TranslationError>.empty
    }
}

class ErrorTranslator: TranslationProvider{
    func getTranslation(ofWord word: String) -> SignalProducer<DataModel, TranslationError> {
        return  SignalProducer<DataModel, TranslationError>(error: TranslationError())
    }
}

class SingleTranslator: TranslationProvider{
    func getTranslation(ofWord word: String) -> SignalProducer<DataModel, TranslationError> {
        let dm = DataModel(head: DataModel.Head(),
                           def: [DataModel.Def(text: "word",
                                               pos: "",
                                               tr: [DataModel.Tr(text: "translation",
                                                                 pos: "",
                                                                 syn: [],
                                                                 mean: [],
                                                                 ex: [])])])
        return  SignalProducer<DataModel, TranslationError>(value: dm)
    }
}

class UnreliableTranslator: TranslationProvider {
    private let trueTranslator = SingleTranslator()
    private let errorTranslator = ErrorTranslator()
    private var numberOfTries = 0
    func getTranslation(ofWord word: String) -> SignalProducer<DataModel, TranslationError> {
        numberOfTries+=1
        if numberOfTries > 5 {
            return trueTranslator.getTranslation(ofWord: word)
        }
        else {
            return errorTranslator.getTranslation(ofWord: word)
        }
    }
}
