Let’s look at some of the differences between classes in Swift and Kotlin. We’re going to create a `Vehicle` class and build from there.

# Initialisation of a class:

Here’s the basic structure for initialising a class.

## Swift:

In Swift you provide an initialiser. 

```swift
public final class Vehicle {
    let make: String
    let model: String
    let year: Int
    let isElectric: Bool
    var mileage: Int
    
    init(
        make: String, 
        model: String,
        year: Int,
        isElectric: Bool,
        mileage: Int = 0
    ) {
        self.make = make
        self.model = model
        self.year = year
        self.isElectric = isElectric
        self.mileage = mileage
    }
}
```

**Remarks:**

- Notice the default value for `mileage` .
- Notice you have to declare `public` and `final` to make the class public and prevent inheritance.
- `let` is read-only.
- `var` is a writeable property.

## Kotlin:

In Kotlin you provide a constructor. It’s a bit more concise since you declare and initialise properties all within the constructor.

```kotlin
class Vehicle(
    val make: String, 
    val model: String, 
    val year: Int, 
    val isElectric: Boolean, 
    var mileage: Int = 0, // Notice the trailing comma
) {
    
}
```

**Remarks:**

- Notice the default value for `mileage`.
- Notice the [trailing comma](https://kotlinlang.org/docs/coding-conventions.html#trailing-commas), which makes version-control diffs cleaner and it’s easier to reorder elements. This is optional.
- Public is the default visibility so there’s no need to declare it.
- All classes are `final`  by default (that is, they don’t allow inheritance) so there’s no need to declare it.
- `val` is a read-only property.
- `var` is a writable property.

# Methods

Now let’s add a method to drive the car. Pretty much identical.

## Swift

```swift
func drive(miles: Int) {
    mileage += miles
}
```

## Kotlin

```kotlin
fun drive(miles: Int) {
	mileage += miles
}
```

# Private Properties

Let’s add a private property to store the car’s serial number. Not much of note here as it’s similar to regular properties.

## Swift

```swift
public final class Vehicle {
    // Other properties as before
    private let serialNumber: String
    
    init(
        // As before
        serialNumber: String
    ) {
        // As before
        self.serialNumber = serialNumber
    }
}
```

## Kotlin

```kotlin
class Vehicle(
    // Constructor as before
    private val serialNumber: String,
)
```

# Private (Set) Properties

Ideally, if we provide a method for driving we wouldn’t also allow the user to fiddle with the odometer directly; we need to make the mileage public for read only.

## Swift

```swift
private (set) var mileage: Int
```

## Kotlin

It’s a bit trickier in Kotlin because there’s no way to call out private set in the constructor shorthand. In that instance we need to move `mileage` out of in constructor and add it as a property of the class with a default value like this:

```kotlin
var mileage: Int = 0
	private set
```

# Computed Properties

Let’s expand our class to include a computed property for determining if the car is new.

## Swift

```swift
var isNew: Bool {
    mileage == 0
}
```

**Remarks:**

- Notice the omission of the `return` keyword.

## Kotlin

```kotlin
val isNew: Boolean 
	get() {
    	return mileage == 0
	}
```

This can be written in the more concise way:

```kotlin
val isNew: Boolean get() = mileage == 0
```

# Convienience Initialisers

## Swift

In Swift you provide a convenience initialiser:

```swift
convenience init(
    make: String,
    model: String,
    year: Int,
    serialNumber: String
) {
    self.init(make: make, model: model, year: year, isElectric: false, serialNumber: serialNumber)
}
```

## Kotlin

In Kotlin you provide a secondary constructor:

```kotlin
class Vehicle(
    // Constructor as before 
) {
    constructor(make: String, model: String, year: Int, serialNumber: String) 
	    : this(make, model, year, false, serialNumber)
}
```

# Reference Semantics

Classes are passed by reference in Swift and Kotlin, meaning that when you update or copy a class, you’re updating or copying the underlying reference rather than the object itself. Here’s how the two compare:

## Swift

```swift
let myFirstCar = Vehicle(make: "Ford", model: "Fiesta", year: 2008, isElectric: false, serialNumber: "123")
myFirstCar.drive(miles: 100)
print(myFirstCar.mileage) // Output: 100

// I sell the car to someone else, transferring ownership.
let newOwnersCar = myFirstCar
print(newOwnersCar.mileage) // Output: 100
newOwnersCar.drive(miles: 200)

print(myFirstCar.mileage) // Output: 300
print(newOwnersCar.mileage) // Output: 300
```

## Kotlin

```kotlin
val myFirstCar = Vehicle(make = "Ford", model = "Fiesta", year = 2008, isElectric = false, serialNumber = "123")
myFirstCar.drive(100)
println(myFirstCar.mileage) // Output: 100

// I sell the car to someone else, transferring ownership.
val newOwnersCar = myFirstCar
println(newOwnersCar.mileage) // Output: 100
newOwnersCar.drive(200)

println(myFirstCar.mileage) // Output: 300
println(newOwnersCar.mileage) // Output: 300
```

**Remarks:**

- Notice that you don’t include the parameter name for the drive method.