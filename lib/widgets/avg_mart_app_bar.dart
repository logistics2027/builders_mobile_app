import 'package:avg_mart/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AvgMartAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final bool leading;
  final List<Widget>? actions;
  final List<Color>? gradientColors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final double elevation;
  final bool centerTitle;
  final double fontSize;
  final FontWeight fontWeight;
  final PreferredSizeWidget? bottom;

  const AvgMartAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading = true,
    this.actions,
    this.gradientColors,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.elevation = 0,
    this.centerTitle = false,
    this.fontSize = 18,
    this.fontWeight = FontWeight.bold,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors ?? AppTheme.headerGradient,
            begin: begin,
            end: end,
          ),
        ),
      ),
      elevation: elevation,
      centerTitle: centerTitle,
      automaticallyImplyLeading: leading,
      actions: actions,
      bottom: bottom,
      title: titleWidget ??
          (title != null
              ? Text(
                  title!,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: fontWeight,
                    fontSize: fontSize,
                  ),
                )
              : null),
      iconTheme: const IconThemeData(color: Colors.white),
      actionsIconTheme: const IconThemeData(color: Colors.white),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}