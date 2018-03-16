import UIKit
import SnapKit
import ReactiveSwift
import ReactiveCocoa

class DictionaryViewController: UIViewController, UICollectionViewDelegateFlowLayout  {

    public var viewModel : VMDictionaryScreen!
    var collectionView : DictionaryCollectionView!
    var searchBar = DictionarySearch()
    private let layout = DictionaryCollectionLayout()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.searchString <~ searchBar.reactive.continuousTextValues.skipNil()

        collectionView.reactive.reloadData <~ viewModel.enteties.map{_ in return ()}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let header = Header("Dictionary")

        let containerView = TopPart(label: header, search: searchBar )

        self.view.backgroundColor = #colorLiteral(red: 0.9921568627, green: 0.9921568627, blue: 0.9921568627, alpha: 1)

        collectionView = DictionaryCollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self

        self.view.addSubview(collectionView)
        self.view.addSubview(containerView)
        containerView.snp.makeConstraints{ make in
            make.top.left.right.equalTo(self.view.safeAreaLayoutGuide)
            make.height.equalTo(120)
        }

        collectionView.snp.makeConstraints{ make in
            make.left.right.bottom.equalTo(self.view.safeAreaLayoutGuide)
            make.top.equalTo(containerView.snp.bottom)
        }
    }
}

extension DictionaryViewController: UICollectionViewDelegate{

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        layout.expandCell(at: indexPath.item)

    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
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
