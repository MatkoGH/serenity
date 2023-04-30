import SwiftUI

// MARK: - Components

extension TimeInterval {
    
    /// Get the components from this time interval, as if this time value was in **seconds**.
    /// - Parameters:
    ///   - places: An array of places to format the components into.
    ///   - minimumPlaceCount: The number of places to maintain for each component but the first.
    ///   - minimumLeadingPlaceCount: The number of places to maintain for the first component.
    /// - Returns: An array of time components relative to the provided places.
    func components(
        _ places: [Place],
        minimumPlaceCount: Int,
        minimumLeadingPlaceCount: Int = 1
    ) -> [Component] {
        var components: [Component] = []
        var previousPlace: Place?
        
        for (index, place) in places.enumerated() {
            var value = floor(self / place.divisor)
            
            // Subtract the extra time from the previous place
            if let previousPlace {
                let convertedPreviousPlace = previousPlace.divisor / place.divisor
                value -= floor(self / previousPlace.divisor) * convertedPreviousPlace
            }
            
            // Create the component, adding the minimum trailing place count if necessary
            let component = Component(
                value: value,
                minimumDisplayPlaces: index > 0 ? minimumPlaceCount : minimumLeadingPlaceCount
            )
            
            components.append(component)
            
            // Set the previous place for the next value
            previousPlace = place
        }
        
        return components
    }
    
    /// Create a string from this time interval, as if this time value was in **seconds**.
    /// - Parameters:
    ///   - places: An array of places to format the components into.
    ///   - minimumPlaceCount: The number of places to maintain for each component but the first.
    ///   - minimumLeadingPlaceCount: The number of places to maintain for the first component.
    ///   - separator: The string separator to put between each component.
    /// - Returns: A string made from components of the provided places.
    func displayStringFromComponents(
        _ places: [Place],
        minimumPlaceCount: Int,
        minimumLeadingPlaceCount: Int = 1,
        joinedBy separator: String = ":"
    ) -> String {
        let components = components(
            places,
            minimumPlaceCount: minimumPlaceCount,
            minimumLeadingPlaceCount: minimumLeadingPlaceCount
        )
        
        return components
            .map { $0.displayString }
            .joined(separator: separator)
    }
}

// MARK: - Component

extension TimeInterval {
    
    struct Component {
        
        /// The value of this component.
        var value: TimeInterval
        
        /// The minimum amount of places visible. For example, if this value were set to `2`, then `6` would display as `06`.
        var minimumDisplayPlaceCount: Int
        
        // MARK: Properties
        
        /// The display value (as an integer), preventing something displaying as `24.0:59.0` instead of `24:59`.
        var displayInt: Int {
            Int(value)
        }
        
        /// The display value (as a string).
        var displayString: String {
            var string = String(displayInt)
            let missingPlaces = minimumDisplayPlaceCount - string.count
            
            // Add leading zeroes if necessary.
            if missingPlaces > 0 {
                string = String(repeating: "0", count: missingPlaces) + string
            }
            
            return string
        }
        
        /// An array of the split string elements of this component.
        var elements: [String] {
            String(value).map { String($0) }
        }
        
        // MARK: Init
        
        init(value: TimeInterval, minimumDisplayPlaces minimumDisplayPlaceCount: Int = 1) {
            self.value = value
            self.minimumDisplayPlaceCount = minimumDisplayPlaceCount
        }
    }
    
    enum Place: Equatable {
        
        /// The preset seconds place.
        case seconds
        
        /// The preset minutes place.
        case minutes
        
        /// The preset hours place.
        case hours
        
        /// A custom place with a provided divisor.
        /// - Parameter divisor: The divisor to use, relative to seconds.
        case custom(divisor: TimeInterval)
        
        /// The divisor for this place.
        var divisor: TimeInterval {
            switch self {
            case .minutes:
                return 60
            case .hours:
                return 3600
            case let .custom(divisor):
                return divisor
            default:
                return 1
            }
        }
    }
}
