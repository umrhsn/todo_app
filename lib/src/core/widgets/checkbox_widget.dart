// core/widgets/checkbox_widget.dart (Fixed scale assertion)
import 'package:flutter/material.dart';

class CheckboxWidget extends StatefulWidget {
  final bool isChecked;
  final bool isCircular;
  final void Function(bool?)? onChanged;
  final Color? activeColor;
  final Color borderColor;
  final double? scale;
  final bool enabled;

  const CheckboxWidget({
    super.key,
    this.isChecked = false,
    this.isCircular = false,
    this.onChanged,
    required this.borderColor,
    this.activeColor,
    this.scale,
    this.enabled = true,
  });

  @override
  State<CheckboxWidget> createState() => _CheckboxWidgetState();
}

class _CheckboxWidgetState extends State<CheckboxWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget checkbox = Checkbox(
      value: widget.isChecked,
      activeColor: widget.activeColor,
      onChanged: widget.enabled ? widget.onChanged : null,
      shape: widget.isCircular
          ? const CircleBorder()
          : RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      side: WidgetStateBorderSide.resolveWith(
        (states) => BorderSide(
          width: 1.0,
          color: widget.enabled
              ? widget.borderColor
              : widget.borderColor.withOpacity(0.5),
        ),
      ),
      splashRadius: 20,
    );

    // Fixed: Only apply Transform.scale if scale is provided and valid
    if (widget.scale != null && widget.scale! > 0) {
      checkbox = Transform.scale(scale: widget.scale!, child: checkbox);
    }

    return GestureDetector(
      onTapDown: (_) {
        if (widget.enabled) {
          _animationController.forward();
        }
      },
      onTapUp: (_) {
        if (widget.enabled) {
          _animationController.reverse();
        }
      },
      onTapCancel: () {
        if (widget.enabled) {
          _animationController.reverse();
        }
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: checkbox);
        },
      ),
    );
  }
}
