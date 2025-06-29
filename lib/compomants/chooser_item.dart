import 'dart:async';
import 'dart:math';
import 'package:byluck/compomants/positioned_circle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChooserItem extends StatefulWidget {
  const ChooserItem({super.key});

  @override
  State<ChooserItem> createState() => _ChooserItemState();
}

class _ChooserItemState extends State<ChooserItem>
    with TickerProviderStateMixin {
  final Map<int, TouchData> _touches = {};
  Timer? _selectionTimer;
  int? _selectedId;
  bool _acceptInput = true;

  @override
  void dispose() {
    _selectionTimer?.cancel();
    for (final touch in _touches.values) {
      touch.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (event) {
              if (_acceptInput) {
                _handleTouch(
                  event.pointer,
                  event.localPosition,
                  constraints.biggest,
                );
              }
            },
            onPointerMove: (event) {
              if (_acceptInput || _selectedId == event.pointer) {
                setState(() {
                  _touches[event.pointer]?.position = event.localPosition;
                });
              }
            },
            onPointerUp: (event) => _removeTouch(event.pointer),
            onPointerCancel: (event) => _removeTouch(event.pointer),
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                color: Colors.grey[200],
                boxShadow: [
                  BoxShadow(color: Colors.red, blurRadius: 20, spreadRadius: 2),
                ],
              ),
              child: Stack(
                children: [
                  if (_touches.isEmpty) Center(child: TextInCenter()),
                  ..._touches.entries.map((entry) {
                    return PositionedCircle(
                      key: ValueKey(entry.key),
                      pos: entry.value.position,
                      containerSize: constraints.biggest,
                      scale: entry.value.scale,
                      isSelected: _selectedId == entry.key,
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleTouch(int pointerId, Offset position, Size containerSize) {
    final controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    )..repeat(reverse: true);

    final animation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    setState(() {
      _touches[pointerId] = TouchData(
        position: position,
        controller: controller,
        animation: animation,
      );
    });

    animation.addListener(() {
      if (_touches.containsKey(pointerId)) {
        setState(() {
          _touches[pointerId]!.scale = animation.value;
        });
      }
    });

    _resetSelectionTimer();
  }

  void _removeTouch(int pointerId) {
    if (!_touches.containsKey(pointerId)) return;

    setState(() {
      _touches[pointerId]?.controller.dispose();
      _touches.remove(pointerId);
      if (pointerId == _selectedId) {
        _selectedId = null;
        _acceptInput = true;
      }
      _resetSelectionTimer();
    });
  }

  void _resetSelectionTimer() {
    _selectionTimer?.cancel();
    if (_touches.length >= 2 && _acceptInput) {
      _selectionTimer = Timer(const Duration(seconds: 3), _selectWinner);
    }
  }

  Future<void> _selectWinner() async {
    if (_touches.length < 2 || _selectedId != null) return;

    try {
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 50));
      await HapticFeedback.vibrate();

      final winnerId = _touches.keys.elementAt(
        Random().nextInt(_touches.length),
      );

      setState(() {
        _selectedId = winnerId;
        _acceptInput = false;
        _touches[winnerId]!.controller.duration = const Duration(
          milliseconds: 150,
        );

        // Remove non-winning touches
        final idsToRemove =
            _touches.keys.where((id) => id != winnerId).toList();
        for (final id in idsToRemove) {
          _touches[id]?.controller.dispose();
          _touches.remove(id);
        }
      });

      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _touches.clear();
        _selectedId = null;
        _acceptInput = true;
      });
    } catch (e) {
      debugPrint('Selection error: $e');
    }
  }
}

class TextInCenter extends StatelessWidget {
  const TextInCenter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.red, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.red, blurRadius: 1, spreadRadius: 1),
        ],
      ),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Touch to add circles\n',
              style: TextStyle(
                fontSize: 20,
                color: Colors.red[300],
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: Colors.black, blurRadius: 2)],
              ),
            ),
            TextSpan(
              text: 'Need 2+ to select winner',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.8),
                    blurRadius: 3,
                    offset: const Offset(1, 1),
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

class TouchData {
  Offset position;
  final AnimationController controller;
  final Animation<double> animation;
  double scale;

  TouchData({
    required this.position,
    required this.controller,
    required this.animation,
    this.scale = 1.0,
  });
}
