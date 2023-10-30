import 'package:flutter/cupertino.dart';

class SpaceHelper {
  static Widget boslukHeight(BuildContext context, double deger) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * deger,
    );
  }

  static Widget boslukWidth(BuildContext context, double deger) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * deger,
    );
  }
}
