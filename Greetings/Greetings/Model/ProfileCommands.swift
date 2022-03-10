import Foundation

enum ProfileCommands{
    static let commands: [CommandItem] = [
        CommandItem(pid: "05", name: "ENGINE COOLANT TEMPERATURE", unit: "°C"),
        CommandItem(pid: "0C", name: "RPM", unit: "rpm"),
        CommandItem(pid: "0D", name: "SPEED", unit: "km/h"),
        CommandItem(pid: "0F", name: "INTAKE AIR TEMPERATURE", unit: "°C"),
        CommandItem(pid: "10", name: "MAF AIR FLOW RATE", unit: "g/s"),
        CommandItem(pid: "66", name: "MAF AIR FLOW RATE SENSOR", unit: "g/s"),
        CommandItem(pid: "24", name: "OXYGEN SENSOR 1", unit: "LAMBDA | V"), //TODO: volts %, ratio V
        CommandItem(pid: "2C", name: "COMMANDED EGR", unit: "%"),
        CommandItem(pid: "2F", name: "FUEL TANK LEVEL INPUT", unit: "%"),
        CommandItem(pid: "3C", name: "CATALYST TEMPERATURE 1 1", unit: "°C"),
        CommandItem(pid: "3E", name: "CATALYST TEMPERATURE 1 2", unit: "°C"),
        CommandItem(pid: "3D", name: "CATALYST TEMPERATURE 2 1", unit: "°C"),
        CommandItem(pid: "3F", name: "CATALYST TEMPERATURE 2 2", unit: "°C"),
        CommandItem(pid: "44", name: "FUEL AIR EQUIVALENCE RATIO", unit: "LAMBDA"),
        CommandItem(pid: "46", name: "AMBIENT AIR TEMPERATURE", unit: "°C"),
        CommandItem(pid: "4F", name: "MAX VALUES", unit: "LAMBDA | V | mA | kPa"),
        CommandItem(pid: "50", name: "MAXIMUM AIR FLOW RATE", unit: "g/s"),
        CommandItem(pid: "51", name: "FUEL TYPE", unit: "Type"),
        CommandItem(pid: "5C", name: "ENGINE OIL TEMPERATURE", unit: "°C"),
        CommandItem(pid: "68", name: "INTAKE AIR TEMPERATURE SENSOR", unit: "°C"),
        CommandItem(pid: "83", name: "NOX SENSOR", unit: "ppm"),
        CommandItem(pid: "A1", name: "NOX SENSOR CORRECTED", unit: "ppm"),
        CommandItem(pid: "A7", name: "NOX SENSOR ALTERNATIVE", unit: "ppm"),
        CommandItem(pid: "A8", name: "NOX SENSOR CORRECTED ALTERNATIVE", unit: "ppm"),
        CommandItem(pid: "86", name: "PARTICULATE MATTER SENSOR", unit: "mg/m^3"),
        CommandItem(pid: "5E", name: "ENGINE FUEL RATE", unit: "L/h"),
        CommandItem(pid: "9D", name: "ENGINE FUEL RATE MULTI", unit: "g/s"), //TODO: which unit for multi?
        CommandItem(pid: "9E", name: "ENGINE EXHAUST FLOW RATE", unit: "kg/h"),
        CommandItem(pid: "2D", name: "EGR ERROR", unit: "%")
    ]
}
