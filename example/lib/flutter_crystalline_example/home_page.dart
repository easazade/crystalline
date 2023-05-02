import 'package:example/flutter_crystalline_example/home_store.dart';
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
        /// building title
        title: WhenDataBuilder<String>(
          listen: true,
          data: homeStore.title,
          onAvailable: (context, data) => Text(data.value),
          onLoading: (context, data) => SizedBox(
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
            listen: true,
            onAvailable: (context, data) => SizedBox(
              width: 54,
              height: 54,
              child: Center(
                child: Text('${data.value}'),
              ),
            ),
            onLoading: (context, data) => SizedBox(
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
              child: Text('Change Title'),
              onPressed: () {
                homeStore.changeTitle();
              },
            ),
            ElevatedButton(
              child: Text('Change Number'),
              onPressed: () {
                homeStore.changeNumber();
              },
            ),
            WhenDataBuilder(
              data: homeStore.number,
              listen: true,
              onAvailable: (context, data) => SizedBox(
                width: 54,
                height: 54,
                child: Center(
                  child: Text('${data.value}'),
                ),
              ),
              onLoading: (context, data) => SizedBox(
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
              listen: true,
              onAvailable: (context, data) => SizedBox(
                width: 54,
                height: 54,
                child: Center(
                  child: Text('${data.value}'),
                ),
              ),
              onLoading: (context, data) => SizedBox(
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
              listen: true,
              builder: (context, _) {
                print('home store being rebuilt');
                if (homeStore.isLoading) {
                  return Text(
                    'on of required data in Home Store'
                    ' has null value aka not available',
                  );
                }
                return Text('home store available');
              },
            ),
            WhenDataBuilder(
              listen: true,
              data: homeStore,
              onAvailable: (context, _) => Text('home store available'),
              onLoading: (context, _) => Text(
                'on of required data in Home Store'
                ' has null value aka not available',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
