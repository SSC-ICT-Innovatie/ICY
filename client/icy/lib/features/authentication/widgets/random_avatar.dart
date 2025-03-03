import 'package:flutter/cupertino.dart';
import 'package:forui/forui.dart';
import 'package:random_avatar/random_avatar.dart';

class RandomAvatarPick extends StatefulWidget {
  final GlobalKey<_RandomAvatarPickState> stateKey = GlobalKey();

  RandomAvatarPick({super.key});

  int get count => stateKey.currentState?.count ?? 0;

  @override
  State<RandomAvatarPick> createState() => _RandomAvatarPickState();
}

class _RandomAvatarPickState extends State<RandomAvatarPick> {
  int count = 0;

  void back() {
    setState(() {
      count--;
    });
  }

  void next() {
    setState(() {
      count++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      direction: Axis.horizontal,
      children: [
        FButton.icon(child: FIcon(FAssets.icons.chevronLeft), onPress: back),
        RandomAvatar(count.toString(), height: 60, width: 60),
        FButton.icon(child: FIcon(FAssets.icons.chevronRight), onPress: next),
      ],
    );
  }
}
