import Foundation

/**
 `Workout` represents a workout with metadata such as band name, difficulty, and associated sets of exercises.
 */
struct Workout {
    // MARK: - Properties
    var bandName: String
    var genres: [String]
    var title: String
    var difficulty: Int
    var sets: [WorkoutSet]
    var timesCompleted: Int = 0
    var bandLogoUrl: String?

    // MARK: - Methods
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

/**
 `WorkoutSet` represents a single set of exercises within a workout, with methods to convert to and from Firestore format.
 */
class WorkoutSet {
    
    // MARK: - Properties
    var exercises: [(name: String, reps: Int)]
    
    // MARK: - Initializer
    init(exercises: [(name: String, reps: Int)]) {
        self.exercises = exercises
    }

    // MARK: - Methods
    func toDict() -> [String: Any] {
        return [
            "exercises": exercises.map { exercise in
                return ["name": exercise.name, "reps": exercise.reps]
            }
        ]
    }

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
