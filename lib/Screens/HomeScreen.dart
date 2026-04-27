import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:master_demo_app/Api/hooks/database.dart';
import 'package:master_demo_app/Api/hooks/open_ai.dart';
import 'package:master_demo_app/env.dart';
import 'ChapterContent.dart';
import '../Models/models.dart';
import 'BurgerMenu.dart';

class HomeScreen extends StatefulWidget {
	const HomeScreen({Key? key, this.title = 'Masters Model by Lindi Mokele'}) : super(key: key);
	final String title;

	@override
	State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
late OpenAIService openai;
	bool loading = true;
	String? loadError;
	List<ContentItem> content = [];
	List<Chapter> chapters = [];
  List<Chapter> sourceChapters = [];
	int? selectedChapterIndex;
  final Set<String> collectedStarIds = <String>{};
  String selectedLanguage = 'English';
  String selectedLanguageCode = 'en'; // New variable for language code
  
  final List<String> southAfricanLanguages = [
    'English',
    'isiZulu',

  ];

  // Map of language names to their language codes
  final Map<String, String> languageCodes = {
    'English': 'en',
    'isiZulu': 'zu',

  };

	@override
	void initState() {
		super.initState();
		loadJsonContent();
    final apiKey = OPEN_AI_KEY;
    openai = OpenAIService(apiKey);
  }

  @override
  void reassemble() {
    super.reassemble();
    loadJsonContent();
  }

	void createSampleChapter() async {
  final chapter = {
    "chapter": "Sample Chapter 2",
    "content": [
      {"type": "heading", "text": "Sample Heading", "style": {"fontSize": 28, "color": "#1E3A8A", "bold": true}},
      {"type": "paragraph", "text": "This is a sample paragraph for the new chapter."}
    ],
    "language": "English"
  };
  final docRef = await addChapter(chapter);
  print('Chapter added with ID: \\${docRef.id}');
}

void fetchAndPrintChapters() async {
  final chapters = await getAllChapters();
  for (final chapter in chapters) {
    print('Chapter: ${chapter['chapter']}');
    // You can also access chapter['content']
  }
}

// Call fetchAndPrintChapters() from your UI or logic to print all chapters from Firestore.
	Future<void> loadJsonContent() async {
		try {
			// Load using the asset path declared in pubspec.yaml ToDo: Api for the data on firestore
			final jsonString = await rootBundle.loadString('lib/Api/data/chapter1content.json');
					final decoded = jsonDecode(jsonString);
					// If the JSON root is a chapter object, map to Chapter, otherwise assume list
					if (decoded is Map<String, dynamic>) {
						final chapter = Chapter.fromJson(decoded);
						setState(() {
              sourceChapters = [chapter];
              chapters = [chapter];
							content = chapter.content;
              selectedChapterIndex = 0;
							loading = false;
						});
					} else if (decoded is List) {
            final parsedChapters =
                decoded.map<Chapter>((e) => Chapter.fromJson(e as Map<String, dynamic>)).toList();
						// Map list entries to Chapter objects
							setState(() {
								sourceChapters = parsedChapters;
								chapters = parsedChapters;
								// also flatten first chapter into content for backward compatibility
								content = chapters.isNotEmpty ? chapters.first.content : [];
								// default select the first chapter
								selectedChapterIndex = chapters.isNotEmpty ? 0 : null;
								loading = false;
							});
              if (selectedLanguage != 'English') {
                await onLanguageSelected(selectedLanguage);
              }
					} else {
						throw FormatException('Unexpected JSON root type');
					}
		} catch (e, st) {
			debugPrint('Error loading JSON: $e\n$st');
			setState(() {
				loadError = e.toString();
				loading = false;
			});
		}
	}

	Future<void> loadContentFirebase() async {
		try {
			setState(() { loading = true; });
			final chaptersData = await getAllChapters();
			setState(() {
				chapters = chaptersData.map<Chapter>((e) => Chapter.fromJson(e)).toList();
				content = chapters.isNotEmpty ? chapters.first.content : [];
				selectedChapterIndex = chapters.isNotEmpty ? 0 : null;
				loading = false;
			});
		} catch (e, st) {
			debugPrint('Error loading chapters from Firestore: $e\n$st');
			setState(() {
				loadError = e.toString();
				loading = false;
			});
		}
	}

