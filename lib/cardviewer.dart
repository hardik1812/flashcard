import 'package:flutter/material.dart';
import 'package:appinio_swiper/appinio_swiper.dart';
import 'dart:math';

// A simple data model for a flashcard, created from a Map
class Flashcard {
  final String question;
  final String answer;

  Flashcard({required this.question, required this.answer});

  factory Flashcard.fromMap(Map<String, String> map) {
    return Flashcard(
      question: map['question'] ?? 'No question',
      answer: map['answer'] ?? 'No answer',
    );
  }
}

// The flashcard swiper page that accepts a list of card data
class FlashcardShowPage extends StatefulWidget {
  final List<Map<String, String>> flashcardsData;
  final String setTitle;

  const FlashcardShowPage({
    super.key,
    required this.flashcardsData,
    required this.setTitle,
  });

  @override
  State<FlashcardShowPage> createState() => _FlashcardShowPageState();
}

class _FlashcardShowPageState extends State<FlashcardShowPage> {
  late final List<Flashcard> _flashcards;

  @override
  void initState() {
    super.initState();
    _flashcards = widget.flashcardsData
        .map((data) => Flashcard.fromMap(data))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.setTitle),
      ),
      body: _flashcards.isEmpty
          ? const Center(child: Text('No cards found in this set.'))
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: AppinioSwiper(
                    // Set loop to true to make cards reappear at the back
                    loop: true,
                    cardCount: _flashcards.length,
                    cardBuilder: (BuildContext context, int index) {
                      return FlashcardContent(flashcard: _flashcards[index]);
                    },
                  ),
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'Swipe left or right to go to the next card. Tap to flip.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
    );
  }
}

// The widget for the content of a single flashcard, handling the flip animation
class FlashcardContent extends StatefulWidget {
  final Flashcard flashcard;

  const FlashcardContent({super.key, required this.flashcard});

  @override
  State<FlashcardContent> createState() => _FlashcardContentState();
}

class _FlashcardContentState extends State<FlashcardContent> {
  bool _isShowingQuestion = true;

  void _flipCard() {
    setState(() {
      _isShowingQuestion = !_isShowingQuestion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flipCard,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [Colors.deepOrange.shade200, Colors.orange.shade300],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
                  return AnimatedBuilder(
                    animation: rotateAnim,
                    child: child,
                    builder: (context, child) {
                      final isUnder = (ValueKey(_isShowingQuestion) != child!.key);
                      var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
                      tilt = isUnder ? -tilt : tilt;
                      final value = isUnder ? min(rotateAnim.value, pi / 2) : rotateAnim.value;
                      return Transform(
                        transform: Matrix4.rotationY(value)..setEntry(3, 0, tilt),
                        alignment: Alignment.center,
                        child: child,
                      );
                    },
                  );
                },
                child: _isShowingQuestion
                    ? _buildCardSide(
                        key: const ValueKey(true),
                        label: 'Question',
                        text: widget.flashcard.question,
                      )
                    : _buildCardSide(
                        key: const ValueKey(false),
                        label: 'Answer',
                        text: widget.flashcard.answer,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardSide({
    required Key key,
    required String label,
    required String text,
  }) {
    return Container(
      key: key,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}