import 'package:flutter/material.dart';
import 'package:master_demo_app/env.dart';
import '../Models/models.dart';
import '../Api/hooks/open_ai.dart';

class ContentPage extends StatefulWidget {
  final List<ContentItem> content;
  final bool scrollable;
  final String languageCode;

  const ContentPage({super.key, required this.content, this.scrollable = true, this.languageCode = 'en'});

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  String? droppedValue; // For interactive blocks
  late OpenAIService openAIService;

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

    final contentColumn = Padding(
      padding: const EdgeInsets.all(16),
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
    switch (item.type) {
      case 'heading':
      case 'interactive_heading':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                item.text ?? '',
                style: TextStyle(
                  fontSize: (item.style?.fontSize ?? 22).toDouble(),
                  color: item.style?.color != null
                      ? Color(int.parse(item.style!.color!.substring(1), radix: 16) + 0xFF000000)
                      : Colors.black,
                  fontWeight: item.style?.bold == true ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up, size: 18),
                onPressed: () => openAIService.speakText(item.text ?? '', widget.languageCode),
              ),
            ],
          ),
        );

      case 'paragraph':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(item.text ?? '', style: const TextStyle(fontSize: 16)),
              IconButton(
                icon: const Icon(Icons.volume_up, size: 18),
                onPressed: () => openAIService.speakText(item.text ?? '', widget.languageCode),
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
              ...(item.items ?? []).map((i) => Text("• $i", style: const TextStyle(fontSize: 16))).toList(),
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
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),
          color: Colors.grey.shade200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.text ?? '', style: const TextStyle(fontFamily: 'monospace')),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.volume_up, size: 18),
                  onPressed: () => openAIService.speakText(item.text ?? '', widget.languageCode),
                ),
              ),
            ],
          ),
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
  // basketCount is now non-nullable and defaults to 0
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
                    Text('Basket count: \\${item.basketCount}', style: const TextStyle(fontSize: 18)),
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
        // Visualizes assigning a value to a variable
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
        // Visualizes if/else logic
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
        // Visualizes a loop incrementing a counter
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

      default:
        return const SizedBox.shrink();
    }
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
