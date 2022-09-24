import 'package:animated_list_plus/src/custom_sliver_animated_grid.dart';
import 'package:animated_list_plus/src/custom_sliver_animated_list.dart';
import 'package:flutter/material.dart';

import 'src.dart';

/// A Flutter ListView that implicitly animates between the changes of two lists.
class ImplicitlyAnimatedGrid<E extends Object> extends StatelessWidget {
  /// The current data that this [ImplicitlyAnimatedGrid] should represent.
  final List<E> items;

  /// Called, as needed, to build list item widgets.
  ///
  /// List items are only built when they're scrolled into view.
  final AnimatedItemBuilder<Widget, E> itemBuilder;

  /// An optional builder when an item was removed from the list.
  ///
  /// If not specified, the [ImplicitlyAnimatedGrid] uses the [itemBuilder] with
  /// the animation reversed.
  final RemovedItemBuilder<Widget, E>? removeItemBuilder;

  /// An optional builder when an item in the list was changed but not its position.
  ///
  /// The [UpdatedItemBuilder] animation will run from 1 to 0 and back to 1 again, while
  /// the item parameter will be the old item in the first half of the animation and the new item
  /// in the latter half of the animation. This allows you for example to fade between the old and
  /// the new item.
  ///
  /// If not specified, changes will appear instantaneously.
  final UpdatedItemBuilder<Widget, E>? updateItemBuilder;

  /// Called by the DiffUtil to decide whether two object represent the same Item.
  /// For example, if your items have unique ids, this method should check their id equality.
  final ItemDiffUtil<E> areItemsTheSame;

  /// The duration of the animation when an item was inserted into the list.
  final Duration insertDuration;

  /// The duration of the animation when an item was removed from the list.
  final Duration removeDuration;

  /// The duration of the animation when an item changed in the list.
  final Duration updateDuration;

  /// Whether to spawn a new isolate on which to calculate the diff on.
  ///
  /// Usually you wont have to specify this value as the MyersDiff implementation will
  /// use its own metrics to decide, whether a new isolate has to be spawned or not for
  /// optimal performance.
  final bool? spawnIsolate;

  /// The axis along which the scroll view scrolls.
  ///
  /// Defaults to [Axis.vertical].
  final Axis scrollDirection;

  /// Whether the scroll view scrolls in the reading direction.
  ///
  /// For example, if the reading direction is left-to-right and
  /// [scrollDirection] is [Axis.horizontal], then the scroll view scrolls from
  /// left to right when [reverse] is false and from right to left when
  /// [reverse] is true.
  ///
  /// Similarly, if [scrollDirection] is [Axis.vertical], then the scroll view
  /// scrolls from top to bottom when [reverse] is false and from bottom to top
  /// when [reverse] is true.
  ///
  /// Defaults to false.
  final bool reverse;

  /// An object that can be used to control the position to which this scroll
  /// view is scrolled.
  ///
  /// Must be null if [primary] is true.
  ///
  /// A [ScrollController] serves several purposes. It can be used to control
  /// the initial scroll position (see [ScrollController.initialScrollOffset]).
  /// It can be used to control whether the scroll view should automatically
  /// save and restore its scroll position in the [PageStorage] (see
  /// [ScrollController.keepScrollOffset]). It can be used to read the current
  /// scroll position (see [ScrollController.offset]), or change it (see
  /// [ScrollController.animateTo]).
  final ScrollController? controller;

  /// Whether this is the primary scroll view associated with the parent
  /// [PrimaryScrollController].
  ///
  /// On iOS, this identifies the scroll view that will scroll to top in
  /// response to a tap in the status bar.
  ///
  /// Defaults to true when [scrollDirection] is [Axis.vertical] and
  /// [controller] is null.
  final bool? primary;

  /// How the scroll view should respond to user input.
  ///
  /// For example, determines how the scroll view continues to animate after the
  /// user stops dragging the scroll view.
  ///
  /// Defaults to matching platform conventions.
  final ScrollPhysics? physics;


  /// A delegate that controls the layout of the children within the [GridView].
  ///
  /// The [GridView], [GridView.builder], and [GridView.custom] constructors let you specify this
  /// delegate explicitly. The other constructors create a [gridDelegate]
  /// implicitly.
  final SliverGridDelegate gridDelegate;

  /// Whether the extent of the scroll view in the [scrollDirection] should be
  /// determined by the contents being viewed.
  ///
  /// If the scroll view does not shrink wrap, then the scroll view will expand
  /// to the maximum allowed size in the [scrollDirection]. If the scroll view
  /// has unbounded constraints in the [scrollDirection], then [shrinkWrap] must
  /// be true.
  ///
  /// Shrink wrapping the content of the scroll view is significantly more
  /// expensive than expanding to the maximum allowed size because the content
  /// can expand and contract during scrolling, which means the size of the
  /// scroll view needs to be recomputed whenever the scroll position changes.
  ///
  /// Defaults to false.
  final bool shrinkWrap;

