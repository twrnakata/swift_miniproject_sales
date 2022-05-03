protocol PriceProtocol{
    associatedtype Currency
    var price: Currency { get }
    mutating func updatePrice(to value: Currency)
}

// inherit PriceProtocol
protocol ProductProtocol: PriceProtocol{
    var productName: String { get }
    var price: Float { get }

    // protocol ระบุ non-failable init
    // ตัว type adopt จะต้องสร้างเป็น non-faiable หรือ failable ที่เป็น implicitly unwrapped failable init
    init!(name: String)
    init(name: String, price: Float)

    func getProductName() -> String
    func getProductPrice() -> Float
}



// สร้าง protocol ทีเป็นตัวกลางแลกเปลี่ยนสินค้า
protocol MoneyProtocol{
    associatedtype Currency
    var currency: Currency{ get }
    // var currency: String{ get }
    var amount: Float { get }
    func getMoney() -> Float
    mutating func addMoney(_ value: Float)
    mutating func changeAmount(to value: Float)
}

// สร้าง protocol ที่กำหนดเงื่อนไขของร้านค้า
protocol MarketProtocol{
    associatedtype ProductType: ProductProtocol
    var product: [ProductType] { get }
    var totalProduct: Int { get }
    subscript(index: Int) -> ProductType { get }
    subscript(name: String) -> ProductType? { get }
    func getProductInMarket(name: String) -> ProductType?
    func addProduct(_ product: ProductType)
    func removeProduct(name: String)
    func sell<Product: ProductProtocol, Bag: MoneyProtocol>(product: Product, to wallet: inout Bag)
}


// ===========================================
// สร้าง protocol สำหรับ extension ที่ตัว array ไว้เพื่อจัดการข้อมูลที่เป็น array
protocol ProductDetailToArrayProtocol: Sequence{
    var count: Int { get }
    func haveThis(_ product: String) -> Bool
    func allProduct() -> Void
}

// extension ProductDetailToArrayProtocol ให้กับ Array
extension Array: ProductDetailToArrayProtocol where Element: ProductProtocol{
    func haveThis(_ product: String) -> Bool{
        for item in self{
            if (item.getProductName().lowercased() == product.lowercased()){
                return true
            }
        }
        return false
        
    }

    func getIndex(_ target: String) -> Int?{
        let target = target.lowercased()
        let productName = self.map{ $0.getProductName().lowercased() }
        
        if(productName.contains(target)){
            let result = productName.firstIndex{ $0 == target }
            return result
        }
        return nil
    }

    func allProduct(){
        print("\n=== All Product ===")
        for (index, item) in self.enumerated(){
            print("Product No.\(index + 1)")
            print("Product Name: \(item.getProductName())")
            print("Product Price(Cost): \(item.getProductPrice())")
        }
            print("=== All Product ===\n")
    }
}



// ===========================================



// ใช้แค่คิดราคาสินค้า ฉะนั้นจะสนใจแต่ตัวเลข เลยไม่จำเป็นต้องรู้ชื่อสินค้า
// ทำ protocol เหมือนเป็น type ตัวนึง ที่ช่วยเก็บสิ่งของไว้ใช้งานภายหลังร่วมกัน
protocol CalculatorProtocol{
    func calculatePrice<Item: ProductProtocol>(of: Item) -> Float
}

// สร้าง Calculator จาก opaque function
func createCalculator(withVat value: Float) -> some CalculatorProtocol{
    Calculator(vat: value)
}


// สร้างตัวคิดเงินไว้ใช้ในร้านค้า
struct Calculator: CalculatorProtocol{
    var vat: Float

    func calculatePrice<Item: ProductProtocol>(of item: Item) -> Float{
        guard item.getProductPrice() > 0.0 else { return 1.0 }
        return (item.getProductPrice() * vat)
    }
}


struct Product: ProductProtocol{
    var productName: String = "[Unname]"
    var price: Float = 0.0

    init(){}
    init(name: String){
        self.init()
        self.productName = name
    }
    init(name: String, price: Float){
        self.productName = name
        self.price = price
    }

