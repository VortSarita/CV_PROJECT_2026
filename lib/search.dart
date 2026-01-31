import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'main.dart';
import 'contact.dart';
import 'aboutme.dart';
import 'project.dart';
import 'reference.dart';

class SearchPage extends StatefulWidget {
  final Color themeColor;
  final bool isDarkMode;
  final Function(bool)? onThemeChanged;
  final Function(Color)? onThemeColorChanged;

  const SearchPage({
    super.key,
    required this.themeColor,
    required this.isDarkMode,
    this.onThemeChanged,
    this.onThemeColorChanged,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  int selectedTab = 1;
  bool _localDarkMode = true;
  final ScrollController _scrollController = ScrollController();
  int? _hoveredCardIndex;
  late AnimationController _sparkleController;
  late AnimationController _floatingController;

  @override
  void initState() {
    super.initState();
    _localDarkMode = widget.isDarkMode;

    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  void _navigateToHomePage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomePage(
          themeColor: widget.themeColor,
          isDarkMode: _localDarkMode,
          onThemeChanged: widget.onThemeChanged,
          onThemeColorChanged: widget.onThemeColorChanged,
        ),
      ),
    );
  }

  void _navigateToAboutPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AboutPage(
          themeColor: widget.themeColor,
          isDarkMode: _localDarkMode,
          onThemeChanged: widget.onThemeChanged,
          onThemeColorChanged: widget.onThemeColorChanged,
        ),
      ),
    );
  }

  void _navigateToProjectPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProjectPage(
          themeColor: widget.themeColor,
          darkMode: _localDarkMode,
        ),
      ),
    );
  }

  void _navigateToReferencePage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReferencePage(
          themeColor: widget.themeColor,
          isDarkMode: _localDarkMode,
          onThemeChanged: widget.onThemeChanged,
          onThemeColorChanged: widget.onThemeColorChanged,
        ),
      ),
    );
  }

  void _navigateToContactPage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ContactPage(
          themeColor: widget.themeColor,
          isDarkMode: _localDarkMode,
          onThemeChanged: widget.onThemeChanged,
          onThemeColorChanged: widget.onThemeColorChanged,
        ),
      ),
    );
  }

  void _handleThemeToggle() {
    setState(() {
      _localDarkMode = !_localDarkMode;
    });

    if (widget.onThemeChanged != null) {
      widget.onThemeChanged!(_localDarkMode);
    }
  }

  @override
  void didUpdateWidget(SearchPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDarkMode != widget.isDarkMode) {
      setState(() {
        _localDarkMode = widget.isDarkMode;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _sparkleController.dispose();
    _floatingController.dispose();
    super.dispose();
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

  // DESKTOP NAVIGATION - Simple MaterialPageRoute
  Widget buildNavTab(String title, int index) {
    bool isActive = selectedTab == index;
    Color activeColor = widget.themeColor;
    Color textColor = _localDarkMode ? Colors.white70 : Colors.black54;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (index == 0) {
            _navigateToHomePage();
          } else if (index == 2) {
            _navigateToContactPage();
          }
        },
        child: Container(
          padding: const EdgeInsets.only(bottom: 3),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? activeColor : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isActive ? activeColor : textColor,
              letterSpacing: 0.6,
            ),
          ),
        ),
      ),
    );
  }

  // MOBILE NAVIGATION - Simple MaterialPageRoute
  Widget _buildMobileNavTab(String title, int index) {
    bool isActive = selectedTab == index;
    Color activeColor = widget.themeColor;
    Color textColor = _localDarkMode ? Colors.white70 : Colors.black87;

    return GestureDetector(
      onTap: () {
        if (index == 0) {
          _navigateToHomePage();
        } else if (index == 2) {
          _navigateToContactPage();
        }
      },
      child: Container(
        padding: const EdgeInsets.only(bottom: 3),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? activeColor : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isActive ? activeColor : textColor,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    return Scaffold(
      backgroundColor: _localDarkMode ? Colors.black : Colors.white,
      body: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Container(
          width: 90,
          color: widget.themeColor,
          child: Stack(
            children: [
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 12,
                    height: double.infinity,
                    color: widget.themeColor,
                  ),
                ),
              ),
              Positioned(
                top: 20,
                left: 8,
                right: 8,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: SizedBox(
                    key: ValueKey<bool>(_localDarkMode),
                    width: 64,
                    height: 64,
                    child: Image.asset(
                      _localDarkMode
                          ? 'assets/cat_night.png'
                          : 'assets/cat_day.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Container(
                height: 100,
                color: Colors.transparent,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 60, top: 10),
                      child: Row(
                        children: [
                          buildNavTab("Home", 0),
                          const SizedBox(width: 50),
                          buildNavTab("Search", 1),
                          const SizedBox(width: 50),
                          buildNavTab("Contact", 2),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 40),
                      child: GestureDetector(
                        onTap: _handleThemeToggle,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          width: 52,
                          height: 28,
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
                                left: _localDarkMode ? 26 : 4,
                                child: Container(
                                  width: 30,
                                  height: 30,
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
                                    color: _localDarkMode
                                        ? Colors.white70
                                        : Colors.black54,
                                    size: 18,
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
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      _buildHomeCard(),
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 60),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'My Journey &',
                                        style: TextStyle(
                                          fontSize: 38,
                                          fontWeight: FontWeight.bold,
                                          color: _localDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                          height: 1.1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'EXPERIENCE',
                                    style: TextStyle(
                                      fontSize: 38,
                                      fontWeight: FontWeight.bold,
                                      color: widget.themeColor,
                                      height: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    width: 120,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          widget.themeColor,
                                          widget.themeColor.withOpacity(0.2),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'As a fourth-year student at the Institute of Technology of Cambodia aiming for a bachelor\'s degree in Telecommunication and Network Engineering.\n\n'
                                    'My academic background has provided me with a solid foundation of networking system, computer program and telecommunication field.\n'
                                    'I am eager to take on challenges that will help me grow both personally and professionally.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      height: 1.7,
                                      color: _localDarkMode
                                          ? Colors.white.withOpacity(0.9)
                                          : Colors.black.withOpacity(1.0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 25),
                            Expanded(
                              child: _buildInfoCard(
                                index: 0,
                                title: 'About Me',
                                icon: Icons.person_outline,
                                description:
                                    'My academic background has provided me with a solid foundation of networking system, computer program and telecommunication field.',
                                tags: ['Networking', 'Telecom', 'Engineering'],
                                stat: '4+ Years',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 60),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildInfoCard(
                                index: 1,
                                title: 'Projects',
                                icon: Icons.work_outline,
                                description:
                                    'Explore my projects including Arduino training, network implementations, Cisco configurations, and volunteer work.',
                                tags: ['Arduino', 'Projects', 'Volunteer'],
                                stat: '3+ Projects',
                              ),
                            ),
                            const SizedBox(width: 40),
                            Expanded(
                              child: _buildInfoCard(
                                index: 2,
                                title: 'Reference',
                                icon: Icons.contact_mail_outlined,
                                description:
                                    'Get in touch for collaboration opportunities, professional connections.',
                                tags: ['GitHub', 'LinkedIn', 'Email', 'Resume'],
                                stat: 'Connect',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required int index,
    required String title,
    required IconData icon,
    required String description,
    required List<String> tags,
    required String stat,
  }) {
    final bool isDay = !_localDarkMode;
    final bool isHovered = _hoveredCardIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredCardIndex = index),
      onExit: (_) => setState(() => _hoveredCardIndex = null),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (index == 0) {
            _navigateToAboutPage();
          } else if (index == 1) {
            _navigateToProjectPage();
          } else if (index == 2) {
            _navigateToReferencePage();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          transform: Matrix4.identity()..scale(isHovered ? 1.02 : 1.0),
          height: 280,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: isDay
                  ? [
                      widget.themeColor.withOpacity(0.75),
                      widget.themeColor.withOpacity(0.45),
                    ]
                  : [
                      widget.themeColor.withOpacity(0.75),
                      widget.themeColor.withOpacity(0.45),
                    ],
            ),
            boxShadow: [
              BoxShadow(
                color: widget.themeColor.withOpacity(isDay ? 0.15 : 0.45),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isDay
                            ? Colors.black.withOpacity(0.15)
                            : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        icon,
                        size: 24,
                        color: isDay ? Colors.black : Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isDay
                            ? Colors.black.withOpacity(0.15)
                            : Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        stat,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDay ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDay ? Colors.black : Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: isDay
                        ? Colors.black.withOpacity(1.0)
                        : Colors.white.withOpacity(0.95),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDay
                              ? Colors.black.withOpacity(0.4)
                              : Colors.white.withOpacity(0.4),
                        ),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDay ? Colors.black : Colors.white,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                const Spacer(),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    index == 0
                        ? 'View More →'
                        : index == 1
                        ? 'See Projects →'
                        : 'View Contacts →',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDay ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: _localDarkMode ? Colors.black : Colors.white,
            border: Border(
              bottom: BorderSide(
                color: widget.themeColor.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              Row(
                children: [
                  _buildMobileNavTab("Home", 0),
                  const SizedBox(width: 25),
                  _buildMobileNavTab("Search", 1),
                  const SizedBox(width: 25),
                  _buildMobileNavTab("Contact", 2),
                ],
              ),
              GestureDetector(
                onTap: _handleThemeToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: 45,
                  height: 25,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: widget.themeColor, width: 2),
                  ),
                  child: Stack(
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        left: _localDarkMode ? 24 : 4,
                        child: Container(
                          width: 16,
                          height: 16,
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
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildMobileHomeCard(),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    top: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Journey &',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: _localDarkMode
                                  ? Colors.white
                                  : Colors.black,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'EXPERIENCE',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: widget.themeColor,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: 60,
                            height: 2.5,
                            decoration: BoxDecoration(
                              color: widget.themeColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 19),
                          Text(
                            'As a fourth-year student at the Institute of Technology of Cambodia aiming for a bachelor\'s degree in Telecommunication and Network Engineering.\n\n'
                            'I am eager to take on challenges that will help me grow both personally and professionally.',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              color: _localDarkMode
                                  ? Colors.white.withOpacity(0.9)
                                  : Colors.black.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 30),
                          _buildMobileInfoCard(
                            'About Me',
                            Icons.person_outline,
                            'My academic background has provided me with a solid foundation in networking systems, computer programming, and telecommunications.',
                            ['Networking', 'Telecom', 'Engineering', 'Cisco'],
                            '4+ Years',
                            0,
                          ),
                          const SizedBox(height: 20),
                          _buildMobileInfoCard(
                            'Project',
                            Icons.work_outline,
                            'Explore my projects including Arduino training, network implementations, Cisco configurations, and volunteer work.',
                            ['Arduino', 'Projects', 'Volunteer', 'Cisco'],
                            '3+ Projects',
                            1,
                          ),
                          const SizedBox(height: 20),
                          _buildMobileInfoCard(
                            'Reference',
                            Icons.contact_mail_outlined,
                            'Get in touch for collaboration opportunities, professional connections.',
                            ['GitHub', 'LinkedIn', 'Email', 'Resume'],
                            'Connect',
                            2,
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileInfoCard(
    String title,
    IconData icon,
    String description,
    List<String> tags,
    String stat,
    int index,
  ) {
    return GestureDetector(
      onTap: () {
        if (index == 0) {
          _navigateToAboutPage();
        } else if (index == 1) {
          _navigateToProjectPage();
        } else if (index == 2) {
          _navigateToReferencePage();
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: _localDarkMode
                ? [
                    widget.themeColor.withOpacity(0.90),
                    widget.themeColor.withOpacity(0.6),
                  ]
                : [
                    widget.themeColor.withOpacity(0.85),
                    widget.themeColor.withOpacity(0.60),
                  ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _localDarkMode
                        ? Colors.white.withOpacity(0.2)
                        : Colors.black.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: _localDarkMode ? Colors.white : Colors.black,
                    size: 26,
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
                    stat,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _localDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: _localDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: TextStyle(
                fontSize: 11,
                color: _localDarkMode
                    ? Colors.white.withOpacity(0.96)
                    : Colors.black.withOpacity(0.85),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: tags
                  .map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _localDarkMode
                            ? Colors.white.withOpacity(0.2)
                            : Colors.black.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _localDarkMode
                              ? Colors.white.withOpacity(0.3)
                              : Colors.black.withOpacity(0.7),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 10,
                          color: _localDarkMode ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 15),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                index == 0
                    ? 'View More →'
                    : index == 1
                    ? 'See Projects →'
                    : 'View Contacts →',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _localDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeCard() {
    bool _isHoveringHomeButton = false;

    return GestureDetector(
      onTap: _navigateToHomePage,
      child: Container(
        margin: const EdgeInsets.all(20),
        height: 260,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              widget.themeColor.withOpacity(0.8),
              widget.themeColor.withOpacity(0.5),
              widget.themeColor.withOpacity(0.3),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: widget.themeColor.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ...List.generate(8, (index) {
              return AnimatedBuilder(
                animation: _floatingController,
                builder: (context, child) {
                  double offset =
                      (_floatingController.value + (index * 0.125)) % 1.0;
                  return Positioned(
                    left: 50.0 + (index * 60),
                    top: 20 + (offset * 240),
                    child: Opacity(
                      opacity: 0.3,
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: _localDarkMode ? Colors.white : Colors.black,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
            Padding(
              padding: const EdgeInsets.all(30),
              child: Row(
                children: [
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 5),
                        Text(
                          "Sarita VORT",
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: _localDarkMode
                                ? Colors.white
                                : Colors.black87,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Network Engineering Student",
                          style: TextStyle(
                            fontSize: 14,
                            color: _localDarkMode ? Colors.white : Colors.black,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "I am a fourth-year Telecommunication and Network Engineering student who eager to take on opportunities where i can grow and improve as a future engineer.",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: _localDarkMode ? Colors.white : Colors.black,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            MouseRegion(
                              onEnter: (_) =>
                                  setState(() => _isHoveringHomeButton = true),
                              onExit: (_) =>
                                  setState(() => _isHoveringHomeButton = false),
                              child: GestureDetector(
                                onTap: _navigateToHomePage,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _localDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      width: 2,
                                    ),
                                    boxShadow: _isHoveringHomeButton
                                        ? [
                                            BoxShadow(
                                              color: _localDarkMode
                                                  ? Colors.white.withOpacity(
                                                      0.5,
                                                    )
                                                  : Colors.black.withOpacity(
                                                      0.3,
                                                    ),
                                              blurRadius: 20,
                                              spreadRadius: 2,
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Go to Home",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: _localDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward,
                                        color: _localDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            _buildSocialIcon(
                              FontAwesomeIcons.github,
                              'https://github.com/VortSarita',
                            ),
                            const SizedBox(width: 10),
                            _buildSocialIcon(
                              FontAwesomeIcons.linkedin,
                              'https://www.linkedin.com/in/vort-sarita-2482b3369/',
                            ),
                            const SizedBox(width: 10),
                            _buildSocialIcon(
                              FontAwesomeIcons.instagram,
                              'https://www.instagram.com/eppy.c0m/',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 60),
                ],
              ),
            ),
            Positioned(
              right: 60,
              bottom: -35,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  ...List.generate(6, (index) {
                    return AnimatedBuilder(
                      animation: _sparkleController,
                      builder: (context, child) {
                        double angle =
                            (index * 60.0) + (_sparkleController.value * 360);
                        return Positioned(
                          left:
                              180 +
                              (120 * (index % 2 == 0 ? 0.8 : 1.2)) *
                                  (angle > 180 ? -1 : 1),
                          top:
                              180 +
                              (120 * (index % 3 == 0 ? 0.6 : 0.8)) *
                                  (index > 2 ? 1 : -1),
                          child: Opacity(
                            opacity:
                                0.3 +
                                (0.7 *
                                    ((_sparkleController.value + index * 0.15) %
                                        1.0)),
                            child: Icon(
                              Icons.star,
                              size:
                                  12 +
                                  (8 *
                                      ((_sparkleController.value +
                                              index * 0.2) %
                                          1.0)),
                              color: _localDarkMode
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        );
                      },
                    );
                  }),
                  Hero(
                    tag: 'avatar',
                    child: Image.asset(
                      'assets/avatar.png',
                      height: 360,
                      fit: BoxFit.contain,
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

  Widget _buildMobileHomeCard() {
    return GestureDetector(
      onTap: _navigateToHomePage,
      child: Container(
        margin: const EdgeInsets.all(20),
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              widget.themeColor.withOpacity(0.8),
              widget.themeColor.withOpacity(0.5),
              widget.themeColor.withOpacity(0.3),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: widget.themeColor.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ...List.generate(6, (index) {
              return AnimatedBuilder(
                animation: _floatingController,
                builder: (context, child) {
                  double offset =
                      (_floatingController.value + (index * 0.15)) % 1.0;
                  return Positioned(
                    left: 30.0 + (index * 50),
                    top: 20 + (offset * 240),
                    child: Opacity(
                      opacity: 0.3,
                      child: Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: _localDarkMode ? Colors.white : Colors.black,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
            Padding(
              padding: const EdgeInsets.all(25),
              child: Row(
                children: [
                  const SizedBox(width: 7),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 5),
                        Text(
                          "Sarita VORT",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: _localDarkMode
                                ? Colors.white
                                : Colors.black87,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 9),
                        Text(
                          "Network Engineering Student",
                          style: TextStyle(
                            fontSize: 12,
                            color: _localDarkMode ? Colors.white : Colors.black,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "I am a fourth-year Telecommunication and Network Engineering...",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            color: _localDarkMode ? Colors.white : Colors.black,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _navigateToHomePage,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _localDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Go to Home",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: _localDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: _localDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      size: 12,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildSocialIconMobile(
                              FontAwesomeIcons.github,
                              'https://github.com/VortSarita',
                            ),
                            const SizedBox(width: 6),
                            _buildSocialIconMobile(
                              FontAwesomeIcons.linkedin,
                              'https://www.linkedin.com/in/vort-sarita-2482b3369/',
                            ),
                            const SizedBox(width: 6),
                            _buildSocialIconMobile(
                              FontAwesomeIcons.instagram,
                              'https://www.instagram.com/eppy.c0m/',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: -10,
              bottom: -20,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  ...List.generate(4, (index) {
                    return AnimatedBuilder(
                      animation: _sparkleController,
                      builder: (context, child) {
                        double angle =
                            (index * 90.0) + (_sparkleController.value * 360);
                        return Positioned(
                          left:
                              100 +
                              (60 * (index % 2 == 0 ? 0.8 : 1.2)) *
                                  (angle > 180 ? -1 : 1),
                          top:
                              100 +
                              (60 * (index % 2 == 0 ? 0.6 : 0.8)) *
                                  (index > 1 ? 1 : -1),
                          child: Opacity(
                            opacity:
                                0.3 +
                                (0.7 *
                                    ((_sparkleController.value + index * 0.15) %
                                        1.0)),
                            child: Icon(
                              Icons.star,
                              size:
                                  8 +
                                  (6 *
                                      ((_sparkleController.value +
                                              index * 0.2) %
                                          1.0)),
                              color: _localDarkMode
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        );
                      },
                    );
                  }),
                  Image.asset(
                    'assets/avatar.png',
                    height: 220,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ],
        ),
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

  Widget _buildSocialIcon(IconData icon, String url) {
    return GestureDetector(
      onTap: () => _launchURL(url),
      child: Container(
        padding: const EdgeInsets.all(8),
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
          size: 16,
          color: _localDarkMode ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
