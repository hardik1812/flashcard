import 'package:cardswipper/input.dart';
import 'package:cardswipper/login.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cardswipper/cardviewer.dart';

// Assuming these are your page files



class HomeApp extends StatelessWidget {
  const HomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current user safely.
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Column(
        children: [
          // Top purple header section
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF501E91),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.menu, color: Colors.white, size: 35),
                          GestureDetector(
                            onTap: () {
                              Fluttertoast.showToast(msg: 'Double tap to sign out');
                            },
                            onDoubleTap: () async {
                              await FirebaseAuth.instance.signOut();
                              // Check if the widget is still in the tree before navigating.
                              if (!context.mounted) return;
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const Login()),
                              );
                              Fluttertoast.showToast(msg: 'Signed out');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF0F0),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                user?.displayName?.toUpperCase() ?? 'GUEST',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Text(
                        'Flashcards Maker',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Pick a set to practice',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Bottom white section with the list of cards
          Expanded(
            child: Container(
              width: double.infinity,
              color: const Color(0xFFFFF0F0),
              child: Column(
                children: [
                  // "New Set" button
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FlashcardCreatorPage()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle, color: Color(0xFFEF9B87), size: 30),
                          SizedBox(width: 10),
                          Text(
                            'Create a New Set',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // List of existing sets
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      // Use the safe 'user' object here. If null, the stream will be null.
                      stream: user == null
                          ? null
                          : FirebaseFirestore.instance
                              .collection(user.uid)
                              .orderBy('createdAt', descending: true)
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (user == null) {
                          return const Center(child: Text("Please log in to see your sets."));
                        }
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return const Center(child: Text('Something went wrong.'));
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text('No flashcard sets found.'));
                        }

                        final flashcardSets = snapshot.data!.docs;

                        return ListView.builder(
                          padding: const EdgeInsets.only(top: 10),
                          itemCount: flashcardSets.length,
                          itemBuilder: (context, index) {
                            final setDoc = flashcardSets[index];
                            final setData = setDoc.data() as Map<String, dynamic>;
                            final setTitle = setData['title'] ?? 'No Title';
                            final cardCount = setData['cardCount'] ?? 0;

                            return GestureDetector(
                              // ### FIX STARTS HERE ###
                              onTap: () async {
                                // 1. Fetch the 'cards' subcollection for the tapped set.
                                final cardsSnapshot = await FirebaseFirestore.instance
                                    .collection(user.uid)
                                    .doc(setDoc.id)
                                    .collection('cards')
                                    .get();

                                // 2. Convert the documents into the List<Map<String, String>> format
                                //    that FlashcardShowPage expects.
                                final List<Map<String, String>> flashcardsData =
                                    cardsSnapshot.docs.map((doc) {
                                  final data = doc.data();
                                  return {
                                    'question': data['question']?.toString() ?? '',
                                    'answer': data['answer']?.toString() ?? '',
                                  };
                                }).toList();

                                // 3. Navigate to the viewer page with the fetched data.
                                //    Check if the widget is still mounted before navigating.
                                if (!context.mounted) return;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FlashcardShowPage(
                                      setTitle: setTitle,
                                      flashcardsData: flashcardsData,
                                    ),
                                  ),
                                );
                              },
                              // ### FIX ENDS HERE ###
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          setTitle,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '$cardCount Cards',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Icon(
                                      Icons.play_circle_outline_rounded,
                                      color: Color(0xFF501E91),
                                      size: 30,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
