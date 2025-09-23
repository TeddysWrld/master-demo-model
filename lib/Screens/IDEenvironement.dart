import 'package:flutter/material.dart';
import 'package:master_demo_app/Api/hooks/open_ai.dart';
import 'package:master_demo_app/env.dart';

// Mini IDE demo widget
class MiniIDE extends StatefulWidget {
  const MiniIDE({Key? key}) : super(key: key);

  @override
  State<MiniIDE> createState() => _MiniIDEState();
}

class _MiniIDEState extends State<MiniIDE> {
  final TextEditingController _controller = TextEditingController(
    text: "int add(int a, int b) => a + b;\nprint(add(2,3));",
  );
  late OpenAIService openai;
  String output = '';
  String hints = 'Tip: Try writing a function and calling it. Use print() to show output.';
  bool _running = false;

  Future<void> _runCode() async {
    setState(() {
      _running = true;
      output = '';
    });

    final source = _controller.text;
    try {
      var test = await openai.reviewAndExecuteCode(_controller.text);
      print("Test results: $test");
    } catch (e) {
      print("Error: $e");
    }
    try {
      // For a simple demo we simulate execution. Real dart_eval integration
      // requires setting up the compiler/runtime according to the package
      // version and capturing prints. If you want that, I can implement it
      // after confirming the dart_eval version.
      await Future.delayed(const Duration(milliseconds: 200));
      var results = await openai.reviewAndExecuteCode(source);
      print("Test results: $results");
      setState(() {
        output = 'Simulated run output:\n${results!["execution_result"]}';
        hints = 'Code reviewed. Suggestions:\n${results["review"]}';
      });
    } catch (e) {
      setState(() {
        output = 'Error: $e';
      });
    } finally {
      setState(() {
        _running = false;
      });
    }
  }

  void clearResults() {
    setState(() {
      output = '';
      hints = 'Tip: Try writing a function and calling it. Use print() to show output.';
    });
  }

  @override
  void initState() {
    super.initState();
    final apiKey = OPEN_AI_KEY;
    openai = OpenAIService(apiKey);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mini IDE')),
      body: LayoutBuilder(builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Row(
                children: [
                  // Editor
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.grey.shade100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('Editor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(height: 8),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              maxLines: null,
                              expands: true,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Type Code here (logic only).',
                              ),
                              style: const TextStyle(fontFamily: 'monospace', fontSize: 15),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: _running ? null : _runCode,
                                icon: _running
                                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                    : const Icon(Icons.play_arrow),
                                label: const Text('Run'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() => _controller.text = '');
                                  clearResults();
                                },
                                icon: const Icon(Icons.clear),
                                label: const Text('Clear'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Output
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.grey.shade50,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('Output', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
                              child: SingleChildScrollView(child: Text(output, style: const TextStyle(fontFamily: 'monospace', fontSize: 14))),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Suggestions bottom
            Container(
              height: 120,
              decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade300)), color: Colors.white),
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Hints and Suggestions', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Expanded(child: SingleChildScrollView(child: Text(hints))),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
