//
//  ValidationViewModel.swift
//  SeSACWeek16
//
//  Created by yongseok lee on 2022/11/01.
//

import Foundation
import RxSwift
import RxCocoa



class validationViewModel {
    
    let validText = BehaviorRelay(value: "닉네임은 최소 8자 이상 필요해요")
    
    struct Input {
        let text: ControlProperty<String?> //nameTextField.rx.text
        let tap: ControlEvent<Void> //stepButton.rx.tap
    }
    
    struct Output {
        let validation: Observable<Bool>
        let tap: ControlEvent<Void>
        let text: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        let valid = input.text
            .orEmpty
            .map { $0.count >= 8 }
            .share()
        
        let text = validText.asDriver()
        
        return Output(validation: valid, tap: input.tap, text: text)
    }
}