    func getProductName() -> String{
        return self.productName
    }

    func getProductPrice() -> Float{
        return self.price
    }

    mutating func updatePrice(to value: Float){
        self.price = value
    }
}


// สร้าง market มี properties เก็บข้อมูลเป็น [Item]

// class Market<Item>: MarketProtocol where Item: ProductProtocol{
class Market<Item: ProductProtocol>: MarketProtocol{
    typealias ProductType = Item
    private(set) var product: [ProductType]
    // var product: [Product] // same result
    var calculator: CalculatorProtocol!
    var totalProduct: Int { return product.count }

    init(){
        self.product = []
    }

    init(market: Market){
        self.product = market.product
        self.calculator = market.calculator
    }

    convenience init(product: ProductType){
        self.init()

        if(isExist(product) == false){
            self.product.append(product)
        }
    }

    convenience init(product: ProductType, calculator: CalculatorProtocol){
        self.init(product: product)
        self.calculator = calculator
    }

    // init array
    init(product: [ProductType]){
        self.product = []
        for (index, item) in product.enumerated(){
            if(isExist(product[index]) == false){
                self.product.append(item)
            }
        }
    }

    // init array
    convenience init(product: [ProductType], calculator: CalculatorProtocol){
        self.init(product: product)
        self.calculator = calculator
    }
    
    
    private func isExist(_ product: ProductType) -> Bool{
        return (self.product.haveThis(product.getProductName())) ? true : false
    }

    func productDetail(number: Int){
        guard number >= 0, number < totalProduct, !(product.isEmpty) else { return }
        
        print("Product Name: \(product[number].getProductName())")
        print("Product Price(Sale): \(calculator.calculatePrice(of: product[number]))")
    }

    func getProductPrice(number: Int) -> Float{
        // guard number >= 0, number < totalProduct, !(product.isEmpty) else { return 0.0 }
        
        return self.calculator.calculatePrice(of: self[number])
    }
    
    func getProductPrice(name: String) -> Float{
        if let index = self.product.getIndex(name){
            return self.getProductPrice(number: index)
        }
        return 0.0
    }

    subscript(index: Int) -> ProductType{
        return self.product[index]
    }

    subscript(name: String) -> ProductType?{
        guard let index = self.product.getIndex(name) else { return nil }
        return self.product[index]
    }
    
    func getProductInMarket(name: String) -> ProductType?{
        return self[name]
    }

    func addProduct(_ product: ProductType){
        if(isExist(product) == false){
            self.product.append(product)
        }
    }
    
    func removeProduct(name: String){
        if let index = self.product.getIndex(name){
            self.product.remove(at: index)
        }
    }

    func sell<Bag: MoneyProtocol>(name: String, to wallet: inout Bag){
        guard self.product.haveThis(name) else {
            print("Item doesn't exist")
            return 
        }
        
        let oldMoney = wallet.getMoney()
        let productPrice = self.getProductPrice(name: name)
        let result = (oldMoney - productPrice)

        if(result > 0){
            wallet.changeAmount(to: result)
        }else{
            print("not enough money")
        }

    }

    func sell<Product: ProductProtocol, Bag: MoneyProtocol>(product: Product, to wallet: inout Bag){
        self.sell(name: product.getProductName(), to: &wallet)
    }

    func average() -> Float{
        var result: Float = 0.0
        for index in 0..<totalProduct{
            result += self[index].getProductPrice()
        }
        return result
    }
    func allProduct() -> Void{
        self.product.allProduct()
    }
}

// สร้าง operator +++ ไว้ใช้ใน Market
postfix operator +++

extension Market{
    // เพิ่มสินค้าจากทั้งสองร้านไปยังอีกร้าน
    static func + (first: Market, second: Market) -> Market{
        first.product = first.product + second.product
        
        return Market(market: first)
    }
    
    // เพิ่มสินค้าจากร้านใหม่เข้าร้านเดิม
    static func += (first: inout Market, second: Market){
        first = first + second
    }

