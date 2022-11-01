//
//  SubjectViewModel.swift
//  SeSACWeek16
//
//  Created by yongseok lee on 2022/10/25.
//

import Foundation
import RxSwift
import RxCocoa

//associated type == generic
protocol CommonViewModel {
    
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}


struct Contact {
    var name: String
    var age: Int
    var number: String
}

class SubjectViewModel: CommonViewModel {
    
    var contactData = [
    Contact(name: "jack", age: 21, number: "01012341234"),
    Contact(name: "Metavers jack", age: 23, number: "010231234"),
    Contact(name: "Real jack", age: 25, number: "01012341234")
    ]
    
    var list = PublishRelay<[Contact]>()
    
    func fetchData() {
        list.accept(contactData)
    }
    
    func resetData() {
        list.accept([])
    }
    
    var test = "asdf"
    
    func newData() {
        let new = Contact(name: "고래밥", age: Int.random(in: 10...50), number: "")
        contactData.append(new)
        
        list.accept(contactData)
    }
    
    func filterData(query: String) {
//        var temp: [Contact] = []
//        for i in contactData {
//            if i.name.contains(query) {
//                temp.append(i)
//            }
//        }
//        list.onNext(temp)
//        
        let result = query != "" ? contactData.filter{ $0.name.contains(query) } : contactData
        list.accept(result)
        
    }
    
    struct Input {
        let addTap: ControlEvent<Void>
        let resetTap:  ControlEvent<Void>
        let newTap:  ControlEvent<Void>
        let searchText: ControlProperty<String?>
    }
    
    struct Output {
        let addTap: ControlEvent<Void>
        let resetTap:  ControlEvent<Void>
        let newTap:  ControlEvent<Void>
        let list: Driver<[Contact]>
        let searchText: Observable<String>
    }
    
    func transform(input: Input) -> Output {
        
        let list = list.asDriver(onErrorJustReturn: [])
        
        let text = input.searchText
            .orEmpty
            .debounce(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance) //wait
            .distinctUntilChanged() //같은값을 받지 않음
        return Output(addTap: input.addTap, resetTap: input.resetTap, newTap: input.newTap, list: list, searchText: text)
    }
    
}
