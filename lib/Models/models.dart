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
  final String? id;
  final String? lockId;
  final String? title;
  final String? prompt;
  final List<String>? options;
  final int? correctIndex;
  final String? successMessage;
  final String? failureMessage;
  final bool? showStarButton;
  final String? starLabel;
  final String? unlockTarget;
  final String? unlockLabel;
  final String? retryLabel;
  final String? code;
  final String? successActionLabel;
  final String? imagePath;
  final String? caption;

  ContentItem({
    required this.type,
    this.text,
    this.items,
    this.blocks,
    this.style,
    this.basketCount = 0,
    this.description,
    this.id,
    this.lockId,
    this.title,
    this.prompt,
    this.options,
    this.correctIndex,
    this.successMessage,
    this.failureMessage,
    this.showStarButton,
    this.starLabel,
    this.unlockTarget,
    this.unlockLabel,
    this.retryLabel,
    this.code,
    this.successActionLabel,
    this.imagePath,
    this.caption,
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
      id: json['id'],
      lockId: json['lockId'],
      title: json['title'],
      prompt: json['prompt'],
      options: (json['options'] != null)
        ? List<String>.from(json['options'] as List<dynamic>)
        : null,
      correctIndex: json['correctIndex'],
      successMessage: json['successMessage'],
      failureMessage: json['failureMessage'],
      showStarButton: json['showStarButton'],
      starLabel: json['starLabel'],
      unlockTarget: json['unlockTarget'],
      unlockLabel: json['unlockLabel'],
      retryLabel: json['retryLabel'],
      code: json['code'],
      successActionLabel: json['successActionLabel'],
      imagePath: json['imagePath'],
      caption: json['caption'],
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
        if (id != null) 'id': id,
        if (lockId != null) 'lockId': lockId,
        if (title != null) 'title': title,
        if (prompt != null) 'prompt': prompt,
        if (options != null) 'options': options,
        if (correctIndex != null) 'correctIndex': correctIndex,
        if (successMessage != null) 'successMessage': successMessage,
        if (failureMessage != null) 'failureMessage': failureMessage,
        if (showStarButton != null) 'showStarButton': showStarButton,
        if (starLabel != null) 'starLabel': starLabel,
        if (unlockTarget != null) 'unlockTarget': unlockTarget,
        if (unlockLabel != null) 'unlockLabel': unlockLabel,
        if (retryLabel != null) 'retryLabel': retryLabel,
        if (code != null) 'code': code,
        if (successActionLabel != null) 'successActionLabel': successActionLabel,
        if (imagePath != null) 'imagePath': imagePath,
        if (caption != null) 'caption': caption,
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
