import ReactiveSwift
import ReactiveCocoa
import Result

extension PropertyProtocol where Value : RandomAccessCollection {
    var first : Property<Value.Element?> {
        get{
            return self.map{ $0.first}
        }
    }
}

extension SignalProducer {
    func debug(_ debugFunction: () -> Void) -> SignalProducer<Value, Error>{
        debugFunction()
        return self
    }
}

extension Reactive where Base: FilledView {
    internal var color: BindingTarget<UIColor> {
        return makeBindingTarget{$0.color = $1}
    }
}

extension Reactive where Base: NotificationCenter {
    /// Create a `Signal` that notifies whenever the system keyboard announces an
    /// upcoming change in its frame.
    ///
    /// - returns: A `Signal` that emits the context of every change in the
    ///            system keyboard's frame.
    public var keyboardWillShow: Signal<(), NoError> {
        return notifications(forName: NSNotification.Name.UIKeyboardWillShow)
            .map { notification in ()}
    }
}

infix operator <~> : BindingPrecedence

public func <~> (property: MutableProperty<String>, textField: UITextField) {
    textField.reactive.text <~ property
    property <~ textField.reactive.continuousTextValues.map { $0 ?? "" }
}

public func <~> (textField: UITextField, property: MutableProperty<String>) {
    textField.reactive.text <~ property
    property <~ textField.reactive.continuousTextValues.map { $0 ?? "" }
}
