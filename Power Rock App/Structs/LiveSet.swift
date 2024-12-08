import UIKit

/**
 `LiveSet` represents a live set during the workout, containing exercises and completion state.
 */
struct LiveSet {
    var exercises: [(name: String, reps: Int, isChecked: Bool)]
    var isCompleted: Bool {
        return exercises.allSatisfy { $0.isChecked }
    }
}
