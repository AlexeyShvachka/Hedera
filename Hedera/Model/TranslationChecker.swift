import Foundation
import CoreData
import ReactiveSwift
import Result

protocol Checker {
    func add(_ userSearch: String)
    var words: Property<[String]> {get}
}

class TranslationChecker: Checker{
    private let translator: TranslationProvider
    private let database: StorageInput
    private let context: NSManagedObjectContext
    public  let words: Property<[String]>
    private let innerWords: MutableProperty<[String]>

    init(_ translator: TranslationProvider,
         _ database: StorageInput,
         _ interval: TimeInterval,
         _ context: NSManagedObjectContext){
        self.translator = translator
        self.database = database
        self.context = context

        let request: NSFetchRequest<Waiting> = Waiting.fetchRequest()
        let waiting = try! context.fetch(request)
        innerWords = MutableProperty(waiting.map{$0.text!})

        words = Property(innerWords)
        fetchTranslations()
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true){ [weak self] _ in
            self?.fetchTranslations()
        }
    }

    public func add(_ userSearch: String) {
        Waiting(context: context).text = userSearch
        try! context.save()
        innerWords.value = pending
        self.fetchTranslations()
    }

    private var pending: [String] {
        get {
            let request: NSFetchRequest<Waiting> = Waiting.fetchRequest()
            let waiting = try! context.fetch(request)
            return waiting.map{$0.text!}
        }
    }

    private func registerTranslations(_ translations: DataModel, for userSearch: String) {
        if translations.definition.isNilOrEmpty {
            self.database.addWord(userSearch, with: [])
        }
        else {
            self.database.addWord(translations.definition!,
                             with: translations.translations ?? [])
        }
        removeFromPending(userSearch)
    }

    private func removeFromPending(_ userSearch: String){
        let request : NSFetchRequest<Waiting>  = Waiting.fetchRequest()
        request.predicate = NSPredicate(format: "text = %@", userSearch)

        let matches = try! context.fetch(request)
        if matches.first != nil{
            context.delete(matches.first!)
            try! context.save()
        }
        innerWords.value = pending
    }

    private func fetchTranslations(){
        for userSearch in pending {
            let translationGenerator = translator.getTranslation(ofWord: userSearch)
            let observer = Signal<DataModel, TranslationError>.Observer(
                value: { [weak self] translation in
                    self?.registerTranslations(translation, for: userSearch)
                })
            translationGenerator.start(observer)
        }
    }
}
