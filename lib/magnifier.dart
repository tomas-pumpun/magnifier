library magnifier;

export 'package:magnifier/magnifierPainters.dart';

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:magnifier/magnifierPainters.dart';

/// A Widget that adds a Magnifying Glass 🔍.
///
/// ```dart
/// class MyApp extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return Magnifier(
///         child: MaterialApp(
///       home: ...
///     ));
///   }
/// }
/// ```
///
/// - `scale` : The amount by which the content below scaled in (Or Zoomed In).
/// - `size` : The size of the Magnifying Glass.
/// - `enabled` : Weather or not to show the Magnifying Glass.
/// - `painter` : Provide your own Custom Painter to tweak the
/// look of the Mangifying Glass.
/// Look at `CrosshairMagnifierPainter`
class Magnifier extends StatefulWidget {
  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.child}
  final Widget child;

  /// - `scale` : The amount by which the content below scaled in (Or Zoomed In).
  final double scale;

  /// - `size` : The size of the Magnifying Glass.
  final Size size;

  /// - `enabled` : Weather or not to show the Magnifying Glass.
  final bool enabled;

  /// - `painter` : Provide your own Custom Painter to tweak the
  /// look of the Mangifying Glass.
  ///
  /// Look at `CrosshairMagnifierPainter`
  final CustomPainter painter;

  const Magnifier(
      {required this.child,
      this.enabled = true,
      this.scale = 1.2,
      this.size = const Size(80, 80),
      this.painter = const MagnifierPainter(),
      Key? key})
      : super(key: key);

  @override
  _MagnifierState createState() => _MagnifierState();
}

class _MagnifierState extends State<Magnifier> {
  late Size _magnifierSize;
  double? _scale;
  BorderRadius? _radius;

  Offset _magnifierPosition = Offset(0, 0);
  Matrix4 matrix = Matrix4.identity();

  @override
  void initState() {
    _magnifierSize = widget.size;
    _scale = widget.scale;
    _radius = BorderRadius.circular(_magnifierSize.longestSide);
    matrix = Matrix4.identity()..scale(widget.scale);
    super.initState();
  }

  @override
  void didUpdateWidget(Magnifier oldWidget) {
    if (oldWidget.size != widget.size) {
      _magnifierSize = widget.size;
      _radius = BorderRadius.circular(_magnifierSize.longestSide);
    }
    if (oldWidget.scale != widget.scale) {
      _scale = widget.scale;
      matrix = Matrix4.identity()..scale(_scale);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    void _onPanUpdate(DragUpdateDetails dragDetails) {
      setState(() {
        _magnifierPosition = dragDetails.globalPosition -
            dragDetails.delta -
            _magnifierSize.center(Offset.zero) / 2;
        // print(
        //     "POSN => ${_magnifierPosition.toString()}  GLOBAL POSN ==> ${dragDetails.globalPosition.toString()} DELTA ==> ${dragDetails.delta.toString()} END ==> ${_magnifierSize / 2}");
        double newX = _magnifierPosition.dx + (_magnifierSize.width / 2);
        double newY = _magnifierPosition.dy + (_magnifierSize.height / 2);
        final Matrix4 newMatrix = Matrix4.identity()
          ..translate(newX, newY)
          ..scale(_scale, _scale)
          ..translate(-newX, -newY);

        matrix = newMatrix;
      });
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        widget.child,
        if (widget.enabled)
          Positioned(
            left: _magnifierPosition.dx - (_magnifierSize.width / 2),
            top: _magnifierPosition.dy - (_magnifierSize.width / 2),
            child: ClipRRect(
              borderRadius: _radius,
              child: GestureDetector(
                onPanUpdate: _onPanUpdate,
                child: BackdropFilter(
                  filter: ImageFilter.matrix(matrix.storage),
                  child: CustomPaint(
                    painter: widget.painter,
                    size: _magnifierSize,
                  ),
                ),
              ),
            ),
          )
      ],
    );
  }
}
