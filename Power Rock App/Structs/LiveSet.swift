import UIKit

// Represents a live set during the workout
struct LiveSet {
    var exercises: [(name: String, reps: Int, isChecked: Bool)]  // Each exercise has a name, reps, and checkbox state
    var isCompleted: Bool {
        return exercises.allSatisfy { $0.isChecked }  // Set is completed if all exercises are checked
    }
}
