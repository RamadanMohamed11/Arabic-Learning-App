import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// مجموعة من التحولات الجميلة والسلسة بين الصفحات
class PageTransitions {
  /// انتقال بتأثير التلاشي والتكبير (Fade + Scale)
  /// مثالي للصفحات الرئيسية والترحيبية
  static CustomTransitionPage<T> fadeScale<T>({
    required Widget child,
    required GoRouterState state,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // منحنى سلس للحركة
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.92,
              end: 1.0,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  /// انتقال بالانزلاق من اليمين (Slide from Right)
  /// مثالي للتنقل للأمام في التطبيق
  static CustomTransitionPage<T> slideRight<T>({
    required Widget child,
    required GoRouterState state,
    Duration duration = const Duration(milliseconds: 350),
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// انتقال بالانزلاق من اليسار (Slide from Left)
  /// مثالي للرجوع أو التنقل للخلف
  static CustomTransitionPage<T> slideLeft<T>({
    required Widget child,
    required GoRouterState state,
    Duration duration = const Duration(milliseconds: 350),
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// انتقال بالانزلاق من الأسفل (Slide Up)
  /// مثالي للنوافذ المنبثقة والشاشات الثانوية
  static CustomTransitionPage<T> slideUp<T>({
    required Widget child,
    required GoRouterState state,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  /// انتقال دوراني مع تلاشي (Rotation + Fade)
  /// مثالي للصفحات الخاصة أو التفاعلية
  static CustomTransitionPage<T> rotationFade<T>({
    required Widget child,
    required GoRouterState state,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: RotationTransition(
            turns: Tween<double>(
              begin: -0.05,
              end: 0.0,
            ).animate(curvedAnimation),
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.9,
                end: 1.0,
              ).animate(curvedAnimation),
              child: child,
            ),
          ),
        );
      },
    );
  }

  /// انتقال بتأثير الانزلاق والتكبير معاً (Slide + Scale)
  /// مثالي للانتقالات السلسة والأنيقة
  static CustomTransitionPage<T> slideScale<T>({
    required Widget child,
    required GoRouterState state,
    Duration duration = const Duration(milliseconds: 450),
    Offset beginOffset = const Offset(0.3, 0.0),
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: beginOffset,
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.85,
              end: 1.0,
            ).animate(curvedAnimation),
            child: FadeTransition(
              opacity: curvedAnimation,
              child: child,
            ),
          ),
        );
      },
    );
  }

  /// انتقال بتأثير التلاشي فقط (Simple Fade)
  /// مثالي للانتقالات السريعة والبسيطة
  static CustomTransitionPage<T> fade<T>({
    required Widget child,
    required GoRouterState state,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
          child: child,
        );
      },
    );
  }

  /// انتقال بتأثير الانزلاق الأفقي مع تلاشي الصفحة السابقة
  /// مثالي للتنقل بين الأقسام الرئيسية
  static CustomTransitionPage<T> sharedAxisHorizontal<T>({
    required Widget child,
    required GoRouterState state,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
        );

        final reverseCurvedAnimation = CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.easeInOutCubic,
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.3, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(curvedAnimation),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset.zero,
                end: const Offset(-0.3, 0.0),
              ).animate(reverseCurvedAnimation),
              child: FadeTransition(
                opacity: Tween<double>(
                  begin: 1.0,
                  end: 0.0,
                ).animate(reverseCurvedAnimation),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }

  /// انتقال بتأثير الزووم الأنيق (Elegant Zoom)
  /// مثالي للصفحات التفاعلية والألعاب
  static CustomTransitionPage<T> elegantZoom<T>({
    required Widget child,
    required GoRouterState state,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutBack,
        );

        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.7,
            end: 1.0,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
            )),
            child: child,
          ),
        );
      },
    );
  }
}
