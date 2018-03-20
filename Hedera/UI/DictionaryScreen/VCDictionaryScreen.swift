import UIKit
import SnapKit
import ReactiveSwift
import ReactiveCocoa

class DictionaryViewController: UIViewController, UICollectionViewDelegateFlowLayout  {

    public var viewModel : VMDictionaryScreen! {
        didSet {
            setDataBindings()
        }
    }

    var collectionView : DictionaryCollectionView!
    var searchBar = DictionarySearch()
    private let layout = DictionaryCollectionLayout()
    var searchContainer: TopShadowContainer!

    override func viewDidLoad() {
        super.viewDidLoad()
        searchContainer = TopShadowContainer(searchBar)

        self.view.backgroundColor = #colorLiteral(red: 0.9921568627, green: 0.9921568627, blue: 0.9921568627, alpha: 1)

        collectionView = DictionaryCollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self

        self.view.addSubviews(collectionView, searchContainer)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setKeyboardUp),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(dismissKeyboard),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)

        searchContainer.snp.makeConstraints{ make in
            make.bottom.left.right.equalTo(self.view.safeAreaLayoutGuide)
            make.height.equalTo(70)
        }

        collectionView.snp.makeConstraints{ make in
            make.left.right.top.equalTo(self.view.safeAreaLayoutGuide)
            make.bottom.equalTo(searchContainer.snp.top)
        }
        setDataBindings()
    }

    @objc func setKeyboardUp(notification: Notification){
        let info = notification.userInfo!
        let keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue

        searchContainer.snp.remakeConstraints{ make in
            make.bottom.equalToSuperview().inset(keyboardFrame.height)
            make.left.right.equalTo(self.view.safeAreaLayoutGuide)
            make.height.equalTo(70)
        }
    }

    @objc func dismissKeyboard(){
        searchContainer.snp.remakeConstraints{ make in
            make.bottom.left.right.equalTo(self.view.safeAreaLayoutGuide)
            make.height.equalTo(70)
        }
    }

    private func setDataBindings() {
        viewModel.searchString <~ searchBar.reactive.continuousTextValues.skipNil()
        collectionView.reactive.reloadData <~ viewModel.enteties.map{_ in return ()}
    }
}

extension DictionaryViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        searchContainer.resignFirstResponder()
        layout.expandCell(at: indexPath.item)
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        searchContainer.resignFirstResponder()
        layout.colapseCell(at: indexPath.item)
    }
}

extension DictionaryViewController : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  viewModel.enteties.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! DictionaryCellView
        cell.configure(viewModel.enteties.value[indexPath.item])
        return cell
    }
}
