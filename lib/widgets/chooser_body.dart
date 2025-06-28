import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:byluck/widgets/positioned_circle.dart';

class ChooserBody extends StatefulWidget {
  const ChooserBody({super.key});

  @override
  State<ChooserBody> createState() => _ChooserBodyState();
}

class _ChooserBodyState extends State<ChooserBody>
    with TickerProviderStateMixin {
  final Map<int, Offset> touchPoints = {};
  final Map<int, double> touchScales = {};
  final Map<int, AnimationController> _controllers = {};
  Timer? _selectionTimer;
  int? _selectedPointerId;
  bool _acceptInput = true;

  @override
  void dispose() {
    _selectionTimer?.cancel();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Listener(
            onPointerDown: (event) {
              if (_acceptInput) {
                _handleNewTouch(event.pointer, event.localPosition);
              }
            },
            onPointerMove: (event) {
              if (_acceptInput || _selectedPointerId == event.pointer) {
                setState(() {
                  touchPoints[event.pointer] = event.localPosition;
                });
              }
            },
            onPointerUp: (event) {
              setState(() {
                _cleanUpPointer(event.pointer);
                if (event.pointer == _selectedPointerId) {
                  _selectedPointerId = null;
                  _acceptInput = true;
                }
                _resetSelectionTimer();
              });
            },
            onPointerCancel: (event) {
              setState(() {
                _cleanUpPointer(event.pointer);
                if (event.pointer == _selectedPointerId) {
                  _selectedPointerId = null;
                  _acceptInput = true;
                }
                _resetSelectionTimer();
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(
                top: 6,
                bottom: 6,
                left: 9,
                right: 9,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.grey[300],
                  boxShadow: [BoxShadow(color: Colors.red, blurRadius: 50)],
                ),
                child: Stack(
                  children:
                      touchPoints.entries.map((entry) {
                        return PositionedCircle(
                          pos: entry.value,
                          containerSize: constraints.biggest,
                          scale: touchScales[entry.key] ?? 1.0,
                          isSelected: _selectedPointerId == entry.key,
                        );
                      }).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleNewTouch(int pointerId, Offset position) async {
    setState(() {
      touchPoints[pointerId] = position;
      touchScales[pointerId] = 1.0;
      _startScalingAnimation(pointerId, isSelected: false);
    });
    _resetSelectionTimer();
  }

  void _resetSelectionTimer() {
    _selectionTimer?.cancel();
    if (touchPoints.length >= 2 && _acceptInput) {
      _selectionTimer = Timer(const Duration(seconds: 3), () {
        _selectRandomTouch();
      });
    }
  }

  Future<void> _selectRandomTouch() async {
    if (touchPoints.length < 2) return;

    // Enhanced vibration with multiple fallbacks
    try {
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 50));
      await HapticFeedback.vibrate();
    } catch (e) {
      debugPrint('Vibration error: $e');
    }

    final random = Random();
    final pointerIds = touchPoints.keys.toList();
    final selectedId = pointerIds[random.nextInt(pointerIds.length)];

    setState(() {
      _selectedPointerId = selectedId;
      _acceptInput = false;

      // Remove all other touches
      final idsToRemove = List<int>.from(touchPoints.keys)
        ..removeWhere((id) => id == selectedId);

      for (final id in idsToRemove) {
        _cleanUpPointer(id);
      }

      // Restart animation with faster speed for selected circle
      _controllers[selectedId]?.dispose();
      _startScalingAnimation(selectedId, isSelected: true);
    });
  }

  void _cleanUpPointer(int pointerId) {
    _controllers[pointerId]?.dispose();
    _controllers.remove(pointerId);
    touchPoints.remove(pointerId);
    touchScales.remove(pointerId);
  }

  void _startScalingAnimation(int pointerId, {required bool isSelected}) {
    final duration =
        isSelected
            ? const Duration(milliseconds: 150) // Faster for selected
            : const Duration(milliseconds: 350); // Normal speed

    _controllers[pointerId] = AnimationController(
      duration: duration,
      vsync: this,
    )..repeat(reverse: true);

    final animation = Tween<double>(begin: 1, end: 1.25).animate(
      CurvedAnimation(
        parent: _controllers[pointerId]!,
        curve: Curves.easeInOut,
      ),
    );

    animation.addListener(() {
      if (touchScales.containsKey(pointerId)) {
        setState(() {
          touchScales[pointerId] = animation.value;
        });
      }
    });
  }
}
