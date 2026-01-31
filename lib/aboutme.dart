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

class AboutPage extends StatefulWidget {
  final Color themeColor;
  final bool isDarkMode;
  final Function(bool)? onThemeChanged;
  final Function(Color)? onThemeColorChanged;

  const AboutPage({
    super.key,
    required this.themeColor,
    required this.isDarkMode,
    this.onThemeChanged,
    this.onThemeColorChanged,
  });

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> with TickerProviderStateMixin {
  bool _localDarkMode = true;
  final ScrollController _scrollController = ScrollController();
  bool _showMyPhoto = true;
  late AnimationController _flipController;

  @override
  void initState() {
    super.initState();
    _localDarkMode = widget.isDarkMode;
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _flipController.dispose();
    super.dispose();
  }

  void _handleThemeToggle() {
    final newValue = !_localDarkMode;
    print('AboutPage: Changing theme to $newValue');
    setState(() {
      _localDarkMode = newValue;
    });
    if (widget.onThemeChanged != null) {
      print('AboutPage: Calling parent callback');
      widget.onThemeChanged!(newValue);
    } else {
      print('AboutPage: ERROR - onThemeChanged is NULL!');
    }
  }

  @override
  void didUpdateWidget(AboutPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDarkMode != widget.isDarkMode) {
      print(
        'AboutPage: Received updated theme from parent: ${widget.isDarkMode}',
      );
      setState(() {
        _localDarkMode = widget.isDarkMode;
      });
    }
  }

  void _togglePhoto() {
    setState(() {
      _showMyPhoto = !_showMyPhoto;
    });
    _flipController.forward(from: 0);
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

  Color get _contactCardColor =>
      _localDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0F0);

