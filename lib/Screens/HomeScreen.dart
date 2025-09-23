import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:master_demo_app/Api/hooks/database.dart';
import 'package:master_demo_app/Api/hooks/open_ai.dart';
import 'package:master_demo_app/env.dart';
import 'ChapterContent.dart';
import '../Models/models.dart';
import 'BurgerMenu.dart';
import 'IDEenvironement.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HomeScreen extends StatefulWidget {
	const HomeScreen({Key? key, this.title = 'Welcome back Lindi Mokele'}) : super(key: key);
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
	int? selectedChapterIndex;
  String selectedLanguage = 'English';
  final List<String> southAfricanLanguages = [
    'English',
    'Afrikaans',
    'isiZulu',
    'isiXhosa',
    'Sepedi',
    'Setswana',
    'Sesotho',
    'Xitsonga',
    'siSwati',
    'Tshivenda',
    'isiNdebele',
  ];

	@override
	void initState() {
		super.initState();
		loadJsonContent();
    // loadContentFirebase();
    final apiKey = OPEN_AI_KEY;
    openai = OpenAIService(apiKey!);
    // addAllChaptersFromJsonAsset('lib/Api/data/chapter1content.json');
    // createSampleChapter(); //check
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
							content = chapter.content;
							loading = false;
						});
					} else if (decoded is List) {
						// Map list entries to Chapter objects
							setState(() {
								chapters = decoded.map<Chapter>((e) => Chapter.fromJson(e as Map<String, dynamic>)).toList();
								// also flatten first chapter into content for backward compatibility
								content = chapters.isNotEmpty ? chapters.first.content : [];
								// default select the first chapter
								selectedChapterIndex = chapters.isNotEmpty ? 0 : null;
								loading = false;
							});
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

  void onLanguageSelected(String? lang) async {
    if (lang != null) {
      setState(() {
        selectedLanguage = lang;
        loading = true;
      });
      print('Selected language: $lang');
      final translated = await openai.translateJsonNested(chapters, lang);
      setState(() {
        chapters = (translated as List).map<Chapter>((e) => Chapter.fromJson(e)).toList();
        content = chapters.isNotEmpty ? chapters.first.content : [];
        selectedChapterIndex = chapters.isNotEmpty ? 0 : null;
        loading = false;
      });
    }
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
			appBar: AppBar(
				title: Text(widget.title),
				actions: [
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
					padding: const EdgeInsets.all(8),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Padding(
								padding: const EdgeInsets.symmetric(vertical: 12),
								child: Row(
									children: [
										Expanded(child: Text(chap.chapter, style: Theme.of(context).textTheme.headlineSmall)),
										ElevatedButton(
											style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
											onPressed: () {
												Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MiniIDE()));
											},
											child: Text('Open Environment'),
										),
									],
								),
							),
							ContentPage(content: chap.content),
						],
					),
				);
			} else {
				// Default: show the first chapter
				final chap = chapters.first;
				return SingleChildScrollView(
					padding: const EdgeInsets.all(8),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Padding(
								padding: const EdgeInsets.symmetric(vertical: 12),
								child: Text(chap.chapter, style: Theme.of(context).textTheme.headlineSmall),
							),
							ContentPage(content: chap.content),
						],
					),
				);
			}
		} else {
			return ContentPage(content: content);
		}
	}

}

