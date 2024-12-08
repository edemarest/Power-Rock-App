
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

### Files to Be Implemented:

1. **EditWorkoutViewController.swift**  
   - **Role**: This screen allows **Star** users to edit the details of a workout.  
   - **Connections**:  
     - Accessible from **WorkoutDetails** for **Star** users to modify their created workouts.

2. **DoWorkoutViewController.swift**  
   - **Role**: Allows **Star** users to start a workout and track their progress.  
   - **Connections**:  
     - Displays the workout sets with exercises that can be checked off as the user completes them.  
     - Accessible from **WorkoutDetails** for **Star** users.

3. **CompletedWorkoutViewController.swift**  
   - **Role**: This screen shows the total **fan power** gained after completing a workout, along with the ability to navigate back to the home screen.  
   - **Connections**:  
     - Shows the total power gained by the user for completing a workout.  
     - Contains a button to go back to the home screen.  
     - Accessible from **DoWorkoutViewController** when a workout is completed.

---

## TODO List
   
### 1. **Refine Input Verification & Add Cover Photo**
   - Add band's cover photo to their workouts (right now nothing is done with the photo)
   - Make sure all input fields are validated before user moves on to next screen
   - Make sure all image uploads work and fall back on a default image


