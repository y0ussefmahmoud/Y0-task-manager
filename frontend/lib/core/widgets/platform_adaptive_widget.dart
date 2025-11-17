import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../utils/platform_utils.dart';

/// A widget that adapts its appearance based on the platform
class PlatformAdaptiveWidget extends StatelessWidget {
  final Widget android;
  final Widget? ios;
  final Widget? windows;
  final Widget? macos;
  final Widget? linux;
  final Widget? web;
  final Widget? fallback;

  const PlatformAdaptiveWidget({
    super.key,
    required this.android,
    this.ios,
    this.windows,
    this.macos,
    this.linux,
    this.web,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isAndroid) {
      return android;
    } else if (PlatformUtils.isIOS) {
      return ios ?? android;
    } else if (PlatformUtils.isWindows) {
      return windows ?? android;
    } else if (PlatformUtils.isMacOS) {
      return macos ?? android;
    } else if (PlatformUtils.isLinux) {
      return linux ?? android;
    } else if (PlatformUtils.isWeb) {
      return web ?? android;
    }
    
    return fallback ?? android;
  }
}

/// Adaptive button that uses Material on Android/Web and Cupertino on iOS
class AdaptiveButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isDestructive;
  final bool isLoading;

  const AdaptiveButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isDestructive = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return PlatformAdaptiveWidget(
        android: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        ios: const Center(
          child: CupertinoActivityIndicator(),
        ),
      );
    }

    return PlatformAdaptiveWidget(
      android: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDestructive ? Colors.red : null,
          foregroundColor: isDestructive ? Colors.white : null,
        ),
        child: Text(text),
      ),
      ios: CupertinoButton.filled(
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}

/// Adaptive dialog that uses Material on Android/Web and Cupertino on iOS
class AdaptiveDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;

  const AdaptiveDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmText = 'موافق',
    this.cancelText = 'إلغاء',
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return PlatformAdaptiveWidget(
      android: AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: onCancel ?? () => Navigator.of(context).pop(),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: onConfirm ?? () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? Colors.red : null,
              foregroundColor: isDestructive ? Colors.white : null,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
      ios: CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(
            onPressed: onCancel ?? () => Navigator.of(context).pop(),
            child: Text(cancelText),
          ),
          CupertinoDialogAction(
            onPressed: onConfirm ?? () => Navigator.of(context).pop(),
            isDestructiveAction: isDestructive,
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'موافق',
    String cancelText = 'إلغاء',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AdaptiveDialog(
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }
}

/// Adaptive loading indicator
class AdaptiveLoadingIndicator extends StatelessWidget {
  final double? size;
  final Color? color;

  const AdaptiveLoadingIndicator({
    super.key,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return PlatformAdaptiveWidget(
      android: SizedBox(
        width: size ?? 24,
        height: size ?? 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: color != null ? AlwaysStoppedAnimation(color) : null,
        ),
      ),
      ios: CupertinoActivityIndicator(
        radius: (size ?? 24) / 2,
        color: color,
      ),
    );
  }
}

/// Adaptive switch
class AdaptiveSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;

  const AdaptiveSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return PlatformAdaptiveWidget(
      android: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: activeColor,
      ),
      ios: CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        activeColor: activeColor,
      ),
    );
  }
}

/// Adaptive slider
class AdaptiveSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final int? divisions;
  final Color? activeColor;

  const AdaptiveSlider({
    super.key,
    required this.value,
    this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return PlatformAdaptiveWidget(
      android: Slider(
        value: value,
        onChanged: onChanged,
        min: min,
        max: max,
        divisions: divisions,
        activeColor: activeColor,
      ),
      ios: CupertinoSlider(
        value: value,
        onChanged: onChanged,
        min: min,
        max: max,
        divisions: divisions,
        activeColor: activeColor,
      ),
    );
  }
}

/// Adaptive text field
class AdaptiveTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final String? labelText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final String? Function(String?)? validator;
  final bool enabled;
  final int? maxLines;
  final Widget? suffixIcon;
  final Widget? prefixIcon;

  const AdaptiveTextField({
    super.key,
    this.controller,
    this.placeholder,
    this.labelText,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.onEditingComplete,
    this.validator,
    this.enabled = true,
    this.maxLines = 1,
    this.suffixIcon,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return PlatformAdaptiveWidget(
      android: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: placeholder,
          suffixIcon: suffixIcon,
          prefixIcon: prefixIcon,
        ),
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        onEditingComplete: onEditingComplete,
        validator: validator,
        enabled: enabled,
        maxLines: maxLines,
      ),
      ios: CupertinoTextField(
        controller: controller,
        placeholder: placeholder ?? labelText,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        onEditingComplete: onEditingComplete,
        enabled: enabled,
        maxLines: maxLines,
        suffix: suffixIcon,
        prefix: prefixIcon,
      ),
    );
  }
}

/// Adaptive app bar
class AdaptiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;

  const AdaptiveAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return PlatformAdaptiveWidget(
      android: AppBar(
        title: Text(title),
        actions: actions,
        leading: leading,
        automaticallyImplyLeading: automaticallyImplyLeading,
        backgroundColor: backgroundColor,
      ),
      ios: CupertinoNavigationBar(
        middle: Text(title),
        trailing: actions?.isNotEmpty == true 
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: actions!,
              )
            : null,
        leading: leading,
        automaticallyImplyLeading: automaticallyImplyLeading,
        backgroundColor: backgroundColor,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Adaptive scaffold
class AdaptiveScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Color? backgroundColor;

  const AdaptiveScaffold({
    super.key,
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return PlatformAdaptiveWidget(
      android: Scaffold(
        appBar: appBar,
        body: body,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar,
        drawer: drawer,
        backgroundColor: backgroundColor,
      ),
      ios: CupertinoPageScaffold(
        navigationBar: appBar as CupertinoNavigationBar?,
        child: body ?? const SizedBox.shrink(),
        backgroundColor: backgroundColor,
      ),
    );
  }
}
