import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;




class SpeechToTextScreen extends StatefulWidget {
  @override
  _SpeechToTextScreenState createState() => _SpeechToTextScreenState();
}

class _SpeechToTextScreenState extends State<SpeechToTextScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = "Press the button and speak";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  // Start listening
  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() {
        _isListening = true;
      });
      _speech.listen(onResult: (result) {
        setState(() {
          _text = result.recognizedWords;
        });
      });
    }
  }

  // Stop listening
  void _stopListening() {
    setState(() {
      _isListening = false;
    });
    _speech.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voice to Text Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Speech to Text Conversion:',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              _text,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            IconButton(
              icon: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                size: 60,
                color: Colors.blue,
              ),
              onPressed: _isListening ? _stopListening : _startListening,
            ),
          ],
        ),
      ),
    );
  }
}
