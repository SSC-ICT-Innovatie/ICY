import 'package:flutter/material.dart';
import '../../../core/utils/widget_utils.dart';

class HomeTabContent extends StatelessWidget {
  final String title;
  final List<dynamic>? items;
  final Widget Function(dynamic)? itemBuilder;
  final Widget? emptyPlaceholder;

  const HomeTabContent({
    Key? key,
    required this.title,
    this.items,
    this.itemBuilder,
    this.emptyPlaceholder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Always wrap the content with proper constraints
    return WidgetUtils.safeHeight(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          Expanded(
            // Use Expanded to fill available space but respect parent constraints
            child:
                items != null && items!.isNotEmpty && itemBuilder != null
                    ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: items!.length,
                      itemBuilder:
                          (context, index) => itemBuilder!(items![index]),
                    )
                    : Center(
                      child:
                          emptyPlaceholder ?? const Text("No items available"),
                    ),
          ),
        ],
      ),
      height: 400, // Adjust as needed
    );
  }
}
