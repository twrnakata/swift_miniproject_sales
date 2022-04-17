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
    func sum<M: MoneyProtocol>(in: M) -> Float
        where M.Currency == Currency
}


protocol TradableProtocol{
    associatedtype Item
    // associatedtype Price
    var item: Item{set get}
    var price: Float { set get}

    func getItem() -> Item
    func getPrice() -> Float
}

protocol MarketProtocol{
    associatedtype ProductType
    var totalProduct: Int { get }
    subscript(index: Int) -> ProductType { get }

    // func buy<T: TradableProtocol, M: MoneyProtocol>(product: T, with money: M) -> T?
        // where M.Price == T.Price
    func sell<T: ProductProtocol, M: MoneyProtocol>(product: T, for money: inout M)
        // where M.Currency: TradableProtocol
}

// ===========================================
// extension array หาชื่อง่ายๆ
protocol ProductDetailToArrayProtocol: Sequence{
    var count: Int { get }
    func take(_ product: String) -> Bool
    func allProduct() -> Void
    // associatedtype Item
    // subscript(i: Int) -> Item { get }
}

extension Array: ProductDetailToArrayProtocol where Element: ProductProtocol{
    func take(_ product: String) -> Bool{
        for item in self{
            if (item.getProductName().lowercased() == product.lowercased()){
                return true
            }
        }
        return false
        
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


extension MarketProtocol where ProductType == Product{
    func say(){
        print("SSS")
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

class Market<Item>: MarketProtocol where Item: ProductProtocol{
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

    func sell<T: ProductProtocol, M: MoneyProtocol>(product: T, for money: inout M){
        
    }
}



var market = Market<Product>()
var mango = Product(name: "Mango",price: 10)
var apple = Product(name: "Apple",price: 20)

market.product.append(mango)
market.product.append(apple)

for item in market.product{
    print(item)
}

var cal = Calculator(vat: 1.09)
market.calculator = cal


market.productDetail(number: 1)


// market.product.allProduct()
// print(market.product.take("apple"))

func calculatePrice<Item: ProductProtocol>(of item: Item) -> Float
    where Item.Currency == Float{
    guard item.getProductPrice() > 0.0 else { return 1.0 }
    // return (item.getProductPrice() * vat)
    return 1
}


market.say()