import 'dart:math' as math;

import 'package:flutter/widgets.dart';

class SliverChildSeparatedBuilderDelegate extends SliverChildBuilderDelegate {
  SliverChildSeparatedBuilderDelegate({
    required NullableIndexedWidgetBuilder itemBuilder,
    ChildIndexGetter? findChildIndexCallback,
    required NullableIndexedWidgetBuilder separatorBuilder,
    int? itemCount,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
  }) : super(
          (BuildContext context, int index) {
            final int itemIndex = index ~/ 2;
            final Widget? widget;
            if (index.isEven) {
              widget = itemBuilder(context, itemIndex);
            } else {
              widget = separatorBuilder(context, itemIndex);
              // ignore: prefer_asserts_with_message , we use FlutterError
              assert(() {
                if (widget == null) {
                  throw FlutterError('separatorBuilder cannot return null.');
                }

                return true;
              }());
            }

            return widget;
          },
          findChildIndexCallback: findChildIndexCallback,
          childCount: itemCount == null ? null : math.max(0, itemCount * 2 - 1),
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
          semanticIndexCallback: (Widget _, int index) {
            return index.isEven ? index ~/ 2 : null;
          },
        );
}
