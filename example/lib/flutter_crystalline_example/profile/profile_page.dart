import 'package:example/flutter_crystalline_example/profile/profile_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crystalline/flutter_crystalline.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('profile')),
      body: ListView(
        children: [
          ElevatedButton(
            child: Text('Update profile'),
            onPressed: () {
              profileStore.update();
            },
          ),
          DataBuilder(
            data: profileStore,
            listen: true,
            builder: (context, _) {
              print('updating profile page widget');
              return Text(profileStore.toString());
            },
          ),
        ],
      ),
    );
  }
}
