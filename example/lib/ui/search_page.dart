import 'package:flutter/material.dart';

import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';

import '../util/util.dart';

class LanguageSearchPage extends StatefulWidget {
  const LanguageSearchPage({Key? key}) : super(key: key);

  @override
  _LanguageSearchPageState createState() => _LanguageSearchPageState();
}

class _LanguageSearchPageState extends State<LanguageSearchPage> {
  final List<Language> filteredLanguages = List.from(languages);

  late final _controller = TextEditingController()
    ..addListener(
      _onQueryChanged,
    );

  String get text => _controller.text.trim();

  void _onQueryChanged() {
    filteredLanguages.clear();

    if (text.isEmpty) {
      filteredLanguages
        ..clear()
        ..addAll(languages);

      setState(() {});

      return;
    }

    final query = text.toLowerCase();
    for (final lang in languages) {
      final englishName = lang.englishName.toLowerCase();
      final nativeName = lang.nativeName.toLowerCase();
      final startsWith = englishName.startsWith(query) || nativeName.startsWith(query);

      if (startsWith) {
        filteredLanguages.add(lang);
      }
    }

    for (final lang in languages) {
      final englishName = lang.englishName.toLowerCase();
      final nativeName = lang.nativeName.toLowerCase();
      final contains = englishName.contains(query) || nativeName.contains(query);

      if (contains && !filteredLanguages.contains(lang)) {
        filteredLanguages.add(lang);
      }
    }

    setState(() {});
  }

  Widget _buildItem(Language lang) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Box(
      border: Border(
        bottom: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      color: Colors.white,
      onTap: () => Navigator.pop(context, lang),
      child: ListTile(
        title: HighlightText(
          query: text,
          text: lang.nativeName,
          style: textTheme.bodyText2?.copyWith(
            fontSize: 16,
          ),
          activeStyle: textTheme.bodyText2?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: HighlightText(
          query: text,
          text: lang.englishName,
          style: textTheme.bodyText1?.copyWith(
            fontSize: 15,
          ),
          activeStyle: textTheme.bodyText1?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final padding = MediaQuery.of(context).viewPadding.top;

    return Scaffold(
      appBar: _buildAppBar(padding, theme, textTheme),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child:
            filteredLanguages.isNotEmpty ? _buildList() : _buildNoLanguagesPlaceholder(),
      ),
    );
  }

  Widget _buildList() {
    return ImplicitlyAnimatedList<Language>(
      items: filteredLanguages,
      updateDuration: const Duration(milliseconds: 400),
      areItemsTheSame: (a, b) => a == b,
      itemBuilder: (context, animation, lang, _) {
        return SizeFadeTransition(
          sizeFraction: 0.7,
          curve: Curves.easeInOut,
          animation: animation,
          child: _buildItem(lang),
        );
      },
      updateItemBuilder: (context, animation, lang) {
        return FadeTransition(
          opacity: animation,
          child: _buildItem(lang),
        );
      },
    );
  }

  PreferredSize _buildAppBar(double padding, ThemeData theme, TextTheme textTheme) {
    return PreferredSize(
      preferredSize: Size.fromHeight(56 + padding),
      child: Box(
        height: 56 + padding,
        width: double.infinity,
        color: theme.accentColor,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
        child: Column(
          children: <Widget>[
            SizedBox(height: padding),
            Expanded(
              child: Row(
                children: <Widget>[
                  const BackButton(
                    color: Colors.white,
                  ),
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      controller: _controller,
                      textInputAction: TextInputAction.search,
                      style: textTheme.bodyText2?.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        hintText: 'Search for a language',
                        hintStyle: textTheme.bodyText2?.copyWith(
                          color: Colors.grey.shade200,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 350),
                    opacity: text.isEmpty ? 0.0 : 1.0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: Colors.white,
                      ),
                      onPressed: () => _controller.text = '',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoLanguagesPlaceholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const <Widget>[
          Icon(
            Icons.translate,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No languages found!',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
