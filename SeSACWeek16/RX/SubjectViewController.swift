//
//  SubjectViewController.swift
//  SeSACWeek16
//
//  Created by yongseok lee on 2022/10/25.
//

import UIKit
import RxSwift
import RxCocoa

class SubjectViewController: UIViewController {

   
    @IBOutlet weak var resetButton: UIBarButtonItem!
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newButton: UIBarButtonItem!
    
    
    let disposeBag = DisposeBag()
    let publish = PublishSubject<Int>() //초기값이 없는 빈 상태
    let behavior = BehaviorSubject(value: 100) //초기값 필수
    let replay = ReplaySubject<Int>.create(bufferSize: 3) //bufferSize 작성된 이벤트 갯수만큼 메모리에서 이벤트를 가지고 있다가, 구독할ㄱ때 한번에 이벤트 전달
    let async = AsyncSubject<Int>()
    
    let viewModel = SubjectViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ContactCell")
        
        let input = SubjectViewModel.Input(addTap: addButton.rx.tap, resetTap: resetButton.rx.tap, newTap: newButton.rx.tap, searchText: searchBar.rx.text)
        let output = viewModel.transform(input: input)
        
//        viewModel.list  // VM -> VC (Output)
//            .asDriver(onErrorJustReturn: [])
        
        output.list
            .drive(tableView.rx.items(cellIdentifier: "ContactCell", cellType: UITableViewCell.self)) {(row, element, cell) in
                cell.textLabel?.text = "\(element.name): \(element.age)세 (\(element.number))"
            }
            .disposed(by: disposeBag)
        
        output.addTap
            .withUnretained(self)
            .subscribe { (vc, _) in
                vc.viewModel.fetchData()
            }
            .disposed(by: disposeBag)
        
        resetButton.rx.tap
            .withUnretained(self)
            .subscribe {(vc, _) in
                vc.viewModel.resetData()
            }
            .disposed(by: disposeBag)
        
        newButton.rx.tap // VC -> VM (Input)
            .withUnretained(self)
            .subscribe { (vc, _) in
                vc.viewModel.newData()
            }
            .disposed(by: disposeBag)
        
        output.searchText
            .withUnretained(self)
            .subscribe { (vc, value ) in
                print("=========\(value)======")
                vc.viewModel.filterData(query: value)
            }
            .disposed(by: disposeBag)
        
//        publishSubject()
//        behaviorSubject()
//        replaySubject()
//        asyncSubject()
        
        
    }
    

}

extension SubjectViewController {
    func asyncSubject() {
        async.onNext(100)
        async.onNext(200)
        async.onNext(300)
        async.onNext(400)
        async.onNext(500)
        
        async
            .subscribe { value in
                print("async - \(value)")
            } onError: { error in
                print("async - \(error)")
            } onCompleted: {
                print("async complete")
            } onDisposed: {
                print("async disposed")
            }
            .disposed(by: disposeBag)
        
        async.onNext(3)
        async.onNext(4)
        async.on(.next(5)) //위와 동일
        
        async.onCompleted()
        async.onNext(6)
    }
    
    func replaySubject() {
        replay.onNext(100)
        replay.onNext(200)
        replay.onNext(300)
        replay.onNext(400)
        replay.onNext(500)
        
        replay
            .subscribe { value in
                print("replay - \(value)")
            } onError: { error in
                print("replay - \(error)")
            } onCompleted: {
                print("replay complete")
            } onDisposed: {
                print("replay disposed")
            }
            .disposed(by: disposeBag)
        
        replay.onNext(3)
        replay.onNext(4)
        replay.on(.next(5)) //위와 동일
        
        replay.onCompleted()
        replay.onNext(6)
    }
    
    func behaviorSubject() {
        behavior.onNext(1)
        behavior.onNext(2)
        
        behavior
            .subscribe { value in
                print("behavior - \(value)")
            } onError: { error in
                print("behavior - \(error)")
            } onCompleted: {
                print("behavior complete")
            } onDisposed: {
                print("behavior disposed")
            }
            .disposed(by: disposeBag)
        
        behavior.onNext(3)
        behavior.onNext(4)
        behavior.on(.next(5)) //위와 동일
        
        behavior.onCompleted()
        behavior.onNext(6)
    }
    
    func publishSubject() {
        //초기값이 없는 빈 상태, subscribe 전/error/completed nitification 이후 이벤트 무시
        // subscribe 후에 대한 이벤트느 다 처리
        publish.onNext(1)
        publish.onNext(2)
        
        publish
            .subscribe { value in
                print("publish - \(value)")
            } onError: { error in
                print("publish - \(error)")
            } onCompleted: {
                print("publish complete")
            } onDisposed: {
                print("publish disposed")
            }
            .disposed(by: disposeBag)
        
        publish.onNext(3)
        publish.onNext(4)
        publish.on(.next(5)) //위와 동일
        
        publish.onCompleted()
        publish.onNext(6)

    }
}
