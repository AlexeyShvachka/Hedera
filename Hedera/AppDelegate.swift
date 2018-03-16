import UIKit
import CoreData
import ReactiveSwift
import SnapKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var coordinator: ViewControllerCoordinator!
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        coordinator = ViewControllerCoordinator()
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.rootViewController = coordinator.tabViewController
        window!.makeKeyAndVisible()
        return true
    }

    var window: UIWindow?
}

class ModelCoordinator{
    public let translator: TranslationProvider
    public let wrapper: DatabaseWrapper
    public let dictionary: Storage
    public let phaseManager: PhaseManager
    private let persistentContainer: NSPersistentContainer
    public let translationChecker: TranslationChecker
    init() {
        translator = Translator()
        phaseManager = SpacedRepetition()
        persistentContainer = NSPersistentContainer(name: "ModelForTranslations")
        persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        wrapper = CoreDataWrapper(persistentContainer.viewContext, phaseManager)
        dictionary = PersistantStorage(with: wrapper, countStorage: UserDefaults.standard)
        translationChecker = TranslationChecker(translator, dictionary, 2.seconds, persistentContainer.viewContext)
        
    }
}

class ViewModelCoordinator{
    let practiceViewModel: VMCardShowingScreen
    let addWordViewModel: ViewModel
    let dictionaryViewModel: VMDictionaryScreen
    init() {
        let model = ModelCoordinator()
        practiceViewModel = VMCardShowingScreen(database: model.dictionary)
        addWordViewModel = ViewModel(translator: model.translator,
                                     database: model.dictionary,
                                     checker: model.translationChecker)
        dictionaryViewModel = VMDictionaryScreen(storage: model.dictionary,
                                                 checker: model.translationChecker)
    }
}

class ViewControllerCoordinator{
    let practiceScreen: CardShowingViewController
    let wordAddScreen: ViewController
    let dictionaryScreen: DictionaryViewController
    public let tabViewController: UITabBarController
    private let tabBarimageInsets = UIEdgeInsetsMake(2, 2, 2, 2)
    let selectedTextColor = #colorLiteral(red: 0.5529411765, green: 0.9568627451, blue: 0.7411764706, alpha: 1)

    init(){
        let viewModel = ViewModelCoordinator()
        practiceScreen = CardShowingViewController()
        practiceScreen.vm = viewModel.practiceViewModel
        practiceScreen.tabBarItem = UITabBarItem(title: "practice", image: #imageLiteral(resourceName: "practiceInactive"), selectedImage: #imageLiteral(resourceName: "practiceActive"))
        practiceScreen.tabBarItem.imageInsets = tabBarimageInsets
        practiceScreen.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: selectedTextColor], for: .selected)

        wordAddScreen = ViewController()
        wordAddScreen.viewModel = viewModel.addWordViewModel
        wordAddScreen.tabBarItem = UITabBarItem(title: "add", image: #imageLiteral(resourceName: "addingInactive"), selectedImage: #imageLiteral(resourceName: "addingActive"))
        wordAddScreen.tabBarItem.imageInsets = tabBarimageInsets
        wordAddScreen.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: selectedTextColor], for: .selected)

        dictionaryScreen = DictionaryViewController()
        dictionaryScreen.viewModel = viewModel.dictionaryViewModel
        dictionaryScreen.tabBarItem = UITabBarItem(title: "dictionary", image: #imageLiteral(resourceName: "dictionaryInactive"), selectedImage: #imageLiteral(resourceName: "dictionaryActive"))
        dictionaryScreen.tabBarItem.imageInsets = tabBarimageInsets
        dictionaryScreen.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: selectedTextColor], for: .selected)

        tabViewController = UITabBarController()
        tabViewController.viewControllers = [practiceScreen, wordAddScreen, dictionaryScreen]
        tabViewController.selectedIndex = 0
    }
}
