//
//  DifferViewController.swift
//  SeSACWeek16
//
//  Created by yongseok lee on 2022/10/19.
//

import UIKit
import Kingfisher
import RxSwift
import RxCocoa

class DifferViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var viewModel = DiffableViewModel()
    
    var disposeBag = DisposeBag()
    
    //Int: section, String: value
    private var dataSource: UICollectionViewDiffableDataSource<Int, SearchResult>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        collectionView.collectionViewLayout = createLayout()
       configureDataSource()
        collectionView.delegate = self
        
//        searchBar.delegate = self
        bindData()
        
//        viewModel.photoList.bind { photo in
//            //Initial
//            var snapshot = NSDiffableDataSourceSnapshot<Int, SearchResult>()
//            snapshot.appendSections([0])
//            snapshot.appendItems(photo.results)
//            self.dataSource.apply(snapshot)
//        }
    }
    
    func bindData() {
        viewModel.photoList
            .withUnretained(self)
            .subscribe {  (vc,photo) in
                var snapshot = NSDiffableDataSourceSnapshot<Int, SearchResult>()
                snapshot.appendSections([0])
                snapshot.appendItems(photo.results)
                vc.dataSource.apply(snapshot)
            } onError: { error in
                print("=====error: \(error)")
            } onCompleted: {
                print("completed")
            } onDisposed: {
                print("dispose")
            }
            .disposed(by: disposeBag)
        
        searchBar
            .rx
            .text
            .orEmpty
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .withUnretained(self)
            .subscribe { (vc, value) in
                vc.viewModel.requestSearchPhoto(query: value)
            }
            .disposed(by: disposeBag)
        
    }
  
}

extension DifferViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
//        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        
//        let alert = UIAlertController(title: item , message: "click", preferredStyle: .alert)
//        let ok = UIAlertAction(title: "ok", style: .cancel)
//        alert.addAction(ok)
//        present(alert, animated: true)
        
    }
}

//extension DifferViewController: UISearchBarDelegate {
//
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
////        var snapshot = dataSource.snapshot()
////        snapshot.appendItems([searchBar.text!])
////        dataSource.apply(snapshot, animatingDifferences: true)
//        viewModel.requestSearchPhoto(query: searchBar.text!)
//
//    }
//}
  
extension DifferViewController {
    
    private func createLayout() -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        return layout
    }
    
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SearchResult>(handler: { cell, indexPath, itemIdentifier in
            
            var content = UIListContentConfiguration.valueCell()
            content.text = "\(itemIdentifier.likes)"
            //string > URL > Data > image
            DispatchQueue.global().async {
                let url = URL(string: itemIdentifier.urls.thumb)!
                let data = try? Data(contentsOf: url)
                
                DispatchQueue.main.async {
                    content.image = UIImage(data: data!)
                    cell.contentConfiguration = content
                }
                
            }
            
            
            var background = UIBackgroundConfiguration.listPlainCell()
            background.strokeWidth = 2
            background.strokeColor = .brown
            cell.backgroundConfiguration = background
        })
        
        //collectionView.dataSource = self
        //numberOfItemsInSection, cellForItemAt
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
            return cell
            
        })
        
    }
}
