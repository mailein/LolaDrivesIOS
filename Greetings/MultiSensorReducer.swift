import Foundation
import pcdfcore

struct MultiSensorReducer{
    func reduce(event: PCDFEvent) -> PCDFEvent {
        if let event = event as? NOXSensorEvent {
            return NOXReducedEvent(source: event.source, timestamp: event.timestamp, bytes: event.bytes, pid: event.pid, mode: event.mode, sensor1_1: event.sensor1_1, sensor1_2: event.sensor1_2, sensor2_1: event.sensor2_1, sensor2_2: event.sensor2_2)
        }
        if let event = event as? NOXSensorCorrectedEvent {
            return NOXReducedEvent(source: event.source, timestamp: event.timestamp, bytes: event.bytes, pid: event.pid, mode: event.mode, sensor1_1: event.sensor1_1, sensor1_2: event.sensor1_2, sensor2_1: event.sensor2_1, sensor2_2: event.sensor2_2)
        }
        if let event = event as? NOXSensorAlternativeEvent {
            return NOXReducedEvent(source: event.source, timestamp: event.timestamp, bytes: event.bytes, pid: event.pid, mode: event.mode, sensor1_1: event.sensor1_1, sensor1_2: event.sensor1_2, sensor2_1: event.sensor2_1, sensor2_2: event.sensor2_2)
        }
        if let event = event as? NOXSensorCorrectedAlternativeEvent {
            return NOXReducedEvent(source: event.source, timestamp: event.timestamp, bytes: event.bytes, pid: event.pid, mode: event.mode, sensor1_1: event.sensor1_1, sensor1_2: event.sensor1_2, sensor2_1: event.sensor2_1, sensor2_2: event.sensor2_2)
        }
        if let event = event as? FuelRateEvent {
            return FuelRateReducedEvent(source: event.source, timestamp: event.timestamp, bytes: event.bytes, pid: event.pid, mode: event.mode, engineFuelRate: event.engineFuelRate, vehicleFuelRate: -1.0)
        }
        if let event = event as? FuelRateMultiEvent {
            return FuelRateReducedEvent(source: event.source, timestamp: event.timestamp, bytes: event.bytes, pid: event.pid, mode: event.mode, engineFuelRate: event.engineFuelRate != -1.0 ? event.engineFuelRate / 832.0 * 3600.0 : -1.0, vehicleFuelRate: event.vehicleFuelRate != -1.0 ? event.vehicleFuelRate / 832.0 * 3600.0 : -1.0)
        }
        return event
    }
}
