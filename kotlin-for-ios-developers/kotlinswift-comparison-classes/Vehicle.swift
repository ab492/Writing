class Vehicle {
    let make: String
    let model: String
    let year: Int
    let isElectric: Bool
    private let serialNumber: String
    private (set) var mileage: Int

    var isNew: Bool {
        mileage == 0
    }

    init(
        make: String,
        model: String,
        year: Int,
        isElectric: Bool,
        serialNumber: String,
        mileage: Int = 0
    ) {
        self.make = make
        self.model = model
        self.year = year
        self.isElectric = isElectric
        self.serialNumber = serialNumber
        self.mileage = mileage
    }

convenience init(
    make: String,
    model: String,
    year: Int,
    serialNumber: String
) {
    self.init(make: make, model: model, year: year, isElectric: false, serialNumber: serialNumber)
}

    func drive(miles: Int) {
        mileage += miles
    }
}

let myFirstCar = Vehicle(make: "Ford", model: "Fiesta", year: 2008, isElectric: false, serialNumber: "123")
myFirstCar.drive(miles: 100)
print(myFirstCar.mileage) // Output: 100

// I sell the car to someone else, transferring ownership.
let newOwnersCar = myFirstCar
print(newOwnersCar.mileage) // Output: 100
newOwnersCar.drive(miles: 200)

print(myFirstCar.mileage) // Output: 300
print(newOwnersCar.mileage) // Output: 300
