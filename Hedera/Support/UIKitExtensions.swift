import Foundation
import UIKit

extension UIView{
    func addSubviews(_ views: UIView...){
        for view in views {
            self.addSubview(view)
        }
    }
}
