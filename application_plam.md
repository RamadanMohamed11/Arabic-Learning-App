# **Flutter Arabic Learning App: Project Plan & To-Do List**

This document outlines a complete plan for developing a Flutter mobile application to teach the Arabic alphabet and letter writing to children and beginners.

### **Phase 1: Project Setup & Foundation**

This phase involves setting up the project environment, folder structure, and basic assets.

* \[ \] **1\. Initialize Flutter Project:**  
  * Create a new Flutter project: flutter create arabic\_learning\_app.  
* \[ \] **2\. Add Dependencies:**  
  * Open pubspec.yaml and add the following packages:  
    * audioplayers: For playing the pronunciation of letters.  
    * provider or flutter\_riverpod: For state management. We will plan with Provider for simplicity.  
    * google\_fonts: For beautiful, child-friendly typography.  
* \[ \] **3\. Create Project Structure:**  
  * Inside the lib folder, create the following directories to keep the code organized:  
    * /assets: To store images, audio files, and fonts.  
      * /assets/audio: For letter sounds.  
      * /assets/images: For letter-related images and UI elements.  
    * /constants: For application-wide constants like colors, themes, and letter data.  
    * /models: For data structures (e.g., a Letter object).  
    * /providers: For state management logic.  
    * /screens: For the main pages/views of the app.  
    * /widgets: For reusable custom UI components.  
