# Card Swiper - A Flutter Flashcard Application

Card Swiper is a mobile application built with Flutter that allows users to create, manage, and study digital flashcard sets. It features a clean user interface, Firebase integration for backend services, and an interactive, swipeable card viewer for an engaging study experience.

## Features

* **User Authentication**: Secure sign-in and sign-out functionality using Firebase Authentication.
* **Create Flashcard Sets**: Users can create new flashcard sets, each with a custom title.
* **Add & Manage Cards**: Dynamically add or remove question-and-answer pairs within a set.
* **Cloud Storage**: All flashcard sets are saved to Firestore and linked to the user's account, ensuring data is synced and persistent.
* **Interactive Study Mode**: Practice your sets using a smooth, swipeable card interface powered by the `appinio_swiper` package.
* **Flip Animation**: Tap any card to flip it over and reveal the answer, complete with a clean animation.

## Tech Stack & Core Dependencies

* **Framework**: Flutter
* **Backend**: Firebase
    * **Authentication**: Firebase Auth
    * **Database**: Cloud Firestore
* **State Management**: `StatefulWidget` (`setState`)
* **Key Packages**:
    * `firebase_core`: To initialize Firebase.
    * `cloud_firestore`: For database interaction.
    * `firebase_auth`: For user authentication.
    * `appinio_swiper`: For the interactive card swiping UI.
    * `fluttertoast`: For simple, non-intrusive notifications.

## Project Structure

```
lib/
├── main.dart          # App entry point, Firebase initialization
├── login.dart         # User authentication screen
├── home_app.dart      # Main screen, lists all user-created flashcard sets
├── input.dart         # UI to create and edit flashcard sets
└── cardviewer.dart    # The interactive card swiper screen for studying
```

## Firestore Database Structure

The data is structured in Firestore to be user-specific and scalable.

* **Root Collection**: Each user's data is stored in a top-level collection named after their Firebase **User ID (uid)**.
* **Set Documents**: Inside the user's collection, each document represents a single flashcard set.
    * `title` (String): The name of the flashcard set.
    * `createdAt` (Timestamp): Server timestamp for sorting.
    * `cardCount` (Number): The total number of cards in the set.
* **Cards Subcollection**: Each set document contains a subcollection named `cards`.
    * **Card Documents**: Each document within this subcollection is a single flashcard.
        * `question` (String): The question text.
        * `answer` (String): The answer text.

**Example:**

```
/2T5pYqN3X... (user.uid collection)
└── 5aFgHj... (set document ID)
    ├── title: "History 101"
    ├── createdAt: "September 06, 2025 at 1:40:15 PM UTC+5:30"
    ├── cardCount: 2
    └── cards (subcollection)
        ├── 8jKlM... (card document ID)
        │   ├── question: "When did WWII end?"
        │   └── answer: "1945"
        └── 9nOpQ... (card document ID)
            ├── question: "Who was the first US President?"
            └── answer: "George Washington"
```



## Screenshots

![login](https://github.com/hardik1812/flashcard/blob/main/Assets/animations/Screenshot_20250906-134336.png)
![Signup](https://github.com/hardik1812/flashcard/blob/main/Assets/animations/Screenshot_20250906-134339.png)
![Home](https://github.com/hardik1812/flashcard/blob/main/Assets/animations/Screenshot_20250906-134702.png)
![Add_card](https://github.com/hardik1812/flashcard/blob/main/Assets/animations/Screenshot_20250906-134706.png)
![Card_view](https://github.com/hardik1812/flashcard/blob/main/Assets/animations/Screenshot_20250906-134713.png)
![Card_view](https://github.com/hardik1812/flashcard/blob/main/Assets/animations/Screenshot_20250906-134715.png)
