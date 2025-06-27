Let’s take a look at some of the differences between enums in Swift and Kotlin.

# Initialisation of an Enum

Here’s the basic structure. Both are very similar.

## Swift

```swift
enum Vehicle {
    case car
    case bike
    case train
}

let vehicle = Vehicle.car
```

### Remarks:

- In Swift the different cases are called enum cases.

## Kotlin

```kotlin
enum class Vehicle {
    CAR, BIKE, TRAIN
}

val vehicle = Vehicle.CAR
```

### Remarks:

- In Kotlin the different cases are called enum constants.

# Raw Values

Let’s look at raw values. Swift provides them out the box whereas they don’t exist in Kotlin.

## Swift

```swift
enum Vehicle: String {
    case car = "car"
    case bike = "bike"
    case train = "train"
}

let vehicle = Vehicle(rawValue: "car")
```

## Kotlin

You can still get the same behaviour by using a companion object (similar to a static method in Switch) though:

```kotlin
enum class Vehicle(val type: String) {
    CAR("car"), BIKE("bike"), TRAIN("train");

    companion object {
        fun fromRawValue(rawValue: String): Vehicle? {
            return values().find { it.type.equals(rawValue, ignoreCase = true) }
        }
    }
}

val vehicle = Vehicle.fromRawValue("car")
```

# Enum with Associated Values

## Swift

In Swift it’s easy to provide associated values in the enum itself:

```swift
enum Vehicle {
    case car(make: String, model: String)
    case bike(make: String, numberOfGears: Int)
    case train(line: String)
}

let vehicle = Vehicle.car(make: "Ford", model: "Fiesta")
```

## Kotlin

Whereas in Kotlin, we have to use a sealed class instead. A sealed class restricts the number of subclasses that can inherit from it, and they’re all known at compile time.

```kotlin
sealed class Vehicle {
    data class Car(val make: String, val model: String) : Vehicle()
    data class Bicycle(val make: String, val numberOfGears: Int) : Vehicle()
    data class Train(val line: String) : Vehicle()
}

val vehicle = Vehicle.Car(make = "Ford", model = "Fiesta")
```

# Init from String

## **Swift**

```swift
enum Vehicle: String {
    case car = "CAR"
    case bike = "BIKE"
    case train = "TRAIN"
}

let carString = "CAR"
let vehicle = Vehicle(rawValue: carString)

```

### Remarks

- Note that `init?(rawValue:)` is a failable initializer.

## **Kotlin**

```kotlin
enum class Vehicle {
    CAR,
    BIKE,
    TRAIN
}

val carString = "CAR"
val vehicle = Vehicle.valueOf(carString)
```

### Remarks

- Note that this will throw a `IllegalArgumentException` if an invalid string is supplied.

# TODO:

- Switch/when
- Serialization