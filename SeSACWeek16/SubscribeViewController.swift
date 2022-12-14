//
//  SubscribeViewController.swift
//  SeSACWeek16
//
//  Created by yongseok lee on 2022/10/26.
//

import UIKit
import RxSwift
import RxCocoa
import RxAlamofire
import RxDataSources

class SubscribeViewController: UIViewController {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    let disposeBag = DisposeBag()
    
    //lazy var?
    lazy var dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Int>>(configureCell: { dataSource, tableView, indexPath, item in
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        cell.textLabel?.text = "\(item)"
        return cell
    })
    
    func testRxDataSource() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        dataSource.titleForHeaderInSection = { dataSource, index in
            return dataSource.sectionModels[index].model
        }
        
        Observable.just([
            SectionModel(model: "title", items: [1, 2, 3]),
            SectionModel(model: "title", items: [1, 2, 3]),
            SectionModel(model: "title", items: [1, 2, 3])
        ])
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
       
    }
    
    func testRxAlamofire() {
        let url = APIKey.searchURL + "apple"
        request(.get, url, headers: ["Authorization": APIKey.authorization])
            .debug()
            .data()
            .decode(type: SearchPhoto.self, decoder: JSONDecoder())
            .subscribe { value in
              print(value)
            }
            .disposed(by: disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        testRxAlamofire()
        testRxDataSource()
        
        Observable.of(1,2,3,4,5,6,7,8,9,10)
            .skip(3)
//            .debug()
            .filter { $0 % 2 == 0 }
            .debug()
            .map { $0 * 2 }
            .subscribe { value in
//                print("=======\(value)")
            }
            .disposed(by: disposeBag)
        
        

        //??? > ?????????: "?????? ?????????"
        //1
        let sample = button.rx.tap
     
        sample
            .subscribe { [weak self] _ in
                self?.label.text = "?????? ?????????"
            }
            .disposed(by: disposeBag)
        //2
        button.rx.tap
            .withUnretained(self)
            .subscribe { (vc, _) in
//                DispatchQueue.main.
                vc.label.text = "?????? ?????????"
            }
            .disposed(by: disposeBag)
        //3 ???????????? ???????????? ?????? ???????????? ??? ??????????????? ???????
        button.rx.tap
            .observe(on: MainScheduler.instance) // ?????? ???????????? ???????????? ??????
            .withUnretained(self)
            .subscribe { (vc, _) in
                vc.label.text = "?????? ?????????"
            }
            .disposed(by: disposeBag)
        
        //4 bind: subscribe, mainSchedular, error X
        button.rx.tap
            .withUnretained(self)
            .bind { (vc, _) in
                vc.label.text = "?????? ?????????"
            }
            .disposed(by: disposeBag)
        
        //5 operator??? ???????????? stream ??????
        button
            .rx
            .tap
            .map { "?????? ?????????"}
            .debug() //print
            .bind(to: label.rx.text)
            .disposed(by: disposeBag)
        
        //6 driver traits: bind + stream ??????(????????? ?????? ??????, share() )
        button.rx.tap
            .map { "?????? ?????????"}
            .asDriver(onErrorJustReturn: "")
            .drive(label.rx.text)
            .disposed(by: disposeBag)
        
    }
    


}
