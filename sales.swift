protocol PriceProtocol{
    associatedtype Currency
    var price: Currency { get }
    // mutating func updatePrice(to value: Currency)
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
    associatedtype Currency
    var currency: Currency{ get }
    var amount: Float { set get }
    func getMoney() -> Float
    mutating func addMoney(_ value: Float)

}

struct BahtCurrency: MoneyProtocol{
    typealias Currency = String
    typealias Price = Float

    var currency: Currency = "Baht"
    var amount: Price

    init(amount: Price){
        currency = "Baht"
        self.amount = amount
    }

    func getMoney() -> Price{
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

    func getProductInMarket(name: String) -> ProductType?
    func sell<Product: ProductProtocol, Bag: MoneyProtocol>(product: Product, to bag: inout Bag)
        // where User: MoneyProtocol
}

// ===========================================
// extension array หาชื่อง่ายๆ
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

    func getItem(_ target: String) -> Int?{
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

extension ProductDetailToArrayProtocol{
        // func average() -> Float{
        //     var sum: Float = 0.0
        //     for index in 0..<count {
        //         // sum += Double(self[index])

        //     }
        //     return sum / Float(count)
        // }
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
    var bag: BahtCurrency
    
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
    // var product: [Product]
    var calculator: CalculatorProtocol!
    var totalProduct: Int { return product.count }

    init(){
        self.product = []
    }
    convenience init(product: Item){
        self.init()
        self.product.append(product)
    }


    func productDetail(number: Int){
        guard number >= 0, number < totalProduct, !(product.isEmpty) else { return }
        
        print("Product Name: \(product[number].productName)")
        print("Product Price(Sale): \(calculator.calculatePrice(of: product[number]))")
    }

    subscript(index: Int) -> ProductType{
        return self.product[index]
    }
    
    func average() -> Float{
        var result: Float = 0.0
        for index in 0..<totalProduct{
            result += self[index].getProductPrice()
        }
        return result
    }
    
    func getProductInMarket(name target: String) -> ProductType?{
        if let index = self.product.getItem(target){
            return self.product[index]
        }
        return nil
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

    func sellItemInMarket<Bag: MoneyProtocol>(name: String, to bag: inout Bag){
        guard self.product.haveThis(name) else {
            print("Item doesn't exist")
            return 
        }
        
        guard let index = self.product.getItem(name) else { return }

        let oldMoney = bag.getMoney()
        let productPrice = product[index].getProductPrice()
        let result = (oldMoney - productPrice)

        if(result > 0){
            bag.changeAmount(to: result)
        }else{
            print("not enough money")
        }
    }
}


var market = Market<Product>()
var mango = Product(name: "Mango",price: 10)
var apple = Product(name: "Apple",price: 20)

market.product.append(mango)
market.product.append(apple)
// market.product.append(apple)

for item in market.product{
    print(item)
}

var cal = Calculator(vat: 1.09)
market.calculator = cal


market.productDetail(number: 1)


// market.product.allProduct()
// print(market.product.haveThis("apple"))

func calculatePrice<Item: ProductProtocol>(of item: Item) -> Float
    where Item.Currency == Float{
    guard item.getProductPrice() > 0.0 else { return 1.0 }
    // return (item.getProductPrice() * vat)
    return 1
}





var naj = BasicUser(name: "Naj")

var userAccount = Account()
userAccount.user.append(naj)

print(userAccount)

var john = Buyer(
    name: "John",
    bag: BahtCurrency(amount: 1000)
    )


var productApple = market.getProductInMarket(name: "Apple")
print(productApple!)

print(john.bag.amount)
market.sell(product: productApple!, to: &john.bag)
market.sellItemInMarket(name: "mango", to: &john.bag)
print(john.bag.amount)