import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';

class TestPage extends StatefulWidget {
  const TestPage();

  @override
  State<StatefulWidget> createState() => TestPageState();
}

class TestPageState extends State<TestPage> {
  static const maxLength = 1000;

  List<Test> nestedList = List.generate(maxLength, (i) => Test(i));
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // crazyListOperationMadness();
  }

  void crazyListOperationMadness() {
    void assignNewList() {
      nestedList = List.generate(Random().nextInt(maxLength), (i) => Test(i))..shuffle();

      setState(() {});
    }

    _timer = Timer.periodic(
      const Duration(milliseconds: 10),
      (_) async {
        assignNewList();
        assignNewList();
        nestedList = List.generate(Random().nextInt(maxLength), (i) => Test(i))
          ..shuffle();
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.amber),
      body: Scrollbar(
        child: ImplicitlyAnimatedReorderableList<Test>(
          padding: const EdgeInsets.all(24),
          items: nestedList,
          areItemsTheSame: (oldItem, newItem) => oldItem == newItem,
          onReorderFinished: (item, from, to, newList) {
            setState(() {
              nestedList
                ..clear()
                ..addAll(newList);
            });
          },
          header: InkWell(
            onTap: () {
              if (_timer == null) {
                crazyListOperationMadness();
              } else {
                _timer?.cancel();
                _timer = null;
              }
            },
            child: Container(
              height: 120,
              color: _timer == null ? Colors.red : Colors.yellow,
              child: Center(
                child: Text(
                  'Header',
                  style: textTheme.headline6?.copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
          footer: Container(
            height: 120,
            color: Colors.red,
            child: Center(
              child: Text(
                'Footer',
                style: textTheme.headline6?.copyWith(color: Colors.white),
              ),
            ),
          ),
          itemBuilder: (context, itemAnimation, item, index) {
            return Reorderable(
              key: ValueKey(item),
              builder: (context, dragAnimation, inDrag) => AnimatedBuilder(
                animation: dragAnimation,
                builder: (context, child) => Card(
                  elevation: 4,
                  // SizeFadeTransition clips, so use the
                  // Card as a parent to avoid the box shadow
                  // to be clipped.
                  child: SizeFadeTransition(
                    animation: itemAnimation,
                    child: Handle(
                      delay: const Duration(milliseconds: 600),
                      child: Container(
                        height: 120,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('${item.key}'),
                            const Icon(Icons.menu),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class Test {
  final int key;
  Test(this.key);

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Test && o.key == key;
  }

  @override
  int get hashCode => key.hashCode;
}
