import Foundation

// MARK: - WorkoutSet
// Class to represent a single set of exercises within a workout
class WorkoutSet {
    
    // MARK: - Properties
    // Array of exercises, where each exercise is represented by a tuple of its name and rep count
    var exercises: [(name: String, reps: Int)]
    
    // MARK: - Initializer
    // Initialize a WorkoutSet with an array of exercises
    init(exercises: [(name: String, reps: Int)]) {
        self.exercises = exercises
    }

    // MARK: - Methods
    // Convert the WorkoutSet to a dictionary for storing in Firestore
    func toDict() -> [String: Any] {
        return [
            "exercises": exercises.map { exercise in
                return ["name": exercise.name, "reps": exercise.reps]
            }
        ]
    }
}

// MARK: - Workout
// Struct to represent a workout, including its band name, genres, and sets of exercises
struct Workout {
    
    // MARK: - Properties
    // Band name that created the workout
    var bandName: String
    
    // List of genres associated with the band
    var genres: [String]
    
    // Title of the workout
    var title: String
    
    // Difficulty level of the workout (1-5)
    var difficulty: Int
    
    // List of sets in the workout, where each set contains exercises
    var sets: [WorkoutSet]
    
    // Number of times the workout has been completed
    var timesCompleted: Int = 0 // Default to 0
}
