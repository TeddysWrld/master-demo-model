import 'package:flutter/material.dart';
import 'package:master_demo_app/env.dart';
import '../Models/models.dart';
import '../Api/hooks/open_ai.dart';

class _FruitOption {
  final String name;
  final Color color;

  const _FruitOption({
    required this.name,
    required this.color,
  });
}

class ContentPage extends StatefulWidget {
  final List<ContentItem> content;
  final bool scrollable;
  final String languageCode;
  final Set<String> collectedStarIds;
  final ValueChanged<String> onStarCollected;

  const ContentPage({
    super.key,
    required this.content,
    this.scrollable = true,
    this.languageCode = 'en',
    required this.collectedStarIds,
    required this.onStarCollected,
  });

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  String? droppedValue; // For interactive blocks
  late OpenAIService openAIService;
  final Map<String, int> _selectedOptions = {};
  final Set<String> _submittedChallenges = {};
  final Set<String> _unlockedChallenges = {};

  @override
  void initState() {
    super.initState();
    openAIService = OpenAIService(OPEN_AI_KEY);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.content.isEmpty) {
      return const Center(child: Text('No content available'));
    }

    final contentColumn = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.content.map<Widget>((item) => renderItem(item)).toList(),
      ),
    );

    if (widget.scrollable) {
      return SingleChildScrollView(child: contentColumn);
    }

    return contentColumn;
  }

  Widget renderItem(ContentItem item) {
    if (item.lockId != null && !_unlockedChallenges.contains(item.lockId)) {
      return const SizedBox.shrink();
    }

    switch (item.type) {
      case 'heading':
      case 'interactive_heading':
        final fontSize = (item.style?.fontSize ?? 22).toDouble();
        final isMainHeading = fontSize >= 26;
        return Padding(
          padding: EdgeInsets.only(top: isMainHeading ? 20 : 14, bottom: isMainHeading ? 6 : 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            item.text ?? '',
                            style: TextStyle(
                              fontSize: fontSize,
                              color: item.style?.color != null
                                  ? Color(int.parse(item.style!.color!.substring(1), radix: 16) + 0xFF000000)
                                  : Colors.black,
                              fontWeight: item.style?.bold == true ? FontWeight.bold : FontWeight.normal,
                              height: 1.3,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.volume_up, size: 18),
                            onPressed: () => openAIService.speakText(item.text ?? '', widget.languageCode),
                          ),
                        ],
                      ),
                    ),
                    if (item.imagePath != null) ...[
                      const SizedBox(width: 12),
                      Image.asset(
                        item.imagePath!,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ],
                ),
              ),
              if (isMainHeading) ...[
                const SizedBox(height: 6),
                Container(height: 2, decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF1E3A8A), Colors.transparent]),
                  borderRadius: BorderRadius.circular(1),
                )),
              ],
            ],
          ),
        );

      case 'paragraph':
        final paragraphText = item.text ?? '';
        const notePrefix = '🧠 Note:';
        final isNote = paragraphText.startsWith(notePrefix);
        final noteBody = isNote ? paragraphText.substring(notePrefix.length).trimLeft() : '';

        if (isNote) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(8),
                border: const Border(left: BorderSide(color: Color(0xFFF59E0B), width: 3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 15, color: Color(0xFF374151), height: 1.6),
                        children: [
                          const TextSpan(
                            text: '🧠 Note: ',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                          ),
                          TextSpan(text: noteBody),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up, size: 16, color: Color(0xFFB45309)),
                    onPressed: () => openAIService.speakText(paragraphText, widget.languageCode),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(paragraphText, style: const TextStyle(fontSize: 16, height: 1.6, color: Color(0xFF374151))),
              IconButton(
                icon: const Icon(Icons.volume_up, size: 18),
                onPressed: () => openAIService.speakText(paragraphText, widget.languageCode),
              ),
            ],
          ),
        );

      case 'list':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...(item.items ?? []).map((i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 5, right: 8),
                      child: Icon(Icons.circle, size: 6, color: Color(0xFF6B7280)),
                    ),
                    Expanded(
                      child: Text(i, style: const TextStyle(fontSize: 16, height: 1.5, color: Color(0xFF374151))),
                    ),
                  ],
                ),
              )).toList(),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.volume_up, size: 18),
                  onPressed: () => openAIService.speakText((item.items ?? []).join('. '), widget.languageCode),
                ),
              ),
            ],
          ),
        );

      case 'code':
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                child: Text(
                  item.text ?? '',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    height: 1.6,
                    color: Color(0xFFE2E8F0),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.volume_up, size: 16, color: Color(0xFF94A3B8)),
                  onPressed: () => openAIService.speakText(item.text ?? '', widget.languageCode),
                ),
              ),
            ],
          ),
        );

      case 'image':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.imagePath != null)
                Image.asset(item.imagePath!, fit: BoxFit.contain),
              if (item.caption != null) ...[
                const SizedBox(height: 6),
                Text(item.caption!, style: const TextStyle(fontSize: 14, color: Colors.black54)),
              ],
            ],
          ),
        );

      case 'variable_basket_demo':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: _VariableBasketDemo(item: item),
        );

      case 'copy_variable_demo':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: _CopyVariableDemo(item: item),
        );

      case 'override_variable_demo':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: _OverrideVariableDemo(item: item),
        );

      case 'interactive_blocks':
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: (item.blocks ?? []).map((block) => Draggable<String>(
                data: block.value.toString(),
                feedback: _buildBlock(block),
                childWhenDragging: Opacity(
                  opacity: 0.5,
                  child: _buildBlock(block),
                ),
                child: _buildBlock(block),
              )).toList(),
        );

      case 'basket_items':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: (item.blocks ?? []).map((block) => Draggable<String>(
                  data: block.value.toString(),
                  feedback: _buildBlock(block),
                  childWhenDragging: Opacity(
                    opacity: 0.5,
                    child: _buildBlock(block),
                  ),
                  child: _buildBlock(block),
                )).toList(),
            ),
            const SizedBox(height: 24),
            DragTarget<String>(
              onAccept: (data) {
                setState(() {
                  item.basketCount = item.basketCount + 1;
                });
              },
              builder: (context, candidateData, rejectedData) {
                return Column(
                  children: [
                    Icon(Icons.shopping_basket, size: 64, color: Colors.brown.shade400),
                    Text('Basket count: ${item.basketCount}', style: const TextStyle(fontSize: 18)),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            Text('When you assign a value to a variable, it is placed in the basket. The count increases each time you drop a block into the basket.',
                style: const TextStyle(fontSize: 15, color: Colors.black54)),
          ],
        );

      case 'variable_assignment':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Draggable<String>(
                  data: item.text ?? '',
                  feedback: _buildBlock(InteractiveBlock(
                    name: item.text ?? '',
                    value: item.text ?? '',
                    color: '#6366F1',
                  )),
                  child: _buildBlock(InteractiveBlock(
                    name: item.text ?? '',
                    value: item.text ?? '',
                    color: '#6366F1',
                  )),
                ),
                const SizedBox(width: 24),
                DragTarget<String>(
                  onAccept: (data) {
                    setState(() {
                      droppedValue = data;
                    });
                  },
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      width: 100,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        border: Border.all(color: Colors.amber, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(droppedValue == null ? 'Drop here' : 'Assigned: $droppedValue'),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(item.description ?? 'Drag the variable to the box to assign its value.', style: const TextStyle(fontSize: 15, color: Colors.black54)),
          ],
        );

      case 'if_condition':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Draggable<String>(
                  data: 'true',
                  feedback: _buildBlock(InteractiveBlock(name: 'true', value: true, color: '#22D3EE')),
                  child: _buildBlock(InteractiveBlock(name: 'true', value: true, color: '#22D3EE')),
                ),
                const SizedBox(width: 16),
                Draggable<String>(
                  data: 'false',
                  feedback: _buildBlock(InteractiveBlock(name: 'false', value: false, color: '#F87171')),
                  child: _buildBlock(InteractiveBlock(name: 'false', value: false, color: '#F87171')),
                ),
                const SizedBox(width: 24),
                DragTarget<String>(
                  onAccept: (data) {
                    setState(() {
                      droppedValue = data;
                    });
                  },
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      width: 100,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        border: Border.all(color: Colors.blue, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          droppedValue == 'true'
                              ? (item.text ?? 'Condition is TRUE!')
                              : droppedValue == 'false'
                                  ? (item.items?.first ?? 'Condition is FALSE!')
                                  : 'Drop true/false',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(item.description ?? 'Drag true/false to the box to see what happens in an if-statement.', style: const TextStyle(fontSize: 15, color: Colors.black54)),
          ],
        );

      case 'loop_counter':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      item.basketCount = (item.basketCount) + 1;
                    });
                  },
                  child: const Text('Next Iteration'),
                ),
                const SizedBox(width: 24),
                Text('Counter: ${item.basketCount}', style: const TextStyle(fontSize: 18)),
              ],
            ),
            const SizedBox(height: 8),
            Text(item.description ?? 'Click to simulate a loop incrementing a counter.', style: const TextStyle(fontSize: 15, color: Colors.black54)),
          ],
        );

      case 'challenge':
        return _buildChallenge(item);

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildChallenge(ContentItem item) {
    final id = item.id ?? item.title ?? item.prompt ?? item.text ?? 'challenge';
    final selected = _selectedOptions[id];
    final submitted = _submittedChallenges.contains(id);
    final isCorrect = submitted && selected == item.correctIndex;
    final starCollected = widget.collectedStarIds.contains(id);
    final options = item.options ?? [];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF1E3A8A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_events_rounded, color: Color(0xFFF7C948), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.title ?? 'Challenge',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.prompt != null) ...[
                  Text(item.prompt!, style: const TextStyle(fontSize: 16, height: 1.5, color: Color(0xFF374151))),
                  const SizedBox(height: 12),
                ],
                if (item.code != null) ...[
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      item.code!,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        height: 1.6,
                        color: Color(0xFFE2E8F0),
                      ),
                    ),
                  ),
                ],

                // Option cards
                ...options.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final option = entry.value;
                  final isSelected = selected == idx;
                  final isThisCorrect = submitted && idx == item.correctIndex;
                  final isThisWrong = submitted && isSelected && !isCorrect;

                  Color borderColor = const Color(0xFFE2E8F0);
                  Color bgColor = const Color(0xFFF8FAFC);
                  Color labelColor = const Color(0xFF374151);
                  Color badgeBg = const Color(0xFFE2E8F0);
                  Color badgeFg = const Color(0xFF6B7280);

                  if (!submitted && isSelected) {
                    borderColor = const Color(0xFF3B82F6);
                    bgColor = const Color(0xFFEFF6FF);
                    badgeBg = const Color(0xFF3B82F6);
                    badgeFg = Colors.white;
                    labelColor = const Color(0xFF1D4ED8);
                  } else if (isThisCorrect) {
                    borderColor = const Color(0xFF22C55E);
                    bgColor = const Color(0xFFF0FDF4);
                    badgeBg = const Color(0xFF22C55E);
                    badgeFg = Colors.white;
                    labelColor = const Color(0xFF166534);
                  } else if (isThisWrong) {
                    borderColor = const Color(0xFFEF4444);
                    bgColor = const Color(0xFFFEF2F2);
                    badgeBg = const Color(0xFFEF4444);
                    badgeFg = Colors.white;
                    labelColor = const Color(0xFF991B1B);
                  }

                  return GestureDetector(
                    onTap: submitted ? null : () => setState(() => _selectedOptions[id] = idx),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderColor, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(color: badgeBg, shape: BoxShape.circle),
                            child: Center(
                              child: Text(
                                String.fromCharCode(65 + idx),
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: badgeFg),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(option, style: TextStyle(fontSize: 15, color: labelColor, height: 1.4)),
                          ),
                          if (isThisCorrect)
                            const Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E), size: 20),
                          if (isThisWrong)
                            const Icon(Icons.cancel_rounded, color: Color(0xFFEF4444), size: 20),
                        ],
                      ),
                    ),
                  );
                }).toList(),

                const SizedBox(height: 4),

                // Action buttons
                Row(
                  children: [
                    if (!submitted)
                      ElevatedButton(
                        onPressed: selected == null
                            ? null
                            : () => setState(() => _submittedChallenges.add(id)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFFCBD5E1),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: const Text('Check Answer', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    if (submitted && !isCorrect) ...[
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _submittedChallenges.remove(id);
                            _selectedOptions.remove(id);
                          });
                        },
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: Text(item.retryLabel ?? 'Try again'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFEF4444),
                          side: const BorderSide(color: Color(0xFFEF4444)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ],
                ),

                // Feedback banner
                if (submitted) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isCorrect ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isCorrect ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isCorrect ? Icons.check_circle_rounded : Icons.info_rounded,
                          color: isCorrect ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            isCorrect
                                ? (item.successMessage ?? 'Correct!')
                                : (item.failureMessage ?? 'Incorrect. Try again.'),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isCorrect ? const Color(0xFF166534) : const Color(0xFF991B1B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Post-correct actions
                if (submitted && isCorrect) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (item.showStarButton == true)
                        ElevatedButton.icon(
                          onPressed: starCollected
                              ? null
                              : () {
                                  widget.onStarCollected(id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Star collected!')),
                                  );
                                },
                          icon: Icon(
                            starCollected ? Icons.star_rounded : Icons.star_border_rounded,
                            color: starCollected ? const Color(0xFF92400E) : const Color(0xFF7C4D00),
                            size: 18,
                          ),
                          label: Text(
                            starCollected ? 'Star collected' : (item.starLabel ?? 'Collect your star'),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: starCollected ? const Color(0xFFFEF3C7) : const Color(0xFFF7C948),
                            foregroundColor: const Color(0xFF7C4D00),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      if (item.unlockTarget != null && !_unlockedChallenges.contains(item.unlockTarget))
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() => _unlockedChallenges.add(item.unlockTarget!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(item.unlockLabel ?? 'Challenge unlocked')),
                            );
                          },
                          icon: const Icon(Icons.lock_open_rounded, size: 16),
                          label: Text(item.unlockLabel ?? 'Unlock next challenge'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlock(InteractiveBlock block) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(int.parse(block.color.substring(1), radix: 16) + 0xFF000000),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(blurRadius: 3, offset: Offset(2, 2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(block.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          if (block.description != null)
            Text(
              block.description!,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
        ],
      ),
    );
  }
}

class _VariableBasketDemo extends StatefulWidget {
  final ContentItem item;

  const _VariableBasketDemo({
    required this.item,
  });

  @override
  State<_VariableBasketDemo> createState() => _VariableBasketDemoState();
}

class _VariableBasketDemoState extends State<_VariableBasketDemo> {
  static const List<_FruitOption> _fruitOptions = [
    _FruitOption(name: 'Apple', color: Color(0xFFEF4444)),
    _FruitOption(name: 'Banana', color: Color(0xFFF59E0B)),
    _FruitOption(name: 'Orange', color: Color(0xFFF97316)),
  ];

  _FruitOption? _storedFruit;
  _FruitOption? _droppingFruit;
  bool _isDropping = false;
  String _explanation = 'Click a fruit to store it in the basket.';

  Future<void> _storeFruit(_FruitOption fruit) async {
    setState(() {
      _droppingFruit = fruit;
      _isDropping = true;
      _explanation = 'Storing ${fruit.name} in Fruitbasket...';
    });

    await Future<void>.delayed(const Duration(milliseconds: 550));
    if (!mounted) return;

    setState(() {
      _storedFruit = fruit;
      _droppingFruit = null;
      _isDropping = false;
      _explanation =
          '${fruit.name} is now stored in the basket. This is like assigning a value to a variable.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeFruit = _storedFruit ?? _droppingFruit;
    final accentColor = activeFruit?.color ?? const Color(0xFF8B5E3C);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.item.text ?? 'Click a fruit to store it in the basket.',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _fruitOptions
                .map(
                  (fruit) => ElevatedButton(
                    onPressed: _isDropping ? null : () => _storeFruit(fruit),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: fruit.color.withOpacity(0.14),
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: fruit.color.withOpacity(0.35)),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: fruit.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          fruit.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final useColumn = constraints.maxWidth < 760;

              final illustrationPanel = Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Visual analogy',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    if (widget.item.imagePath != null)
                      Expanded(
                        child: Center(
                          child: AnimatedScale(
                            scale: _isDropping ? 1.03 : 1,
                            duration: const Duration(milliseconds: 250),
                            child: Image.asset(widget.item.imagePath!, fit: BoxFit.contain),
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    if (widget.item.caption != null)
                      Text(
                        widget.item.caption!,
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                  ],
                ),
              );

              final basketPanel = Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFFBEB), Color(0xFFFFFFFF)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: accentColor.withOpacity(0.35)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDBEAFE),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'Variable name: Fruitbasket',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1D4ED8),
                            ),
                          ),
                        ),
                        if (_storedFruit != null)
                          Text(
                            'Value stored',
                            style: TextStyle(
                              fontSize: 13,
                              color: accentColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: double.infinity,
                            constraints: const BoxConstraints(maxWidth: 280),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: accentColor, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withOpacity(0.12),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.shopping_basket, size: 52, color: accentColor),
                                const SizedBox(height: 12),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 320),
                                  transitionBuilder: (child, animation) {
                                    return ScaleTransition(
                                      scale: CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOutBack,
                                      ),
                                      child: FadeTransition(opacity: animation, child: child),
                                    );
                                  },
                                  child: Text(
                                    _storedFruit == null
                                        ? 'Basket is empty'
                                        : _storedFruit!.name,
                                    key: ValueKey(_storedFruit?.name ?? 'empty'),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_droppingFruit != null)
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 520),
                              curve: Curves.easeInOutCubic,
                              top: _isDropping ? 92 : 10,
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 180),
                                opacity: _isDropping ? 1 : 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _droppingFruit!.color.withOpacity(0.16),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: _droppingFruit!.color.withOpacity(0.4),
                                    ),
                                  ),
                                  child: Text(
                                    _droppingFruit!.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Container(
                        key: ValueKey(_storedFruit?.name ?? _explanation),
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          _storedFruit == null
                              ? 'Fruitbasket = empty'
                              : 'Fruitbasket = ${_storedFruit!.name}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _explanation,
                      style: const TextStyle(fontSize: 15, color: Colors.black87),
                    ),
                  ],
                ),
              );

              if (useColumn) {
                return Column(
                  children: [
                    SizedBox(height: 320, child: illustrationPanel),
                    const SizedBox(height: 16),
                    SizedBox(height: 380, child: basketPanel),
                  ],
                );
              }

              return SizedBox(
                height: 400,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: illustrationPanel),
                    const SizedBox(width: 16),
                    Expanded(child: basketPanel),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CopyVariableDemo extends StatefulWidget {
  final ContentItem item;

  const _CopyVariableDemo({
    required this.item,
  });

  @override
  State<_CopyVariableDemo> createState() => _CopyVariableDemoState();
}

