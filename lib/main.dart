import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'services/mastitis_vision_service.dart';
import 'models/mastitis_vision_result.dart';
import 'api_test_screen.dart';

void main() {
  runApp(const BoviCareApp());
}

const forest = Color(0xFF176B45);
const green = Color(0xFF238653);
const cream = Color(0xFFF8F7F0);
const ink = Color(0xFF20352A);
const muted = Color(0xFF77857A);

class BoviCareApp extends StatelessWidget {
  const BoviCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BoviCare',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: cream,
        colorScheme: ColorScheme.fromSeed(seedColor: forest),
      ),
      home: const HomeScreen(),
    );
  }
}

class Cow {
  const Cow({
    required this.name,
    required this.id,
    required this.status,
    this.breed = 'Gir',
    this.healthScore = 95,
    this.age = '4 yrs',
    this.milkYield = '18 L',
    this.lastCheck = 'Today',
  });

  final String name;
  final String id;
  final String status;
  final String breed;
  final int healthScore;
  final String age;
  final String milkYield;
  final String lastCheck;
}

class HealthRecord {
  const HealthRecord({
    required this.cowName,
    required this.cowId,
    required this.date,
    required this.result,
    this.notes = '',
  });

  final String cowName;
  final String cowId;
  final DateTime date;
  final String result;
  final String notes;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedTab = 0;
  String topNavMode = 'Home'; // 'Login', 'Home', 'Profile'
  bool marathi = false;

  final List<Cow> cows = [
    const Cow(
      name: 'Ganga',
      id: 'COW-001',
      status: 'Healthy',
      breed: 'Holstein',
      age: '4 yrs',
      healthScore: 95,
      milkYield: '18 L',
      lastCheck: 'Today',
    ),
    const Cow(
      name: 'Lakshmi',
      id: 'COW-003',
      status: 'Healthy',
      breed: 'Gir',
      age: '5 yrs',
      healthScore: 92,
      milkYield: '12 L',
      lastCheck: 'Yesterday',
    ),
    const Cow(
      name: 'Nandini',
      id: 'COW-002',
      status: 'Attention',
      breed: 'Jersey',
      age: '3 yrs',
      healthScore: 64,
      milkYield: '9 L',
      lastCheck: '2 days ago',
    ),
  ];

  final List<HealthRecord> records = [
    HealthRecord(
      cowName: 'Lakshmi',
      cowId: 'COW-003',
      date: DateTime.now().subtract(const Duration(days: 1)),
      result: 'Healthy',
      notes: 'Routine herd assessment. Clear milk, healthy udder.',
    ),
    HealthRecord(
      cowName: 'Nandini',
      cowId: 'COW-002',
      date: DateTime.now().subtract(const Duration(days: 2)),
      result: 'Needs follow-up',
      notes: 'Slight redness observed on rear quarter.',
    ),
  ];

  String _translate(String english, String marathiText) {
    return marathi ? marathiText : english;
  }

  void _selectTab(int index) {
    setState(() {
      selectedTab = index;
      topNavMode = 'Home';
    });
  }

  List<Widget> get pages => [
        DashboardScreen(
          cows: cows,
          records: records,
          marathi: marathi,
          tr: _translate,
          onAssess: () => _selectTab(2),
          onCows: () => _selectTab(1),
          onRecords: () => _selectTab(3),
        ),
        MyCowsPage(
          cows: cows,
          onBack: () => _selectTab(0),
          onAssessCow: (cow) => _selectTab(2),
          onAddCow: (newCow) {
            setState(() {
              cows.add(newCow);
            });
          },
        ),
        AssessPage(
          onBack: () => _selectTab(0),
          cows: cows,
          records: records,
          onRecordAdded: (newRecord) {
            setState(() {
              records.insert(0, newRecord);
            });
          },
          onViewRecords: () => _selectTab(3),
        ),
        HealthRecordsPage(records: records, onBack: () => _selectTab(0)),
        BoviCareProfilePage(
          onBack: () => _selectTab(0),
          onLogout: () {
            setState(() => topNavMode = 'Login');
          },
        ),
      ];

