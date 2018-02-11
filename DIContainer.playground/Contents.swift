import UIKit

protocol Wheel {
    var radius: Double { get }
}

protocol Engine {
    var name: String { get }
}

struct SportWheel: Wheel {
    let name = "Sport"
    let radius = 20.0
}

struct V8Engine: Engine {
    let name = "V8"
}

struct Vehicle {
    let engine: Engine
    let wheel: Wheel

    init(engine: Engine, wheel: Wheel) {
        self.engine = engine
        self.wheel = wheel
    }
}

var container: DIContainer! = DIContainer() { cfg in
    cfg.register(SportWheel.init, as: Wheel.self)
    cfg.register(V8Engine.init, as: Engine.self)
    cfg.register2(Vehicle.init)
}

container.verify()

let x = Vehicle.init
let vehicle: Vehicle = container.getInstance()
print(vehicle)

