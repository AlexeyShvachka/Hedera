import Foundation
import UIKit

extension UIView{
    func addSubviews(_ views: UIView...){
        for view in views {
            self.addSubview(view)
        }
    }
}

extension Array {
    func isValid(index: Int) -> Bool{
        return index > 0 && index < self.count
    }
}

extension Array where Element: Equatable {
    mutating func remove(element: Element) {
        if let index = self.index(of: element){
            self.remove(at: index)
        }
    }
}

extension Optional where Wrapped: StringProtocol {
    public var isNilOrEmpty : Bool {
        get{
            switch self {
            case .some(let value):
                return value.isEmpty
            default:
                return true
            }
        }
    }
}

/*operator to simplify debug printning, by writing
    foo(~|~bar(4,"z")
 instead of
    let result = bar(4,"z")
    print(result)
    foo(result)
*/
prefix operator ~|~

prefix func ~|~<T>(value:T) -> T {
    print(value)
    return value
}
