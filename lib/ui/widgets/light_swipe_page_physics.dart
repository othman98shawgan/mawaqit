import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// A [PageScrollPhysics] tuned so light flicks and short drags (>15% width)
/// smoothly advance days without snapping back. Use with `pageSnapping: false`
/// on [PageView] so Flutter does not shadow this physics with default snapping.
class LightSwipePagePhysics extends PageScrollPhysics {
  const LightSwipePagePhysics({super.parent});

  @override
  LightSwipePagePhysics applyTo(ScrollPhysics? ancestor) {
    return LightSwipePagePhysics(parent: buildParent(ancestor));
  }

  @override
  double get minFlingVelocity => 20.0;

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 0.5,
        stiffness: 200.0,
        damping: 21.0,
      );

  double _targetPixels(
    ScrollMetrics position,
    Tolerance tolerance,
    double velocity,
  ) {
    final viewport = position.viewportDimension;
    if (viewport <= 0) return position.pixels;

    final page = position.pixels / viewport;
    double targetPage;

    if (velocity > tolerance.velocity) {
      targetPage = page.floorToDouble() + 1.0;
    } else if (velocity < -tolerance.velocity) {
      targetPage = page.ceilToDouble() - 1.0;
    } else if (position is ScrollPosition) {
      if (position.userScrollDirection == ScrollDirection.reverse) {
        final frac = page - page.floorToDouble();
        targetPage = frac > 0.15 ? page.floorToDouble() + 1.0 : page.floorToDouble();
      } else if (position.userScrollDirection == ScrollDirection.forward) {
        final frac = page.ceilToDouble() - page;
        targetPage = frac > 0.15 ? page.ceilToDouble() - 1.0 : page.ceilToDouble();
      } else {
        targetPage = page.roundToDouble();
      }
    } else {
      targetPage = page.roundToDouble();
    }

    final minPage = position.minScrollExtent / viewport;
    final maxPage = position.maxScrollExtent / viewport;
    return targetPage.clamp(minPage, maxPage) * viewport;
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }

    final tolerance = toleranceFor(position);
    final target = _targetPixels(position, tolerance, velocity);
    if ((target - position.pixels).abs() < tolerance.distance &&
        velocity.abs() < tolerance.velocity) {
      return null;
    }
    return ScrollSpringSimulation(
      spring,
      position.pixels,
      target,
      velocity,
      tolerance: tolerance,
    );
  }
}
