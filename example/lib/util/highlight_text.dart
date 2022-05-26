import 'package:flutter/material.dart';

class HighlightText extends StatefulWidget {
  final TextStyle? activeStyle;
  final TextStyle? style;
  final String query;
  final String text;
  final TextAlign textAlign;
  final TextDirection? textDirection;
  final bool softWrap;
  final TextOverflow overflow;
  final double textScaleFactor;
  final int? maxLines;
  const HighlightText({
    Key? key,
    this.activeStyle,
    this.style,
    this.query = '',
    this.text = '',
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.softWrap = true,
    this.overflow = TextOverflow.ellipsis,
    this.textScaleFactor = 1.0,
    this.maxLines,
  }) : super(key: key);

  @override
  _HighlightTextState createState() => _HighlightTextState();
}

class _HighlightTextState extends State<HighlightText> {
  TextStyle get style => widget.style ?? Theme.of(context).textTheme.bodyText2!;
  TextStyle get activeStyle =>
      widget.activeStyle ?? style.copyWith(fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    final idxs = getQueryHighlights(widget.text, widget.query);

    return RichText(
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
      softWrap: widget.softWrap,
      textDirection: widget.textDirection,
      textScaleFactor: widget.textScaleFactor,
      text: TextSpan(
        children: idxs.map((idx) {
          return TextSpan(
            text: widget.text.substring(idx.first, idx.second),
            style: idx.third ? activeStyle : style,
          );
        }).toList(),
      ),
    );
  }
}

String replaceLast(String source, String matcher, String replacement) {
  final index = source.lastIndexOf(matcher);
  return source.replaceRange(index, index + matcher.length, replacement);
}

List<Triplet<int, int, bool>> getQueryHighlights(String text, String query) {
  final t = text.toLowerCase();
  final q = query.toLowerCase();

  if (t.isEmpty || q.isEmpty || !t.contains(q)) return [Triplet(0, t.length, false)];

  List<Triplet<int, int, bool>> idxs = [];

  var w = t;
  do {
    final i = w.lastIndexOf(q);
    final e = i + q.length;
    if (i != -1) {
      w = replaceLast(w, q, '');
      idxs.insert(0, Triplet(i, e, true));
    }
  } while (w.contains(q));

  if (idxs.isEmpty) {
    idxs.add(Triplet(0, t.length, false));
  } else {
    final List<Triplet<int, int, bool>> result = [];
    Triplet<int, int, bool>? last;

    for (final idx in idxs) {
      final isLast = idx == idxs.last;
      if (last == null) {
        if (idx.first == 0) {
          result.add(idx);
        } else {
          result..add(Triplet(0, idx.first, false))..add(idx);
        }
      } else if (last.second == idx.first) {
        result.add(idx);
      } else {
        result..add(Triplet(last.second, idx.first, false))..add(idx);
      }

      if (isLast && idx.second != t.length) {
        result.add(Triplet(idx.second, t.length, false));
      }

      last = idx;
    }

    idxs = result;
  }

  return idxs;
}

class Triplet<A, B, C> {
  A first;
  B second;
  C third;
  Triplet(
    this.first,
    this.second,
    this.third,
  );

  Triplet copyWith({
    A? first,
    B? second,
    C? third,
  }) {
    return Triplet(
      first ?? this.first,
      second ?? this.second,
      third ?? this.third,
    );
  }

  @override
  String toString() => 'Triple first: $first, second: $second, third: $third';

  @override
  bool operator ==(Object o) {
    return o is Triplet && o.first == first && o.second == second && o.third == third;
  }

  @override
  int get hashCode {
    return hashList([
      first,
      second,
      third,
    ]);
  }
}
