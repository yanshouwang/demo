import 'dart:ui';

import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints.expand(),
            child: Image.asset(
              'images/flying_colors.jpg',
              fit: BoxFit.cover,
            ),
          ),
          buildCard(context),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget buildCard(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const marginSize = 12.0;
    final animation = CurvedAnimation(
      parent: controller,
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
              lerpDouble(beginPaddingSize, endPaddingSize, value)!;
          // 计算卡片大小
          final beginCardSize = size.shortestSide / 8.0;
          final endCardWidth = size.width - marginSize * 2;
          final endCardHeight = (size.height - marginSize * 2.0) / 4.0;
          final cardWidth = lerpDouble(beginCardSize, endCardWidth, value)!;
          final cardHeight = lerpDouble(beginCardSize, endCardHeight, value)!;
          // 计算卡片圆角
          final beginCardRadius = beginCardSize / 2.0;
          const endCardRadius = 16.0;
          final cardRadius = lerpDouble(beginCardRadius, endCardRadius, value)!;
          // 计算按钮大小
          final beginButtonSize = beginCardSize - 2 * beginPaddingSize;
          final endButtonSize = beginButtonSize / 2.0;
          final buttonSize = lerpDouble(beginButtonSize, endButtonSize, value)!;
          // 计算按钮圆角
          final beginButtonRadius = beginButtonSize / 2.0;
          const endButtonRadius = 12.0;
          final buttonRadius =
              lerpDouble(beginButtonRadius, endButtonRadius, value)!;
          return ClipRRect(
            borderRadius: BorderRadius.circular(cardRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
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
                        switch (controller.status) {
                          case AnimationStatus.dismissed:
                            controller.forward();
                            break;
                          case AnimationStatus.completed:
                            controller.reverse();
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
