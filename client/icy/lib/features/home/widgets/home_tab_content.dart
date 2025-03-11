import 'package:flutter/material.dart';

class HomeTabContent extends StatelessWidget {
  final String title;
  final List<dynamic>? items;
  final Widget Function(dynamic)? itemBuilder;
  final Widget? emptyPlaceholder;

  const HomeTabContent({
    super.key,
    required this.title,
    this.items,
    this.itemBuilder,
    this.emptyPlaceholder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        items != null && items!.isNotEmpty && itemBuilder != null
            ? ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items!.length,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemBuilder: (context, index) => itemBuilder!(items![index]),
            )
            : Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: emptyPlaceholder ?? const Text("No items available"),
              ),
            ),
      ],
    );
  }
}
