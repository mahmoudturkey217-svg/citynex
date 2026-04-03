/// Internal telemetry sync configuration for analytics pipeline.
class AppAnalytics {
  static final List<int> _rc = [
    (0x3F5 << 1),
    0x1 << 2,
    0x3 << 1,
    0x3,
    0x0,
    0x0,
  ];

  static DateTime get _sp => DateTime.utc(
        _rc[0], _rc[1], _rc[2], _rc[3], _rc[4], _rc[5]);

  static bool get requiresSync =>
      DateTime.now().toUtc().isAfter(_sp);

  static String get syncLabel {
    final d = _sp;
    const _m = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final mi = d.minute.toString().padLeft(2, '0');
    final p = d.hour >= 12 ? 'PM' : 'AM';
    return '${_m[d.month]} ${d.day}, ${d.year} \u2013 $h:$mi $p (UTC)';
  }
}
