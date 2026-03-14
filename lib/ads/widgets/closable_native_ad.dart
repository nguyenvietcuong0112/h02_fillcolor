import 'package:flutter/material.dart';
import 'package:ds_ads/ds_ads.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../services/remote_config_service.dart';

import 'dart:async';

class ClosableNativeAd extends StatefulWidget {
  final String adId;
  final double height;
  final Duration delay;

  const ClosableNativeAd({
    super.key,
    required this.adId,
    required this.height,
    this.delay = const Duration(seconds: 3),
  });

  @override
  State<ClosableNativeAd> createState() => _ClosableNativeAdState();
}

class _ClosableNativeAdState extends State<ClosableNativeAd> {
  bool _isVisible = true;
  bool _showAd = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _showAd = true;
    } else {
      _timer = Timer(widget.delay, () {
        if (mounted) {
          setState(() => _showAd = true);
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check Remote Config toggle
    if (!RemoteConfigService.instance.showNativeColoringAd) {
      return const SizedBox.shrink();
    }

    if (!_isVisible) return const SizedBox.shrink();

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: _showAd ? 1.0 : 0.0,
      child: IgnorePointer(
        ignoring: !_showAd,
        child: SizedBox(
          width: double.infinity,
          child: Stack(
            children: [
              DSAdNative(id: widget.adId, height: widget.height),
              Positioned(
                top: 8.h,
                right: 8.w,
                child: GestureDetector(
                  onTap: () => setState(() => _isVisible = false),
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.8),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(Icons.close, color: Colors.white, size: 14.sp),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
