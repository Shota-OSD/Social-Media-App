import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'topic_posts_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClassFlowHome extends StatefulWidget {
  const ClassFlowHome({super.key, required this.auth});
  final FirebaseAuth auth;

  @override
  State<ClassFlowHome> createState() => _ClassFlowHomeState();
}

class _ClassFlowHomeState extends State<ClassFlowHome> {
  List<String> topics = [];

  @override
  void initState() {
    super.initState();
    fetchTopics();
  }

  Future<void> fetchTopics() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('topics').get();

      for (var doc in querySnapshot.docs) {
        topics.add(doc.id);
      }
      print(topics);
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching topics: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
            auth: widget.auth,
          ),
          SizedBox(
            height: 20,
          ),
          TopicBoard(
            title: 'Science Topic Board',
            description:
                'Here you can find resources, discussions, and announcements related to science topics.',
            auth: widget.auth,
            colorTheme: Colors.lightBlue,
          ),
          SizedBox(
            height: 20,
          ),
          TopicBoard(
            title: 'History Topic Board',
            description:
                'Here you can find resources, discussions, and announcements related to history topics.',
            auth: widget.auth,
            colorTheme: Colors.brown,
          ),
          SizedBox(
            height: 20,
          ),
          TopicBoard(
            title: 'English Topic Board',
            description:
                'Here you can find resources, discussions, and announcements related to english topics.',
            auth: widget.auth,
            colorTheme: Colors.greenAccent,
          ),
          TopicBoard(
            title: 'Art Topic Board',
            description:
                'Here you can share your art, and interact with others!',
            colorTheme: Color.fromARGB(255, 224, 202, 0),
            auth: widget.auth,
          ),
          TopicBoard(
            title: 'General Board',
            description: 'Here you can discuss any general topics!',
            auth: widget.auth,
            colorTheme: Colors.deepPurpleAccent,
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
  final FirebaseAuth auth;
  const TopicBoard(
      {super.key,
      required this.title,
      required this.description,
      required this.colorTheme,
      required this.auth});

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
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          TopicRoom(topicID: title, auth: auth)));
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
