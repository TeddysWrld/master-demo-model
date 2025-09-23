class Chapter {
  final String chapter;
  final List<ContentItem> content;

  Chapter({required this.chapter, required this.content});

  factory Chapter.fromJson(Map<String, dynamic> json) {
    var contentJson = json['content'] as List<dynamic>?;
    List<ContentItem> contentItems = [];
    if (contentJson != null) {
      contentItems = contentJson
          .map((e) => ContentItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return Chapter(chapter: json['chapter'] ?? '', content: contentItems);
  }

  Map<String, dynamic> toJson() => {
        'chapter': chapter,
        'content': content.map((e) => e.toJson()).toList(),
      };
}
extension ChapterJson on Chapter {
  Map<String, dynamic> toJsonList() {
    return {
      "chapter": chapter,
      "content": content.map((c) => c.toJson()).toList(),
    };
  }
}

// Base class for content items
class ContentItem {
  final String type;
  final String? text;
  final List<String>? items; // for lists
  final List<InteractiveBlock>? blocks; // for interactive_blocks
  final Style? style; // for headings or interactive headings
  int basketCount;
  final String? description; // for interactive explanations

  ContentItem({
    required this.type,
    this.text,
    this.items,
    this.blocks,
    this.style,
    this.basketCount = 0,
    this.description,
  });


  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      type: json['type'],
      text: json['text'],
      items: (json['items'] != null)
        ? List<String>.from(json['items'] as List<dynamic>)
        : null,
      blocks: (json['blocks'] != null)
        ? List<InteractiveBlock>.from((json['blocks'] as List<dynamic>)
            .map((b) => InteractiveBlock.fromJson(b as Map<String, dynamic>)))
        : null,
      style: json['style'] != null ? Style.fromJson(json['style']) : null,
      basketCount: json['basketCount'] ?? 0,
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        if (text != null) 'text': text,
        if (items != null) 'items': items,
        if (blocks != null) 'blocks': blocks!.map((b) => b.toJson()).toList(),
        if (style != null) 'style': style!.toJson(),
        'basketCount': basketCount,
        if (description != null) 'description': description,
      };
}

// Interactive block for draggable blocks
class InteractiveBlock {
  final String name;
  final dynamic value;
  final String color;
  final String? description;

  InteractiveBlock({
    required this.name,
    required this.value,
    required this.color,
    this.description,
  });

  factory InteractiveBlock.fromJson(Map<String, dynamic> json) {
    return InteractiveBlock(
      name: json['name'],
      value: json['value'],
      color: json['color'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'value': value,
        'color': color,
        if (description != null) 'description': description,
      };
}

// Optional style class for headings
class Style {
  final double? fontSize;
  final String? color;
  final bool? bold;

  Style({this.fontSize, this.color, this.bold});

  factory Style.fromJson(Map<String, dynamic> json) {
    return Style(
      fontSize: (json['fontSize'] != null) ? json['fontSize'].toDouble() : null,
      color: json['color'],
      bold: json['bold'],
    );
  }

  Map<String, dynamic> toJson() => {
        if (fontSize != null) 'fontSize': fontSize,
        if (color != null) 'color': color,
        if (bold != null) 'bold': bold,
      };
}
