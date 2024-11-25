// lib/apple_app_template.dart
import 'package:flutter/material.dart';

class AppleAppTemplate extends StatelessWidget {
  const AppleAppTemplate({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apple App Template',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 16.0, color: Colors.grey),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 18.0),
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'My Tasks',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const CheckboxList(), // Include the checkbox list
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SecondScreen()),
                );
              },
              child: const Text('Go to Second Screen'),
            ),
          ],
        ),
      ),
    );
  }
}

class CheckboxList extends StatelessWidget {
  const CheckboxList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(5, (index) {
        return CheckboxListTile(
          title: Text('Task ${index + 1}'),
          value: false,
          onChanged: (bool? value) {},
        );
      }),
    );
  }
}

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Screen'),
        backgroundColor: Colors.blueAccent,
      ),
      body: const Center(
        child: Text(
          'This is the second screen.',
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