    // เพิ่มราคาสินค้าเดิมขึ้นอีก 1 เท่า
    static postfix func +++ (market: inout Market){
        for index in 0..<market.totalProduct{
            let newPrice = market[index].price + market[index].price
            market.product[index].updatePrice(to: newPrice as! Item.Currency)
        }
    }

    // เปรียบเทียบจำนวนและสินค้าว่าเท่ากันไหม
    static func == (first: Market, second: Market) -> Bool{
        let productCount = (first.totalProduct == second.totalProduct)
        guard productCount else { return false }

        for index in 0..<first.totalProduct{
            let find = first.product[index].getProductName()
            if(second.product.haveThis(find)){
                continue
            }else{
                return false
            }
        }

        return true
    }
}

// สร้าง statuc ไว้ระบุสถานะให้กับ User
struct Status{
    var name: String
    var value: Value

    enum Value{
        case bool(Bool)
        case int(Int)
    }

    init(_ name: String, _ value: Value){
        self.name = name
        self.value = value
    }
}


@resultBuilder
struct StatusBuilder{
    // รับ Statuc เข้ามาได้หลายตัวแล้วเอามาจอยกัน
    static func buildBlock(_ component: [Status]...) -> [Status]{
        Array(component.joined())
    }
    static func buildExpression(_ dataSet: (name: String, bool: Bool)) -> [Status]{
        [Status(dataSet.name, .bool(dataSet.bool))]
    }
    static func buildExpression(_ dataSet: (name: String, int: Int)) -> [Status]{
        [Status(dataSet.name, .int(dataSet.int))]
    }
    // ถ้ารับเข้ามาเป็น Status จะคืนเป็น Array
    static func buildExpression(_ status: Status) -> [Status]{
        [status]
    }
    
}

func makeStatus(@StatusBuilder _ status: () -> [Status]) -> [Status]{
    status()
}



// สร้าง protocol ที่กำหนดข้อมูลของ User
// กำหนด level ให้เป็น open สามารถเข้าถึงได้จาก source file ใดๆ ก็ได้
public protocol UserProtocol{
    var name: String { get set }

    func getName() -> String
}

struct BasicUser: UserProtocol{
    var name: String
    var status: [Status]

    init(name: String,
        @StatusBuilder builder: () -> [Status]){
            self.name = name
            self.status = builder()
    }

    func getName() -> String{
        return self.name
    }
}

// สร้าง class Customer โดยมี wallet เป็นกระเป๋าเงินไว้ซื้อสินค้า
class Customer: UserProtocol{
    var name: String
    var wallet: CustomerWallet? // strong ref

    init(name: String){
        self.name = name
    }
    
    init(name: String, wallet: CustomerWallet){
        self.name = name
        self.wallet = wallet
    }

    func getName() -> String{
        return self.name
    }

    deinit{
        print("Delete Customer name: \(self.name)")
    }
}

fileprivate class Account: UserProtocol{
    private var user: [UserProtocol]
    var name: String
    
    init(){
        self.name = "Account"
        self.user = []
    }
    convenience init(user: UserProtocol){
        self.init()
        if(!(user.getName().isEmpty)){
            self.user.append(user)
        }
    }
    convenience init(user newUser: UserProtocol...){
        self.init(user: newUser)
    }
    convenience init(user: [UserProtocol]){
        self.init()
        for acc in user{
            if(!(acc.getName().isEmpty)){
                self.user.append(acc)
            }
        }
    }
    // ส่งชื่อที่กำหนดไว้ในคลาสและชื่อสมาชิกที่เก็บไว้ออกไป
    func getName() -> String{
        var result = self.name + ":"
        for acc in user{
            result += " \(acc.getName())"
        }
        return result
    }
    func addUser(_ newUser: UserProtocol){
        if(!(newUser.getName().isEmpty)){
            self.user.append(newUser)
        }
    }
    func removeUser(name: String){
        for (index, acc) in user.enumerated(){
            if(acc.getName() == name){
                self.user.remove(at: index)
            }
        }
    }
}

