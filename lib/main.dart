import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import 'viseme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RiveNative.init();
  runApp(const LipsyncApp());
}

class LipsyncApp extends StatelessWidget {
  const LipsyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lipsync Test',
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple),
      home: const LipsyncPage(),
    );
  }
}

class LipsyncPage extends StatefulWidget {
  const LipsyncPage({super.key});

  @override
  State<LipsyncPage> createState() => _LipsyncPageState();
}

class _LipsyncPageState extends State<LipsyncPage> {
  static const _riveAsset = 'assets/dwarf-talking.riv';
  static const _viewModelName = 'ViewModel1';
  static const _propertyName = 'Laut';

  /// How long one beat is. Normal sounds take one beat, long vowels take
  /// [longSoundBeats] beats.
  static const _soundDuration = Duration(milliseconds: 120);

  final _textController = TextEditingController();

  File? _file;
  RiveWidgetController? _controller;
  ViewModelInstance? _viewModelInstance;
  ViewModelInstanceString? _lautProperty;
  String? _error;

  Timer? _playback;
  Viseme? _current;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final file = await File.asset(_riveAsset, riveFactory: Factory.rive);
      if (file == null) throw Exception('Could not load $_riveAsset');

      final controller = RiveWidgetController(file);

      final viewModel = file.viewModelByName(_viewModelName);
      if (viewModel == null) {
        throw Exception('View model "$_viewModelName" not found in file');
      }
      final instance = viewModel.createDefaultInstance();
      if (instance == null) {
        throw Exception('Could not create instance of "$_viewModelName"');
      }
      controller.dataBind(DataBind.byInstance(instance));

      final laut = instance.string(_propertyName);
      if (laut == null) {
        throw Exception('String property "$_propertyName" not found');
      }

      laut.value = Viseme.closed.riveValue;

      setState(() {
        _file = file;
        _controller = controller;
        _viewModelInstance = instance;
        _lautProperty = laut;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  /// Plays the mouth shapes for [text] one after another, then closes the mouth.
  void _speak(String text) {
    _playback?.cancel();
    final sequence = [...textToVisemes(text), Viseme.closed];
    var index = 0;

    void step() {
      _setViseme(sequence[index]);
      index++;
      if (index >= sequence.length) _playback?.cancel();
    }

    step();
    if (index < sequence.length) {
      _playback = Timer.periodic(_soundDuration, (_) => step());
    }
  }

  void _setViseme(Viseme viseme) {
    _lautProperty?.value = viseme.riveValue;
    setState(() => _current = viseme);
  }

  @override
  void dispose() {
    _playback?.cancel();
    _textController.dispose();
    _lautProperty?.dispose();
    _viewModelInstance?.dispose();
    _controller?.dispose();
    _file?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      appBar: AppBar(title: const Text('Lipsync Test')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _error != null
                  ? Center(child: Text(_error!, textAlign: TextAlign.center))
                  : controller == null
                      ? const Center(child: CircularProgressIndicator())
                      : RiveWidget(controller: controller, fit: Fit.contain),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('Laut: ${_current?.riveValue ?? '-'}'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _textController,
                    enabled: _lautProperty != null,
                    onSubmitted: _speak,
                    decoration: InputDecoration(
                      labelText: 'Text',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: _lautProperty == null
                            ? null
                            : () => _speak(_textController.text),
                      ),
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
}
