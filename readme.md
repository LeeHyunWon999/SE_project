# Software Engineering Project
## Team 5 : Lee, Hong, Lam, Joffrey

> ### User Story
> - Gil Dong is an office worker.   
> - He listens to the alarm in the morning, but sometimes he is late because he turns it off and goes to bed right away. To solve this, he is looking for a sure way to wake up on a wake-up call.   
> - Gildong's eyes are blurry due to frequent work. That's why he prefers screens that reduce eye strain.   
> - Gil-dong uses a business cell phone and a personal cell phone separately. However, he wants to see the schedule on both phones at the same time.   
> - Gildong is busy with work, so he prefers to operate other apps through widgets. He wants to manipulate it that way, too, if there is an app to do.   
> - Since Gil-dong frequently collaborates with other co-workers around him, he wants the ability to easily share his completion status with people around him.   
-------------------

> ### Mandatory Requirements
> 1. Architecture
>    - Task Hierarchy
>    - Task Creation
>    - Task Attributes : Prioriy, Place, Dependency(Association), Tag, etc.
>    - Drag & Drop Interface
>    - Progress Tracking
> 2. Additional Task Elements
>    - Task Description
>    - Hyperlinks
>    - File Attachments
>    - File Preview
> 3. Schedule Management
>    - Task Due Dates
>    - Setting Due Dates - Calander View & Clock Interface
>    - Setting Due Dates - Text Input for Dates
>    - Today's Work and This Week's Work
> 4. Notifications
>    - Task Notifications
>    - Smart Notification System
>    - Notification Variability
>    - Task Categorization
> 5. Repeating Task
>    - Repeating Task Creation
>    - Repetition Frequency
>    - Custom Repetition
>    - Task Modification
>    - Task Instances
> 6. Display
>    - Calendar View
>    - Priority-Based List View
>    - Due Date-Based List View
>    - Sub-Task Hierarchy Display
> 7. Supporting Task Performance
>    - Task Completion Points
>    - Performance Calculation
>    - Point Deduction for Missed Deadlines
>    - Points Visualization
--------------------------
> ### Custom Requirements
> 1. Complicated Unlocking Alarm Mode
> 2. Themes(light, dark, green, etc.)
> 3. Login & Database(using Firebase)
> 4. Widget
> 5. Share

**flutter example**
```flutter
Widget _buildRow(WordPair pair) {
  return ListTile(
    title: Text(
      pair.asPascalCase,
      style: _biggerFont,
    ),
  );
}
```

[Flutter Docs](http://www.google.com](https://docs.flutter.dev/)https://docs.flutter.dev/)
