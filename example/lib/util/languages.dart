const english = Language(
  englishName: 'English',
  nativeName: 'English',
);

const french = Language(
  englishName: 'French',
  nativeName: 'Français',
);

const german = Language(
  englishName: 'German',
  nativeName: 'Deutsch',
);

const spanish = Language(
  englishName: 'Spanish',
  nativeName: 'Español',
);

const chinese = Language(
  englishName: 'Chinese',
  nativeName: '中文',
);

const danish = Language(
  englishName: 'Danish',
  nativeName: 'Dansk',
);

const hindi = Language(
  englishName: 'Hindi',
  nativeName: 'हिंदी',
);

const afrikaans = Language(
  englishName: 'Afrikaans',
  nativeName: 'Afrikaans',
);

const portuguese = Language(
  englishName: 'Portuguese',
  nativeName: 'Português',
);

const List<Language> languages = [
  english,
  french,
  german,
  spanish,
  chinese,
  danish,
  hindi,
  afrikaans,
  portuguese,
];

class Language {
  final String englishName;
  final String nativeName;
  const Language({
    required this.englishName,
    required this.nativeName,
  });

  @override
  String toString() => 'Language englishName: $englishName, nativeName: $nativeName';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Language && o.englishName == englishName && o.nativeName == nativeName;
  }

  @override
  int get hashCode => englishName.hashCode ^ nativeName.hashCode;
}