class _CopyVariableDemoState extends State<_CopyVariableDemo> {
  static const List<_FruitOption> _fruitOptions = [
    _FruitOption(name: 'Apple', color: Color(0xFFEF4444)),
    _FruitOption(name: 'Banana', color: Color(0xFFF59E0B)),
    _FruitOption(name: 'Orange', color: Color(0xFFF97316)),
  ];

  _FruitOption? _basketA;
  _FruitOption? _basketB;
  String _explanation =
      'Select a fruit for Basket A, then press COPY to copy it to Basket B.';

  void _storeInA(_FruitOption fruit) {
    setState(() {
      _basketA = fruit;
      _explanation =
          '${fruit.name} is stored in Basket A. Now click COPY to transfer the value.';
    });
  }

  void _copyToB() {
    if (_basketA == null) {
      setState(() {
        _explanation = 'Please select a fruit in Basket A first.';
      });
      return;
    }

    setState(() {
      _basketB = _basketA;
      _explanation =
          'Value copied! Basket B now has ${_basketB!.name}. Both baskets hold the same value.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.item.text ?? 'Select a fruit for Basket A, then press COPY to copy it to Basket B.',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _fruitOptions.map((fruit) {
              final isSelected = _basketA?.name == fruit.name;

              return ElevatedButton(
                onPressed: () => _storeInA(fruit),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? fruit.color : fruit.color.withOpacity(0.14),
                  foregroundColor: isSelected ? Colors.white : Colors.black87,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: fruit.color.withOpacity(0.35)),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : fruit.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      fruit.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final vertical = constraints.maxWidth < 680;

              if (vertical) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildBasketCard(
                      label: 'Basket A',
                      fruit: _basketA,
                      color: const Color(0xFF355C7D),
                      animated: false,
                    ),
                    const SizedBox(height: 18),
                    _buildBasketCard(
                      label: 'Basket B',
                      fruit: _basketB,
                      color: const Color(0xFF2A9D8F),
                      animated: true,
                    ),
                    const SizedBox(height: 18),
                    _buildCopyButton(),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _buildBasketCard(
                      label: 'Basket A',
                      fruit: _basketA,
                      color: const Color(0xFF355C7D),
                      animated: false,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: _buildBasketCard(
                      label: 'Basket B',
                      fruit: _basketB,
                      color: const Color(0xFF2A9D8F),
                      animated: true,
                    ),
                  ),
                  const SizedBox(width: 18),
                  _buildCopyButton(),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Text(
              _explanation,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyButton() {
    return ElevatedButton(
      onPressed: _copyToB,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1D3557),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: const Text(
        'COPY ->',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildBasketCard({
    required String label,
    required _FruitOption? fruit,
    required Color color,
    required bool animated,
  }) {
    final textWidget = Text(
      fruit?.name ?? 'Empty',
      key: ValueKey(fruit?.name ?? 'Empty'),
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 110,
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 2),
              borderRadius: BorderRadius.circular(16),
              color: color.withOpacity(0.05),
            ),
            child: Center(
              child: animated
                  ? AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: textWidget,
                    )
                  : textWidget,
            ),
          ),
        ],
      ),
    );
  }
}

