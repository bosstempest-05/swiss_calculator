import 'package:flutter/material.dart';
import 'dart:async';

class PomodoroTimer extends StatefulWidget {
  const PomodoroTimer({super.key});

  @override
  State<PomodoroTimer> createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer> {
  int _workDuration = 25;
  int _breakDuration = 5;

  late int _timeLeft;
  bool _isRunning = false;
  bool _isWorkMode = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timeLeft = _workDuration * 60;
  }

  void _startTimer() {
    if (_timer != null) _timer!.cancel();
    setState(() => _isRunning = true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _timer!.cancel();
          _isRunning = false;
          _toggleMode();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _timeLeft = _isWorkMode ? (_workDuration * 60) : (_breakDuration * 60);
    });
  }

  void _toggleMode() {
    _timer?.cancel();
    setState(() {
      _isWorkMode = !_isWorkMode;
      _timeLeft = _isWorkMode ? (_workDuration * 60) : (_breakDuration * 60);
      _isRunning = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _showSettings(Color adaptiveText) {
    double tempWork = _workDuration.toDouble();
    double tempBreak = _breakDuration.toDouble();

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Timer Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: adaptiveText,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Work Duration',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      Text(
                        '${tempWork.toInt()} min',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: adaptiveText,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: tempWork,
                    min: 1,
                    max: 90,
                    activeColor: Theme.of(context).colorScheme.primary,
                    onChanged: (val) => setModalState(() => tempWork = val),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Break Duration',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      Text(
                        '${tempBreak.toInt()} min',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: adaptiveText,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: tempBreak,
                    min: 1,
                    max: 30,
                    activeColor: Colors.greenAccent,
                    onChanged: (val) => setModalState(() => tempBreak = val),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _workDuration = tempWork.toInt();
                          _breakDuration = tempBreak.toInt();
                          _resetTimer();
                        });
                        Navigator.pop(context);
                      },
                      child: Text(
                        'SAVE',
                        style: TextStyle(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalTime = _isWorkMode ? (_workDuration * 60) : (_breakDuration * 60);
    double progress = _timeLeft / totalTime;

    // ---> NEW: Light Mode Logic <---
    bool isLightMode = Theme.of(context).brightness == Brightness.light;
    Color adaptiveTextColor = isLightMode ? Colors.black87 : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pomodoro Timer',
          style: TextStyle(color: adaptiveTextColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: adaptiveTextColor),
        actions: [
          IconButton(
            icon: Icon(Icons.tune, size: 28, color: adaptiveTextColor),
            onPressed: () => _showSettings(adaptiveTextColor),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildModeButton('Work', _isWorkMode, adaptiveTextColor),
                  _buildModeButton('Break', !_isWorkMode, adaptiveTextColor),
                ],
              ),
            ),
            const SizedBox(height: 60),

            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 250,
                  height: 250,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _isWorkMode
                          ? Theme.of(context).colorScheme.primary
                          : Colors.greenAccent,
                    ),
                  ),
                ),
                // ---> NEW: Smooth fade animation on the ticking clock! <---
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    _formatTime(_timeLeft),
                    key: ValueKey<int>(_timeLeft),
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: adaptiveTextColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _resetTimer,
                  icon: const Icon(Icons.refresh, size: 36),
                  color: Colors.grey,
                ),
                const SizedBox(width: 24),
                FloatingActionButton.large(
                  onPressed: _isRunning ? _pauseTimer : _startTimer,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Icon(
                    _isRunning ? Icons.pause : Icons.play_arrow,
                    size: 40,
                    // Reverses color so it pops against the primary color
                    color: isLightMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(width: 24),
                IconButton(
                  onPressed: _toggleMode,
                  icon: const Icon(Icons.skip_next, size: 36),
                  color: Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton(String text, bool isActive, Color adaptiveText) {
    return GestureDetector(
      onTap: () {
        if (!isActive) _toggleMode();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            // Reverses the text color of the active chip
            color: isActive
                ? Theme.of(context).scaffoldBackgroundColor
                : Colors.grey,
          ),
        ),
      ),
    );
  }
}
