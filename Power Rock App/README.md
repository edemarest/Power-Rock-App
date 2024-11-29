
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

### 1. **Implement Missing Screens**
   - **EditWorkoutViewController**: **Star** users will be able to edit their workout details from the **WorkoutDetails** screen.
   - **DoWorkoutViewController**: **Star** users will be able to complete the workout, checking off exercises as they go from the **WorkoutDetails** screen.
   - **CompletedWorkoutViewController**: Displays the total **fan power** gained by the user after completing the workout, with a button to navigate back to the home screen.
   
### 2. **Refine Input Verification & Add Cover Photo**
   - Add band's cover photo to their workouts (right now nothing is done with the photo)
   - Make sure all input fields are validated before user moves on to next screen
   - Make sure all image uploads work and fall back on a default image

### 3. **Add Fan Power Logic**
   - **Stars**:  
     - Track the number of times each workout is created and calculate the band's total fan power by adding up the values from all workouts created by the same band.
   - **Fans**:  
     - Track total power by each workout completed. The power for each workout is calculated as **difficulty x 100**.
   
### 4. **Stylize All Screens**
   - Apply consistent styling across all screens to match the vibe of the app.  
   - Incorporate images, where applicable, to enhance the user experience.

### 5. **Remove Repeated Functions/Logic**
   - Clean up the code by removing any repeated functions or logic.  
   - Ensure the structure of each view is consistent, making the code easier to maintain.