class _OverrideVariableDemo extends StatefulWidget {
  final ContentItem item;

  const _OverrideVariableDemo({
    required this.item,
  });

  @override
  State<_OverrideVariableDemo> createState() => _OverrideVariableDemoState();
}

class _OverrideVariableDemoState extends State<_OverrideVariableDemo> {
  static const List<_FruitOption> _fruitOptions = [
    _FruitOption(name: 'Apple', color: Color(0xFFEF4444)),
    _FruitOption(name: 'Banana', color: Color(0xFFF59E0B)),
    _FruitOption(name: 'Orange', color: Color(0xFFF97316)),
  ];

  _FruitOption? _basketFruit;
  String _explanation =
      'Click a fruit to store it. Click another fruit to override the value.';

  void _updateFruit(_FruitOption fruit) {
    setState(() {
      if (_basketFruit == null) {
        _basketFruit = fruit;
        _explanation =
            '${fruit.name} is stored in the basket. This is assigning a value to a variable.';
      } else {
        final oldFruit = _basketFruit!;
        _basketFruit = fruit;
        _explanation =
            'Value updated! ${oldFruit.name} was replaced with ${fruit.name}. This is overriding a variable value.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _basketFruit?.color ?? const Color(0xFF8B5E3C);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.item.text ??
                'Click a fruit to store it. Click another fruit to override the value.',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _fruitOptions.map((fruit) {
              final isSelected = _basketFruit?.name == fruit.name;

              return ElevatedButton(
                onPressed: () => _updateFruit(fruit),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? fruit.color : fruit.color.withOpacity(0.14),
                  foregroundColor: isSelected ? Colors.white : Colors.black87,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: fruit.color.withOpacity(0.35)),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : fruit.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      fruit.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Center(
            child: Container(
              width: 220,
              height: 140,
              decoration: BoxDecoration(
                border: Border.all(color: accentColor, width: 3),
                borderRadius: BorderRadius.circular(18),
                color: accentColor.withOpacity(0.06),
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: Text(
                    _basketFruit?.name ?? 'Basket (empty)',
                    key: ValueKey(_basketFruit?.name),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Text(
              _explanation,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
