import 'package:end2end_messaging/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NoInternetPage extends ConsumerStatefulWidget {
  const NoInternetPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NoInternetPageState();
}

class _NoInternetPageState extends ConsumerState<NoInternetPage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CustomColors.black,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: Color(0xff1c1c1c),
        middle: Text(
          'No Internet',
          style: TextStyle(color: Colors.white),
        ),
      ),
      child: Center(
        child: Column(
          children: [
            CupertinoButton(
              onPressed: () {},
              child: const Text(
                'selamlars',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
