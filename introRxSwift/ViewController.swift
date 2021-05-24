//Criando uma tableview com RxSwift

import UIKit
import RxSwift
import RxCocoa

//Model
struct Product {
    let imageName: String
    let title: String
}
//ViewModel
//toda vez que Items muda via fetchItems, a tableView automagicamente vai se atualizar
struct ProductViewModel {
    var items = PublishSubject<[Product]>()//subscriber
    
    var products: [Product] = []
    
    mutating func fetchItems() {
        self.products = [
            Product(imageName: "house", title: "Home"),
            Product(imageName: "gear", title: "Settings"),
            Product(imageName: "person.circle", title: "Profile"),
            Product(imageName: "airplane", title: "Flights"),
            Product(imageName: "bell", title: "Activity"),
        ]
        
        items.onNext(products)//action de publish
        addItem()
    }
    //metodo pra adicionar novo item
    mutating func addItem() {
        products.append(Product(imageName: "bell", title: "Activity"))
        items.onNext(products) //a reatividade ta AQUI
    }
}
//ViewController
class ViewController: UIViewController {
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()

    private var viewModel = ProductViewModel()
    
    private var bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.frame = view.bounds
        bindTableData()
    }
    
    func bindTableData() {
        //liga products com a tableview ( fala pra interface que isso são dados, se mudar precisam ser atualizados)
        viewModel.items.bind(
            to: tableView.rx.items(
                cellIdentifier: "cell",
                cellType: UITableViewCell.self)
        ) { row, model, cell in
            cell.textLabel?.text = model.title//assina a textlabel setando a view
            cell.imageView?.image = UIImage(systemName: model.imageName) //assina imageview setando a view
        }.disposed(by: bag)
        
        viewModel.items.subscribe { items in
                print("on next") //confirma que o onNext esta sendo observado
        }
        //liga handlers de model
        //sempre que for selecionado vai ligar ao proximo (bind.onNext)
        tableView.rx.modelSelected(Product.self).bind { product in
            print(product.title)//pra checar o resultado
        }.disposed(by: bag)
        
        //busca(fetch) items pela viewmodel
        viewModel.fetchItems()
    }
}
//sem delegate e data source
//sem row.wrap
