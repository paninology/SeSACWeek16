//
//  RXCocoaExampleViewController.swift
//  SeSACWeek16
//
//  Created by yongseok lee on 2022/10/24.
//

import UIKit
import RxCocoa
import RxSwift

class RXCocoaExampleViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var simpleLabel: UILabel!
    @IBOutlet weak var simpleSwtich: UISwitch!
    @IBOutlet weak var signName: UITextField!
    @IBOutlet weak var signEmail: UITextField!
    @IBOutlet weak var signButton: UIButton!
    @IBOutlet weak var nickNameLabel: UILabel!
    
    
    var disposeBag = DisposeBag()
    
    var nickName = Observable.just("jack")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nickName
            .bind(to: nickNameLabel.rx.text)
            .disposed(by: disposeBag)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            self.nickName = "Hello"
        }
        
        
        setTableView()
        setPickerView()
       setSwitch()
        setSign()
        setOperator()
    }
    
    deinit {
        print("RxCocoaExampleViewConntroller deinited")
    }
    
    func setSign() {
        //ex. 택1(Observable), 택2(Observable) > 레이블(Observer, bind)
        Observable.combineLatest(signName.rx.text.orEmpty, signEmail.rx.text.orEmpty) { value1, value2 in
            return "name은 \(value1)이고, 이메일은 \(value2)입니다."
        }
        .bind(to: simpleLabel.rx.text)
        .disposed(by: disposeBag)
        
        signName //UITextField
            .rx //Reactive
            .text //String?
            .orEmpty //String
            .map { $0.count } //Int
            .map { $0 < 4 } //bool
            .bind(to: signEmail.rx.isHidden)
            .disposed(by: disposeBag)
    
        signEmail.rx.text.orEmpty
            .map { $0.count > 4 }
            .bind(to: signButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        signButton.rx.tap
//            .withUnretained(self)  >> weak self 대신
            .subscribe { [weak self] _ in
                self?.showAlert()
            }
            .disposed(by: disposeBag)
    }
    
    func setOperator() {
        
//        Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
//            .subscribe { value in
//                print("Interval - \(value)")
//            } onError: { error in
//                print("Interval - \(error)")
//            } onCompleted: {
//                print("Interval completed")
//            } onDisposed: {
//                print("Interval disposed")
//            }
//            .disposed(by: disposeBag)
        
        //disposeBag: 리소스 해제 관리 -
            //1. 시퀀스 끝날 때 but bind
            //2. class deinit 자동 해제 (bind)
            //3. dispose 직접 호출
            //4. DisposeBag을 새롭게 할당하거나, nil 전달. >예외케이스 (디이닛이 안되는 루트뷰에 interval같은 무한호출)
        //dispose() 는 구독하는것 마다 별도로 관리
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5 ) {
//            self.disposeBag = DisposeBag() //한번에 리소스 정리
//        }
        
        let itemsA = [3.3, 4.0, 5.5, 6.6, 2.0]
        let itemsB = [2.3, 2.0, 1.4]
        
        Observable.repeatElement("jack")  //Infinite Observable Sequence
            .take(5) //Finite Observable Sequence
            .subscribe { value in
                print("repeat - \(value)")
            } onError: { error in
                print("repeat - \(error)")
            } onCompleted: {
                print("repeat completed")
            } onDisposed: {
                print("repeat disposed")
            }
            .disposed(by: disposeBag)
        
        Observable.just(itemsA)
            .subscribe { value in
                print("just - \(value)")
            } onError: { error in
                print("just - \(error)")
            } onCompleted: {
                print("just completed")
            } onDisposed: {
                print("just disposed")
            }
            .disposed(by: disposeBag)
        
        Observable.of(itemsA, itemsB)
            .subscribe { value in
                print("of - \(value)")
            } onError: { error in
                print("of - \(error)")
            } onCompleted: {
                print("of completed")
            } onDisposed: {
                print("of disposed")
            }
            .disposed(by: disposeBag)
        
        Observable.from(itemsA)
            .subscribe { value in
                print("From - \(value)")
            } onError: { error in
                print("From - \(error)")
            } onCompleted: {
                print("From completed")
            } onDisposed: {
                print("From disposed")
            }
            .disposed(by: disposeBag)
            
    }
    
    func showAlert() {
        let alert = UIAlertController( title: "ggg", message: nil, preferredStyle: .alert)
        let ok = UIAlertAction(title: "ok", style: .cancel)
        alert.addAction(ok)
        present(alert, animated:  true)
    }
    
    func setSwitch() {
        
        Observable.of(false) //just?? of??
            .bind(to: simpleSwtich.rx.isOn)
            .disposed(by: disposeBag)
        
    }

    func setTableView() {
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        let items = Observable.just([
            "First Item",
            "Second Item",
            "Third Item"
        ])

        items
        .bind(to: tableView.rx.items) { (tableView, row, element) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
            cell.textLabel?.text = "\(element) @ row \(row)"
            return cell
        }
        .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(String.self)
            .map({ data in
                "\(data)를 클릭했습니다."
            })
            .bind(to: simpleLabel.rx.text)
            .disposed(by: disposeBag)


    }
    
    func setPickerView() {
        
        let items = Observable.just([
                "영화",
                "애니",
                "드라마"
            ])
     
        items
            .bind(to: pickerView.rx.itemTitles) { (row, element) in
                return element
            }
            .disposed(by: disposeBag)
        
        pickerView.rx.modelSelected(String.self)
            .map{ $0.description }
            .subscribe(onNext: { value in
                print(value)
            })
            .disposed(by: disposeBag)
    }
   
}
