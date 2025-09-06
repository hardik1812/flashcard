import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

InputDecoration inputDecor({required String labelText}) {
  return InputDecoration(
    labelText: labelText,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
  );
}

class FlashcardPairControllers {
  final TextEditingController questionController;
  final TextEditingController answerController;

  FlashcardPairControllers()
      : questionController = TextEditingController(),
        answerController = TextEditingController();

  void dispose() {
    questionController.dispose();
    answerController.dispose();
  }
}

class FlashcardCreatorPage extends StatefulWidget {
  const FlashcardCreatorPage({super.key});

  @override
  State<FlashcardCreatorPage> createState() => _FlashcardCreatorPageState();
}

class _FlashcardCreatorPageState extends State<FlashcardCreatorPage> {
  final TextEditingController _titleController = TextEditingController();
  final List<FlashcardPairControllers> _cardControllers = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _cardControllers.add(FlashcardPairControllers());
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (var controllerPair in _cardControllers) {
      controllerPair.dispose();
    }
    super.dispose();
  }

  void _addCardPair() {
    setState(() {
      _cardControllers.add(FlashcardPairControllers());
    });
  }

  void _removeCardPair(int index) {
    if (_cardControllers.length > 1) {
      setState(() {
        _cardControllers[index].dispose();
        _cardControllers.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You must have at least one card."),
          backgroundColor: Colors.orangeAccent,
        ),
      );
    }
  }

  Future<void> _createFlashcards() async {
    if (_isSaving) return;

    final String title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title for your flashcard set.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final List<Map<String, String>> flashcards = [];
    for (var controllerPair in _cardControllers) {
      final question = controllerPair.questionController.text.trim();
      final answer = controllerPair.answerController.text.trim();
      if (question.isNotEmpty && answer.isNotEmpty) {
        flashcards.add({'question': question, 'answer': answer});
      }
    }

    if (flashcards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill out at least one question and answer.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();
      final setDocumentRef = firestore.collection('${FirebaseAuth.instance.currentUser?.uid}').doc();

      batch.set(setDocumentRef, {
        'title': title,
        'createdAt': FieldValue.serverTimestamp(),
        'cardCount': flashcards.length,
      });

      for (final cardData in flashcards) {
        final cardDocumentRef = setDocumentRef.collection('cards').doc();
        batch.set(cardDocumentRef, cardData);
      }

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"$title" flashcard set created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      _titleController.clear();
      setState(() {
        for (var controller in _cardControllers) {
          controller.dispose();
        }
        _cardControllers.clear();
        _cardControllers.add(FlashcardPairControllers());
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcard Creator'),
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: TextField(
                controller: _titleController,
                decoration: inputDecor(labelText: 'Flashcard Set Title'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 100),
                itemCount: _cardControllers.length,
                itemBuilder: (context, index) {
                  return Card(
                    key: ValueKey(_cardControllers[index]),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Card ${index + 1}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.redAccent),
                                onPressed: () => _removeCardPair(index),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller:
                                _cardControllers[index].questionController,
                            decoration: inputDecor(labelText: 'Question'),
                            minLines: 2,
                            maxLines: 4,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller:
                                _cardControllers[index].answerController,
                            decoration: inputDecor(labelText: 'Answer'),
                            minLines: 2,
                            maxLines: 4,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _createFlashcards,
                  icon: _isSaving
                      ? Container(
                          width: 24,
                          height: 24,
                          padding: const EdgeInsets.all(2.0),
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isSaving ? 'Saving...' : 'Create Flashcards'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF9B87),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCardPair,
        tooltip: 'Add Card',
        hoverColor: const Color(0xFFEF9B87),
        backgroundColor: const Color(0xFFEF9B87),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}