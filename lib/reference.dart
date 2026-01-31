import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SmoothPageTransition extends PageRouteBuilder {
  final Widget page;

  SmoothPageTransition({required this.page})
    : super(
        pageBuilder:
            (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        transitionsBuilder:
            (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child,
            ) {
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

class ReferencePage extends StatefulWidget {
  final Color themeColor;
  final bool isDarkMode;
  final Function(bool)? onThemeChanged;
  final Function(Color)? onThemeColorChanged;

  const ReferencePage({
    super.key,
    required this.themeColor,
    required this.isDarkMode,
    this.onThemeChanged,
    this.onThemeColorChanged,
  });

  @override
  State<ReferencePage> createState() => _ReferencePageState();
}

class _ReferencePageState extends State<ReferencePage>
    with TickerProviderStateMixin {
  bool _localDarkMode = true;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _cardAnimationController;
  late Animation<double> _cardSlideAnimation;
  late Animation<double> _cardFadeAnimation;

  // Professor data - REMOVED email and phone fields
  final List<Map<String, String>> professors = [
    {
      'name': 'Dr. SRENG Sokchenda',
      'title': 'Professor of Network Engineering',
      'department': 'Telecommunication and Network Engineering Department',
      'institution': 'Institute of Technology of Cambodia',
      'specialty': 'Analog and Digital Comm.',
    },
    {
      'name': 'Dr. THOURN Kosorl',
      'title': 'Professor of Telecom Engineering',
      'department': 'Telecommunication and Network Engineering Department',
      'institution': 'Institute of Technology of Cambodia',
      'specialty': 'Microwave Circcuit and Antenna',
    },
    {
      'name': 'Dr. MUY Sengly',
      'title': 'Ai Engineering',
      'department': 'Telecommunication and Network Engineering Department',
      'institution': 'Institute of Technology of Cambodia',
      'specialty': 'Mobile Application',
    },
  ];

  @override
  void initState() {
    super.initState();
    _localDarkMode = widget.isDarkMode;

    _cardAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _cardSlideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _cardFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _cardAnimationController, curve: Curves.easeIn),
    );

    _cardAnimationController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  void _handleThemeToggle() {
    final newValue = !_localDarkMode;
    print('ReferencePage: Changing theme to $newValue');
    setState(() {
      _localDarkMode = newValue;
    });
    if (widget.onThemeChanged != null) {
      print('ReferencePage: Calling parent callback');
      widget.onThemeChanged!(newValue);
    } else {
      print('ReferencePage: ERROR - onThemeChanged is NULL!');
    }
  }

  @override
  void didUpdateWidget(ReferencePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDarkMode != widget.isDarkMode) {
      print(
        'ReferencePage: Received updated theme from parent: ${widget.isDarkMode}',
      );
      setState(() {
        _localDarkMode = widget.isDarkMode;
      });
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open $url')));
      }
    }
  }

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

  void _handleBack() {
    print('ReferencePage: Navigating back with theme: $_localDarkMode');
    Navigator.of(context).pop(_localDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
    );
  }

  Widget _buildDesktopLayout() {
    return Stack(
      children: [
        // Main content
        Container(
          color: _backgroundColor,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(45),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 80),
                  _buildHeroSection(),
                  const SizedBox(height: 40),
                  _buildReferenceGrid(),
                  const SizedBox(height: 40),
                  _buildConnectSection(),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
        // Top navigation bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: _backgroundColor.withOpacity(0.95),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_localDarkMode ? 0.2 : 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Cat Logo
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: widget.themeColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Image.asset(
                      _localDarkMode
                          ? 'assets/cat_night.png'
                          : 'assets/cat_day.png',
                      key: ValueKey(_localDarkMode),
                      width: 35,
                      height: 35,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.pets_rounded,
                          color: Colors.white,
                          size: 32,
                        );
                      },
                    ),
                  ),
                ),
                const Spacer(),
                // Back button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _handleBack,
                    borderRadius: BorderRadius.circular(25),
                    hoverColor: widget.themeColor.withOpacity(0.1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: widget.themeColor,
                          width: 2.2,
                        ),
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
                const SizedBox(width: 20),
                // Theme toggle
                GestureDetector(
                  onTap: _handleThemeToggle,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    width: 70,
                    height: 36,
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
                          left: _localDarkMode ? 40 : 4,
                          child: Container(
                            width: 28,
                            height: 28,
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
                              key: ValueKey(_localDarkMode),
                              color: _localDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                              size: 20,
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
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    return AnimatedBuilder(
      animation: _cardFadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _cardFadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _cardSlideAnimation.value),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: _textColor,
                      height: 1.3,
                      letterSpacing: -1.5,
                    ),
                    children: [
                      const TextSpan(text: 'Academic '),
                      TextSpan(
                        text: 'References',
                        style: TextStyle(color: widget.themeColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: widget.themeColor.withOpacity(
                      _localDarkMode ? 0.15 : 0.5,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: widget.themeColor.withOpacity(0.5),
                      width: 2.5,
                    ),
                  ),
                  child: Text(
                    'Below are my academic references from the Institute of Technology of Cambodia. A professors who guided and supervised throughout our studies in Telecommunication and Network Engineering.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.7,
                      color: _localDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReferenceGrid() {
    return AnimatedBuilder(
      animation: _cardFadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _cardFadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _cardSlideAnimation.value * 1.5),
            child: Column(
              children: professors.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, String> prof = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: _buildProfessorCard(
                    prof['name']!,
                    prof['title']!,
                    prof['department']!,
                    prof['institution']!,
                    prof['specialty']!,
                    index,
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfessorCard(
    String name,
    String title,
    String department,
    String institution,
    String specialty,
    int index,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _localDarkMode
              ? [
                  widget.themeColor.withOpacity(0.75),
                  widget.themeColor.withOpacity(0.45),
                ]
              : [
                  widget.themeColor.withOpacity(0.85),
                  widget.themeColor.withOpacity(0.35),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: widget.themeColor.withOpacity(_localDarkMode ? 0.45 : 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _localDarkMode
                      ? Colors.white.withOpacity(0.2)
                      : Colors.black.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 40,
                  color: _localDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(width: 20),
              // Name and title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _localDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _localDarkMode
                            ? Colors.white.withOpacity(0.9)
                            : Colors.black.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      department,
                      style: TextStyle(
                        fontSize: 12,
                        color: _localDarkMode
                            ? Colors.white.withOpacity(0.8)
                            : Colors.black.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      institution,
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: _localDarkMode
                            ? Colors.white.withOpacity(0.7)
                            : Colors.black.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              // Reference number
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _localDarkMode
                      ? Colors.white.withOpacity(0.25)
                      : Colors.black.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Ref ${index + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _localDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Specialty
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _localDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.school_rounded,
                  size: 18,
                  color: _localDarkMode ? Colors.white : Colors.black,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Specialty',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _localDarkMode
                              ? Colors.white.withOpacity(0.7)
                              : Colors.black.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        specialty,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _localDarkMode ? Colors.white : Colors.black,
                        ),
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

  Widget _buildConnectSection() {
    return AnimatedBuilder(
      animation: _cardFadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _cardFadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _cardSlideAnimation.value * 2),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _localDarkMode
                      ? [
                          widget.themeColor.withOpacity(0.20),
                          widget.themeColor.withOpacity(0.05),
                        ]
                      : [
                          widget.themeColor.withOpacity(0.30),
                          widget.themeColor.withOpacity(0.10),
                        ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.themeColor.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.verified_rounded,
                    size: 48,
                    color: widget.themeColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Reference Note',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: _textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'These professors have directly support academic work and can provide detailed information about work ethic, and accomplishments during time at ITC.\n\nFor formal reference requests.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: _subtextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============= MOBILE LAYOUT =============
  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Top bar - COMPACT
        Container(
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _surfaceColor,
            border: Border(
              bottom: BorderSide(
                color: widget.themeColor.withOpacity(0.25),
                width: 1.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_localDarkMode ? 0.2 : 0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Cat Logo - SMALLER
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.themeColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Image.asset(
                      _localDarkMode
                          ? 'assets/cat_night.png'
                          : 'assets/cat_day.png',
                      key: ValueKey(_localDarkMode),
                      width: 30,
                      height: 30,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.pets_rounded,
                          color: Colors.white,
                          size: 24,
                        );
                      },
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  // Back button - COMPACT
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _handleBack,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: widget.themeColor,
                            width: 1.8,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.arrow_back_rounded,
                              color: widget.themeColor,
                              size: 14,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Back',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: widget.themeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Theme toggle - COMPACT
                  GestureDetector(
                    onTap: _handleThemeToggle,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: 55,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: widget.themeColor,
                          width: 1.8,
                        ),
                      ),
                      child: Stack(
                        children: [
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                            left: _localDarkMode ? 32 : 3,
                            top: 3,
                            child: Container(
                              width: 22,
                              height: 22,
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
                                key: ValueKey(_localDarkMode),
                                color: widget.themeColor,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildMobileHeroSection(),
                  const SizedBox(height: 24),
                  _buildMobileReferenceList(),
                  const SizedBox(height: 24),
                  _buildMobileConnectSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileHeroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: _textColor,
              height: 1.2,
            ),
            children: [
              const TextSpan(text: 'Academic\n'),
              TextSpan(
                text: 'References',
                style: TextStyle(color: widget.themeColor),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: widget.themeColor.withOpacity(_localDarkMode ? 0.2 : 0.4),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.themeColor.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Text(
            'Below are my academic references from ITC. These professors have supervised student studies in Telecommunication and Network Engineering.',
            style: TextStyle(
              fontSize: 12,
              height: 1.6,
              color: _localDarkMode
                  ? Colors.white.withOpacity(0.9)
                  : Colors.black.withOpacity(0.9),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileReferenceList() {
    return Column(
      children: professors.asMap().entries.map((entry) {
        int index = entry.key;
        Map<String, String> prof = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildMobileProfessorCard(
            prof['name']!,
            prof['title']!,
            prof['department']!,
            prof['specialty']!,
            index,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMobileProfessorCard(
    String name,
    String title,
    String department,
    String specialty,
    int index,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: _localDarkMode
              ? [
                  widget.themeColor.withOpacity(0.75),
                  widget.themeColor.withOpacity(0.45),
                ]
              : [
                  widget.themeColor.withOpacity(0.85),
                  widget.themeColor.withOpacity(0.35),
                ],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: widget.themeColor.withOpacity(_localDarkMode ? 0.45 : 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _localDarkMode
                      ? Colors.white.withOpacity(0.2)
                      : Colors.black.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 30,
                  color: _localDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(width: 14),
              // Name and ref number
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _localDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _localDarkMode
                            ? Colors.white.withOpacity(0.9)
                            : Colors.black.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _localDarkMode
                      ? Colors.white.withOpacity(0.25)
                      : Colors.black.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  'Ref ${index + 1}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _localDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Department
          Text(
            department,
            style: TextStyle(
              fontSize: 10,
              color: _localDarkMode
                  ? Colors.white.withOpacity(0.8)
                  : Colors.black.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 12),
          // Specialty
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _localDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.school_rounded,
                  size: 14,
                  color: _localDarkMode ? Colors.white : Colors.black,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    specialty,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _localDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileConnectSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _localDarkMode
              ? [
                  widget.themeColor.withOpacity(0.20),
                  widget.themeColor.withOpacity(0.05),
                ]
              : [
                  widget.themeColor.withOpacity(0.30),
                  widget.themeColor.withOpacity(0.10),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.themeColor.withOpacity(0.5), width: 2),
      ),
      child: Column(
        children: [
          Icon(Icons.verified_rounded, size: 36, color: widget.themeColor),
          const SizedBox(height: 12),
          Text(
            'Reference Note',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'These professors can provide detailed information about an academic performance and skills.\n\nFor formal reference requests.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, height: 1.6, color: _subtextColor),
          ),
        ],
      ),
    );
  }
}