  void _handleBack() {
    print('AboutPage: Navigating back with theme: $_localDarkMode');
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
    return Row(
      children: [
        // Left Content Area
        Expanded(
          flex: 3,
          child: Container(
            color: _backgroundColor,
            child: Stack(
              children: [
                // Main scrollable content
                SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(45),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 60),
                        _buildHeroSection(),
                        const SizedBox(height: 24),
                        _buildExperienceSection(),
                        const SizedBox(height: 28),
                        _buildEducationSection(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                // Top navigation bar
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: _backgroundColor.withOpacity(0.95),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            _localDarkMode ? 0.2 : 0.1,
                          ),
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
                              border: Border.all(
                                color: widget.themeColor,
                                width: 2.2,
                              ),
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
            ),
          ),
        ),
        // Right Sidebar
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              color: _surfaceColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_localDarkMode ? 0.2 : 0.1),
                  blurRadius: 20,
                  offset: const Offset(-5, 0),
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  _buildPhotoSection(),
                  const SizedBox(height: 24),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: _buildContactSection()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildHobbiesSection()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTechnicalSkillsSection(),
                  const SizedBox(height: 16),
                  _buildLanguageSection(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Column(
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
              const TextSpan(text: 'Hello,\n'),
              const TextSpan(text: 'I\'m '),
              TextSpan(
                text: 'VORT Sarita',
                style: TextStyle(color: widget.themeColor),
              ),
              const TextSpan(text: ' !'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.themeColor.withOpacity(_localDarkMode ? 0.15 : 0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.themeColor.withOpacity(0.5),
              width: 2.5,
            ),
          ),
          child: Text(
            'I am a fourth-year student majoring in Telecommunication and Network Engineering at the Institute of Technology of Cambodia (ITC). I thrive in learning and developing both new and existing skills. I am dependable and often seek out new responsibilities across various fields. My approach to work is energetic, focused and i am both determined and decisive. I am eager to take on opportunities where i can grow and improve as a future engineer.',
            style: TextStyle(
              fontSize: 14,
              height: 1.7,
              color: _localDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExperienceSection() {
    return Container(
      padding: const EdgeInsets.all(26),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: _localDarkMode
                              ? Colors.white.withOpacity(0.2)
                              : Colors.black.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.work_history_outlined,
                          size: 22,
                          color: _localDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Experience',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: _localDarkMode ? Colors.white : Colors.black,
                          letterSpacing: -0.8,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: _localDarkMode
                      ? Colors.white.withOpacity(0.25)
                      : Colors.black.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '4+ Years',
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
          _buildExperienceItem(
            '2025',
            'Internship at Electricite du Cambodge (EDC)',
            'Technical intern',
            [
              'Got hands-on experience by visiting service rooms and understanding the technical setup required to keep things running.',
              'Joined the team for field work, which gave me a real-world look at how electrical infrastructure is managed outside the office.',
            ],
          ),
          const SizedBox(height: 14),
          _buildExperienceItem(
            '2024',
            'Arduino(IDE) Training Session',
            'F&B Group',
            [
              'Conducted a training session on the essentials of the Arduino controller',
              'Session was hosted by F&B Group',
            ],
          ),
          const SizedBox(height: 14),
          _buildExperienceItem(
            '2023',
            'Charity & Field Trip Volunteer',
            'Community Service',
            [
              'Participated in the charity field trip to Koh Kong Province',
              'Worked with department\'s Telecommunication and Network Engineering group',
            ],
          ),
          const SizedBox(height: 14),
          _buildExperienceItem(
            '2023 - Present',
            'Organizing student club',
            'Department club activity',
            [
              'Work as part of the organizing committee for department club activity',
              'Helped plan and execute various events and activities for students',
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: ['Networking', 'Telecom', 'Engineering', 'Cisco'].map((
              tag,
            ) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _localDarkMode
                        ? Colors.white.withOpacity(0.7)
                        : Colors.black.withOpacity(0.7),
                  ),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: _localDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildExperienceItem(
    String year,
    String position,
    String company,
    List<String> responsibilities,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: widget.themeColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            year,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: _localDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          position,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _localDarkMode ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          company,
          style: TextStyle(
            fontSize: 13,
            color: _localDarkMode ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        ...responsibilities.map(
          (resp) => Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    color: _localDarkMode ? Colors.white : Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    resp,
                    style: TextStyle(
                      fontSize: 13,
                      color: _localDarkMode
                          ? Colors.white.withOpacity(0.9)
                          : Colors.black.withOpacity(0.9),
                      height: 1.5,
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

  Widget _buildEducationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: widget.themeColor.withOpacity(_localDarkMode ? 0.15 : 0.30),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: widget.themeColor.withOpacity(0.5),
              width: 2.5,
            ),
          ),
          child: Text(
            'Education',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: widget.themeColor,
              letterSpacing: -0.8,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _surfaceColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.themeColor.withOpacity(0.5),
              width: 2.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'University',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                ),
              ),
              const SizedBox(height: 12),
              _buildEducationItem(
                '2022 - Present',
                'Telecommunication and Network Engineering',
                'Institute of Technology of Cambodia',
                'Bachelor\'s Degree',
                showYear: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _surfaceColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.themeColor.withOpacity(0.5),
              width: 2.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'English School',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                ),
              ),
              const SizedBox(height: 12),
              _buildEducationItem(
                '2016 - 2021',
                'Western International School',
                'Phnom Penh',
                'English Language Program',
                showYear: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _surfaceColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.themeColor.withOpacity(0.5),
              width: 2.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'School',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                ),
              ),
              const SizedBox(height: 12),
              _buildEducationItem(
                '2020 - 2022',
                'High School',
                'Hun Sen Berey 100 Khmeng High School',
                'Phnom Penh',
                showYear: true,
              ),
              const SizedBox(height: 10),
              _buildEducationItem(
                '2017 - 2019',
                'Middle School',
                'Hun Sen Pochentong High School',
                'Phnom Penh',
                showYear: true,
              ),
              const SizedBox(height: 10),
              _buildEducationItem(
                '2009 - 2016',
                'Elementary School',
                'Sopheak mongkol High School',
                'Phnom Penh',
                showYear: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEducationItem(
    String year,
    String degree,
    String field,
    String school, {
    bool showYear = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: widget.themeColor.withOpacity(_localDarkMode ? 0.15 : 0.4),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: widget.themeColor.withOpacity(0.2), width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showYear)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: widget.themeColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: widget.themeColor.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: Text(
                year,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: widget.themeColor,
                ),
              ),
            ),
          if (showYear) const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  degree,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  field,
                  style: TextStyle(
                    fontSize: 12,
                    color: _localDarkMode ? Colors.white70 : Colors.black,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  school,
                  style: TextStyle(
                    fontSize: 11,
                    color: _subtextColor.withOpacity(0.8),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: _togglePhoto,
          child: AnimatedBuilder(
            animation: _flipController,
            builder: (context, child) {
              final angle = _flipController.value * 3.14159;
              final transform = Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle);

              return Transform(
                transform: transform,
                alignment: Alignment.center,
                child: Container(
                  width: 200,
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: widget.themeColor.withOpacity(0.5),
                      width: 5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.themeColor.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(3.14159),
                      child: _showMyPhoto
                          ? Image.asset(
                              'assets/My_photo.JPG',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: widget.themeColor.withOpacity(0.2),
                                  child: Icon(
                                    Icons.person_rounded,
                                    size: 80,
                                    color: widget.themeColor,
                                  ),
                                );
                              },
                            )
                          : Image.asset(
                              'assets/avatar.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: widget.themeColor.withOpacity(0.2),
                                  child: Icon(
                                    Icons.person_rounded,
                                    size: 80,
                                    color: widget.themeColor,
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _togglePhoto,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: widget.themeColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.themeColor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.flip_camera_android_rounded,
                  size: 14,
                  color: widget.themeColor,
                ),
                const SizedBox(width: 6),
                Text(
                  _showMyPhoto ? 'Switch to Avatar' : 'Switch to Photo',
                  style: TextStyle(
                    fontSize: 11,
                    color: widget.themeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: widget.themeColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Sarita VORT',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: widget.themeColor,
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _localDarkMode
                  ? [
                      widget.themeColor.withOpacity(0.85),
                      widget.themeColor.withOpacity(0.55),
                    ]
                  : [
                      widget.themeColor.withOpacity(0.75),
                      widget.themeColor.withOpacity(0.45),
                    ],
            ),
          ),
          child: Text(
            'Telecom and Network Engineer',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _localDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _localDarkMode
            ? widget.themeColor.withOpacity(0.15)
            : widget.themeColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: widget.themeColor.withOpacity(0.5),
          width: 2.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _localDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 14),
          _buildContactItem(Icons.phone_outlined, '+855 15 881 107'),
          const SizedBox(height: 10),
          _buildContactItem(Icons.email_outlined, 'saritavort@gmail.com'),
          const SizedBox(height: 10),
          _buildContactItem(
            Icons.location_on_outlined,
            'St. Sangkat Krang Thnong',
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildSocialIcon(
                FontAwesomeIcons.github,
                'https://github.com/VortSarita',
              ),
              const SizedBox(width: 9),
              _buildSocialIcon(
                FontAwesomeIcons.linkedin,
                'https://www.linkedin.com/in/vort-sarita-2482b3369/',
              ),
              const SizedBox(width: 9),
              _buildSocialIcon(
                FontAwesomeIcons.instagram,
                'https://www.instagram.com/eppy.c0m/',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: widget.themeColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: _localDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, String url) {
    return GestureDetector(
      onTap: () => _launchURL(url),
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: _localDarkMode
                ? Colors.white.withOpacity(0.6)
                : Colors.black.withOpacity(0.6),
            width: 1.5,
          ),
          color: _localDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
        ),
        child: FaIcon(
          icon,
          size: 14,
          color: _localDarkMode ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildTechnicalSkillsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        border: Border.all(color: widget.themeColor.withOpacity(0.5), width: 1),
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
          Text(
            'Skills',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _localDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 14),
          _buildSkillCategory('Programming', [
            'C & C++',
            'Java',
            'Arduino (ide)',
          ]),
          const SizedBox(height: 10),
          _buildSkillCategory('Office', [
            'Microsoft-word',
            'Excel',
            'PowerPoint',
          ]),
          const SizedBox(height: 10),
          _buildSkillCategory('Other', ['SimullDE', 'Basic MATLAB']),
        ],
      ),
    );
  }

  Widget _buildSkillCategory(String category, List<String> skills) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: _localDarkMode ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: skills.map((skill) {
            return SizedBox(
              width: 85,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: _localDarkMode
                      ? Colors.white.withOpacity(0.15)
                      : Colors.black.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _localDarkMode
                        ? Colors.white.withOpacity(0.3)
                        : Colors.black.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  skill,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: _localDarkMode ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLanguageSection() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        border: Border.all(
          color: widget.themeColor.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.themeColor.withOpacity(_localDarkMode ? 0.15 : 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Language',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _localDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 14),
          _buildLanguageItem('Khmer', 'Native', 1.0),
          const SizedBox(height: 12),
          _buildLanguageItem('English', 'Fluent', 0.9),
          const SizedBox(height: 12),
          _buildLanguageItem('French', 'Intermediate', 0.6),
        ],
      ),
    );
  }

  Widget _buildLanguageItem(String language, String level, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              language,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _localDarkMode ? Colors.white : Colors.black,
              ),
            ),
            Text(
              level,
              style: TextStyle(
                fontSize: 11,
                color: _localDarkMode
                    ? Colors.white.withOpacity(1)
                    : Colors.black.withOpacity(1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: _localDarkMode
                ? Colors.white.withOpacity(0.3)
                : Colors.black.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation(
              _localDarkMode ? Colors.white : Colors.black,
            ),
            minHeight: 5,
          ),
        ),
      ],
    );
  }

  Widget _buildHobbiesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _localDarkMode
            ? widget.themeColor.withOpacity(0.15)
            : widget.themeColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: widget.themeColor.withOpacity(0.5),
          width: 2.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hobbies & Interests',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              _buildHobbyItem(Icons.sports_esports_rounded, 'Gaming'),
              _buildHobbyItem(Icons.music_note_rounded, 'Music'),
              _buildHobbyItem(Icons.camera_alt_rounded, 'Photography'),
              _buildHobbyItem(Icons.menu_book_rounded, 'Reading'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHobbyItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.themeColor.withOpacity(0.25),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: widget.themeColor),
        ),
        const SizedBox(height: 7),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: _textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
                  _buildMobilePhotoSection(),
                  const SizedBox(height: 16),
                  _buildMobileHeroSection(),
                  const SizedBox(height: 14),
                  // Contact and Hobbies side by side
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: _buildMobileContactSection()),
                        const SizedBox(width: 10),
                        Expanded(child: _buildMobileHobbiesSection()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildMobileExperienceSection(),
                  const SizedBox(height: 14),
                  _buildMobileEducationSection(),
                  const SizedBox(height: 14),
                  // Skills and Language side by side
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: _buildMobileTechnicalSkillsSection()),
                        const SizedBox(width: 10),
                        Expanded(child: _buildMobileLanguageSection()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobilePhotoSection() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _togglePhoto,
            child: AnimatedBuilder(
              animation: _flipController,
              builder: (context, child) {
                final angle = _flipController.value * 3.14159;
                final transform = Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(angle);

                return Transform(
                  transform: transform,
                  alignment: Alignment.center,
                  child: Container(
                    width: 160,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: widget.themeColor.withOpacity(0.7),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.themeColor.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(3.14159),
                        child: _showMyPhoto
                            ? Image.asset(
                                'assets/My_photo.JPG',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: widget.themeColor.withOpacity(0.2),
                                    child: Icon(
                                      Icons.person_rounded,
                                      size: 60,
                                      color: widget.themeColor,
                                    ),
                                  );
                                },
                              )
                            : Image.asset(
                                'assets/avatar.png',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: widget.themeColor.withOpacity(0.1),
                                    child: Icon(
                                      Icons.person_rounded,
                                      size: 60,
                                      color: widget.themeColor,
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _togglePhoto,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: widget.themeColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.flip_camera_android_rounded,
                    size: 12,
                    color: widget.themeColor,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _showMyPhoto ? 'Switch to Avatar' : 'Switch to Photo',
                    style: TextStyle(
                      fontSize: 10,
                      color: widget.themeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: widget.themeColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Sarita VORT',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: widget.themeColor.withOpacity(_localDarkMode ? 0.3 : 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Telecom and Network Engineer',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: _localDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
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
              const TextSpan(text: 'Hello,\n'),
              const TextSpan(text: 'I\'m '),
              TextSpan(
                text: 'VORT Sarita',
                style: TextStyle(color: widget.themeColor),
              ),
              const TextSpan(text: ' !'),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 3,
                    decoration: BoxDecoration(
                      color: widget.themeColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'ABOUT ME',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: widget.themeColor,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'I am a fourth-year student majoring in Telecommunication and Network Engineering at the Institute of Technology of Cambodia (ITC). I thrive in learning and developing both new and existing skills. I am dependable and often seek out new responsibilities across various fields. My approach to work is energetic, focused and i am both determined and decisive. I am eager to take on opportunities where i can grow and improve as a future engineer.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.6,
                  color: _localDarkMode
                      ? Colors.white.withOpacity(0.9)
                      : Colors.black.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileContactSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _localDarkMode
            ? widget.themeColor.withOpacity(0.15)
            : widget.themeColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: widget.themeColor.withOpacity(0.5), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 12),
          _buildContactItem(Icons.phone_outlined, '+855 15 881 107'),
          const SizedBox(height: 10),
          _buildContactItem(Icons.email_outlined, 'saritavort@gmail.com'),
          const SizedBox(height: 10),
          _buildContactItem(
            Icons.location_on_outlined,
            'St. Sangkat Krang Thnong',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildSocialIconMobile(
                FontAwesomeIcons.github,
                'https://github.com/VortSarita',
              ),
              const SizedBox(width: 8),
              _buildSocialIconMobile(
                FontAwesomeIcons.linkedin,
                'https://www.linkedin.com/in/vort-sarita-2482b3369/',
              ),
              const SizedBox(width: 8),
              _buildSocialIconMobile(
                FontAwesomeIcons.instagram,
                'https://www.instagram.com/eppy.c0m/',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIconMobile(IconData icon, String url) {
    return GestureDetector(
      onTap: () => _launchURL(url),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: _localDarkMode
                ? Colors.white.withOpacity(0.6)
                : Colors.black.withOpacity(0.6),
            width: 1,
          ),
          color: _localDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
        ),
        child: FaIcon(
          icon,
          size: 12,
          color: _localDarkMode ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildMobileExperienceSection() {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _localDarkMode
                          ? Colors.white.withOpacity(0.25)
                          : Colors.black.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.work_history_outlined,
                      size: 16,
                      color: _localDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Experience',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _localDarkMode ? Colors.white : Colors.black,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: _localDarkMode
                      ? Colors.white.withOpacity(0.25)
                      : Colors.black.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '4+ Years',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _localDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMobileExperienceItem(
            '2025',
            'Internship at Electricite du Cambodge (EDC)',
            'Technical intern',
            [
              'Got hands-on experience by visiting service rooms and understanding the technical setup required to keep things running.',
              'Joined the team for field work, which gave me a real-world look at how electrical infrastructure is managed outside the office.',
            ],
          ),
          const SizedBox(height: 12),
          _buildMobileExperienceItem(
            '2024',
            'Arduino(IDE) Training Session',
            'F&B Group',
            [
              'Conducted a training session on the essentials of the Arduino controller',
              'Session was hosted by F&B Group',
            ],
          ),
          const SizedBox(height: 12),
          _buildMobileExperienceItem(
            '2023',
            'Charity & Field Trip Volunteer',
            'Community Service',
            [
              'Participated in the charity field trip to Koh Kong Province',
              'Worked with department\'s Telecommunication and Network Engineering group',
            ],
          ),
          const SizedBox(height: 12),
          _buildMobileExperienceItem(
            '2023 - Present',
            'Organizing student club',
            'Department club activity',
            [
              'Work as part of the organizing committee for department club activity',
              'Helped plan and execute various events and activities for students',
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: ['Networking', 'Telecom', 'Engineering', 'Cisco'].map((
              tag,
            ) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _localDarkMode
                        ? Colors.white.withOpacity(0.6)
                        : Colors.black.withOpacity(0.6),
                  ),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: _localDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileExperienceItem(
    String year,
    String position,
    String company,
    List<String> responsibilities,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: widget.themeColor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            year,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: _localDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          position,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _localDarkMode ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          company,
          style: TextStyle(
            fontSize: 11,
            color: _localDarkMode
                ? Colors.white.withOpacity(1)
                : Colors.black.withOpacity(1),
          ),
        ),
        const SizedBox(height: 8),
        ...responsibilities.map(
          (resp) => Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 3,
                  height: 3,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    color: _localDarkMode ? Colors.white : Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    resp,
                    style: TextStyle(
                      fontSize: 11,
                      color: _localDarkMode
                          ? Colors.white.withOpacity(1)
                          : Colors.black.withOpacity(1),
                      height: 1.4,
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

  Widget _buildMobileEducationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            decoration: BoxDecoration(
              color: widget.themeColor.withOpacity(
                _localDarkMode ? 0.15 : 0.30,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: widget.themeColor.withOpacity(0.5),
                width: 1.8,
              ),
            ),
            child: Text(
              'Education',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: widget.themeColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _surfaceColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.themeColor.withOpacity(0.5),
              width: 1.8,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'University',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                ),
              ),
              const SizedBox(height: 8),
              _buildMobileEducationItem(
                '2022 - Present',
                'Telecommunication and Network Engineering',
                'Institute of Technology of Cambodia',
                'Bachelor\'s Degree',
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _surfaceColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.themeColor.withOpacity(0.5),
              width: 1.8,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'English School',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                ),
              ),
              const SizedBox(height: 8),
              _buildMobileEducationItem(
                '2016 - 2021',
                'Western International School',
                'Phnom Penh',
                'English Language Program',
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _surfaceColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.themeColor.withOpacity(0.5),
              width: 1.8,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'School',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                ),
              ),
              const SizedBox(height: 8),
              _buildMobileEducationItem(
                '2020 - 2022',
                'High School',
                'Hun Sen Berey 100 Khnong High School',
                'Phnom Penh',
              ),
              const SizedBox(height: 8),
              _buildMobileEducationItem(
                '2017 - 2019',
                'Middle School',
                'Hun Sen Pochentong High School',
                'Phnom Penh',
              ),
              const SizedBox(height: 8),
              _buildMobileEducationItem(
                '2009 - 2016',
                'Elementary School',
                'Sopheak mongkol High School',
                'Phnom Penh',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileEducationItem(
    String year,
    String degree,
    String field,
    String school,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: widget.themeColor.withOpacity(_localDarkMode ? 0.15 : 0.4),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: widget.themeColor.withOpacity(0.5),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: widget.themeColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: widget.themeColor.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Text(
              year,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: widget.themeColor.withOpacity(1),
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            degree,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            field,
            style: TextStyle(
              fontSize: 10,
              color: _localDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            school,
            style: TextStyle(
              fontSize: 9,
              color: _subtextColor.withOpacity(0.8),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileTechnicalSkillsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.themeColor.withOpacity(0.5),
          width: 1.2,
        ),
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
          Text(
            'Skills',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: _localDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          _buildMobileSkillCategory('Programming', [
            'C & C++',
            'Java',
            'Arduino (ide)',
          ]),
          const SizedBox(height: 10),
          _buildMobileSkillCategory('Office', [
            'Microsoft-word',
            'Excel',
            'PowerPoint',
          ]),
          const SizedBox(height: 10),
          _buildMobileSkillCategory('Other', ['SimullDE', 'Basic MATLAB']),
        ],
      ),
    );
  }

  Widget _buildMobileSkillCategory(String category, List<String> skills) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: _localDarkMode ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 5,
          runSpacing: 5,
          children: skills.map((skill) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _localDarkMode
                    ? Colors.white.withOpacity(0.15)
                    : Colors.black.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _localDarkMode
                      ? Colors.white.withOpacity(0.4)
                      : Colors.black.withOpacity(0.4),
                  width: 0.8,
                ),
              ),
              child: Text(
                skill,
                style: TextStyle(
                  fontSize: 9,
                  color: _localDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMobileLanguageSection() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.themeColor.withOpacity(0.2),
          width: 1.2,
        ),
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
          Text(
            'Language',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: _localDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          _buildMobileLanguageItem('Khmer', 'Native', 1.0),
          const SizedBox(height: 10),
          _buildMobileLanguageItem('English', 'Fluent', 0.9),
          const SizedBox(height: 10),
          _buildMobileLanguageItem('French', 'Intermediate', 0.6),
        ],
      ),
    );
  }

  Widget _buildMobileLanguageItem(
    String language,
    String level,
    double progress,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              language,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _localDarkMode ? Colors.white : Colors.black,
              ),
            ),
            Text(
              level,
              style: TextStyle(
                fontSize: 10,
                color: _localDarkMode
                    ? Colors.white.withOpacity(1)
                    : Colors.black.withOpacity(1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: _localDarkMode
                ? Colors.white.withOpacity(0.2)
                : Colors.black.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation(
              _localDarkMode ? Colors.white : Colors.black,
            ),
            minHeight: 5,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileHobbiesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _localDarkMode
            ? widget.themeColor.withOpacity(0.15)
            : widget.themeColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.themeColor.withOpacity(0.5), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hobbies & Interests',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildMobileHobbyItem(Icons.sports_esports_rounded, 'Gaming'),
              _buildMobileHobbyItem(Icons.music_note_rounded, 'Music'),
              _buildMobileHobbyItem(Icons.camera_alt_rounded, 'Photography'),
              _buildMobileHobbyItem(Icons.menu_book_rounded, 'Reading'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHobbyItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: widget.themeColor.withOpacity(0.4),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: widget.themeColor),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: _textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