  Future<void> onLanguageSelected(String? lang) async {
    if (lang != null) {
      setState(() {
        selectedLanguage = lang;
        selectedLanguageCode = languageCodes[lang] ?? 'en'; // Update language code
        loading = true;
      });

      if (lang == 'English') {
        setState(() {
          chapters = sourceChapters;
          content = chapters.isNotEmpty ? chapters.first.content : [];
          selectedChapterIndex = chapters.isNotEmpty ? 0 : null;
          loading = false;
        });
        return;
      }

      print('Selected language: $lang (Code: ${languageCodes[lang]})');
      final translated = await openai.translateJsonNested(sourceChapters, lang);
      setState(() {
        chapters = (translated as List).map<Chapter>((e) => Chapter.fromJson(e)).toList();
        content = chapters.isNotEmpty ? chapters.first.content : [];
        selectedChapterIndex = chapters.isNotEmpty ? 0 : null;
        loading = false;
      });
    }
  }

  void onStarCollected(String starId) {
    if (collectedStarIds.contains(starId)) {
      return;
    }

    setState(() {
      collectedStarIds.add(starId);
    });
  }

	@override
	Widget build(BuildContext context) {
		Widget body;
		if (loading) {
			body = const Center(child: CircularProgressIndicator());
		} else if (loadError != null) {
			body = Center(child: Text('Failed to load content: $loadError'));
		} else {
				// render chapters (default shows first chapter)
				body = renderChapters(context);
		}

		return Scaffold(
			backgroundColor: const Color(0xFFF5F7FA),
			appBar: AppBar(
				title: Text(widget.title),
				actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF4C2), Color(0xFFF7C948)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(999),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFF7C4D00), size: 20),
                const SizedBox(width: 6),
                Text(
                  '${collectedStarIds.length}',
                  style: const TextStyle(
                    color: Color(0xFF5D3A00),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          DropdownButtonHideUnderline(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0,2))],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: DropdownButton<String>(
                value: selectedLanguage,
                icon: const Icon(Icons.language, color: Colors.white),
                dropdownColor: Colors.black,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                items: southAfricanLanguages.map((lang) => DropdownMenuItem(
                  value: lang,
                  child: Text(lang, style: const TextStyle(color: Colors.white)),
                )).toList(),
                onChanged: onLanguageSelected,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
			),
						drawer: BurgerMenu(
							chapters: chapters,
							selectedIndex: selectedChapterIndex,
							loading: loading,
							onSelect: (idx) => setState(() => selectedChapterIndex = idx),
						),
			body: body,
		);
	}

  Widget renderChapters(BuildContext context) {
		if (chapters.isNotEmpty) {
			if (selectedChapterIndex != null && selectedChapterIndex! >= 0 && selectedChapterIndex! < chapters.length) {
				final chap = chapters[selectedChapterIndex!];
				return SingleChildScrollView(
					padding: const EdgeInsets.fromLTRB(12, 16, 12, 32),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Padding(
								padding: const EdgeInsets.symmetric(vertical: 12),
								child: Text(
									chap.chapter,
									style: Theme.of(context).textTheme.headlineSmall?.copyWith(
										fontWeight: FontWeight.w700,
										color: const Color(0xFF1E3A8A),
										letterSpacing: 0.2,
									),
								),
							),
							ContentPage(
                content: chap.content,
                languageCode: selectedLanguageCode,
                collectedStarIds: collectedStarIds,
                onStarCollected: onStarCollected,
              ),
						],
					),
				);
			} else {
				// Default: show the first chapter
				final chap = chapters.first;
				return SingleChildScrollView(
					padding: const EdgeInsets.fromLTRB(12, 16, 12, 32),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Padding(
								padding: const EdgeInsets.symmetric(vertical: 12),
								child: Text(
									chap.chapter,
									style: Theme.of(context).textTheme.headlineSmall?.copyWith(
										fontWeight: FontWeight.w700,
										color: const Color(0xFF1E3A8A),
										letterSpacing: 0.2,
									),
								),
							),
							ContentPage(
                content: chap.content,
                languageCode: selectedLanguageCode,
                collectedStarIds: collectedStarIds,
                onStarCollected: onStarCollected,
              ),
						],
					),
				);
			}
		} else {
			return ContentPage(
        content: content,
        languageCode: selectedLanguageCode,
        collectedStarIds: collectedStarIds,
        onStarCollected: onStarCollected,
      );
		}
	}

}

