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
        title: WhenDataBinder(
          data: homeStore.title,
          onValue: (context, data) => Text(data.value),
          onOperate: (context, data) => const SizedBox(
            height: 14,
            width: 14,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          WhenDataBinder(
            data: homeStore.number,
            onValue: (context, data) => SizedBox(
              width: 54,
              height: 54,
              child: Center(
                child: Text('${data.value}'),
              ),
            ),
            onOperate: (context, data) => const SizedBox(
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
            WhenDataBinder(
              data: homeStore.number,
              onValue: (context, data) => SizedBox(
                width: 54,
                height: 54,
                child: Center(
                  child: Text('${data.value}'),
                ),
              ),
              onOperate: (context, data) => const SizedBox(
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
            WhenDataBinder(
              data: homeStore.number,
              onValue: (context, data) => SizedBox(
                width: 54,
                height: 54,
                child: Center(
                  child: Text('${data.value}'),
                ),
              ),
              onOperate: (context, data) => const SizedBox(
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
            DataBuilder(
              data: homeStore,
              builder: (context, _) {
                print('home store being rebuilt');
                if (homeStore.isOperating) {
                  return const Text(
                    'on of required data in Home Store'
                    ' has null value aka not available',
                  );
                }
                return const Text('home store available');
              },
            ),
            WhenDataBinder(
              data: homeStore,
              onValue: (context, _) => const Text('home store available'),
              onOperate: (context, _) => const Text(
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
