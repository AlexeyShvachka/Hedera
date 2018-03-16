//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport



class MyViewController : UIViewController {
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        let label = FilledView()
        label.backgroundColor = UIColor.gray
        label.frame = CGRect(x: 150, y: 200, width: 120, height: 50)
        label.text = "100%"
        label.textColor = .black
        
        view.addSubview(label)
        self.view = view
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
