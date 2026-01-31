import 'dart:async';
import 'package:flutter/material.dart';

class ProjectPage extends StatefulWidget {
  final Color themeColor;
  final bool darkMode;
  final Function(bool)? onThemeChanged;
  final Function(Color)? onThemeColorChanged;

  const ProjectPage({
    super.key,
    required this.themeColor,
    required this.darkMode,
    this.onThemeChanged,
    this.onThemeColorChanged,
  });

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  bool _localDarkMode = true;
  int selectedIndex = 0;
  final DateTime _nextProjectTime = DateTime.now().add(const Duration(days: 7));
  late Timer _timer;

  // =========================================================
  // COLOR GETTERS - MATCHING ABOUTME.DART STYLE
  // =========================================================
  Color get _backgroundColor =>
      _localDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FA);

  Color get _surfaceColor =>
      _localDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

  Color get _cardColor =>
      _localDarkMode ? const Color(0xFF2D2D2D) : const Color(0xFFFAFAFA);

  Color get _textColor =>
      _localDarkMode ? Colors.white : const Color(0xFF333333);

  Color get _subtextColor =>
      _localDarkMode ? const Color(0xFFAAAAAA) : const Color(0xFF666666);

  @override
  void initState() {
    super.initState();
    _localDarkMode = widget.darkMode;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _handleThemeToggle() {
    final newValue = !_localDarkMode;
    setState(() {
      _localDarkMode = newValue;
    });
    if (widget.onThemeChanged != null) {
      widget.onThemeChanged!(newValue);
    }
  }

  @override
  void didUpdateWidget(ProjectPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.darkMode != widget.darkMode) {
      setState(() {
        _localDarkMode = widget.darkMode;
      });
    }
  }

  // ==============================
  // YOUR PROJECTS DATA
  // ==============================
  final List<Map<String, dynamic>> projects = [
    {
      "title": "Real-Time Alarm Clock",
      "date": "Dec 27, 2024",
      "desc":
          " Alarm Clock is designed to address the everyday need for time management and punctuality. It keep track of the current time with an accurate display and can be used to set an alarm for everyday life. This smart alarm clock also improves the ability to maintain a balanced and productive life.",
      "image": "assets/Alarm.png",
      "tech": "Arduino IDE • Tech Stack",
      "owner": "@vortsarita",
      "status": "Completed",
    },
    {
      "title": "Tic Tac Toe Game",
      "date": "Jul 10, 2025",
      "desc":
          "Tic Tac toe is a classic two-player game where players alternate marking cells with an X or an O. The goal is to be the first to get a certain number of your marks in a row, whether that's horizontally, vertically, or diagonally. It's a simple game to learn, but it requires a bit of strategy to master!",
      "image": "assets/TicTac.png",
      "tech": "SceneBuilder • CSS • VS Code",
      "owner": "@vortsarita",
      "status": "Completed",
    },
    {
      "title": "Cambodia Guide App",
      "date": "Jan 01, 2026",
      "desc":
          "Guide App helps users saving time and reducing confusion. The app offers a simple and user-friendly way to access useful information anytime and anywhere.\nShow all the 25 provinces in Cambodia, popular destination in each province.",
      "image": "assets/Trip.png",
      "tech": "Flutter • Dart • Animations",
      "owner": "@vortsarita",
      "status": "Live",
    },
  ];

  String _getTimeRemaining() {
    final now = DateTime.now();
    final difference = _nextProjectTime.difference(now);

    if (difference.isNegative) {
      return "Coming soon";
    }

    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;

    if (days > 0) {
      return "${days}d ${hours}h ${minutes}m";
    } else if (hours > 0) {
      return "${hours}h ${minutes}m";
    } else {
      return "${minutes}m";
    }
  }

  @override
  Widget build(BuildContext context) {
    bool mobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // APP BAR
            _buildAppBar(mobile),

            // CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: mobile ? 16 : 40,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero section with selected project
                    _buildHeroSection(),
                    const SizedBox(height: 40),

                    // "Top Projects" header with countdown
                    _buildProjectsHeader(),
                    const SizedBox(height: 20),

                    // Projects - Desktop: Grid, Mobile: Horizontal scroll
                    mobile ? _buildMobileProjects() : _buildDesktopProjects(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(bool mobile) {
    return Container(
      height: 100,
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(horizontal: mobile ? 20 : 60),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Back arrow with matching AboutMe.dart style
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pop(context, _localDarkMode),
              borderRadius: BorderRadius.circular(25),
              hoverColor: widget.themeColor.withOpacity(0.1),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: widget.themeColor, width: 2.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_back_rounded,
                      color: widget.themeColor,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Back',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: widget.themeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Center: Logo with "My Projects" text
          mobile
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: widget.themeColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          child: Image.asset(
                            _localDarkMode
                                ? 'assets/cat_night.png'
                                : 'assets/cat_day.png',
                            key: ValueKey<bool>(_localDarkMode),
                            width: 35,
                            height: 35,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "My Projects",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _subtextColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: widget.themeColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          child: Image.asset(
                            _localDarkMode
                                ? 'assets/cat_night.png'
                                : 'assets/cat_day.png',
                            key: ValueKey<bool>(_localDarkMode),
                            width: 35,
                            height: 35,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "My Projects",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _textColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),

          // Right: Theme toggle
          GestureDetector(
            onTap: _handleThemeToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: mobile ? 52 : 70,
              height: mobile ? 28 : 36,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: widget.themeColor, width: 2.2),
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    left: _localDarkMode
                        ? (mobile ? 30 : 40)
                        : (mobile ? 4 : 4),
                    child: Container(
                      width: mobile ? 20 : 28,
                      height: mobile ? 20 : 28,
                      decoration: BoxDecoration(
                        color: widget.themeColor.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        _localDarkMode
                            ? Icons.nightlight_round
                            : Icons.wb_sunny,
                        key: ValueKey<bool>(_localDarkMode),
                        color: _localDarkMode ? Colors.white70 : Colors.black54,
                        size: mobile ? 16 : 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    final project = projects[selectedIndex];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: _surfaceColor,
        border: Border.all(
          color: widget.themeColor.withOpacity(0.5),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_localDarkMode ? 0.2 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date and owner
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: widget.themeColor.withOpacity(
                    _localDarkMode ? 0.15 : 0.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.themeColor.withOpacity(0.5),
                    width: 2.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: widget.themeColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      project["date"],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: widget.themeColor,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 16, color: _subtextColor),
                  const SizedBox(width: 6),
                  Text(
                    project["owner"],
                    style: TextStyle(
                      fontSize: 12,
                      color: _textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Project title
          Text(
            project["title"],
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: _textColor,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            project["desc"],
            style: TextStyle(fontSize: 14, height: 1.6, color: _subtextColor),
          ),
          const SizedBox(height: 20),

          // Tech stack and stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: widget.themeColor.withOpacity(_localDarkMode ? 0.15 : 0.3),
              border: Border.all(
                color: widget.themeColor.withOpacity(0.5),
                width: 2.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "TECH STACK",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        color: _subtextColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      project["tech"],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _textColor,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "STATUS",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        color: _subtextColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: project["status"] == "Live"
                            ? Colors.green.withOpacity(
                                _localDarkMode ? 0.15 : 0.3,
                              )
                            : widget.themeColor.withOpacity(
                                _localDarkMode ? 0.15 : 0.3,
                              ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: project["status"] == "Live"
                              ? Colors.green.withOpacity(0.5)
                              : widget.themeColor.withOpacity(0.5),
                          width: 2.5,
                        ),
                      ),
                      child: Text(
                        project["status"],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: project["status"] == "Live"
                              ? Colors.green
                              : widget.themeColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // View button
          Align(
            alignment: Alignment.centerRight,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.themeColor,
                        widget.themeColor.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: widget.themeColor.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // PROJECTS HEADER
  // =========================================================
  Widget _buildProjectsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "3+ Projects",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: _textColor,
            letterSpacing: 0.3,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: widget.themeColor.withOpacity(_localDarkMode ? 0.15 : 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.themeColor.withOpacity(0.5),
              width: 2.5,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.timer_outlined, size: 14, color: _subtextColor),
              const SizedBox(width: 8),
              Text(
                _getTimeRemaining(),
                style: TextStyle(
                  fontSize: 12,
                  color: _textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================
  // DESKTOP PROJECTS
  // =========================================================
  Widget _buildDesktopProjects() {
    return SizedBox(
      height: 380,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: projects.length,
        separatorBuilder: (context, index) => const SizedBox(width: 20),
        itemBuilder: (context, index) {
          return _buildProjectCard(index, false);
        },
      ),
    );
  }

  // =========================================================
  // MOBILE PROJECTS - FIXED SCROLLING
  // =========================================================
  Widget _buildMobileProjects() {
    return SizedBox(
      height: 380,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              for (int i = 0; i < projects.length; i++) ...[
                _buildProjectCard(i, true),
                if (i < projects.length - 1) const SizedBox(width: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // PROJECT CARD - COMPACT MOBILE VERSION
  // =========================================================
  Widget _buildProjectCard(int index, bool mobile) {
    final project = projects[index];
    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: mobile ? 250 : 300, // Reduced from 280 for mobile
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected
              ? widget.themeColor.withOpacity(_localDarkMode ? 0.15 : 0.3)
              : _surfaceColor,
          border: Border.all(
            color: isSelected
                ? widget.themeColor.withOpacity(0.6)
                : widget.themeColor.withOpacity(0.5),
            width: isSelected ? 2.5 : 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_localDarkMode ? 0.2 : 0.1),
              blurRadius: 15,
              spreadRadius: 1,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image - smaller on mobile
                Container(
                  height: mobile ? 150 : 180, // Reduced height on mobile
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    image: DecorationImage(
                      image: AssetImage(project["image"]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Project info - more compact
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(
                      mobile ? 12 : 16,
                    ), // Tighter padding on mobile
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Project title - smaller font on mobile
                            Text(
                              project["title"],
                              style: TextStyle(
                                fontSize: mobile ? 14 : 16, // Smaller font
                                fontWeight: FontWeight.bold,
                                color: _textColor,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 1,
                            ),
                            const SizedBox(height: 6), // Reduced spacing
                            // Tech stack - smaller font
                            Text(
                              project["tech"],
                              style: TextStyle(
                                fontSize: mobile ? 10 : 11, // Smaller font
                                color: _subtextColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8), // Reduced spacing
                            // Profile avatar and name - smaller on mobile
                            Row(
                              children: [
                                // Profile avatar
                                Container(
                                  width: mobile ? 24 : 28, // Smaller on mobile
                                  height: mobile ? 24 : 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: widget.themeColor,
                                      width: 1.2, // Thinner border
                                    ),
                                    image: const DecorationImage(
                                      image: AssetImage('assets/avatar.png'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6), // Reduced spacing
                                // Your name - smaller font
                                Text(
                                  'Vort Sarita',
                                  style: TextStyle(
                                    fontSize: mobile ? 11 : 12, // Smaller font
                                    fontWeight: FontWeight.w500,
                                    color: _textColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Bottom row (date and status) - more compact
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              project["date"],
                              style: TextStyle(
                                fontSize: mobile ? 10 : 11, // Smaller font
                                fontWeight: FontWeight.w500,
                                color: _subtextColor,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: mobile ? 8 : 10, // Smaller padding
                                vertical: mobile ? 3 : 4,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? widget.themeColor.withOpacity(
                                        _localDarkMode ? 0.15 : 0.3,
                                      )
                                    : widget.themeColor.withOpacity(
                                        _localDarkMode ? 0.1 : 0.2,
                                      ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: widget.themeColor.withOpacity(0.5),
                                  width: 2.5,
                                ),
                              ),
                              child: Text(
                                project["status"],
                                style: TextStyle(
                                  fontSize: mobile ? 9 : 10, // Smaller font
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? widget.themeColor
                                      : _textColor,
                                ),
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

            // Selected indicator - smaller on mobile
            if (isSelected)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: widget.themeColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: mobile ? 12 : 14,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
