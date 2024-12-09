
# App Structure Overview

## File Structure and Interconnections

### Main Files:
1. **MainVC.swift**  
   - **Role**: This is the main entry point of the app where authentication is checked.  
   - **Connections**:  
     - Fetches user details from Firestore.  
     - Navigates to either **StarHomeViewController** or **FanHomeViewController** based on the user type (Star or Fan).
     - If the user is not authenticated, it navigates to **WelcomeViewController**.

2. **WelcomeViewController.swift**  
   - **Role**: The initial screen for unauthenticated users, where they can log in or register.  
   - **Connections**:  
     - Navigates to **LoginViewController** or **FanRegisterViewController** or **StarRegisterViewController** based on user action.

3. **StarHomeViewController.swift**  
   - **Role**: This is the home screen for **Star** users, where they can see and manage their workouts.  
   - **Connections**:  
     - Displays a list of **workouts** created by the user.  
     - Allows navigation to **CreateWorkoutViewController** for creating new workouts.  
     - Each workout cell leads to **WorkoutDetails** for more detailed information.

4. **FanHomeViewController.swift**  
   - **Role**: This is the home screen for **Fan** users, where they can browse and complete workouts.  
   - **Connections**:  
     - Displays a filtered list of workouts based on the genres of the user.  
     - Allows fans to tap a workout, leading them to **WorkoutDetails**.

5. **WorkoutDetails.swift**  
   - **Role**: Displays detailed information about a specific workout.  
   - **Connections**:  
     - Shows workout details like band name, genres, and sets.  
     - Allows **Star** users to edit the workout (navigate to **EditWorkoutViewController**).  
     - Allows **Fan** users to complete the workout (navigate to **DoWorkoutViewController**).
