import UIKit
import SnapKit
import ReactiveCocoa
import ReactiveSwift

class CardShowingViewController: UIViewController {

    public var vm: VMCardShowingScreen!

    private let header = Header("Practice")
    private let wordContainer = WordContainer()
    private let translationContainer = TranslationContainer()

    private let curtainButton = ShowTranslationButton()
    private let noGuessButton = RoundButton()
    private let guessButton = RoundButton()

    private let doneMessage = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubviews(header,
                              wordContainer,
                              curtainButton,
                              translationContainer,
                              guessButton,
                              noGuessButton,
                              doneMessage)
        setUpInitialConstraints()
        
        view.backgroundColor = #colorLiteral(red: 0.9921568627, green: 0.9921568627, blue: 0.9921568627, alpha: 1)

        doneMessage.text = "No words left for today"
        doneMessage.textAlignment = .center
        doneMessage.textColor = #colorLiteral(red: 0.7411764706, green: 0.7411764706, blue: 0.7411764706, alpha: 1)
        doneMessage.font = UIFont.preferredFont(forTextStyle: .callout)

        noGuessButton.backgroundColor = #colorLiteral(red: 0, green: 0.7882352941, blue: 0.8392156863, alpha: 1)
        noGuessButton.setTitle("Not guessed", for: .normal)

        guessButton.backgroundColor = #colorLiteral(red: 0, green: 0.8980392157, blue: 0.6039215686, alpha: 1)
        guessButton.setTitle("Guessed", for: .normal)

        wordContainer.word <~ vm.currentWord
        translationContainer.textView.reactive.text <~ vm.currentWord.map{$0?.allTranslations.joined(separator: "\n") ?? ""}

        curtainButton.addTarget(self, action: #selector(showTranslation), for: .primaryActionTriggered)

        guessButton.addTarget(self, action: #selector(hideTranslation), for: .primaryActionTriggered)
        guessButton.addTarget(vm, action: #selector(vm.wordWasGuessed), for: .primaryActionTriggered)

        noGuessButton.addTarget(self, action: #selector(hideTranslation), for: .primaryActionTriggered)
        noGuessButton.addTarget(vm, action: #selector(vm.wordWasNotGuessed), for: .primaryActionTriggered)

        vm.currentWord.signal.observeValues{[weak self] wrapedWord in
            switch wrapedWord {
            case .some(_) :
                self?.showNormalState()
            case .none:
                self?.showEmptyState()
            }
        }

        if vm.currentWord.value == .none {
            showEmptyState()
        }
        else {
            showNormalState()
        }


    }

    private func showNormalState(){
        wordContainer.isHidden = false
        translationContainer.isHidden = false
        guessButton.isHidden = false
        noGuessButton.isHidden = false
        curtainButton.isHidden = false
        doneMessage.isHidden = true
    }
    private func showEmptyState(){
        wordContainer.isHidden = true
        translationContainer.isHidden = true
        guessButton.isHidden = true
        noGuessButton.isHidden = true
        curtainButton.isHidden = true
        doneMessage.isHidden = false
    }
}

extension CardShowingViewController{
    @objc func showTranslation() {
        self.translationContainer.snp.remakeConstraints{ make in
            make.height.equalTo(self.view.safeAreaLayoutGuide).dividedBy(4)
            make.left.right.equalTo(self.view.safeAreaLayoutGuide).inset(20)
            make.top.equalTo(self.wordContainer.snp.bottom).inset(15)
        }
        curtainButton.isHidden = true
    }

    @objc func hideTranslation(){
        translationContainer.snp.remakeConstraints{ make in
            make.height.equalTo(self.view.safeAreaLayoutGuide).dividedBy(4)
            make.left.right.equalTo(self.view.safeAreaLayoutGuide).inset(20)
            make.top.equalTo(self.wordContainer)
        }

        curtainButton.isHidden = false
        self.view.bringSubview(toFront: curtainButton)
        self.view.bringSubview(toFront: wordContainer)
    }
    
    private func setUpInitialConstraints(){
        header.snp.makeConstraints{ make in
            make.left.equalTo(view.safeAreaLayoutGuide).inset(15)
            make.top.right.equalTo(view.safeAreaLayoutGuide)
            make.height.equalToSuperview().dividedBy(10)
        }
        doneMessage.snp.makeConstraints{ make in
            make.left.right.centerY.equalToSuperview()
            make.height.equalToSuperview().dividedBy(10)
        }
        wordContainer.snp.makeConstraints{ make in
            make.height.equalTo(self.view.safeAreaLayoutGuide).dividedBy(4)
            make.top.equalTo(header.snp.bottom)
            make.left.right.equalTo(self.view.safeAreaLayoutGuide).inset(10)
        }

        curtainButton.snp.makeConstraints{ make in
            make.left.right.equalTo(self.view.safeAreaLayoutGuide).inset(10)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(self.view).dividedBy(10)
        }

        guessButton.snp.makeConstraints{ make in
            make.right.equalTo(self.view.safeAreaLayoutGuide).inset(15)
            make.width.equalTo(self.view.safeAreaLayoutGuide).dividedBy(2.3)
            make.height.equalTo(self.view.safeAreaLayoutGuide).dividedBy(10)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(20)
        }

        noGuessButton.snp.makeConstraints{ make in
            make.left.equalTo(self.view.safeAreaLayoutGuide).inset(15)
            make.width.equalTo(self.view.safeAreaLayoutGuide).dividedBy(2.3)
            make.height.equalTo(self.view.safeAreaLayoutGuide).dividedBy(10)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(20)
        }

        hideTranslation()
    }

}
