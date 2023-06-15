import 'dart:ui';

import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../util/util.dart';
import 'ui.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({
    Key? key,
  }) : super(key: key);

  @override
  _LanguagePageState createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage>
    with SingleTickerProviderStateMixin {
  static const double _horizontalHeight = 96;
  static const List<String> options = [
    'Shuffle',
    'Test',
  ];

  final List<Language> selectedLanguages = [
    english,
    german,
    spanish,
    french,
  ];

  bool inReorder = false;

  ScrollController scrollController = ScrollController();

  void onReorderFinished(List<Language> newItems) {
    scrollController.jumpTo(scrollController.offset);
    setState(() {
      inReorder = false;

      selectedLanguages
        ..clear()
        ..addAll(newItems);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    print(selectedLanguages.toString());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Examples'),
        actions: <Widget>[
          _buildPopupMenuButton(textTheme),
        ],
      ),
      body: ListView(
        controller: scrollController,
        // Prevent the ListView from scrolling when an item is
        // currently being dragged.
        padding: const EdgeInsets.only(bottom: 24),
        children: <Widget>[
          _buildHeadline('Vertically'),
          const Divider(height: 0),
          _buildVerticalLanguageList(),
          _buildHeadline('Horizontally'),
          _buildHorizontalLanguageList(),
          const SizedBox(height: 500),
        ],
      ),
    );
  }

  // * An example of a vertically reorderable list.
  Widget _buildVerticalLanguageList() {
    final theme = Theme.of(context);

    Reorderable buildReorderable(
      Language lang,
      Widget Function(Widget tile) transition,
    ) {
      return Reorderable(
        key: ValueKey(lang),
        builder: (context, dragAnimation, inDrag) {
          final tile = Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildTile(lang),
              const Divider(height: 0),
            ],
          );

          return AnimatedBuilder(
            animation: dragAnimation,
            builder: (context, _) {
              final t = dragAnimation.value;
              final color = Color.lerp(Colors.white, Colors.grey.shade100, t);

              return Material(
                color: color,
                elevation: lerpDouble(0, 8, t)!,
                child: transition(tile),
              );
            },
          );
        },
      );
    }

    return ImplicitlyAnimatedReorderableList<Language>(
      items: selectedLanguages,
      shrinkWrap: true,
      reorderDuration: const Duration(milliseconds: 200),
      removeDuration: Duration.zero,
      liftDuration: const Duration(milliseconds: 300),
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      areItemsTheSame: (oldItem, newItem) => oldItem == newItem,
      onReorderStarted: (item, index) => setState(() => inReorder = true),
      onReorderFinished: (movedLanguage, from, to, newItems) {
        // Update the underlying data when the item has been reordered!
        onReorderFinished(newItems);
      },
      itemBuilder: (context, itemAnimation, lang, index) {
        return buildReorderable(lang, (tile) {
          return SizeFadeTransition(
            sizeFraction: 0.7,
            curve: Curves.easeInOut,
            animation: itemAnimation,
            child: tile,
          );
        });
      },
      removeItemBuilder: (context, animation, nearbyUser) {
        return Reorderable(
            key: UniqueKey(),
            child: SizedBox(
              width: 0,
              height: 0,
            ));
      },
      updateItemBuilder: (context, itemAnimation, lang) {
        return buildReorderable(lang, (tile) {
          return FadeTransition(
            opacity: itemAnimation,
            child: tile,
          );
        });
      },
      footer: _buildFooter(context, theme.textTheme),
    );
  }

  Widget _buildHorizontalLanguageList() {
    return Container(
      height: _horizontalHeight,
      alignment: Alignment.center,
      child: ImplicitlyAnimatedReorderableList<Language>(
        items: selectedLanguages,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        areItemsTheSame: (oldItem, newItem) => oldItem == newItem,
        onReorderStarted: (item, index) => setState(() => inReorder = true),
        onReorderFinished: (item, from, to, newItems) =>
            onReorderFinished(newItems),
        itemBuilder: (context, itemAnimation, item, index) {
          return Reorderable(
            key: ValueKey(item.toString()),
            builder: (context, dragAnimation, inDrag) {
              final t = dragAnimation.value;
              final box = _buildBox(item, t);

              return SizeFadeTransition(
                animation: itemAnimation,
                axis: Axis.horizontal,
                axisAlignment: 1.0,
                curve: Curves.ease,
                child: box,
              );
            },
          );
        },
        updateItemBuilder: (context, itemAnimation, item) {
          return Reorderable(
            key: ValueKey(item.toString()),
            child: FadeTransition(
              opacity: itemAnimation,
              child: _buildBox(item, 0),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTile(Language lang) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Slidable(
      // Specify a key if the Slidable is dismissible.
      key: UniqueKey(),

      // The start action pane is the one at the left or the top side.
      startActionPane: ActionPane(
        // A motion is a widget used to control how the pane animates.
        motion: const ScrollMotion(),

        // A pane can dismiss the Slidable.
        dismissible: DismissiblePane(onDismissed: () {
          setState(() => selectedLanguages.remove(lang));
        }),

        // All actions are defined in the children parameter.
        children: [
          // A SlidableAction can have an icon and/or a label.
          SlidableAction(
            onPressed: (context) {
              setState(() => selectedLanguages.remove(lang));
            },
            backgroundColor: Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
          SlidableAction(
            onPressed: (context) {
              setState(() => selectedLanguages.remove(lang));
            },
            backgroundColor: Color(0xFF21B7CA),
            foregroundColor: Colors.white,
            icon: Icons.share,
            label: 'Share',
          ),
        ],
      ),

      // The end action pane is the one at the right or the bottom side.
      endActionPane: ActionPane(
        motion: ScrollMotion(),
        children: [
          SlidableAction(
            // An action can be bigger than the others.
            flex: 2,
            onPressed: (context) {
              setState(() => selectedLanguages.remove(lang));
            },
            backgroundColor: Color(0xFF7BC043),
            foregroundColor: Colors.white,
            icon: Icons.archive,
            label: 'Archive',
          ),
          SlidableAction(
            onPressed: (context) {
              setState(() => selectedLanguages.remove(lang));
            },
            backgroundColor: Color(0xFF0392CF),
            foregroundColor: Colors.white,
            icon: Icons.save,
            label: 'Save',
          ),
        ],
      ),

      // The child of the Slidable is what the user sees when the
      // component is not dragged.
      child: ListTile(title: Text(lang.nativeName)),
    );
  }

  Widget _buildBox(Language item, double t) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final elevation = lerpDouble(0, 8, t)!;

    return Handle(
      delay: const Duration(milliseconds: 500),
      child: Box(
        height: _horizontalHeight,
        borderRadius: 8,
        border: Border.all(
          color: Colors.grey.shade300,
          width: 2,
        ),
        elevation: elevation,
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        margin: const EdgeInsets.only(right: 8),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                item.nativeName,
                style: textTheme.bodyText2,
              ),
              const SizedBox(height: 8),
              Text(
                item.englishName,
                style: textTheme.bodyText1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, TextTheme textTheme) {
    return Box(
      color: Colors.white,
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LanguageSearchPage(),
          ),
        );

        if (result != null && !selectedLanguages.contains(result)) {
          setState(() {
            selectedLanguages.add(result);
          });
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: const SizedBox(
              height: 36,
              width: 36,
              child: Center(
                child: Icon(
                  Icons.add,
                  color: Colors.grey,
                ),
              ),
            ),
            title: Text(
              'Add a language',
              style: textTheme.bodyText1?.copyWith(
                fontSize: 16,
              ),
            ),
          ),
          const Divider(height: 0),
        ],
      ),
    );
  }

  Widget _buildHeadline(String headline) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    Widget buildDivider() => Container(
          height: 2,
          color: Colors.grey.shade300,
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 16),
        buildDivider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Text(
            headline,
            style: textTheme.bodyText1?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        buildDivider(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPopupMenuButton(TextTheme textTheme) {
    return PopupMenuButton<String>(
      padding: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      onSelected: (value) {
        switch (value) {
          case 'Shuffle':
            setState(selectedLanguages.shuffle);
            break;
          case 'Test':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TestPage(),
              ),
            );
            break;
        }
      },
      itemBuilder: (context) => options.map((option) {
        return PopupMenuItem(
          value: option,
          child: Text(
            option,
            style: textTheme.bodyText1,
          ),
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}

class Pair<A, B> {
  final A first;
  final B second;
  Pair(
    this.first,
    this.second,
  );
}