  Widget _buildTopPills() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _topPill('Login', () {
          setState(() => topNavMode = 'Login');
        }),
        const SizedBox(width: 8),
        _topPill('Home', () {
          setState(() {
            topNavMode = 'Home';
            selectedTab = 0;
          });
        }),
        const SizedBox(width: 8),
        _topPill('Profile', () {
          setState(() {
            topNavMode = 'Home';
            selectedTab = 4;
          });
        }),
      ],
    );
  }

  Widget _topPill(String title, VoidCallback onTap) {
    final isSelected = (title == 'Home' && topNavMode == 'Home' && selectedTab != 4) ||
        (title == 'Profile' && (topNavMode == 'Profile' || (topNavMode == 'Home' && selectedTab == 4))) ||
        (title == 'Login' && topNavMode == 'Login');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF232724) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF5A635B) : const Color(0xFF323633),
            width: 1.2,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF9EAAA0),
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE9ECE5), width: 1),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(6, 4, 6, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: _navDestination(0, Icons.home_rounded, Icons.home_outlined, 'Home')),
          Expanded(child: _navDestination(1, Icons.pets_rounded, Icons.pets_outlined, 'My Cows')),
          Expanded(child: _centerAssessNavDestination(2, 'Assess')),
          Expanded(
            child: _navDestination(
              3,
              Icons.assignment_rounded,
              Icons.assignment_outlined,
              'Records',
            ),
          ),
          Expanded(
            child: _navDestination(
              4,
              Icons.person_rounded,
              Icons.person_outline_rounded,
              'Profile',
            ),
          ),
        ],
      ),
    );
  }

  Widget _centerAssessNavDestination(int index, String label) {
    return InkWell(
      onTap: () => _selectTab(index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF1B3929),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1B3929).withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.document_scanner_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1B3929),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navDestination(
    int index,
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
  ) {
    final isSelected = (topNavMode == 'Home' && selectedTab == index);

    return InkWell(
      onTap: () => _selectTab(index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Icon(
                isSelected ? activeIcon : inactiveIcon,
                color: isSelected ? const Color(0xFF1B3929) : const Color(0xFF5A665D),
                size: 22,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? const Color(0xFF1B3929) : const Color(0xFF5A665D),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isWide = screenSize.width > 480;

    Widget currentScreenContent;
    if (topNavMode == 'Login') {
      currentScreenContent = BoviCareLoginPage(
        onLoginSuccess: () {
          setState(() {
            topNavMode = 'Home';
            selectedTab = 0;
          });
        },
      );
    } else {
      currentScreenContent = Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: selectedTab,
              children: pages,
            ),
          ),
          _buildPhoneBottomNav(),
        ],
      );
    }

    if (!isWide) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F8F4),
        body: SafeArea(
          bottom: false,
          child: currentScreenContent,
        ),
      );
    }

    final phoneHeight = (screenSize.height - 90).clamp(740.0, 850.0);

    return Scaffold(
      backgroundColor: const Color(0xFF131514),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTopPills(),
                const SizedBox(height: 16),
                Container(
                  width: 390,
                  height: phoneHeight,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8F4),
                    borderRadius: BorderRadius.circular(44),
                    border: Border.all(
                      color: const Color(0xFF2B2E2B),
                      width: 3.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.6),
                        blurRadius: 36,
                        spreadRadius: 2,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: currentScreenContent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CowFacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Faint radar concentric circles
    final radarPaint1 = Paint()
      ..color = const Color(0xFF38634B).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final radarPaint2 = Paint()
      ..color = const Color(0xFF38634B).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(Offset(cx, cy), 42, radarPaint1);
    canvas.drawCircle(Offset(cx, cy), 32, radarPaint2);

    final linePaint = Paint()
      ..color = const Color(0xFFA2D396)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = const Color(0xFFA2D396)
      ..style = PaintingStyle.fill;

    // Head outline (smooth rounded shape)
    final headRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy + 2), width: 34, height: 36),
      const Radius.circular(15),
    );
    canvas.drawRRect(headRect, linePaint);

    // Muzzle / snout
    final snoutRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy + 12), width: 22, height: 13),
      const Radius.circular(7),
    );
    canvas.drawRRect(snoutRect, linePaint);

    // Nostrils
    canvas.drawCircle(Offset(cx - 4.5, cy + 12), 1.5, fillPaint);
    canvas.drawCircle(Offset(cx + 4.5, cy + 12), 1.5, fillPaint);

    // Eyes
    canvas.drawCircle(Offset(cx - 7, cy + 1), 1.6, fillPaint);
    canvas.drawCircle(Offset(cx + 7, cy + 1), 1.6, fillPaint);

    // Horns
    final leftHorn = Path()
      ..moveTo(cx - 10, cy - 12)
      ..quadraticBezierTo(cx - 18, cy - 19, cx - 22, cy - 10);
    canvas.drawPath(leftHorn, linePaint);

    final rightHorn = Path()
      ..moveTo(cx + 10, cy - 12)
      ..quadraticBezierTo(cx + 18, cy - 19, cx + 22, cy - 10);
    canvas.drawPath(rightHorn, linePaint);

    // Ears
    final leftEar = Path()
      ..moveTo(cx - 14, cy - 4)
      ..quadraticBezierTo(cx - 24, cy - 2, cx - 16, cy + 5);
    canvas.drawPath(leftEar, linePaint);

    final rightEar = Path()
      ..moveTo(cx + 14, cy - 4)
      ..quadraticBezierTo(cx + 24, cy - 2, cx + 16, cy + 5);
    canvas.drawPath(rightEar, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SparklinePainter extends CustomPainter {
  final List<double> points;
  final Color color;

  SparklinePainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final dx = size.width / (points.length - 1);
    final minVal = points.reduce((a, b) => a < b ? a : b);
    final maxVal = points.reduce((a, b) => a > b ? a : b);
    final range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    for (int i = 0; i < points.length; i++) {
      final x = i * dx;
      final normY = 1.0 - ((points[i] - minVal) / range);
      final y = 2.0 + normY * (size.height - 4.0);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.cows,
    required this.records,
    required this.marathi,
    required this.tr,
    required this.onAssess,
    required this.onCows,
    required this.onRecords,
  });

  final List<Cow> cows;
  final List<HealthRecord> records;
  final bool marathi;
  final String Function(String, String) tr;
  final VoidCallback onAssess;
  final VoidCallback onCows;
  final VoidCallback onRecords;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String selectedAction = 'Assess';

  Widget _quickActionTile({
    required String title,
    required IconData icon,
    required bool isPrimary,
  }) {
    final isSelected = selectedAction == title;

    if (isPrimary || isSelected) {
      return Expanded(
        child: InkWell(
          onTap: () {
            setState(() => selectedAction = title);
            if (title == 'Assess') {
              widget.onAssess();
            }
          },
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: 74,
            decoration: BoxDecoration(
              color: const Color(0xFF1B3929),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1B3929).withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 22),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() => selectedAction = title);
          if (title == 'Assess') {
            widget.onAssess();
          } else if (title == 'Fever') {
            showMessage(context, 'Fever screening filter selected.');
          } else if (title == 'Milk log') {
            showMessage(context, 'Daily milk logging opened.');
          } else if (title == 'Vaccine') {
            showMessage(context, 'Vaccination schedules opened.');
          }
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 74,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE8ECE5)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F2E4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF2E6845), size: 18),
              ),
              const SizedBox(height: 5),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1A2E23),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _needsAttentionItem({
    required String title,
    required String subtitle,
    required String badgeText,
    required bool isAlert,
    required IconData icon,
  }) {
    final badgeColor = isAlert ? const Color(0xFFD8553D) : const Color(0xFFC47D1E);
    final badgeBg = isAlert ? const Color(0xFFFCEAE6) : const Color(0xFFFEF3E2);
    final iconBg = isAlert ? const Color(0xFFFDECE8) : const Color(0xFFFEF5E7);

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECE5)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: badgeColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1A2E23),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF708075),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                color: badgeColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _calendarEventCard({
    required String day,
    required String month,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECE5)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E6DF), width: 1.2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day,
                  style: const TextStyle(
                    color: Color(0xFF1A2E23),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  month,
                  style: const TextStyle(
                    color: Color(0xFF7A8A7F),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1A2E23),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF708075),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFFA8B6AB),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _topPerformerCard({
    required String initials,
    required String name,
    required String breed,
    required String healthPercent,
    required String milkYield,
    required double progress,
  }) {
    return Expanded(
      child: InkWell(
        onTap: widget.onCows,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE8ECE5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE2EED7),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Color(0xFF275338),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: Color(0xFF1A2E23),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          breed,
                          style: const TextStyle(
                            color: Color(0xFF7A8A7F),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: const Color(0xFFE8ECE5),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF1B3929),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    healthPercent,
                    style: const TextStyle(
                      color: Color(0xFF2D7046),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: milkYield,
                          style: const TextStyle(
                            color: Color(0xFF1A2E23),
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const TextSpan(
                          text: ' L',
                          style: TextStyle(
                            color: Color(0xFF7A8A7F),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7F7F2),
      child: Column(
        children: [
          // Top Header Area (Forest Green)
          Container(
            color: const Color(0xFF1B3929),
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
            child: Row(
              children: [
                // RP Avatar
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF284A37),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF3B624D),
                      width: 1.2,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'RP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Titles
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Good morning, Ramesh',
                        style: TextStyle(
                          color: Color(0xFFA2BFB0),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 1),
                      Text(
                        'Patil Dairy Farm',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                // Notification Tray Button with Gold Dot
                InkWell(
                  onTap: () {
                    showMessage(context, 'Alerts: 1 cow requires fever follow-up.');
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF284A37),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF3B624D),
                        width: 1.2,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.crop_square_rounded,
                          color: Colors.white,
                          size: 19,
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF0B429),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Page Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                // TODAY'S OVERVIEW Hero Card
                Container(
                  color: const Color(0xFF1B3929),
                  padding: const EdgeInsets.fromLTRB(18, 6, 18, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "TODAY'S OVERVIEW",
                        style: TextStyle(
                          color: Color(0xFF8CAE9B),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '21 of 24 cows are\nhealthy',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    height: 1.15,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Your herd is stable. 3 cows need\na closer look.',
                                  style: TextStyle(
                                    color: Color(0xFFA9C2B4),
                                    fontSize: 12,
                                    height: 1.35,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                FilledButton(
                                  onPressed: widget.onAssess,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF1B3929),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    minimumSize: Size.zero,
                                    shape: const StadiumBorder(),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Start assessment',
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 14,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Custom vector cow face + concentric radar waves
                          CustomPaint(
                            size: const Size(86, 86),
                            painter: CowFacePainter(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      // Segmented Progress Bar (Healthy: 21, Watch: 2, Alert: 1)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 21,
                              child: Container(
                                height: 5.5,
                                color: const Color(0xFF6EAE48),
                              ),
                            ),
                            const SizedBox(width: 2.5),
                            Expanded(
                              flex: 2,
                              child: Container(
                                height: 5.5,
                                color: const Color(0xFFE5A93C),
                              ),
                            ),
                            const SizedBox(width: 2.5),
                            Expanded(
                              flex: 1,
                              child: Container(
                                height: 5.5,
                                color: const Color(0xFFD8553D),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 9),
                      // Legend Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: '21 ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Healthy',
                                  style: TextStyle(
                                    color: Color(0xFFA9C2B4),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: '2 ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Watch',
                                  style: TextStyle(
                                    color: Color(0xFFA9C2B4),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: '1 ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Alert',
                                  style: TextStyle(
                                    color: Color(0xFFA9C2B4),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Farm health score & Milk today cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // Farm Health Score Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFE8ECE5)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Farm health score',
                                style: TextStyle(
                                  color: Color(0xFF6B7B71),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '86',
                                      style: TextStyle(
                                        color: Color(0xFF1A2E23),
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' / 100',
                                      style: TextStyle(
                                        color: Color(0xFF8A988F),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.arrow_outward_rounded,
                                        size: 13,
                                        color: Color(0xFF2E7D4E),
                                      ),
                                      SizedBox(width: 3),
                                      Text(
                                        '4 pts',
                                        style: TextStyle(
                                          color: Color(0xFF2E7D4E),
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  CustomPaint(
                                    size: const Size(48, 18),
                                    painter: SparklinePainter(
                                      points: const [
                                        10,
                                        12,
                                        11,
                                        14,
                                        15,
                                        18,
                                        20,
                                      ],
                                      color: const Color(0xFF2E7D4E),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Milk Today Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFE8ECE5)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Milk today',
                                style: TextStyle(
                                  color: Color(0xFF6B7B71),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '342',
                                      style: TextStyle(
                                        color: Color(0xFF1A2E23),
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' L',
                                      style: TextStyle(
                                        color: Color(0xFF8A988F),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.arrow_outward_rounded,
                                        size: 13,
                                        color: Color(0xFF2E7D4E),
                                      ),
                                      SizedBox(width: 3),
                                      Text(
                                        '2.1%',
                                        style: TextStyle(
                                          color: Color(0xFF2E7D4E),
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  CustomPaint(
                                    size: const Size(48, 18),
                                    painter: SparklinePainter(
                                      points: const [
                                        12,
                                        14,
                                        11,
                                        13,
                                        16,
                                        15,
                                        19,
                                      ],
                                      color: const Color(0xFF2E7D4E),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Quick actions Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick actions',
                        style: TextStyle(
                          color: Color(0xFF1A2E23),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _quickActionTile(
                            title: 'Assess',
                            icon: Icons.assignment_outlined,
                            isPrimary: true,
                          ),
                          const SizedBox(width: 8),
                          _quickActionTile(
                            title: 'Fever',
                            icon: Icons.device_thermostat_outlined,
                            isPrimary: false,
                          ),
                          const SizedBox(width: 8),
                          _quickActionTile(
                            title: 'Milk log',
                            icon: Icons.water_drop_outlined,
                            isPrimary: false,
                          ),
                          const SizedBox(width: 8),
                          _quickActionTile(
                            title: 'Vaccine',
                            icon: Icons.vaccines_outlined,
                            isPrimary: false,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Needs attention Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Needs attention',
                            style: TextStyle(
                              color: Color(0xFF1A2E23),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          InkWell(
                            onTap: widget.onCows,
                            borderRadius: BorderRadius.circular(6),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              child: Text(
                                'View all',
                                style: TextStyle(
                                  color: Color(0xFF2E6845),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _needsAttentionItem(
                        title: 'Kaveri · Tag 021',
                        subtitle: 'Temperature 39.8 °C',
                        badgeText: 'Alert',
                        isAlert: true,
                        icon: Icons.device_thermostat_outlined,
                      ),
                      _needsAttentionItem(
                        title: 'Nandini · Tag 009',
                        subtitle: 'Low feed intake, 2 days',
                        badgeText: 'Watch',
                        isAlert: false,
                        icon: Icons.restaurant_outlined,
                      ),
                      _needsAttentionItem(
                        title: 'Gauri · Tag 012',
                        subtitle: 'Milk yield down 18%',
                        badgeText: 'Watch',
                        isAlert: false,
                        icon: Icons.water_drop_outlined,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Care calendar Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Care calendar',
                            style: TextStyle(
                              color: Color(0xFF1A2E23),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          InkWell(
                            onTap: widget.onRecords,
                            borderRadius: BorderRadius.circular(6),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              child: Text(
                                'Open',
                                style: TextStyle(
                                  color: Color(0xFF2E6845),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _calendarEventCard(
                        day: '20',
                        month: 'OCT',
                        title: 'FMD vaccination',
                        subtitle: '6 cows · Shed A',
                      ),
                      _calendarEventCard(
                        day: '24',
                        month: 'OCT',
                        title: 'Vet visit, Dr. Sharma',
                        subtitle: 'Routine check · 10:00',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Top performers Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Top performers',
                            style: TextStyle(
                              color: Color(0xFF1A2E23),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          InkWell(
                            onTap: widget.onCows,
                            borderRadius: BorderRadius.circular(6),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              child: Text(
                                'My cows',
                                style: TextStyle(
                                  color: Color(0xFF2E6845),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _topPerformerCard(
                            initials: 'GA',
                            name: 'Ganga',
                            breed: 'Holstein',
                            healthPercent: '95% healthy',
                            milkYield: '18',
                            progress: 0.95,
                          ),
                          const SizedBox(width: 12),
                          _topPerformerCard(
                            initials: 'LA',
                            name: 'Lakshmi',
                            breed: 'Gir',
                            healthPercent: '92% healthy',
                            milkYield: '12',
                            progress: 0.92,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BoviCareLoginPage extends StatefulWidget {
  const BoviCareLoginPage({super.key, required this.onLoginSuccess});

  final VoidCallback onLoginSuccess;

  @override
  State<BoviCareLoginPage> createState() => _BoviCareLoginPageState();
}

class _BoviCareLoginPageState extends State<BoviCareLoginPage> {
  final TextEditingController _phoneController =
      TextEditingController(text: '+91 98765 43210');
  final TextEditingController _pinController =
      TextEditingController(text: '1234');

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7F8F4),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              width: 68,
              height: 68,
              decoration: const BoxDecoration(
                color: Color(0xFF679C28),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.pets_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'BoviCare',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E2E24),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Patil Dairy, Nashik',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF5E8E25),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: const Icon(Icons.phone_outlined, color: Color(0xFF5E8E25)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE5EAE1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE5EAE1)),
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _pinController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Security PIN',
              prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF5E8E25)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE5EAE1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE5EAE1)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: widget.onLoginSuccess,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF679C28),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Sign In to Farm',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: widget.onLoginSuccess,
            child: const Text(
              'Continue as Guest Demo →',
              style: TextStyle(color: Color(0xFF5E8E25), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class BoviCareProfilePage extends StatelessWidget {
  const BoviCareProfilePage({
    super.key,
    required this.onBack,
    required this.onLogout,
  });

  final VoidCallback onBack;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7F8F4),
      child: Column(
        children: [
          Container(
            color: const Color(0xFF679C28),
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
            child: Row(
              children: [
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Farm Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEBF5D5),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'RP',
                        style: TextStyle(
                          color: Color(0xFF3E6319),
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Patil Dairy, Nashik',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E2E24),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Owner: Ramesh Patil · Nashik, Maharashtra',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF758579),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE8ECE4)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            '14',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E2E24),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Total Cattle',
                            style: TextStyle(fontSize: 11, color: Color(0xFF758579)),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '180 L',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF4C7820),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Daily Milk',
                            style: TextStyle(fontSize: 11, color: Color(0xFF758579)),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '3',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFC7691C),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Need Review',
                            style: TextStyle(fontSize: 11, color: Color(0xFF758579)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Material(
                  color: Colors.transparent,
                  child: ListTile(
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFFE8ECE4)),
                    ),
                    leading: const Icon(Icons.language_rounded, color: Color(0xFF5E8E25)),
                    title: const Text('Language: English / मराठी'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      showMessage(context, 'Language switcher available in settings.');
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Material(
                  color: Colors.transparent,
                  child: ListTile(
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFFE8ECE4)),
                    ),
                    leading: const Icon(Icons.notifications_active_outlined, color: Color(0xFF5E8E25)),
                    title: const Text('SMS & WhatsApp Alerts'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      showMessage(context, 'Alert preferences saved.');
                    },
                  ),
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: onLogout,
                  icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                  label: const Text('Log Out', style: TextStyle(color: Colors.redAccent)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PremiumActionCard extends StatelessWidget {
  const PremiumActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.value,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE7EAE1)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFDDEFE2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFF176B45), size: 25),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color(0xFF20352A),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF77857A),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (value != null) ...[
                const SizedBox(width: 12),
                Text(
                  value!,
                  style: const TextStyle(
                    color: Color(0xFF20352A),
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF77857A)),
            ],
          ),
        ),
      ),
    );
  }
}

class SimpleScreen extends StatelessWidget {
  const SimpleScreen({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFE4F0E3),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(icon, color: forest, size: 48),
            ),
            const SizedBox(height: 22),
            Text(
              title,
              style: const TextStyle(
                color: ink,
                fontSize: 25,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: muted, fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class AssessPage extends StatefulWidget {
  const AssessPage({
    super.key,
    required this.onBack,
    this.cows = const [],
    this.records = const [],
    this.onRecordAdded,
    this.onViewRecords,
  });

  final VoidCallback onBack;
  final List<Cow> cows;
  final List<HealthRecord> records;
  final ValueChanged<HealthRecord>? onRecordAdded;
  final VoidCallback? onViewRecords;

  @override
  State<AssessPage> createState() => _AssessPageState();
}

class _AssessPageState extends State<AssessPage> {
  late List<Cow> _herdCows;
  late List<HealthRecord> _localRecords;

  @override
  void initState() {
    super.initState();
    _herdCows = widget.cows.isNotEmpty
        ? widget.cows
        : const [
            Cow(
              name: 'Ganga',
              id: 'COW-001',
              status: 'Healthy',
              breed: 'Holstein',
              age: '4 yrs',
              healthScore: 95,
              milkYield: '18 L',
              lastCheck: 'Today',
            ),
            Cow(
              name: 'Lakshmi',
              id: 'COW-003',
              status: 'Healthy',
              breed: 'Gir',
              age: '5 yrs',
              healthScore: 92,
              milkYield: '12 L',
              lastCheck: 'Yesterday',
            ),
            Cow(
              name: 'Nandini',
              id: 'COW-002',
              status: 'Attention',
              breed: 'Jersey',
              age: '3 yrs',
              healthScore: 64,
              milkYield: '9 L',
              lastCheck: '2 days ago',
            ),
          ];
    _localRecords = List.from(widget.records);
  }

  @override
  void didUpdateWidget(covariant AssessPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cows.isNotEmpty) {
      _herdCows = widget.cows;
    }
    if (widget.records.isNotEmpty) {
      _localRecords = List.from(widget.records);
    }
  }

  // 1. Guided Clinical Udder Assessment Flow (Wizard)
  void _startAssessmentWizard([Cow? preselectedCow]) {
    Cow selectedCow = preselectedCow ?? _herdCows.first;
    final affectedQuarters = <String>{};
    String swelling = 'None';
    String warmth = 'Normal';
    String milkAppearance = 'Normal creamy';
    String milkConsistency = 'Clear';
    String cowBehavior = 'Calm';
    bool hasFever = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            // Calculate dynamic mastitis risk score
            int score = 96;
            if (swelling == 'Mild') score -= 15;
            if (swelling == 'Severe') score -= 35;
            if (warmth == 'Warm') score -= 10;
            if (warmth == 'Hot') score -= 25;
            if (milkAppearance == 'Watery') score -= 20;
            if (milkAppearance == 'Yellowish/Discolored') score -= 25;
            if (milkAppearance == 'Blood-tinged') score -= 35;
            if (milkConsistency == 'Flakes') score -= 20;
            if (milkConsistency == 'Clots') score -= 30;
            if (cowBehavior == 'Restless / Pain') score -= 15;
            if (cowBehavior == 'Kicking cluster') score -= 20;
            if (hasFever) score -= 20;
            if (affectedQuarters.isNotEmpty) score -= (affectedQuarters.length * 5);
            score = score.clamp(18, 98);

            String resultCategory;
            Color resultColor;
            String recommendation;

            if (score >= 88) {
              resultCategory = 'Healthy (Grade 0)';
              resultColor = const Color(0xFF2E7D32);
              recommendation = 'Normal udder health. Continue routine pre-dip and post-dip sanitization.';
            } else if (score >= 65) {
              resultCategory = 'Subclinical Risk (Grade 1)';
              resultColor = const Color(0xFFC48E28);
              recommendation = 'Early inflammation suspected. Conduct CMT paddle test and inspect foremilk daily.';
            } else {
              resultCategory = 'Clinical Alert (Grade 2/3)';
              resultColor = const Color(0xFFC62828);
              recommendation = 'Acute mastitis indicators detected! Isolate milk, disinfect clusters, and consult veterinarian immediately.';
            }

            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFF7F8F4),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD3DBCF),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Udder Health Screening',
                              style: TextStyle(
                                fontFamily: 'serif',
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1B2E21),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Clinical observations & mastitis detection',
                              style: TextStyle(fontSize: 12.5, color: Color(0xFF6B7B6D)),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: resultColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$score%',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: resultColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // 1. Select Cow
                    const Text(
                      '1. Select Cow',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF20352A)),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _herdCows.map((cow) {
                          final isSelected = cow.id == selectedCow.id;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text('${cow.name} (${cow.id})'),
                              selected: isSelected,
                              selectedColor: const Color(0xFF20352A),
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFF20352A),
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              ),
                              onSelected: (val) {
                                if (val) setSheetState(() => selectedCow = cow);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2. Interactive 4-Quarter Check
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '2. Udder Quarters Inspection',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF20352A)),
                        ),
                        Text(
                          affectedQuarters.isEmpty ? 'All Clear' : '${affectedQuarters.length} Flagged',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: affectedQuarters.isEmpty ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: ['FL (Front Left)', 'FR (Front Right)', 'RL (Rear Left)', 'RR (Rear Right)'].map((q) {
                        final isMarked = affectedQuarters.contains(q);
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: InkWell(
                              onTap: () {
                                setSheetState(() {
                                  if (isMarked) {
                                    affectedQuarters.remove(q);
                                  } else {
                                    affectedQuarters.add(q);
                                  }
                                });
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: isMarked ? const Color(0xFFE57373) : Colors.white,
                                  border: Border.all(
                                    color: isMarked ? const Color(0xFFD32F2F) : const Color(0xFFE2E7DE),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  q.split(' ').first,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isMarked ? Colors.white : const Color(0xFF20352A),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // 3. Swelling & Heat
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Udder Swelling', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF20352A))),
                              const SizedBox(height: 6),
                              _buildDropdown(
                                value: swelling,
                                items: const ['None', 'Mild', 'Severe'],
                                onChanged: (v) => setSheetState(() => swelling = v!),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Quarter Heat', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF20352A))),
                              const SizedBox(height: 6),
                              _buildDropdown(
                                value: warmth,
                                items: const ['Normal', 'Warm', 'Hot'],
                                onChanged: (v) => setSheetState(() => warmth = v!),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // 4. Foremilk Quality
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Milk Appearance', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF20352A))),
                              const SizedBox(height: 6),
                              _buildDropdown(
                                value: milkAppearance,
                                items: const ['Normal creamy', 'Watery', 'Yellowish/Discolored', 'Blood-tinged'],
                                onChanged: (v) => setSheetState(() => milkAppearance = v!),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Consistency', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF20352A))),
                              const SizedBox(height: 6),
                              _buildDropdown(
                                value: milkConsistency,
                                items: const ['Clear', 'Flakes', 'Clots'],
                                onChanged: (v) => setSheetState(() => milkConsistency = v!),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // 5. Cow Reaction & Temperature
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Milking Behavior', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF20352A))),
                              const SizedBox(height: 6),
                              _buildDropdown(
                                value: cowBehavior,
                                items: const ['Calm', 'Restless / Pain', 'Kicking cluster'],
                                onChanged: (v) => setSheetState(() => cowBehavior = v!),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Elevated Temp?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF20352A))),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () => setSheetState(() => hasFever = !hasFever),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                                  decoration: BoxDecoration(
                                    color: hasFever ? const Color(0xFFFFEBEE) : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: hasFever ? const Color(0xFFEF5350) : const Color(0xFFE2E7DE),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        hasFever ? 'Fever (>39.5°C)' : 'Normal (38.5°C)',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: hasFever ? const Color(0xFFC62828) : const Color(0xFF20352A),
                                        ),
                                      ),
                                      Icon(
                                        hasFever ? Icons.check_circle_rounded : Icons.circle_outlined,
                                        size: 16,
                                        color: hasFever ? const Color(0xFFC62828) : const Color(0xFF8A998E),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Evaluation Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: resultColor.withValues(alpha: 0.35)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                score >= 88
                                    ? Icons.check_circle_rounded
                                    : (score >= 65 ? Icons.warning_amber_rounded : Icons.error_outline_rounded),
                                color: resultColor,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                resultCategory,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: resultColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            recommendation,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF5E6F62), height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Save Record Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        onPressed: () {
                          final newRecord = HealthRecord(
                            cowName: selectedCow.name,
                            cowId: selectedCow.id,
                            date: DateTime.now(),
                            result: score >= 88 ? 'Healthy' : (score >= 65 ? 'Needs follow-up' : 'Clinical Mastitis Alert'),
                            notes: 'Screening Score: $score%. Udder: $swelling swelling, $warmth temp. Milk: $milkAppearance ($milkConsistency). Quarters: ${affectedQuarters.isEmpty ? "All Clear" : affectedQuarters.join(", ")}.',
                          );

                          setState(() {
                            _localRecords.insert(0, newRecord);
                          });
                          widget.onRecordAdded?.call(newRecord);
                          Navigator.pop(ctx);

                          _showAssessmentSuccessDialog(selectedCow, score, resultCategory);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF1B3929),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Save to Health Records', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAssessmentSuccessDialog(Cow cow, int score, String verdict) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          backgroundColor: const Color(0xFFF7F8F4),
          title: Row(
            children: const [
              Icon(Icons.check_circle_rounded, color: Color(0xFF1B3929), size: 26),
              SizedBox(width: 10),
              Text(
                'Assessment Logged',
                style: TextStyle(fontFamily: 'serif', fontSize: 19, fontWeight: FontWeight.w700, color: Color(0xFF1B2E21)),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assessment successfully saved for ${cow.name} (${cow.id}).',
                style: const TextStyle(fontSize: 13, color: Color(0xFF4C5E51)),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E7DE)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Overall Health Index', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF2A3D2F))),
                    Text('$score%', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1B3929))),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close', style: TextStyle(color: Color(0xFF6A7B6D))),
            ),
            if (widget.onViewRecords != null)
              FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  widget.onViewRecords!();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1B3929),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('View in Records'),
              ),
          ],
        );
      },
    );
  }

  // 2. California Mastitis Test (CMT) Paddle Calculator
  void _openCmtCalculator([Cow? preselectedCow]) {
    Cow selectedCow = preselectedCow ?? _herdCows.first;
    int q1 = 0, q2 = 0, q3 = 0, q4 = 0;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final avgScore = (q1 + q2 + q3 + q4) / 4.0;
            String cmtVerdict;
            Color cmtColor;
            String sccRange;

            if (avgScore <= 0.25) {
              cmtVerdict = 'Negative (CMT 0)';
              cmtColor = const Color(0xFF2E7D32);
              sccRange = '< 200,000 cells/mL (High Quality)';
            } else if (avgScore <= 1.25) {
              cmtVerdict = 'Trace to Mild (CMT 1)';
              cmtColor = const Color(0xFFC48E28);
              sccRange = '200,000 – 1,200,000 cells/mL (Subclinical)';
            } else {
              cmtVerdict = 'Distinct / Strong Reaction (CMT 2-3)';
              cmtColor = const Color(0xFFC62828);
              sccRange = '> 2,000,000 cells/mL (Clinical Alert)';
            }

            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFF7F8F4),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD3DBCF),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CMT Paddle Calculator',
                              style: TextStyle(
                                fontFamily: 'serif',
                                fontSize: 21,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1B2E21),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'California Mastitis Test viscosity index',
                              style: TextStyle(fontSize: 12, color: Color(0xFF6B7B6D)),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: cmtColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            avgScore.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: cmtColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Cow selector for CMT
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _herdCows.map((c) {
                          final isSel = c.id == selectedCow.id;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(c.name),
                              selected: isSel,
                              selectedColor: const Color(0xFF20352A),
                              labelStyle: TextStyle(
                                color: isSel ? Colors.white : const Color(0xFF20352A),
                                fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                              ),
                              onSelected: (val) {
                                if (val) setModalState(() => selectedCow = c);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 4-Quarter CMT Wells
                    _buildCmtWell('Front Left (FL)', q1, (val) => setModalState(() => q1 = val)),
                    const SizedBox(height: 8),
                    _buildCmtWell('Front Right (FR)', q2, (val) => setModalState(() => q2 = val)),
                    const SizedBox(height: 8),
                    _buildCmtWell('Rear Left (RL)', q3, (val) => setModalState(() => q3 = val)),
                    const SizedBox(height: 8),
                    _buildCmtWell('Rear Right (RR)', q4, (val) => setModalState(() => q4 = val)),
                    const SizedBox(height: 16),

                    // CMT Verdict Banner
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cmtColor.withValues(alpha: 0.35)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                avgScore <= 0.25
                                    ? Icons.check_circle_rounded
                                    : (avgScore <= 1.25 ? Icons.warning_amber_rounded : Icons.error_outline_rounded),
                                color: cmtColor,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                cmtVerdict,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: cmtColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('Estimated SCC: $sccRange', style: const TextStyle(fontSize: 11.5, color: Color(0xFF5E6F62))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Save CMT Result Action
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        onPressed: () {
                          final newRecord = HealthRecord(
                            cowName: selectedCow.name,
                            cowId: selectedCow.id,
                            date: DateTime.now(),
                            result: avgScore <= 0.25 ? 'Healthy' : (avgScore <= 1.25 ? 'Needs follow-up' : 'Clinical Mastitis Alert'),
                            notes: 'CMT Paddle Score: ${avgScore.toStringAsFixed(1)}. Wells: FL:$q1, FR:$q2, RL:$q3, RR:$q4. SCC Est: $sccRange.',
                          );
                          setState(() {
                            _localRecords.insert(0, newRecord);
                          });
                          widget.onRecordAdded?.call(newRecord);
                          Navigator.pop(ctx);
                          _showAssessmentSuccessDialog(selectedCow, ((1.0 - (avgScore / 3.0).clamp(0.0, 1.0)) * 100).toInt(), cmtVerdict);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF1B3929),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Save CMT Result', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCmtWell(String label, int currentScore, ValueChanged<int> onSelect) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E7DE)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF20352A))),
          Row(
            children: [0, 1, 2, 3].map((val) {
              final isSel = currentScore == val;
              return GestureDetector(
                onTap: () => onSelect(val),
                child: Container(
                  margin: const EdgeInsets.only(left: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isSel ? const Color(0xFF1B3929) : const Color(0xFFF1F3EC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    val == 0 ? '0' : '+$val',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isSel ? Colors.white : const Color(0xFF334638),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 3. AI Photo / Udder Vision Scanner
  void _openAiPhotoScanner() {
    bool isScanning = false;
    MastitisVisionResult? scanResult;
    final visionService = MastitisVisionService();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setScanState) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF161817),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B403D),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'AI Udder Vision Scanner',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF285536),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('MobileNetV2 TFLite', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Viewfinder
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: const Color(0xFF222624),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF3B443F)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Reticle
                          Positioned.fill(
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isScanning ? const Color(0xFF4CAF50) : const Color(0xFF6C7C71),
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                          if (isScanning)
                            const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(color: Color(0xFF81C784)),
                                  SizedBox(height: 12),
                                  Text(
                                    'Executing MobileNetV2 mastitis inference...',
                                    style: TextStyle(color: Color(0xFFA5D6A7), fontSize: 12),
                                  ),
                                ],
                              ),
                            )
                          else if (scanResult != null)
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    scanResult!.riskTier == 'High'
                                        ? Icons.warning_amber_rounded
                                        : Icons.verified_rounded,
                                    color: scanResult!.riskTier == 'High'
                                        ? const Color(0xFFE57373)
                                        : const Color(0xFF81C784),
                                    size: 36,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    scanResult!.label,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Mastitis Risk: ${(scanResult!.mastitisProbability * 100).toStringAsFixed(1)}% (Tier: ${scanResult!.riskTier})',
                                    style: TextStyle(
                                      color: scanResult!.riskTier == 'High' ? const Color(0xFFEF9A9A) : const Color(0xFFA5D6A7),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Healthy Baseline: ${(scanResult!.normalProbability * 100).toStringAsFixed(1)}%',
                                    style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 11),
                                  ),
                                ],
                              ),
                            )
                          else
                            const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.center_focus_strong_rounded, color: Color(0xFF8C9E91), size: 44),
                                SizedBox(height: 8),
                                Text('Align udder inside frame to screen', style: TextStyle(color: Color(0xFFB5C4BA), fontSize: 13)),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    if (scanResult != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF222624),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recommendation: ${scanResult!.recommendation}',
                              style: const TextStyle(color: Color(0xFFD2DDD5), fontSize: 12),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              scanResult!.disclaimer,
                              style: const TextStyle(color: Color(0xFF8B9B90), fontSize: 10.5, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: FilledButton.icon(
                        onPressed: isScanning
                            ? null
                            : () async {
                                setScanState(() {
                                  isScanning = true;
                                });
                                // Generate a 224x224 RGB test buffer representing bovine udder tissue
                                final testBuffer = Uint8List(224 * 224 * 3);
                                for (int i = 0; i < testBuffer.length; i += 3) {
                                  testBuffer[i] = 185; // R
                                  testBuffer[i + 1] = 145; // G
                                  testBuffer[i + 2] = 140; // B
                                }
                                final result = await visionService.predictFromRgbBytes(testBuffer);
                                if (ctx.mounted) {
                                  setScanState(() {
                                    isScanning = false;
                                    scanResult = result;
                                  });
                                }
                              },
                        icon: const Icon(Icons.camera_alt_rounded, size: 18),
                        label: Text(scanResult != null ? 'Scan Again' : 'Capture & Screen Udder'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF285536),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 4. Pre-Milking Teat Prep & Sanitization Protocol
  void _openHygieneProtocol() {
    int timerSeconds = 30;
    bool isTimerRunning = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setTimerState) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFF7F8F4),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD3DBCF),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Teat Prep & Milking Hygiene',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1B2E21),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Mastitis prevention standard operating procedure',
                      style: TextStyle(fontSize: 12.5, color: Color(0xFF6B7B6D)),
                    ),
                    const SizedBox(height: 18),

                    // 30-Sec Pre-dip Timer Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2EBD5),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFD4E0CB)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: const BoxDecoration(
                              color: Color(0xFF1B3929),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$timerSeconds s',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Pre-Dip Contact Timer',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1B2E21)),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Allow 0.5% iodine dip 30s to destroy surface bacteria before wiping.',
                                  style: TextStyle(fontSize: 11, color: Color(0xFF5A705E), height: 1.3),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              if (!isTimerRunning) {
                                setTimerState(() {
                                  isTimerRunning = true;
                                  timerSeconds = 30;
                                });
                                Future.delayed(const Duration(milliseconds: 300), () {
                                  // simulated quick timer for farmer
                                  if (ctx.mounted) {
                                    setTimerState(() {
                                      timerSeconds = 0;
                                      isTimerRunning = false;
                                    });
                                  }
                                });
                              } else {
                                setTimerState(() {
                                  isTimerRunning = false;
                                  timerSeconds = 30;
                                });
                              }
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B3929),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                timerSeconds == 0 ? 'Done!' : (isTimerRunning ? 'Timing' : 'Start'),
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Protocol Checklist steps
                    _buildProtocolStep(
                      step: '1',
                      title: 'Strip Foremilk Into Cup',
                      desc: 'Strip 2-3 squirts from each quarter onto black strip plate. Never strip onto bedding.',
                    ),
                    const SizedBox(height: 10),
                    _buildProtocolStep(
                      step: '2',
                      title: 'Pre-Dip All 4 Teats',
                      desc: 'Coat at least 75% of teat barrel with approved sanitizing dip (e.g. 0.5% iodine).',
                    ),
                    const SizedBox(height: 10),
                    _buildProtocolStep(
                      step: '3',
                      title: 'Wipe Clean & Dry',
                      desc: 'Use one clean, dry paper towel per cow. Dry teat ends thoroughly to avoid teat canal entry.',
                    ),
                    const SizedBox(height: 10),
                    _buildProtocolStep(
                      step: '4',
                      title: 'Post-Milking Barrier Seal',
                      desc: 'Dip teats immediately after cluster removal to seal open teat sphincter for 30 minutes.',
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: FilledButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF1B3929),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Understood & Close', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProtocolStep({required String step, required String title, required String desc}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5EDE0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F3EA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                step,
                style: const TextStyle(color: Color(0xFF176B45), fontWeight: FontWeight.w800, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: Color(0xFF1B2E21))),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7B6D), height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSymptomAdviceDialog(String title, String tag, String explanation, String actions) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF7F8F4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Row(
            children: [
              const Icon(Icons.info_rounded, color: Color(0xFF176B45), size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontFamily: 'serif', fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1B2E21)),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(explanation, style: const TextStyle(fontSize: 12.5, color: Color(0xFF4C5E51), height: 1.4)),
              const SizedBox(height: 12),
              const Text('Recommended Actions:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: Color(0xFF1B2E21))),
              const SizedBox(height: 4),
              Text(actions, style: const TextStyle(fontSize: 12, color: Color(0xFF5E6F62), height: 1.4)),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1B3929),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E7DE)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF5A6C5D)),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12.5, color: Color(0xFF20352A))))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalCows = _herdCows.length;
    final healthyCows = _herdCows.where((c) => c.status == 'Healthy').length;
    final attentionCows = totalCows - healthyCows;

    return Container(
      color: const Color(0xFFF7F8F4),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Preserved Header exactly as requested
            AssessHeader(onBack: widget.onBack),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 8, bottom: 24),
                children: [
                  // Preserved Welcome Title & Subtitle
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Welcome to health screening',
                      style: TextStyle(
                        color: Color(0xFF20352A),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Record observations and check for possible warning signs.',
                      style: TextStyle(
                        color: Color(0xFF77857A),
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Preserved Banner with cow image kept intact
                  AssessmentBanner(
                    onAssessNow: () => _startAssessmentWizard(),
                  ),
                  const SizedBox(height: 20),

                  // Preserved "Before you begin" guidance card
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Before you begin',
                      style: TextStyle(
                        color: Color(0xFF20352A),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE7EAE1)),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: Color(0xFF176B45),
                            size: 22,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Choose the cow you want to assess and record any changes you observe. Screening provides guidance, not a veterinary diagnosis.',
                              style: TextStyle(
                                color: Color(0xFF77857A),
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // NEW FEATURE: UDDER HEALTH OVERVIEW (Cohesive with My Cows HERD SUMMARY)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2EBD5),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          // Subtle decorative ripples on top right matching My Cows
                          Positioned(
                            right: -12,
                            top: -16,
                            child: Container(
                              width: 86,
                              height: 86,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF38634B).withValues(alpha: 0.07),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 18,
                            top: 14,
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF38634B).withValues(alpha: 0.05),
                              ),
                            ),
                          ),

                          // Card content
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'UDDER HEALTH OVERVIEW',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.5,
                                        color: Color(0xFF5A705E),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.04),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'Updated today',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF4C6351),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Segmented Bar (Healthy vs Attention)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: SizedBox(
                                    height: 7,
                                    child: Row(
                                      children: [
                                        if (healthyCows > 0)
                                          Expanded(
                                            flex: healthyCows,
                                            child: Container(color: const Color(0xFF557B45)),
                                          ),
                                        if (attentionCows > 0)
                                          Expanded(
                                            flex: attentionCows,
                                            child: Container(color: const Color(0xFFC49332)),
                                          ),
                                        if (totalCows == 0)
                                          Expanded(
                                            child: Container(color: const Color(0xFFCBD6C2)),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // Key metrics row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text(
                                          '${((healthyCows / (totalCows == 0 ? 1 : totalCows)) * 100).round()}%',
                                          style: const TextStyle(
                                            fontSize: 21,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF182A1C),
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        const Text(
                                          'Herd Index',
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            color: Color(0xFF586B5A),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          '$healthyCows/$totalCows',
                                          style: const TextStyle(
                                            fontSize: 21,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF182A1C),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          width: 7,
                                          height: 7,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF557B45),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Text(
                                          'Clear',
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            color: Color(0xFF586B5A),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'Grade 0',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF182A1C),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          width: 7,
                                          height: 7,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFC49332),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Text(
                                          'Low Risk',
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            color: Color(0xFF586B5A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // NEW FEATURE: Quick Screening Action Tiles Hub (Matching Dashboard style)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Screening Actions',
                      style: TextStyle(
                        color: Color(0xFF20352A),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _buildQuickActionTile(
                          title: 'Clinical',
                          subtitle: '4-Quarter',
                          icon: Icons.checklist_rounded,
                          isPrimary: true,
                          onTap: () => _startAssessmentWizard(),
                        ),
                        const SizedBox(width: 8),
                        _buildQuickActionTile(
                          title: 'CMT Paddle',
                          subtitle: 'Viscosity',
                          icon: Icons.science_outlined,
                          isPrimary: false,
                          onTap: () => _openCmtCalculator(),
                        ),
                        const SizedBox(width: 8),
                        _buildQuickActionTile(
                          title: 'AI Scanner',
                          subtitle: 'Thermal',
                          icon: Icons.camera_alt_outlined,
                          isPrimary: false,
                          onTap: () => _openAiPhotoScanner(),
                        ),
                        const SizedBox(width: 8),
                        _buildQuickActionTile(
                          title: 'Teat Prep',
                          subtitle: '30s Dip',
                          icon: Icons.timer_outlined,
                          isPrimary: false,
                          onTap: () => _openHygieneProtocol(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tabular Random Forest Inference Banner
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ApiTestScreen()),
                        );
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF176B45).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF176B45).withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF176B45),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.biotech_rounded, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Supabase Cloud Milk ML Lab',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF176B45),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Test 5-parameter biochemical prediction (Temp, pH, Conductivity, SCC, Yield)',
                                    style: TextStyle(fontSize: 11, color: Color(0xFF556558)),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF176B45)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // NEW FEATURE: Choose Cow to Screen Carousel
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Choose cow to assess',
                          style: TextStyle(
                            color: Color(0xFF20352A),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${_herdCows.length} cows ready',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7B6D)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 114,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: _herdCows.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final cow = _herdCows[index];
                        final isHealthy = cow.status == 'Healthy';
                        return InkWell(
                          onTap: () => _startAssessmentWizard(cow),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: 154,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE4E9E0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      cow.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1B2E21),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isHealthy ? const Color(0xFFE2EFE3) : const Color(0xFFFDF0D5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${cow.healthScore}%',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: isHealthy ? const Color(0xFF2A6836) : const Color(0xFFA67313),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${cow.id} · ${cow.breed}',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF758578)),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Text('Screen cow', style: TextStyle(fontSize: 11, color: Color(0xFF176B45), fontWeight: FontWeight.w700)),
                                    Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF176B45)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 22),

                  // NEW FEATURE: Warning signs to watch
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Warning signs to watch',
                      style: TextStyle(
                        color: Color(0xFF20352A),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _buildWarningCard(
                          icon: Icons.water_drop_outlined,
                          title: 'Foremilk Abnormalities',
                          desc: 'Watery secretions, yellow whey, or clotted flakes on strip cup.',
                          tag: 'High Priority',
                          color: const Color(0xFFC62828),
                          onTap: () => _showSymptomAdviceDialog(
                            'Foremilk Abnormalities',
                            'High Priority',
                            'Watery milk, discoloration, or curdled clots indicate somatic cell reaction and active bacterial presence in foremilk.',
                            '1. Isolate milk from bulk tank.\n2. Do not massage infected quarter vigorously.\n3. Perform CMT paddle check immediately.\n4. Consult your herd veterinarian.',
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildWarningCard(
                          icon: Icons.thermostat_rounded,
                          title: 'Quarter Warmth & Swelling',
                          desc: 'Quarter feels hot, firm, or enlarged compared to opposite sides.',
                          tag: 'Inflammation',
                          color: const Color(0xFFC48E28),
                          onTap: () => _showSymptomAdviceDialog(
                            'Quarter Warmth & Swelling',
                            'Inflammation',
                            'Localized heat and firmness indicates acute blood circulation surge battling udder tissue infection.',
                            '1. Compare warmth with symmetrical contralateral quarter.\n2. Check cow body temperature for fever (>39.5°C).\n3. Frequent milking out to reduce bacterial toxin load.',
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildWarningCard(
                          icon: Icons.shield_outlined,
                          title: 'Pain or Kicking During Milking',
                          desc: 'Cow flinches or resists cluster attachment due to udder tenderness.',
                          tag: 'Behavioral',
                          color: const Color(0xFF176B45),
                          onTap: () => _showSymptomAdviceDialog(
                            'Milking Discomfort',
                            'Behavioral',
                            'Pain response upon teat cluster placement is a primary behavioral indicator of subclinical or clinical mastitis.',
                            '1. Inspect teat end for hyperkeratosis or sores.\n2. Ensure gentle vacuum level.\n3. Check foremilk strip cup before cluster attachment.',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // NEW FEATURE: Recent herd assessments
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent herd assessments',
                          style: TextStyle(
                            color: Color(0xFF20352A),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (widget.onViewRecords != null)
                          InkWell(
                            onTap: widget.onViewRecords,
                            child: const Text(
                              'View all',
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF176B45)),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_localRecords.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE5EDE0)),
                        ),
                        child: const Center(
                          child: Text(
                            'No screenings recorded yet. Tap "Assess now" to begin.',
                            style: TextStyle(fontSize: 12, color: Color(0xFF758578)),
                          ),
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: _localRecords.take(3).map((rec) {
                          final isHealthy = rec.result == 'Healthy';
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE5EDE0)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isHealthy ? const Color(0xFFE3EFE3) : const Color(0xFFFDF0D5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isHealthy ? Icons.check_circle_outline_rounded : Icons.warning_amber_rounded,
                                    color: isHealthy ? const Color(0xFF2A6836) : const Color(0xFFA67313),
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${rec.cowName} (${rec.cowId})',
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1B2E21)),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        rec.result,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: isHealthy ? const Color(0xFF2A6836) : const Color(0xFFA67313),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${rec.date.day}/${rec.date.month}',
                                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF758578)),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    if (isPrimary) {
      return Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF1B3929),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1B3929).withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 9.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8ECE5)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F2E4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF2E6845), size: 16),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1A2E23),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF7A8A7F),
                  fontSize: 9.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWarningCard({
    required IconData icon,
    required String title,
    required String desc,
    required String tag,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5EDE0)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF1B2E21))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(tag, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: color)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(desc, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7B6D), height: 1.35)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyCowsPage extends StatefulWidget {
  const MyCowsPage({
    super.key,
    required this.cows,
    required this.onBack,
    this.onAssessCow,
    this.onAddCow,
  });

  final List<Cow> cows;
  final VoidCallback onBack;
  final ValueChanged<Cow>? onAssessCow;
  final ValueChanged<Cow>? onAddCow;

  @override
  State<MyCowsPage> createState() => _MyCowsPageState();
}

class _MyCowsPageState extends State<MyCowsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All'; // 'All', 'Healthy', 'Attention'
  String _sortBy = 'Name'; // 'Name', 'Health', 'Yield'
  late List<Cow> _localCows;

  @override
  void initState() {
    super.initState();
    _localCows = List.from(widget.cows);
  }

  @override
  void didUpdateWidget(covariant MyCowsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cows != widget.cows) {
      _localCows = List.from(widget.cows);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSort() {
    setState(() {
      if (_sortBy == 'Name') {
        _sortBy = 'Health';
      } else if (_sortBy == 'Health') {
        _sortBy = 'Yield';
      } else {
        _sortBy = 'Name';
      }
    });
  }

  List<Cow> get _filteredAndSortedCows {
    final query = _searchController.text.trim().toLowerCase();
    var list = _localCows.where((c) {
      if (_selectedFilter == 'Healthy' && c.status != 'Healthy') return false;
      if (_selectedFilter == 'Attention' && c.status != 'Attention') return false;
      if (query.isNotEmpty) {
        final matchesName = c.name.toLowerCase().contains(query);
        final matchesId = c.id.toLowerCase().contains(query);
        final matchesBreed = c.breed.toLowerCase().contains(query);
        return matchesName || matchesId || matchesBreed;
      }
      return true;
    }).toList();

    if (_sortBy == 'Name') {
      list.sort((a, b) => a.name.compareTo(b.name));
    } else if (_sortBy == 'Health') {
      list.sort((a, b) => b.healthScore.compareTo(a.healthScore));
    } else if (_sortBy == 'Yield') {
      int parseYield(String y) => int.tryParse(y.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      list.sort((a, b) => parseYield(b.milkYield).compareTo(parseYield(a.milkYield)));
    }

    return list;
  }

  void _openAddCowDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final idCtrl = TextEditingController(text: 'COW-00${_localCows.length + 1}');
    final breedCtrl = TextEditingController(text: 'Gir');
    final ageCtrl = TextEditingController(text: '4 yrs');
    final yieldCtrl = TextEditingController(text: '16 L');
    String status = 'Healthy';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFF7F8F4),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD3DBCF),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Add New Cow',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1B2E21),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Enter cow credentials and health details to join the herd.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF6B7B6D)),
                    ),
                    const SizedBox(height: 18),
                    _buildModalInput('Cow Name', nameCtrl, hint: 'e.g. Shanti'),
                    const SizedBox(height: 12),
                    _buildModalInput('Tag ID', idCtrl, hint: 'e.g. COW-004'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildModalInput('Breed', breedCtrl, hint: 'Gir / Holstein')),
                        const SizedBox(width: 10),
                        Expanded(child: _buildModalInput('Age', ageCtrl, hint: '3 yrs')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildModalInput('Daily Yield', yieldCtrl, hint: '14 L'),
                    const SizedBox(height: 14),
                    const Text(
                      'Health Status',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2A3D2F),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Healthy')),
                            selected: status == 'Healthy',
                            selectedColor: const Color(0xFFE2EFE3),
                            onSelected: (val) {
                              if (val) setModalState(() => status = 'Healthy');
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Attention')),
                            selected: status == 'Attention',
                            selectedColor: const Color(0xFFFDF0D5),
                            onSelected: (val) {
                              if (val) setModalState(() => status = 'Attention');
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        onPressed: () {
                          final name = nameCtrl.text.trim();
                          if (name.isEmpty) return;
                          final newCow = Cow(
                            name: name,
                            id: idCtrl.text.trim().isEmpty ? 'COW-00${_localCows.length + 1}' : idCtrl.text.trim(),
                            status: status,
                            breed: breedCtrl.text.trim().isEmpty ? 'Gir' : breedCtrl.text.trim(),
                            age: ageCtrl.text.trim().isEmpty ? '4 yrs' : ageCtrl.text.trim(),
                            milkYield: yieldCtrl.text.trim().isEmpty ? '15 L' : yieldCtrl.text.trim(),
                            healthScore: status == 'Healthy' ? 94 : 68,
                            lastCheck: 'Today',
                          );
                          setState(() {
                            _localCows.add(newCow);
                          });
                          widget.onAddCow?.call(newCow);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added ${newCow.name} to your herd'),
                              backgroundColor: const Color(0xFF1B3929),
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF1B3929),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Save Cow', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModalInput(String label, TextEditingController ctrl, {required String hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF2A3D2F)),
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E7DE)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            controller: ctrl,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1B2E21)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF9AA79C), fontSize: 13),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _localCows.length;
    final healthy = _localCows.where((cow) => cow.status == 'Healthy').length;
    final monitor = total - healthy;
    final cowsList = _filteredAndSortedCows;

    return Container(
      color: const Color(0xFFF7F8F4),
      child: Column(
        children: [
          // Top Header (Icon + My Cows + Add cow button)
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
            child: Row(
              children: [
                // Cow squircle icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDFECD9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.pets_rounded,
                    color: Color(0xFF1B3929),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                // Title & Subtitle
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'My Cows',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1B2E21),
                          letterSpacing: -0.3,
                          fontFamily: 'serif',
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Manage your herd',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF6B7B6D),
                        ),
                      ),
                    ],
                  ),
                ),
                // + Add cow outline button
                InkWell(
                  onTap: () => _openAddCowDialog(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD4E0CB), width: 1.2),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, size: 16, color: Color(0xFF1B3929)),
                        SizedBox(width: 4),
                        Text(
                          'Add cow',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1B3929),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Body
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
              children: [
                // HERD SUMMARY Card
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2EBD5),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      // Subtle decorative concentric ripples on top right
                      Positioned(
                        right: -12,
                        top: -16,
                        child: Container(
                          width: 86,
                          height: 86,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF38634B).withValues(alpha: 0.07),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 18,
                        top: 14,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF38634B).withValues(alpha: 0.05),
                          ),
                        ),
                      ),

                      // Card Content
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header: HERD SUMMARY and Updated today
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'HERD SUMMARY',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.5,
                                    color: Color(0xFF5A705E),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Updated today',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF4C6351),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Segmented Bar (Healthy vs To monitor)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: SizedBox(
                                height: 7,
                                child: Row(
                                  children: [
                                    if (healthy > 0)
                                      Expanded(
                                        flex: healthy,
                                        child: Container(color: const Color(0xFF557B45)),
                                      ),
                                    if (monitor > 0)
                                      Expanded(
                                        flex: monitor,
                                        child: Container(color: const Color(0xFFC49332)),
                                      ),
                                    if (total == 0)
                                      Expanded(
                                        child: Container(color: const Color(0xFFCBD6C2)),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Stats row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      '$total',
                                      style: const TextStyle(
                                        fontSize: 21,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF182A1C),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    const Text(
                                      'Total',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF586B5A),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$healthy',
                                      style: const TextStyle(
                                        fontSize: 21,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF182A1C),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      width: 7,
                                      height: 7,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF557B45),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'Healthy',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF586B5A),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$monitor',
                                      style: const TextStyle(
                                        fontSize: 21,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF182A1C),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      width: 7,
                                      height: 7,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFC49332),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'To monitor',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF586B5A),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Search & Filter Bar (Clean white background, NO black box per user instruction)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E7DE), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search_rounded,
                              color: Color(0xFF758578),
                              size: 21,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: (val) => setState(() {}),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF1B2E21),
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Search name or tag',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF8B9B8E),
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            if (_searchController.text.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: Color(0xFF8B9B8E),
                                  size: 18,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: _toggleSort,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E7DE), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.tune_rounded,
                          color: Color(0xFF1B3929),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Filter Chips Row (All, Healthy, Attention)
                Row(
                  children: [
                    _buildFilterChip('All', total),
                    const SizedBox(width: 8),
                    _buildFilterChip('Healthy', healthy),
                    const SizedBox(width: 8),
                    _buildFilterChip('Attention', monitor),
                  ],
                ),
                const SizedBox(height: 14),

                // Showing cows count & Sort subheader
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Showing ${cowsList.length} cows',
                      style: const TextStyle(
                        color: Color(0xFF5E6F61),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    InkWell(
                      onTap: _toggleSort,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.swap_vert_rounded,
                              size: 16,
                              color: Color(0xFF1B3929),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'Sort: $_sortBy',
                              style: const TextStyle(
                                color: Color(0xFF1B3929),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Cow Cards List
                if (cowsList.isEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 24),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE5E9E0)),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.search_off_rounded,
                          size: 44,
                          color: Color(0xFF8FA192),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No cows found',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1B2E21),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Try adjusting your search query or filter tags.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Color(0xFF6B7B6D)),
                        ),
                        const SizedBox(height: 14),
                        OutlinedButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _selectedFilter = 'All');
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1B3929),
                            side: const BorderSide(color: Color(0xFFD4E0CB)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Reset filters'),
                        ),
                      ],
                    ),
                  )
                else
                  ...cowsList.map((cow) => _buildCowCard(cow)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    final isSelected = _selectedFilter == label;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF20352A) : const Color(0xFFF0F3EC),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF2D3E31),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2F4D3A) : const Color(0xFFDFE5DC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : const Color(0xFF55685A),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCowCard(Cow cow) {
    final isHealthy = cow.status == 'Healthy';
    final initials = cow.name.length >= 2 ? cow.name.substring(0, 2).toUpperCase() : cow.name.toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E9E0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Avatar, Name & Breed, Status Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isHealthy ? const Color(0xFFDFEBD7) : const Color(0xFFFCE9C8),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isHealthy ? const Color(0xFF265034) : const Color(0xFF9E6E16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name and breed/age
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cow.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1B2E21),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${cow.id} · ${cow.breed} · ${cow.age}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF6B7C6E),
                      ),
                    ),
                  ],
                ),
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isHealthy ? const Color(0xFFE2EFE3) : const Color(0xFFFDF0D5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  cow.status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isHealthy ? const Color(0xFF2A6836) : const Color(0xFFA67313),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Health score progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Container(
              height: 6,
              width: double.infinity,
              color: const Color(0xFFECECE3),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (cow.healthScore / 100.0).clamp(0.0, 1.0),
                child: Container(
                  color: isHealthy ? const Color(0xFF4C6E3B) : const Color(0xFFC7922E),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Bottom metrics & assess action row
          Row(
            children: [
              // Health %
              const Icon(
                Icons.shield_outlined,
                size: 15,
                color: Color(0xFF607263),
              ),
              const SizedBox(width: 4),
              Text(
                '${cow.healthScore}%',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF435447),
                ),
              ),
              const SizedBox(width: 16),
              // Milk yield
              const Icon(
                Icons.water_drop_outlined,
                size: 15,
                color: Color(0xFF607263),
              ),
              const SizedBox(width: 4),
              Text(
                cow.milkYield,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF435447),
                ),
              ),
              const SizedBox(width: 16),
              // Last checked
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: Color(0xFF607263),
              ),
              const SizedBox(width: 4),
              Text(
                cow.lastCheck,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF506254),
                ),
              ),
              const Spacer(),
              // Assess CTA
              InkWell(
                onTap: () {
                  if (widget.onAssessCow != null) {
                    widget.onAssessCow!(cow);
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Assess',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF556F5A),
                        ),
                      ),
                      SizedBox(width: 3),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 11,
                        color: Color(0xFF556F5A),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HealthRecordsPage extends StatelessWidget {
  const HealthRecordsPage({
    super.key,
    required this.records,
    required this.onBack,
  });

  final List<HealthRecord> records;
  final VoidCallback onBack;

  static const _cream = Color(0xFFF8F7F0);
  static const _forest = Color(0xFF176B45);
  static const _ink = Color(0xFF20352A);
  static const _muted = Color(0xFF77857A);
  static const _paleGreen = Color(0xFFE5F2E4);
  static const _cardBg = Color(0xFFFFFEFA);
  static const _border = Color(0xFFE7EAE1);
  static const _amber = Color(0xFFAD7412);

  @override
  Widget build(BuildContext context) {
    final totalRecords = records.length;
    final followUps = records
        .where((r) => r.result.toLowerCase().contains('follow-up'))
        .length;

    return Container(
      color: _cream,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── A. Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
              child: Row(
                children: [
                  Material(
                    color: _paleGreen,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      onTap: onBack,
                      borderRadius: BorderRadius.circular(14),
                      child: const SizedBox(
                        width: 44,
                        height: 46,
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: _forest,
                          size: 23,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 13),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Health Records',
                          style: TextStyle(
                            color: _ink,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          "Review your herd's health history",
                          style: TextStyle(color: _muted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Scrollable body ──
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                children: [
                  // ── B. Assessment summary card ──
                  Container(
                    decoration: BoxDecoration(
                      color: _cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _border),
                      boxShadow: [
                        BoxShadow(
                          color: _ink.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Top row: icon + title/subtitle
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
                          child: Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: _paleGreen,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.assignment_rounded,
                                  color: _forest,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Assessment summary',
                                      style: TextStyle(
                                        color: _ink,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      'Saved assessments and observations',
                                      style: TextStyle(
                                        color: _muted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Thin divider
                        const Divider(
                          height: 1,
                          thickness: 0.8,
                          color: _border,
                        ),

                        // Stat tiles row
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Expanded(
                                child: _summaryStatTile(
                                  value: '$totalRecords',
                                  label: 'Total records',
                                  valueColor: _forest,
                                  bgColor: const Color(0xFFE8F5E9),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _summaryStatTile(
                                  value: '$followUps',
                                  label: 'Need follow-up',
                                  valueColor: _amber,
                                  bgColor: const Color(0xFFFFF8E1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── C. Recent assessments heading ──
                  const Text(
                    'Recent assessments',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Recent assessments card
                  if (records.isEmpty)
                    _emptyState()
                  else
                    ...records.reversed.map(_recordCard),

                  const SizedBox(height: 18),

                  // ── D. Footer note ──
                  const Center(
                    child: Text(
                      'Illustrative layout · Counts will come from saved assessment records.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _muted,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Pale stat tile used inside the summary card.
  Widget _summaryStatTile({
    required String value,
    required String label,
    required Color valueColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _muted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Empty state shown when no records exist.
  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 24),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _ink.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _paleGreen,
              borderRadius: BorderRadius.circular(23),
              boxShadow: [
                BoxShadow(
                  color: _forest.withValues(alpha: 0.07),
                  blurRadius: 14,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.description_outlined,
              color: _forest,
              size: 34,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No records yet',
            style: TextStyle(
              color: _ink,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your saved cow assessments will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _muted,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Individual record card for the list.
  Widget _recordCard(HealthRecord record) {
    final needsFollowUp = record.result.toLowerCase().contains('follow-up');

    final dateText =
        '${record.date.day.toString().padLeft(2, '0')}/'
        '${record.date.month.toString().padLeft(2, '0')}/'
        '${record.date.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: needsFollowUp
                  ? const Color(0xFFFFF0CE)
                  : const Color(0xFFDFF0E2),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              Icons.assignment_outlined,
              color: needsFollowUp ? _amber : _forest,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.cowName,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${record.cowId}  •  $dateText',
                  style: const TextStyle(color: _muted, fontSize: 11),
                ),
                const SizedBox(height: 7),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: needsFollowUp
                        ? const Color(0xFFFFF0CE)
                        : const Color(0xFFE2F4DF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    record.result,
                    style: TextStyle(
                      color:
                          needsFollowUp ? const Color(0xFF98620B) : _forest,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (record.notes.isNotEmpty) ...[
                  const SizedBox(height: 7),
                  Text(
                    record.notes,
                    style: const TextStyle(color: _muted, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: _forest, size: 23),
        ],
      ),
    );
  }
}

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}



class AssessHeader extends StatelessWidget {
  final VoidCallback onBack;

  const AssessHeader({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Pale-green back button
          Material(
            color: const Color(0xFFEAF5E9),
            borderRadius: BorderRadius.circular(17),
            child: InkWell(
              onTap: onBack,
              borderRadius: BorderRadius.circular(17),
              child: const SizedBox(
                width: 46,
                height: 46,
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: Color(0xFF176B45),
                  size: 24,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Title and subtitle
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Assess',
                  style: TextStyle(
                    fontSize: 23,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    color: Color(0xFF172E27),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Check your cow’s udder health',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.25,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF758078),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AssessmentBanner extends StatelessWidget {
  const AssessmentBanner({super.key, required this.onAssessNow});

  final VoidCallback onAssessNow;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        height: 122,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFFF2F7EC),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: const Color(0xFFE5EDE0)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF176B45).withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Use the image across the entire banner.
            Image.asset(
              'asset/images/cow_assessment_banner.jpeg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) {
                return const ColoredBox(color: Color(0xFFEAF5E5));
              },
            ),

            // Text and button remain functional.
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 190,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Start a new\nassessment',
                        style: TextStyle(
                          color: Color(0xFF172E27),
                          fontSize: 15,
                          height: 1.05,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Check for early signs of mastitis\n'
                        'in just a few simple steps.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFF758078),
                          fontSize: 9,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 7),
                      SizedBox(
                        height: 26,
                        child: FilledButton(
                          onPressed: onAssessNow,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF087448),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            minimumSize: Size.zero,
                            shape: const StadiumBorder(),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Assess now',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 7),
                              Icon(Icons.arrow_forward_rounded, size: 14),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddCowHeader extends StatelessWidget {
  final VoidCallback onBack;

  const AddCowHeader({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    const forest = Color(0xFF176B50);
    const ink = Color(0xFF20352A);
    const muted = Color(0xFF77857A);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      color: const Color(0xFFF6F5EC),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back),
                color: forest,
                tooltip: 'Back to My Cows',
              ),
              const SizedBox(width: 8),
              const Text(
                'My Cows',
                style: TextStyle(color: forest, fontSize: 14),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.chevron_right, size: 18, color: muted),
              ),
              const Text(
                'Add Cow',
                style: TextStyle(
                  color: ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Register a cow',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: ink,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Add your cow's details to keep health records organized.",
            style: TextStyle(fontSize: 15, color: muted),
          ),
        ],
      ),
    );
  }
}
