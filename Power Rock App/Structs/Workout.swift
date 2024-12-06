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

    // Initialize a WorkoutSet from a dictionary fetched from Firestore
    static func fromDict(_ dict: [String: Any]) -> WorkoutSet? {
        guard let exercisesArray = dict["exercises"] as? [[String: Any]] else { return nil }
        let exercises = exercisesArray.compactMap { exerciseDict -> (name: String, reps: Int)? in
            guard let name = exerciseDict["name"] as? String,
                  let reps = exerciseDict["reps"] as? Int else { return nil }
            return (name, reps)
        }
        return WorkoutSet(exercises: exercises)
    }
}

// MARK: - Workout
struct Workout {
    
    // MARK: - Properties
    var bandName: String
    var genres: [String]
    var title: String
    var difficulty: Int
    var sets: [WorkoutSet]
    var timesCompleted: Int = 0 // Default to 0
    var bandLogoUrl: String? // Optional logo URL for the band

    // MARK: - Methods
    // Convert the Workout to a dictionary for storing in Firestore
    func toDict() -> [String: Any] {
        return [
            "bandName": bandName,
            "genres": genres,
            "title": title,
            "difficulty": difficulty,
            "timesCompleted": timesCompleted,
            "bandLogoUrl": bandLogoUrl ?? "Default_Workout_Image",
            "sets": sets.map { $0.toDict() }
        ]
    }


    // Initialize a Workout from a dictionary fetched from Firestore
    static func fromDict(_ dict: [String: Any]) -> Workout? {
        guard let bandName = dict["bandName"] as? String,
              let genres = dict["genres"] as? [String],
              let title = dict["title"] as? String,
              let difficulty = dict["difficulty"] as? Int,
              let timesCompleted = dict["timesCompleted"] as? Int,
              let setsArray = dict["sets"] as? [[String: Any]] else { return nil }

        let sets = setsArray.compactMap { WorkoutSet.fromDict($0) }
        let bandLogoUrl = dict["bandLogoUrl"] as? String

        return Workout(
            bandName: bandName,
            genres: genres,
            title: title,
            difficulty: difficulty,
            sets: sets,
            timesCompleted: timesCompleted,
            bandLogoUrl: bandLogoUrl
        )
    }
}
