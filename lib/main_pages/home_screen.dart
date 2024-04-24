import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../util/index.dart';

class ClassFlowHome extends StatefulWidget {
  const ClassFlowHome({super.key});

  @override
  State<ClassFlowHome> createState() => _ClassFlowHomeState();
}

class _ClassFlowHomeState extends State<ClassFlowHome> {
  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(
            child: Column(children: [
          SizedBox(
            height: 20,
          ),
          TopicBoard(
            title: 'Math Topic Board',
            description:
                'Here you can find resources, discussions, and announcements related to math topics.',
            colorTheme: Colors.deepOrange,
          ),
          SizedBox(
            height: 20,
          ),
          TopicBoard(
            title: 'Science Topic Board',
            description:
                'Here you can find resources, discussions, and announcements related to science topics.',
            colorTheme: Colors.lightBlue,
          ),
          SizedBox(
            height: 20,
          ),
          TopicBoard(
            title: 'History Topic Board',
            description:
                'Here you can find resources, discussions, and announcements related to history topics.',
            colorTheme: Colors.brown,
          ),
          SizedBox(
            height: 20,
          ),
          TopicBoard(
            title: 'English Topic Board',
            description:
                'Here you can find resources, discussions, and announcements related to english topics.',
            colorTheme: Colors.greenAccent,
          ),
        ])),
      ),
    );
  }
}

class TopicBoard extends StatelessWidget {
  final String title;
  final String description;
  final Color colorTheme;
  const TopicBoard(
      {super.key,
      required this.title,
      required this.description,
      required this.colorTheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: colorTheme,
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            'Welcome to the $title!',
            style: const TextStyle(
              fontSize: 18.0,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12.0),
          Text(
            description,
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 24.0),
          ElevatedButton(
            onPressed: () {
              // Implement action when button is pressed
            },
            style: ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              backgroundColor: colorTheme,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text(
              'Open Topic Board',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
