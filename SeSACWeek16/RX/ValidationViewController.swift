//
//  ValidationViewController.swift
//  SeSACWeek16
//
//  Created by yongseok lee on 2022/10/27.
//

import UIKit
import RxSwift
import RxCocoa

class ValidationViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var validationLabel: UILabel!
    @IBOutlet weak var stepButton: UIButton!
    
    let disposeBag = DisposeBag()
    let viewModel = validationViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()

    }
    
    func bind() {
        
        //인풋 아웃풋 나눠서 뷰모델에서 계산하는 코드
        let input = validationViewModel.Input(text: nameTextField.rx.text, tap: stepButton.rx.tap)
        let output = viewModel.transform(input: input)
        
        output.text
            .drive(validationLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.validation
            .bind(to: stepButton.rx.isEnabled, validationLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
    
        //기존 코드
        
        viewModel.validText //Output
            .asDriver()
            .drive(validationLabel.rx.text)
            .disposed(by: disposeBag)
        
        let validation = nameTextField.rx.text //Input
            .orEmpty
            .map { $0.count >= 8 }
            .share()

        output.validation
            .bind(to: stepButton.rx.isEnabled, validationLabel.rx.isHidden)
            .disposed(by: disposeBag)

        output.validation
            .withUnretained(self)
            .bind { (vc, value) in
                let color: UIColor = value ? .systemPink : .lightGray
                vc.stepButton.backgroundColor = color
            }
            .disposed(by: disposeBag)
        
        let testA = stepButton.rx.tap
            .map { "안녕하세요" }
            .asDriver(onErrorJustReturn: "")
        
        testA
            .drive( validationLabel.rx.text)
            .disposed(by: disposeBag)
        //dispose 리소스 정리, deinit, rx생명주기 끝날때
        
        testA
            .drive(nameTextField.rx.text)
            .disposed(by: disposeBag)
        
        testA
            .drive(stepButton.rx.title())
            .disposed(by: disposeBag)

    }

    func observableVSSubject() {
        
        
        let sampleInt = Observable<Int>.create { observer in
            observer.onNext(Int.random(in: 1...100))
            return Disposables.create()
        }
        
        sampleInt.subscribe { value in
            print("sampleInt: \(value)")
        }
        .disposed(by: disposeBag)
        
        let subjectInt = BehaviorSubject<Int>.create { observer in
            observer.onNext(Int.random(in: 1...100))
            return Disposables.create()
        }
    }
}
