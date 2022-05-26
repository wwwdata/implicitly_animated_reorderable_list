/* import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';

import 'util/box.dart';

class Examples extends StatelessWidget {
  const Examples({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // * ImplicitlyAnimatedList
    // Specify the generic type of the data in the list.
    ImplicitlyAnimatedList<Language>(
      // The current items in the list.
      data: items,
      // Called by the DiffUtil to decide whether two object represent the same item.
      // For example, if your items have unique ids, this method should check their id equality.
      areItemsTheSame: (a, b) => a.id == b.id,
      // Called, as needed, to build list item widgets.
      // List items are only built when they're scrolled into view.
      itemBuilder: (context, animation, item, index) {
        // Specifiy a transition to be used by the ImplicitlyAnimatedList.
        // In this case a custom transition.
        return SizeFadeTranstion(
          sizeFraction: 0.7,
          curve: Curves.easeInOut,
          animation: animation,
          child: Text(item.name),
        );
      },
      // An optional builder when an item was removed from the list.
      // If not specified, the List uses the itemBuilder with
      // the animation reversed.
      removedItemBuilder: (context, animation, oldItem) {
        return FadeTransition(
          opacity: animation,
          child: Text(oldItem.name),
        );
      },
    );

    // * ImplicitlyAnimatedReorderableList
    ImplicitlyAnimatedReorderableList<Language>(
      data: items,
      areItemsTheSame: (a, b) => a.id == b.id,
      itemBuilder: (context, itemAnimation, item, index) {
        // Each item must be wrapped in a Reorderable widget.
        return Reorderable(
          // Each item must have a unique key.
          key: ValueKey(item),
          // The animation of the Reorderable builder can be used to
          // change to appearance of the item between dragged and normal
          // state. For example to add elevation. Implicit animation are
          // not yet supported.
          builder: (context, dragAnimation, inDrag) {
            final t = dragAnimation.value;

            final elevation = lerpDouble(0, 8, t);
            final color = Color.lerp(Colors.white, Colors.white.withOpacity(0.8), t);

            return SizeFadeTranstion(
              sizeFraction: 0.7,
              curve: Curves.easeInOut,
              animation: itemAnimation,
              child: Box(
                color: color,
                elevation: elevation,
                child: ListTile(
                  title: Text(item.name),
                  // The child of a Handle can initialize a drag/reorder.
                  // This could for example be an Icon or the whole item itself. You can
                  // use the delay parameter to specify the duration for how long a pointer
                  // must press the child, until it can be dragged.
                  trailing: Handle(
                    delay: const Duration(milliseconds: 100),
                    child: Icon(
                      Icons.list,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
 */