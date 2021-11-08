import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  late AnimationController scanController;
  late AnimationController cardController;

  @override
  void initState() {
    super.initState();
    scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          buildBackground(context),
          buildScanAnimation(context),
          buildCard(context),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cardController.dispose();
    scanController.dispose();
    super.dispose();
  }

  Widget buildBackground(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints.expand(),
      child: Image.asset(
        'images/flying_colors.jpg',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget buildScanAnimation(BuildContext context) {
    final animation = CurvedAnimation(
      parent: scanController,
      curve: Curves.linear,
    );
    return ConstrainedBox(
      constraints: const BoxConstraints.expand(),
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return CustomPaint(
            painter: ScanAnimationPainter(animation.value),
          );
        },
      ),
    );
  }

  Widget buildCard(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const marginSize = 12.0;
    final animation = CurvedAnimation(
      parent: cardController,
      curve: Curves.easeOutBack,
    );
    return Container(
      margin: const EdgeInsets.all(marginSize),
      alignment: Alignment.bottomRight,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final value = animation.value;
          // 计算内边距
          const beginPaddingSize = 4.0;
          const endPaddingSize = beginPaddingSize * 2.0;
          final paddingSize =
              ui.lerpDouble(beginPaddingSize, endPaddingSize, value)!;
          // 计算卡片大小
          final beginCardSize = size.shortestSide / 8.0;
          final endCardWidth = size.width - marginSize * 2;
          final endCardHeight = (size.height - marginSize * 2.0) / 4.0;
          final cardWidth = ui.lerpDouble(beginCardSize, endCardWidth, value)!;
          final cardHeight =
              ui.lerpDouble(beginCardSize, endCardHeight, value)!;
          // 计算卡片圆角
          final beginCardRadius = beginCardSize / 2.0;
          const endCardRadius = 16.0;
          final cardRadius =
              ui.lerpDouble(beginCardRadius, endCardRadius, value)!;
          // 计算按钮大小
          final beginButtonSize = beginCardSize - 2 * beginPaddingSize;
          final endButtonSize = beginButtonSize / 2.0;
          final buttonSize =
              ui.lerpDouble(beginButtonSize, endButtonSize, value)!;
          // 计算按钮圆角
          final beginButtonRadius = beginButtonSize / 2.0;
          const endButtonRadius = 12.0;
          final buttonRadius =
              ui.lerpDouble(beginButtonRadius, endButtonRadius, value)!;
          return ClipRRect(
            borderRadius: BorderRadius.circular(cardRadius),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
              child: Container(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                width: cardWidth,
                height: cardHeight,
                alignment: Alignment.topRight,
                padding: EdgeInsets.all(paddingSize),
                child: SizedBox(
                  width: buttonSize,
                  height: buttonSize,
                  child: Material(
                    animationDuration: Duration.zero,
                    type: MaterialType.button,
                    clipBehavior: Clip.antiAlias,
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(buttonRadius),
                    child: InkWell(
                      onTap: () {
                        switch (cardController.status) {
                          case AnimationStatus.dismissed:
                            cardController.forward();
                            scanController.repeat();
                            break;
                          case AnimationStatus.completed:
                            cardController.reverse();
                            scanController.reset();
                            break;
                          default:
                            break;
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ScanAnimationPainter extends CustomPainter {
  final double progress;

  ScanAnimationPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = width / 4.0;
    const step = 12.0;
    canvas.translate(width / 2.0, -height + (height + size.height) * progress);
    final path = ui.Path();
    var dx = 0.0;
    path.moveTo(dx, 0.0);
    path.lineTo(dx, height);
    while (dx <= width / 2.0) {
      dx += step;
      path.moveTo(dx, 0.0);
      path.lineTo(dx, height);
      path.moveTo(-dx, 0.0);
      path.lineTo(-dx, height);
    }
    var dy = height;
    while (dy >= 0) {
      path.moveTo(-width / 2.0, dy);
      path.lineTo(width / 2.0, dy);
      dy -= step;
    }
    final from = ui.Offset.zero;
    final to = from.translate(0.0, height);
    final colors = [Colors.transparent, Colors.white];
    final paint = Paint()
      ..shader = ui.Gradient.linear(from, to, colors)
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(path, paint);
    // 画底部粗线
    final p1 = ui.Offset(-width / 2.0, height);
    final p2 = ui.Offset(width / 2.0, height);
    paint
      ..color = Colors.white
      ..strokeWidth = 2.0;
    canvas.drawLine(p1, p2, paint);
  }

  @override
  bool shouldRepaint(covariant ScanAnimationPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
