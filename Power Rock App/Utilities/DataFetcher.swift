import FirebaseFirestore
import FirebaseAuth

struct DataFetcher {
    // Fetch user details
    static func fetchUserDetails(completion: @escaping (String?, [String]?, String?, Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(nil, nil, nil, NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                completion(nil, nil, nil, error)
                return
            }

            guard let data = snapshot?.data(),
                  let userType = data["userType"] as? String else {
                completion(nil, nil, nil, NSError(domain: "Firestore", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid user data"]))
                return
            }

            let bandName = userType == "Star" ? data["bandName"] as? String ?? "" : ""
            let genres = data["genres"] as? [String] ?? []
            let bandLogoUrl = data["bandLogoUrl"] as? String ?? "Default_Workout_Image"
            completion(bandName, genres, bandLogoUrl, nil)
        }
    }

    // Fetch user genres
    static func fetchUserGenres(completion: @escaping ([String]?, Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(nil, NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let data = snapshot?.data(),
                  let genres = data["genres"] as? [String] else {
                completion(nil, NSError(domain: "Firestore", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid genres data"]))
                return
            }

            completion(genres, nil)
        }
    }

    // Fetch workouts
    static func fetchWorkouts(completion: @escaping ([Workout]?, Error?) -> Void) {
        let db = Firestore.firestore()
        db.collection("workouts").getDocuments(source: .default) { snapshot, error in
            if let error = error {
                print("Error fetching workouts from Firestore: \(error.localizedDescription)")
                completion(nil, error)
                return
            }

            guard let documents = snapshot?.documents else {
                print("No documents found in the workouts collection.")
                completion(nil, NSError(domain: "Firestore", code: 0, userInfo: [NSLocalizedDescriptionKey: "No workout data found"]))
                return
            }

            print("Fetched \(documents.count) workout documents.")
            var allWorkouts: [Workout] = []

            for document in documents {
                let data = document.data()
                print("Workout Data: \(data)") // Log the raw data

                if let bandName = data["bandName"] as? String,
                   let genres = data["genres"] as? [String],
                   let title = data["title"] as? String,
                   let difficulty = data["difficulty"] as? Int,
                   let setsData = data["sets"] as? [[String: Any]] {

                    var sets: [WorkoutSet] = []
                    for setData in setsData {
                        if let exercisesData = setData["exercises"] as? [[String: Any]] {
                            var exercises: [(name: String, reps: Int)] = []
                            for exerciseData in exercisesData {
                                if let name = exerciseData["name"] as? String,
                                   let reps = exerciseData["reps"] as? Int {
                                    exercises.append((name: name, reps: reps))
                                }
                            }
                            let workoutSet = WorkoutSet(exercises: exercises)
                            sets.append(workoutSet)
                        }
                    }

                    let workout = Workout(
                        bandName: bandName,
                        genres: genres,
                        title: title,
                        difficulty: difficulty,
                        sets: sets
                    )
                    allWorkouts.append(workout)
                } else {
                    print("Invalid workout document: \(data)") // Log invalid documents
                }
            }

            print("Total valid workouts fetched: \(allWorkouts.count)")
            completion(allWorkouts, nil)
        }
    }


    // Fetch current user type
    static func fetchCurrentUserType(completion: @escaping (String?, Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(nil, NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let data = snapshot?.data(),
                  let userType = data["userType"] as? String else {
                completion(nil, NSError(domain: "Firestore", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid user type"]))
                return
            }

            completion(userType, nil)
        }
    }
    
    // MARK: - Fetch My Workouts
    static func fetchMyWorkouts(completion: @escaping ([Workout]?, Error?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user ID found. Unable to fetch workouts.")
            completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No user ID found"]))
            return
        }

        let db = Firestore.firestore()
        let userWorkoutsRef = db.collection("users").document(userId).collection("MyWorkouts")

        userWorkoutsRef.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching workouts: \(error.localizedDescription)")
                completion(nil, error)
                return
            }

            guard let documents = snapshot?.documents else {
                print("No workouts found for user.")
                completion([], nil)
                return
            }

            let workouts = documents.compactMap { doc -> Workout? in
                let data = doc.data()
                guard
                    let title = data["title"] as? String,
                    let bandName = data["bandName"] as? String,
                    let genres = data["genres"] as? [String],
                    let difficulty = data["difficulty"] as? Int,
                    let setsData = data["sets"] as? [[String: Any]]
                else {
                    print("Invalid workout document: \(doc.data())")
                    return nil
                }

                let sets = setsData.compactMap { setData -> WorkoutSet? in
                    guard let exercises = setData["exercises"] as? [[String: Any]] else { return nil }
                    let parsedExercises = exercises.compactMap { exercise -> (String, Int)? in
                        guard
                            let name = exercise["name"] as? String,
                            let reps = exercise["reps"] as? Int
                        else { return nil }
                        return (name, reps)
                    }
                    return WorkoutSet(exercises: parsedExercises)
                }

                return Workout(
                    bandName: bandName,
                    genres: genres,
                    title: title,
                    difficulty: difficulty,
                    sets: sets,
                    timesCompleted: 0 // Default value
                )
            }

            print("Fetched workouts (\(workouts.count)):")
            workouts.forEach { print("- \($0.title)") }

            completion(workouts, nil)
        }
    }


    // MARK: - Fetch Workout Details for MyWorkouts
    static func fetchWorkoutsByTitles(titles: [String], completion: @escaping ([Workout]?, Error?) -> Void) {
        let db = Firestore.firestore()
        db.collection("workouts").whereField("title", in: titles).getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let documents = snapshot?.documents else {
                completion(nil, NSError(domain: "Firestore", code: 0, userInfo: [NSLocalizedDescriptionKey: "No workout data found"]))
                return
            }

            var allWorkouts: [Workout] = []
            for document in documents {
                let data = document.data()

                if let bandName = data["bandName"] as? String,
                   let genres = data["genres"] as? [String],
                   let title = data["title"] as? String,
                   let difficulty = data["difficulty"] as? Int,
                   let setsData = data["sets"] as? [[String: Any]] {

                    var sets: [WorkoutSet] = []
                    for setData in setsData {
                        if let exercisesData = setData["exercises"] as? [[String: Any]] {
                            var exercises: [(name: String, reps: Int)] = []
                            for exerciseData in exercisesData {
                                if let name = exerciseData["name"] as? String,
                                   let reps = exerciseData["reps"] as? Int {
                                    exercises.append((name: name, reps: reps))
                                }
                            }
                            let workoutSet = WorkoutSet(exercises: exercises)
                            sets.append(workoutSet)
                        }
                    }

                    let workout = Workout(bandName: bandName, genres: genres, title: title, difficulty: difficulty, sets: sets)
                    allWorkouts.append(workout)
                }
            }

            completion(allWorkouts, nil)
        }
    }
    
    static func isWorkoutInMyWorkouts(workoutTitle: String, completion: @escaping (Bool, Error?) -> Void) {
            guard let userId = Auth.auth().currentUser?.uid else {
                print("No user ID found. Unable to check workout.")
                completion(false, nil)
                return
            }
            
            let db = Firestore.firestore()
            let userWorkoutsRef = db.collection("users").document(userId).collection("MyWorkouts")
            
            userWorkoutsRef.whereField("title", isEqualTo: workoutTitle).getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching workouts: \(error.localizedDescription)")
                    completion(false, error)
                    return
                }
                
                let isAdded = snapshot?.documents.count ?? 0 > 0
                print("Workout '\(workoutTitle)' check result: \(isAdded)")
                completion(isAdded, nil)
            }
        }

    static func addWorkoutToMyWorkouts(workout: Workout, completion: @escaping (Error?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        
        let db = Firestore.firestore()
        let userWorkoutsRef = db.collection("users").document(userId).collection("MyWorkouts")
        
        // Add workout details to MyWorkouts collection
        userWorkoutsRef.document(workout.title).setData([
            "title": workout.title,
            "bandName": workout.bandName,
            "genres": workout.genres,
            "difficulty": workout.difficulty,
            "sets": workout.sets.map { set in
                ["exercises": set.exercises.map { ["name": $0.name, "reps": $0.reps] }]
            }
        ]) { error in
            if let error = error {
                print("Error adding workout to MyWorkouts: \(error.localizedDescription)")
            } else {
                print("Successfully added workout '\(workout.title)' to MyWorkouts.")
            }
            completion(error)
        }
    }

    static func removeWorkoutFromMyWorkouts(workoutTitle: String, completion: @escaping (Error?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        
        let db = Firestore.firestore()
        let userWorkoutsRef = db.collection("users").document(userId).collection("MyWorkouts")
        
        // Find and delete workout by title
        userWorkoutsRef.whereField("title", isEqualTo: workoutTitle).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching workout for removal: \(error.localizedDescription)")
                completion(error)
                return
            }
            
            guard let documents = snapshot?.documents, !documents.isEmpty else {
                print("No workout found with title '\(workoutTitle)' to remove.")
                completion(nil)
                return
            }
            
            // Delete all matching documents
            for document in documents {
                document.reference.delete { error in
                    if let error = error {
                        print("Error deleting workout: \(error.localizedDescription)")
                    } else {
                        print("Successfully removed workout '\(workoutTitle)' from MyWorkouts.")
                    }
                    completion(error)
                }
            }
        }
    }

    
    static func saveUserData(uid: String, firstName: String, genres: [String], completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        let userData: [String: Any] = [
            "userType": "Fan",
            "firstName": firstName,
            "genres": genres
        ]
        db.collection("users").document(uid).setData(userData, completion: completion)
    }

    // Add initial workouts to MyWorkouts based on user's genres
    static func addInitialWorkoutsToMyWorkouts(uid: String, genres: [String], completion: @escaping (Error?) -> Void) {
        print("Fetching all workouts to match user genres: \(genres)")

        fetchWorkouts { workouts, error in
            if let error = error {
                print("Error fetching workouts: \(error.localizedDescription)")
                completion(error)
                return
            }

            guard let workouts = workouts else {
                print("No workouts found in database.")
                completion(NSError(domain: "DataFetcher", code: 0, userInfo: [NSLocalizedDescriptionKey: "No workouts found"]))
                return
            }

            // Normalize genres for matching
            let normalizedGenres = Set(genres.map { $0.lowercased() })
            print("Normalized user genres: \(normalizedGenres)")

            let matchingWorkouts = workouts.filter { workout in
                let workoutGenres = Set(workout.genres.map { $0.lowercased() })
                let matches = !workoutGenres.isDisjoint(with: normalizedGenres)
                print("Checking workout: \(workout.title), Genres: \(workout.genres), Matches: \(matches)")
                return matches
            }

            if matchingWorkouts.isEmpty {
                print("No matching workouts found for user genres.")
            } else {
                print("Found \(matchingWorkouts.count) matching workouts:")
                matchingWorkouts.forEach { print("- \($0.title)") }
            }

            // Save matching workouts to MyWorkouts
            let db = Firestore.firestore()
            let myWorkoutsRef = db.collection("users").document(uid).collection("MyWorkouts")
            let batch = db.batch()

            for workout in matchingWorkouts {
                let docRef = myWorkoutsRef.document()
                batch.setData(workout.toDict(), forDocument: docRef)
            }

            batch.commit { error in
                if let error = error {
                    print("Error saving workouts to MyWorkouts: \(error.localizedDescription)")
                } else {
                    print("Successfully added \(matchingWorkouts.count) workouts to MyWorkouts.")
                }
                completion(error)
            }
        }
    }

    
    static func ensurePowerPointsForFan(completion: @escaping (Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)

        userRef.getDocument { snapshot, error in
            if let error = error {
                completion(error)
                return
            }

            guard let data = snapshot?.data(),
                  let userType = data["userType"] as? String,
                  userType == "Fan" else {
                completion(NSError(domain: "Firestore", code: 0, userInfo: [NSLocalizedDescriptionKey: "User is not a fan or data is invalid"]))
                return
            }

            if data["powerPoints"] == nil {
                // Add powerPoints field if it doesn't exist
                userRef.updateData(["powerPoints": 0]) { error in
                    if let error = error {
                        print("Error adding powerPoints field: \(error.localizedDescription)")
                    } else {
                        print("Successfully initialized powerPoints field for fan user.")
                    }
                    completion(error)
                }
            } else {
                completion(nil) // powerPoints field already exists
            }
        }
    }

    static func updateUserPowerPoints(by points: Int, completion: @escaping (Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)

        userRef.getDocument { snapshot, error in
            if let error = error {
                completion(error)
                return
            }

            guard let data = snapshot?.data(),
                  let userType = data["userType"] as? String,
                  userType == "Fan" else {
                completion(NSError(domain: "Firestore", code: 0, userInfo: [NSLocalizedDescriptionKey: "User is not a fan or data is invalid"]))
                return
            }

            userRef.updateData([
                "powerPoints": FieldValue.increment(Int64(points))
            ]) { error in
                if let error = error {
                    print("Error updating power points: \(error.localizedDescription)")
                } else {
                    print("Successfully updated power points by \(points).")
                }
                completion(error)
            }
        }
    }

    static func fetchUserPowerPoints(completion: @escaping (Int?, Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(nil, NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)

        userRef.getDocument { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let data = snapshot?.data(),
                  let powerPoints = data["powerPoints"] as? Int else {
                completion(nil, NSError(domain: "Firestore", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid power points data"]))
                return
            }

            completion(powerPoints, nil)
        }
    }
    static func deleteWorkout(workoutTitle: String, completion: @escaping (Error?) -> Void) {
            let db = Firestore.firestore()
            db.collection("workouts").whereField("title", isEqualTo: workoutTitle).getDocuments { snapshot, error in
                if let error = error {
                    print("Error finding workout to delete: \(error.localizedDescription)")
                    completion(error)
                    return
                }

                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    print("No workout found with the title \(workoutTitle).")
                    completion(nil)
                    return
                }

                for document in documents {
                    document.reference.delete { error in
                        if let error = error {
                            print("Error deleting workout: \(error.localizedDescription)")
                        } else {
                            print("Workout \(workoutTitle) deleted successfully.")
                        }
                        completion(error)
                    }
                }
            }
        }
}
