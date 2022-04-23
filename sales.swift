protocol PriceProtocol{
    associatedtype Currency
    var price: Currency { get }
    mutating func updatePrice(to value: Currency)
}

// inherit PriceProtocol ลงมา แล้วทำ associatedtype เป็น Float
protocol ProductProtocol: PriceProtocol{
    var productName: String { get }
    var price: Float { get }

    init!(name: String)
    init(name: String, price: Float)

    // แต่ถ้า protocol ระบุเป็น non-failable init
    //ตัว type adopt จะต้องสร้างเป็น non-faiable หรือ failable ที่เป็น implicitly unwrapped failable init


    func getProductName() -> String
    func getProductPrice() -> Float
    // mutating func addProduct(name: String, price: Float)
}




protocol MoneyProtocol{
    // associatedtype Currency
    var currency: String{ get }
    var amount: Float { set get }
    func getMoney() -> Float
    mutating func addMoney(_ value: Float)

}

struct MoneyCurrency: MoneyProtocol{
    // typealias Currency = String
    // typealias Price = Float

    var currency: String
    var amount: Float

    // init(amount: Float){
    //     self.currency = "Baht"
    //     self.amount = amount
    // }

    func getMoney() -> Float{
        return self.amount
    }
    mutating func addMoney(_ value: Float){
        self.amount += value
    }
}

// extension เพื่อสร้างฟังก์ชั่นและกำหนดค่า default
extension MoneyProtocol{
    mutating func changeAmount(to value: Float){
        self.amount = value
    }
}


protocol MarketProtocol{
    associatedtype ProductType: ProductProtocol
    var product: [ProductType] { get }
    var totalProduct: Int { get }
    subscript(index: Int) -> ProductType { get }
    subscript(name: String) -> ProductType? { get }
    func getProductInMarket(name: String) -> ProductType?
    func sell<Product: ProductProtocol, Bag: MoneyProtocol>(product: Product, to bag: inout Bag)
}

// ===========================================
// สร้าง protocol ไว้ extension array เพื่อให้หาข้อมูลใน array ตามที่ต้องการ
protocol ProductDetailToArrayProtocol: Sequence{
    var count: Int { get }
    func haveThis(_ product: String) -> Bool
    func allProduct() -> Void
    // associatedtype Item
    // subscript(i: Int) -> Item { get }
}

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
        for (index, item) in self.enumerated(){
            print("\nProduct No.\(index + 1)")
            print("Product Name: \(item.getProductName())")
            print("Product Price(Cost): \(item.getProductPrice())")
            // print("===")
        }
    }
}



// ===========================================


// ใช้แค่คิดราคาสินค้า ฉะนั้นจะสนใจแต่ตัวเลข เลยไม่จำเป็นต้องรู้ชื่อสินค้า
protocol CalculatorProtocol{
    // associatedtype DataType: ProductProtocol where DataType.price == DataType
    // associatedtype DataType
    func calculatePrice<Item: ProductProtocol>(of: Item) -> Float

    // mutating func changeCalculate(to: Calculator)
}

// ทำ protocol เหมือนเป็น type ตัวนึง ที่ช่วยเก็บสิ่งของไว้ใช้งานภายหลังร่วมกัน

// ทำตัว Product เป็น protocol type?
// เช่น [product]: ProductProtocol



protocol SellProductProtocol{
    // func sell(product: ProductProtocol)
}

// วิธีการขายมีหลายประเภท ถ้าจะขายวิธีแรก ก็ใช้ protocol เพื่อแบ่งประเภทการขาย

protocol SellProtocolInSummer{ // conform to price?

}

protocol SellProtocolNormal{
    
}



// สร้าง Product จาก opaque function
/*
func buildGame<T: GameProtocol>() -> T{
    T()
}
*/




protocol UserProtocol{
    var name: String { get }

    func getName() -> String
}


struct BasicUser: UserProtocol{
    var name: String

    func getName() -> String{
        return self.name
    }
}

