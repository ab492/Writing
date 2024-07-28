// For running in https://play.kotlinlang.org/

fun main() {    
    val myFirstCar = Vehicle(make = "Ford", model = "Fiesta", year = 2008, isElectric = false, serialNumber = "123")
    myFirstCar.drive(100)
    println(myFirstCar.mileage) // Output: 100

    // I sell the car to someone else, transferring ownership.
    val newOwnersCar = myFirstCar
    println(newOwnersCar.mileage) // Output: 100
    newOwnersCar.drive(200)

    println(myFirstCar.mileage) // Output: 300
    println(newOwnersCar.mileage) // Output: 300
}

class Vehicle(
    val make: String, 
    val model: String, 
    val year: Int, 
    val isElectric: Boolean, 
    private val serialNumber: String,
) {
    val isNew: Boolean get() = mileage == 0
    
    var mileage: Int = 0
	private set
    
    constructor(make: String, model: String, year: Int, serialNumber: String) : this(make, model, year, false, serialNumber)

    fun drive(miles: Int) {
        mileage += miles
    }
}