  /// The amount of space by which to inset the children.
  final EdgeInsetsGeometry? padding;

  /// Creates a Flutter ListView that implicitly animates between the changes
  /// of two lists.
  const ImplicitlyAnimatedGrid({
    Key? key,
    required this.items,
    required this.itemBuilder,
    required this.areItemsTheSame,
    this.removeItemBuilder,
    this.updateItemBuilder,
    this.insertDuration = const Duration(milliseconds: 500),
    this.removeDuration = const Duration(milliseconds: 500),
    this.updateDuration = const Duration(milliseconds: 500),
    this.spawnIsolate,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    required this.gridDelegate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      scrollDirection: scrollDirection,
      reverse: reverse,
      controller: controller,
      primary: primary,
      physics: physics,
      shrinkWrap: shrinkWrap,
      slivers: <Widget>[
        SliverPadding(
          padding: padding ?? const EdgeInsets.all(0),
          sliver: SliverImplicitlyAnimatedGrid<E>(
            items: items,
            itemBuilder: itemBuilder,
            gridDelegate: gridDelegate,
            areItemsTheSame: areItemsTheSame,
            updateItemBuilder: updateItemBuilder,
            removeItemBuilder: removeItemBuilder,
            insertDuration: insertDuration,
            removeDuration: removeDuration,
            updateDuration: updateDuration,
            spawnIsolate: spawnIsolate,
          ),
        ),
      ],
    );
  }
}

/// A Flutter Sliver that implicitly animates between the changes of two lists.
class SliverImplicitlyAnimatedGrid<E extends Object>
    extends ImplicitlyAnimatedListBase<Widget, E> {
  /// Creates a Flutter Sliver that implicitly animates between the changes of two lists.
  ///
  /// {@template implicitly_animated_reorderable_list.constructor}
  /// The [items] parameter represents the current items that should be displayed in
  /// the list.
  ///
  /// The [itemBuilder] callback is used to build each child as needed. The parent must
  /// be a [Reorderable] widget.
  ///
  /// The [areItemsTheSame] callback is called by the DiffUtil to decide whether two objects
  /// represent the same item. For example, if your items have unique ids, this method should
  /// check their id equality.
  ///
  /// The [onReorderFinished] callback is called in response to when the dragged item has
  /// been released and animated to its final destination. Here you should update
  /// the underlying data in your model/bloc/database etc.
  ///
  /// The [spawnIsolate] flag indicates whether to spawn a new isolate on which to
  /// calculate the diff between the lists. Usually you wont have to specify this
  /// value as the MyersDiff implementation will use its own metrics to decide, whether
  /// a new isolate has to be spawned or not for optimal performance.
  /// {@endtemplate}
  

  /// A delegate that controls the layout of the children within the [GridView].
  ///
  /// The [GridView], [GridView.builder], and [GridView.custom] constructors let you specify this
  /// delegate explicitly. The other constructors create a [gridDelegate]
  /// implicitly.
  final SliverGridDelegate gridDelegate;
  const SliverImplicitlyAnimatedGrid({
    Key? key,
    required List<E> items,
    required AnimatedItemBuilder<Widget, E> itemBuilder,
    required ItemDiffUtil<E> areItemsTheSame,
    required this.gridDelegate,
    RemovedItemBuilder<Widget, E>? removeItemBuilder,
    UpdatedItemBuilder<Widget, E>? updateItemBuilder,
    Duration insertDuration = const Duration(milliseconds: 500),
    Duration removeDuration = const Duration(milliseconds: 500),
    Duration updateDuration = const Duration(milliseconds: 500),
    bool? spawnIsolate,
  }) : super(
          key: key,
          items: items,
          itemBuilder: itemBuilder,
          areItemsTheSame: areItemsTheSame,
          removeItemBuilder: removeItemBuilder,
          updateItemBuilder: updateItemBuilder,
          insertDuration: insertDuration,
          removeDuration: removeDuration,
          updateDuration: updateDuration,
          spawnIsolate: spawnIsolate,
        );

  @override
  _SliverImplicitlyAnimatedListState<E> createState() =>
      _SliverImplicitlyAnimatedListState<E>();
}

class _SliverImplicitlyAnimatedListState<E extends Object>
    extends ImplicitlyAnimatedListBaseState<Widget,
        SliverImplicitlyAnimatedGrid<E>, E> {
  @override
  Widget build(BuildContext context) {
    return CustomSliverAnimatedGrid(
      key: animatedListKey,
      gridDelegate:widget.gridDelegate,
      initialItemCount: newList.length,
      itemBuilder: (context, index, animation) {
        final E? item = data.getOrNull(index) ??
            newList.getOrNull(index) ??
            oldList.getOrNull(index);
        final didChange = changes[item] != null;

        if (item == null) {
          return Container();
        } else if (updateItemBuilder != null && didChange) {
          return buildUpdatedItemWidget(item);
        } else {
          return itemBuilder(context, animation, item, index);
        }
      },
    );
  }
}
