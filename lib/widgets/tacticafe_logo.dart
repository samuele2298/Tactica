/// TacticaFe logo widget component
/// Provides consistent logo display across the application

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Sizes for different logo usage contexts
enum LogoSize {
  small(24),
  medium(48),
  large(80),
  extraLarge(120);
  
  const LogoSize(this.value);
  final double value;
}

/// Reusable TacticaFe logo widget
class TacticafeLogo extends StatelessWidget {
  final LogoSize size;
  final bool animated;
  final Duration? animationDuration;
  final Color? colorFilter;

  const TacticafeLogo({
    super.key,
    this.size = LogoSize.medium,
    this.animated = false,
    this.animationDuration,
    this.colorFilter,
  });

  /// Static method for quick logo access
  static Widget small({Color? colorFilter}) => TacticafeLogo(
    size: LogoSize.small,
    colorFilter: colorFilter,
  );

  static Widget medium({bool animated = false, Color? colorFilter}) => TacticafeLogo(
    size: LogoSize.medium,
    animated: animated,
    colorFilter: colorFilter,
  );

  static Widget large({bool animated = true, Color? colorFilter}) => TacticafeLogo(
    size: LogoSize.large,
    animated: animated,
    colorFilter: colorFilter,
  );

  @override
  Widget build(BuildContext context) {
    Widget logo = SvgPicture.asset(
      'assets/images/tacticafe_logo.svg',
      height: size.value,
      width: size.value,
      colorFilter: colorFilter != null 
          ? ColorFilter.mode(colorFilter!, BlendMode.srcIn)
          : null,
    );

    if (animated) {
      return _AnimatedLogo(
        logo: logo,
        duration: animationDuration ?? const Duration(seconds: 3),
      );
    }

    return logo;
  }
}

/// Internal animated wrapper for the logo
class _AnimatedLogo extends StatefulWidget {
  final Widget logo;
  final Duration duration;

  const _AnimatedLogo({
    required this.logo,
    required this.duration,
  });

  @override
  State<_AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<_AnimatedLogo>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _rotation = Tween<double>(
      begin: 0,
      end: 0.02, // Very subtle rotation
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _scale = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scale.value,
          child: Transform.rotate(
            angle: _rotation.value,
            child: widget.logo,
          ),
        );
      },
    );
  }
}