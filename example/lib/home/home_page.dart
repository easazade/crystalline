import 'package:example/home/home_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crystalline/flutter_crystalline.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: WhenDataBuilder(
          data: homeStore.title,
          onValue: (context, data) => Text(data.value),
          onAnyOperation: (context, data) => const SizedBox(
            height: 14,
            width: 14,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          WhenDataBuilder(
            data: homeStore.number,
            onValue: (context, data) => SizedBox(
              width: 54,
              height: 54,
              child: Center(
                child: Text('${data.value}'),
              ),
            ),
            onAnyOperation: (context, data) => const SizedBox(
              height: 54,
              width: 54,
              child: Row(
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              child: const Text('Change Title'),
              onPressed: () => homeStore.changeTitle(),
            ),
            ElevatedButton(
              child: const Text('Change Number'),
              onPressed: () => homeStore.changeNumber(),
            ),
            WhenDataBuilder(
              data: homeStore.number,
              onValue: (context, data) => SizedBox(
                width: 54,
                height: 54,
                child: Center(
                  child: Text('${data.value}'),
                ),
              ),
              onAnyOperation: (context, data) => const SizedBox(
                height: 54,
                width: 54,
                child: Row(
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            WhenDataBuilder(
              data: homeStore.number,
              onValue: (context, data) => SizedBox(
                width: 54,
                height: 54,
                child: Center(
                  child: Text('${data.value}'),
                ),
              ),
              onAnyOperation: (context, data) => const SizedBox(
                height: 54,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Updating '),
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.yellow,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Builder(
              builder: (context) {
                print('home store being rebuilt');
                if (homeStore.isAnyOperation) {
                  return const Text(
                    'on of required data in Home Store'
                    ' has null value aka not available',
                  );
                }
                return const Text('home store available');
              },
            ),
            WhenDataBuilder(
              data: homeStore,
              onValue: (context, _) => const Text('home store available'),
              onAnyOperation: (context, _) => const Text(
                'on of required data in Home Store'
                ' has null value aka not available',
              ),
              onFailure: (context, _) => Text(homeStore.failure.message),
            ),
          ],
        ),
      ),
    );
  }
}
