import UIKit
import SnapKit
import ReactiveCocoa
import ReactiveSwift
import Result

class ViewController: UIViewController {
    let inputField = UserInput()
    public var viewModel: ViewModel!
    let header = Header("Word add")
    let resultView = RequestResultContainer()
    let addToDatabaseButton = AddToDatabaseButton()

}

extension ViewController{
    @objc func save(){
        viewModel.saveCurrent()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.9921568627, green: 0.9921568627, blue: 0.9921568627, alpha: 1)

        self.view.addSubviews(header,
                              inputField,
                              resultView,
                              addToDatabaseButton)
        let gestureRecognizer = UITapGestureRecognizer(target: inputField, action: #selector(inputField.resignFirstResponder))
        resultView.addGestureRecognizer(gestureRecognizer)

      //  inputField.addTarget(inputField, action: #selector(inputField.becomeFirstResponder), for: .allTouchEvents)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setKeyboardUp),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(dismissKeyboard),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
        addToDatabaseButton.addTarget(self,
                                      action: #selector(save),
                                      for: .primaryActionTriggered)

        addToDatabaseButton.addTarget(inputField,
                                      action: #selector(inputField.resignFirstResponder),
                                      for: .primaryActionTriggered)

        addToDatabaseButton.reactive.isHidden <~ viewModel.stateToObserve.map{ state in
            switch state{
            case .empty:
                return true
            default:
                return false
            }
        }

        addToDatabaseButton.reactive.isEnabled <~ viewModel.stateToObserve.map{ state in
            switch state{
            case  .added(_), .alreadyInDatabase(_), .addedForLater(_):
                return false
            default:
                return true
            }
        }
        resultView.reactive.isHidden <~ viewModel.stateToObserve.map{ state in
            switch state{
            case .empty:
                return true
            default:
                return false
            }
        }

        header.snp.remakeConstraints{ make in
            make.top.equalTo(safeArea).inset(10)
            make.left.equalTo(safeArea).inset(15)
            make.right.equalTo(safeArea).inset(15)
            make.height.equalTo(safeArea).dividedBy(9)
        }

        inputField.delegate = self
        inputField <~> viewModel.userSearch
        viewModel.stateToObserve.signal.observe(on: UIScheduler()).observeValues{[weak self] state in
            self?.show(state)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setEmpty()
    }
}


extension ViewController {

    var safeArea: UILayoutGuide {
        get {
            return self.view.safeAreaLayoutGuide
        }
    }

    @objc func setKeyboardUp(notification: Notification){
        let info = notification.userInfo!
        let keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue

        inputField.snp.remakeConstraints{ make in
            make.top.equalTo(header.snp.bottom)
            make.left.equalTo(safeArea).inset(10)
            make.right.equalTo(safeArea).inset(10)
            make.height.equalTo(safeArea).dividedBy(15)
        }
        resultView.snp.remakeConstraints{ make in
            make.top.equalTo(inputField.snp.bottom).offset(10)
            make.left.right.equalTo(safeArea).inset(30)
            make.bottom.equalToSuperview().offset(-(keyboardFrame.height + 10))
        }

        self.view.bringSubview(toFront: addToDatabaseButton)
        addToDatabaseButton.snp.remakeConstraints{ make in
            make.bottom.equalTo(resultView).offset(-20)
            make.right.equalTo(safeArea).inset(20)
            make.width.equalTo(100)
            make.height.equalTo(150)
        }
    }

    @objc func dismissKeyboard(){

        if resultView.isHidden {
            inputField.snp.remakeConstraints{ make in
                make.centerY.equalTo(safeArea)
                make.left.equalTo(safeArea).inset(10)
                make.right.equalTo(safeArea).inset(10)
                make.height.equalTo(safeArea).dividedBy(12)
            }
        } else {
            addToDatabaseButton.snp.remakeConstraints{ make in
                make.bottom.equalTo(safeArea).offset(-20)
                make.left.right.equalTo(safeArea).inset(20)
                make.height.equalTo(safeArea).dividedBy(10)
            }

        }
        resultView.snp.remakeConstraints{ make in
            make.top.equalTo(inputField.snp.bottom).offset(10)
            make.left.right.equalTo(safeArea).inset(30)
            make.bottom.equalTo(addToDatabaseButton.snp.top).offset(-10)
        }
    }

    func setEmpty(){
        addToDatabaseButton.isHidden = true
        resultView.isHidden = true
        inputField.snp.remakeConstraints{ make in
            make.centerY.equalTo(safeArea)
            make.left.equalTo(safeArea).inset(10)
            make.right.equalTo(safeArea).inset(10)
            make.height.equalTo(safeArea).dividedBy(11)
        }
    }

    func setConstraints(){
        let vStack = UIStackView()

        addToDatabaseButton.addTarget(self, action: #selector(save), for: .primaryActionTriggered)



        resultView.snp.makeConstraints{make in
            make.left.right.equalTo(vStack)
        }
        inputField.snp.makeConstraints{ make in
            make.left.equalTo(vStack).offset(10)
            make.right.equalTo(vStack).offset(-10)
            make.height.equalTo(vStack).dividedBy(10)
        }

        addToDatabaseButton.snp.makeConstraints{ make in
            make.left.equalTo(vStack).offset(10)
            make.right.equalTo(vStack).offset(-10)
            make.height.equalTo(vStack).dividedBy(10)

        }

        self.view.addSubview(vStack)
        vStack.snp.makeConstraints{ make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)//.inset(UIEdgeInsetsMake(50, 0, 0, 0))
        }

    }
}

extension ViewController:  UITextFieldDelegate  {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        return string != " "
    }
}


fileprivate extension ViewController {
    func show(_ state: StateToShow){
        print(state)
        resultView.show(state)
    }
}