struct Buyer: UserProtocol{
    var name: String
    var bag: MoneyCurrency
    
    func getName() -> String{
        return self.name
    }
}

struct Account{
    var user: [UserProtocol]
    
    init(){
        user = []
    }
}


// func addMoneyToAccount(money: Int) -> some UserProtocol{
//     return BasicUser(name:"A")
// }



// =================================


// สร้างตัวคิดเงิน
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
    var product: [ProductType]
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

    func average() -> Float{
        var result: Float = 0.0
        for index in 0..<totalProduct{
            result += self[index].getProductPrice()
        }
        return result
    }
    
    func sell<Product: ProductProtocol, Bag: MoneyProtocol>(product: Product, to bag: inout Bag){
        let productName = product.getProductName()

        guard self.product.haveThis(productName) else {
            print("Item doesn't exist")
            return 
        }
        
        let oldMoney = bag.getMoney()
        let productPrice = product.getProductPrice()
        let result = (oldMoney - productPrice)

        if(result > 0){
            bag.changeAmount(to: result)
        }else{
            print("not enough money")
        }
    }

    func sell<Bag: MoneyProtocol>(name: String, to bag: inout Bag){
        guard self.product.haveThis(name) else {
            print("Item doesn't exist")
            return 
        }
        
        guard let index = self.product.getIndex(name) else { return }

        let oldMoney = bag.getMoney()
        let productPrice = self.getProductPrice(number: index)
        let result = (oldMoney - productPrice)

        if(result > 0){
            bag.changeAmount(to: result)
        }else{
            print("not enough money")
        }
    }
}

postfix operator +++

// ทำ subcript เป็น string คืนค่าสินค้า
// สินค้ามีเพียงชิ้นเดียว
// ทำฟังก์ชั่นคิดราคาสินค้าง่ายๆ
// owned ใส่ user อาชีพ? ที่อยู่?

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




// กำหนด type เป็น Product
var fruitMarket = Market<Product>()

var mango = Product(name: "Mango", price: 10)
var apple = Product(name: "Apple", price: 20)


fruitMarket.product.append(mango)
fruitMarket.product.append(apple)
// fruitMarket.product.append(banana)


for item in fruitMarket.product{
    print(item)
}

func createCalculator(withVat value: Float) -> some CalculatorProtocol{
    Calculator(vat: value)
}

var cal = createCalculator(withVat: 1.09)
fruitMarket.calculator = cal


fruitMarket.productDetail(number: 1)


// fruitMarket.product.allProduct()
// print(fruitMarket.product.haveThis("apple"))

func calculatePrice<Item: ProductProtocol>(of item: Item) -> Float
    where Item.Currency == Float{
    guard item.getProductPrice() > 0.0 else { return 1.0 }
    // return (item.getProductPrice() * vat)
    return 1
}





var kaning = BasicUser(name: "Kaning")

var userAccount = Account()
userAccount.user.append(kaning)

print(userAccount)


func createThaiBaht(amount: Float) -> some MoneyProtocol{
    MoneyCurrency(currency: "Baht", amount: amount)
}

var s = createThaiBaht(amount:2000)
print(s)

var john = Buyer(
    name: "John",
    // bag: s as! MoneyCurrency
    bag: MoneyCurrency(currency: "Baht", amount: 1000)
    )


var productApple = fruitMarket.getProductInMarket(name: "Apple")
print(productApple!)

print(john.bag.amount)
fruitMarket.sell(product: productApple!, to: &john.bag)
fruitMarket.sell(name: "mango", to: &john.bag)
print("mango price: \(fruitMarket.getProductPrice(name: "mango"))")
print(john.bag.amount)


var secondMarket = Market<Product>()
secondMarket.product.append(Product(name: "Banana", price: 50))
var newMarket = fruitMarket + secondMarket
print(newMarket.product)

print(secondMarket == newMarket)

print(secondMarket.product)
secondMarket+++
print(secondMarket.product)