* \[ \] **4\. Prepare Assets:**  
  * **Audio:** Record or obtain .mp3 files for the pronunciation of each of the 28 Arabic letters. Place them in /assets/audio.  
  * **Images:** Find or create a simple, engaging image for each letter (e.g., "أ" \-\> "أسد"  
    [Image of a cartoon lion](https://encrypted-tbn2.gstatic.com/licensed-image?q=tbn:ANd9GcQfgobtLzhZIcRvo1aLz59zDMCsF4wbNSOMDTVpIAs3oyj7y4hyDne0GhBxbeE7w38GOVkNSIwsRRlpt73eoQF3vdM0BBc3hVKElGWhENWUxARS478)  
    ). Place them in /assets/images.  
  * **Configure pubspec.yaml:** Declare the assets/ folder in the flutter section of your pubspec.yaml file so the app can use these files.  
* \[ \] **5\. Define Data Model:**  
  * Create a file lib/models/letter\_model.dart.  
  * Define a Letter class to hold all information related to an alphabet character.

class Letter {  
  final String id;  
  final String character; // e.g., "أ"  
  final String name; // e.g., "Alif"  
  final String audioPath; // e.g., "audio/alif.mp3"  
  final String imagePath; // e.g., "images/lion.png"

  Letter({  
    required this.id,  
    required this.character,  
    required this.name,  
    required this.audioPath,  
    required this.imagePath,  
  });  
}

* \[ \] **6\. Create App Constants:**  
  * In lib/constants/, create a file to hold the list of all letters using the Letter model. This will be your app's "database."

### **Phase 2: Building the UI & Core Features**

This phase focuses on creating the visual components and user interactions.

* \[ \] **1\. Setup Main & Home Screen:**  
  * Modify main.dart to set up the app's theme, define routes, and wrap the app with a ChangeNotifierProvider for state management.  
  * Create lib/screens/home\_screen.dart.  
  * **Widget Description:** This screen will be the main menu. Design it with two large, colorful, and tappable buttons:  
    * A MenuButton widget for "Learn The Alphabet" that navigates to the Alphabet Screen.  
    * A MenuButton widget for "Practice Writing" that navigates to the Tracing Screen.  
    * Use a Scaffold with a Column or GridView and custom-designed buttons.  
* \[ \] **2\. Build the Alphabet Learning Screen:**  
  * Create lib/screens/alphabet\_screen.dart.  
  * **Widget Description:** This screen will display all the letters in a grid.  
    * Use a Scaffold with an AppBar.  
    * The body will be a GridView.builder that iterates through your list of Letter objects.  
    * **Create a LetterCard widget (lib/widgets/letter\_card.dart):**  
      * This will be a Card or a stylized Container.  
      * Inside, display the Letter.character prominently.  
      * Add the Letter.imagePath as a small illustration.  
      * Wrap it in an InkWell or GestureDetector.  
      * On tap, use the audioplayers package to play the sound from Letter.audioPath.  
* \[ \] **3\. Build the Letter Tracing Screen:**  
  * This is the most complex part. Create lib/screens/tracing\_screen.dart.  
  * **Widget Description:** The screen will be divided into a drawing area and a control area.  
    * Use a Scaffold, a Column, and a Stack widget.  
    * **The Stack (Drawing Area):**  
      1. **Bottom Layer:** A Center widget containing a large, semi-transparent Text widget displaying the letter to be traced. This is the visual guide.  
      2. **Top Layer:** A custom drawing canvas.  
    * **Create a DrawingCanvas widget (lib/widgets/drawing\_canvas.dart):**  
      * This will be a stateful widget using CustomPainter and GestureDetector.  
      * It will track a list of points (List\<Offset?\>) that the user draws.  
      * onPanStart, onPanUpdate, onPanEnd will update this list of points.  
      * The CustomPainter will draw lines connecting the points in the list.  
    * **Control Area:**  
      * A row of IconButtons or ElevatedButtons below the canvas.  
      * **"Check" Button:** Triggers the writing validation logic.  
      * **"Clear" Button:** Clears the list of points and redraws the canvas.  
      * **"Next Letter" Button:** To move to the next letter in the alphabet.

### **Phase 3: State Management & Business Logic**

This phase involves managing the app's state and implementing the core functionality.

* \[ \] **1\. Create Tracing Provider:**  
  * Create lib/providers/tracing\_provider.dart.  
  * This class will extend ChangeNotifier.  
  * **Responsibilities:**  
    * Hold the current letter being traced.  
    * Hold the list of points (List\<Offset?\>) for the user's drawing.  
    * Contain the logic to compare the user's drawing with a correct path.  
    * Hold the result state (e.g., isCorrect, isPending, isWrong).  
    * Methods:  
      * startDrawing(Offset point)  
      * updateDrawing(Offset point)  
      * endDrawing()  
      * clearDrawing()  
      * checkDrawing()  
      * loadNextLetter()  
* \[ \] **2\. Implement Writing Validation Logic:**  
  * This is challenging. A practical approach is point-based sampling.  
  * **Plan:**  
    1. For each letter, manually define a "golden" or correct path (a List\<Offset\>). This is tedious but necessary for accuracy. You can add this to your Letter model.  
    2. When the "Check" button is pressed, the checkDrawing() method in your provider will execute.  
    3. The logic will check if a high percentage (e.g., \>85%) of the user's drawn points are within a certain small distance of any point on the "golden" path.  
    4. It should also check if the drawing starts and ends near the correct start/end points.  
  * Update the UI based on the result: show a "Correct\!" or "Try Again\!" message, play a success/failure sound, and animate the result.  
* \[ \] **3\. Connect UI to Provider:**  
  * In tracing\_screen.dart, wrap the main widget with a Consumer\<TracingProvider\>.  
  * Call provider methods from the UI buttons (e.g., onPressed: () \=\> provider.clearDrawing()).  
  * Pass the list of points from the provider to your DrawingCanvas widget to be painted.

### **Phase 4: Polishing & Deployment**

* \[ \] **1\. Add Animations & Sound Effects:**  
  * Animate the feedback on the tracing screen (e.g., a checkmark that scales up).  
  * Add sound effects for button clicks, correct answers, and wrong answers to make the app more engaging for children.  
* \[ \] **2\. Test on Devices:**  
  * Test the app on both Android and iOS physical devices of different screen sizes to ensure the layout is responsive and touch interactions are smooth.  
* \[ \] **3\. App Icon & Splash Screen:**  
  * Design a unique app icon.  
  * Add a native splash screen to provide a professional launch experience.  
* \[ \] **4\. Prepare for Release:**  
  * Follow the Flutter documentation to build and sign your app for release on the Google Play Store and Apple App Store.