// extension เพื่อสร้างฟังก์ชั่นและกำหนดค่า default
extension UserProtocol{
    mutating func changeName(to newName: String){
        self.name = newName
    }
}



class CustomerWallet: MoneyProtocol{
    var currency: String
    private(set) var amount: Float
    unowned let owner: Customer

    init(currency: String, amount: Float, owner: Customer){
        self.currency = currency
        self.amount = amount
        self.owner = owner
    }

    convenience init(amount: Float, owner: Customer){
        self.init(currency: "Baht", amount: amount, owner: owner)
    }

    func getMoney() -> Float{
        return self.amount
    }
    func addMoney(_ value: Float){
        self.amount += value
    }
    func changeAmount(to value: Float){
        self.amount = value
    }

    deinit{
        print("=====")
        print("Delete Wallet with detail:")
        print("Currency: \(self.currency), Amount: \(self.amount)")
        print("=====")
    }
}

// ====================================================
// end protocol, struct, class
// ====================================================


// กำหนด type เป็น Product
var fruitMarket = Market<Product>()

var mango = Product(name: "Mango", price: 10)
var apple = Product(name: "Apple", price: 20)

fruitMarket.addProduct(mango)
fruitMarket.addProduct(apple)


for item in fruitMarket.product{
    print(item)
}
print("or")
fruitMarket.product.allProduct()




var cal = createCalculator(withVat: 1.09)
fruitMarket.calculator = cal

fruitMarket.productDetail(number: 1)


var kaning = BasicUser(name: "Kaning"){
    Status("Online", .bool(false))
}
for status in kaning.status{
    print(status)
}

fileprivate var userAccount = Account()
userAccount.addUser(kaning)
print(userAccount.getName())
print("before add John")

func createThaiBaht(currency: String, amount: Float, owner: Customer) -> some MoneyProtocol{
    CustomerWallet(currency: currency, amount: amount, owner: owner)
}

var john: Customer? = Customer(name: "John")

// downcast to CustomerWallet
var thaiBahtForJohn: CustomerWallet? = (createThaiBaht(currency: "Baht", amount:2000, owner: john!)) as? CustomerWallet
john?.wallet = thaiBahtForJohn

// ทดสอบใส่ john เข้าไปใน userAccount
userAccount.addUser(john!)
print(userAccount.getName())
// ลบ john ออกจาก userAccount เพราะกำหนดให้ john เป็น nil ในภายหลัง
userAccount.removeUser(name: "John")
print("\nremove john from userAccount\n")
print(userAccount.getName())


var productApple = fruitMarket.getProductInMarket(name: "Apple")
print(productApple!)

// แสดงเงินของ john ก่อนซื้อสินค้า
print(john!.wallet!.amount)
fruitMarket.sell(product: productApple!, to: &john!.wallet!)

// เรียกดูเงิน john หลังซื้อสินค้า 1 ชิ้น
print(john!.wallet!.amount)
fruitMarket.sell(name: "mango", to: &john!.wallet!)

// เรียกใช้ฟังก์ชั่นแสดงราคาสินค้า
print("mango price: \(fruitMarket.getProductPrice(name: "mango"))")

// เรียกดูเงิน john หลังซื้อสินค้าไป 2 ชิ้น
print(john!.wallet!.amount)
print("")

// สร้าง market ขึ้นมาอีกตัวเพื่อทดลองใช้ operator
var secondMarket = Market<Product>()
secondMarket.addProduct(Product(name: "Banana", price: 50))

// ใช้ operator รวมสินค้าทั้งสองร้านเข้าด้วยกัน
var newMarket = fruitMarket + secondMarket
newMarket.product.allProduct()

print(secondMarket == newMarket)

newMarket.allProduct()
// ใช้ operator เพิ่มราคาสินค้าขึ้นอีก 1 เท่า
newMarket+++
newMarket.allProduct()

// คืนพื้นที่ให้เงินบาท
thaiBahtForJohn = nil
print(thaiBahtForJohn?.owner.name) // nil
print(john?.wallet?.amount)
print(john?.name)


print("===============")
john = nil
print("===============")
