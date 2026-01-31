import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'search.dart';
import 'contact.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _globalDarkMode = true;
  Color _themeColor = const Color(0xFF6C63FF);

  void _updateTheme(bool isDarkMode) {
    setState(() {
      _globalDarkMode = isDarkMode;
    });
  }

  void _updateThemeColor(Color color) {
    setState(() {
      _themeColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(
        themeColor: _themeColor,
        isDarkMode: _globalDarkMode,
        onThemeChanged: _updateTheme,
        onThemeColorChanged: _updateThemeColor,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final Color themeColor;
  final bool isDarkMode;
  final Function(bool)? onThemeChanged;
  final Function(Color)? onThemeColorChanged;

  const HomePage({
    super.key,
    this.themeColor = const Color(0xFF6C63FF),
    this.isDarkMode = true,
    this.onThemeChanged,
    this.onThemeColorChanged,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int selectedTab = 0;
  int selectedColor = 0;
  late bool isDarkMode;
  late Color themeColor;
  late PageController mobilePageController;
  int currentPage = 0;

  late AnimationController avatarController;
  late Animation<double> avatarScale;
  late Animation<double> avatarFade;

  final List<Map<String, dynamic>> themeColors = [
    {'deep': const Color(0xFF689F38), 'name': 'Green'},
    {'deep': const Color(0xFFF9A825), 'name': 'Yellow'},
    {'deep': const Color(0xFFF57F17), 'name': 'Orange'},
    {'deep': const Color(0xFFE64A19), 'name': 'Red'},
    {'deep': const Color(0xFF1565C0), 'name': 'Blue'},
    {'deep': const Color(0xFF4527A0), 'name': 'Purple'},
    {'deep': const Color(0xFFAD1457), 'name': 'Pink'},
  ];

  @override
  void initState() {
    super.initState();

    isDarkMode = widget.isDarkMode;
    themeColor = widget.themeColor;

    selectedColor = themeColors.indexWhere(
      (color) => color['deep'] == themeColor,
    );
    if (selectedColor == -1) {
      selectedColor = 0;
      themeColor = themeColors[0]['deep']!;
    }

    mobilePageController = PageController();
    mobilePageController.addListener(() {
      setState(() {
        currentPage = mobilePageController.page?.round() ?? 0;
      });
    });

    avatarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    avatarScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: avatarController, curve: Curves.easeOutBack),
    );
    avatarFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: avatarController, curve: Curves.easeIn));
    avatarController.forward();
  }

  void _toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
    if (widget.onThemeChanged != null) {
      widget.onThemeChanged!(isDarkMode);
    }
  }

  void _handleColorChange(int index) {
    setState(() {
      selectedColor = index;
      themeColor = themeColors[index]['deep']!;
    });
    if (widget.onThemeColorChanged != null) {
      widget.onThemeColorChanged!(themeColor);
    }
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDarkMode != widget.isDarkMode) {
      setState(() {
        isDarkMode = widget.isDarkMode;
      });
    }
    if (oldWidget.themeColor != widget.themeColor) {
      setState(() {
        themeColor = widget.themeColor;
        selectedColor = themeColors.indexWhere(
          (color) => color['deep'] == themeColor,
        );
        if (selectedColor == -1) selectedColor = 0;
      });
    }
  }

  @override
  void dispose() {
    mobilePageController.dispose();
    avatarController.dispose();
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

  Future<void> _downloadCV() async {
    try {
      if (kIsWeb) {
        final url = 'assets/Sarita_VORT_CV.pdf';
        await launchUrl(Uri.parse(url), mode: LaunchMode.platformDefault);
        return;
      }

      final ByteData data = await rootBundle.load('assets/Sarita_VORT_CV.pdf');
      final bytes = data.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/Sarita_VORT_CV.pdf');
      await file.writeAsBytes(bytes);
      await OpenFile.open(file.path);
    } catch (e) {
      debugPrint('Download error: $e');
    }
  }

  // SIMPLE DESKTOP NAV TAB - No theme passing back
  Widget buildNavTab(String title, int index) {
    bool isActive = selectedTab == index;
    Color activeColor = themeColor;
    Color textColor = isDarkMode ? Colors.white70 : Colors.black54;

    return GestureDetector(
      onTap: () {
        if (index == 0) {
          // Already on Home
          setState(() {
            selectedTab = index;
          });
        } else if (index == 1) {
          // Navigate to Search
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => SearchPage(
                themeColor: themeColor,
                isDarkMode: isDarkMode,
                onThemeChanged: widget.onThemeChanged,
                onThemeColorChanged: widget.onThemeColorChanged,
              ),
            ),
          );
        } else if (index == 2) {
          // Navigate to Contact
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ContactPage(
                themeColor: themeColor,
                isDarkMode: isDarkMode,
                onThemeChanged: widget.onThemeChanged,
                onThemeColorChanged: widget.onThemeColorChanged,
              ),
            ),
          );
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

  // SIMPLE MOBILE NAV TAB - No theme passing back
  Widget _buildMobileNavTab(String title, int index) {
    bool isActive = selectedTab == index;
    Color activeColor = themeColor;
    Color textColor = isDarkMode ? Colors.white70 : Colors.black54;

    return GestureDetector(
      onTap: () {
        if (index == 0) {
          // Already on Home
          setState(() {
            selectedTab = index;
          });
        } else if (index == 1) {
          // Navigate to Search
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => SearchPage(
                themeColor: themeColor,
                isDarkMode: isDarkMode,
                onThemeChanged: widget.onThemeChanged,
                onThemeColorChanged: widget.onThemeColorChanged,
              ),
            ),
          );
        } else if (index == 2) {
          // Navigate to Contact
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ContactPage(
                themeColor: themeColor,
                isDarkMode: isDarkMode,
                onThemeChanged: widget.onThemeChanged,
                onThemeColorChanged: widget.onThemeColorChanged,
              ),
            ),
          );
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
    Color sidebarColor = themeColor;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        color: isDarkMode ? Colors.black : Colors.white,
        child: isMobile
            ? _buildMobileLayout(themeColor)
            : _buildDesktopLayout(themeColor, sidebarColor),
      ),
    );
  }

  Widget _buildDesktopLayout(Color deepColor, Color sidebarColor) {
    return Row(
      children: [
        Container(
          width: 90,
          color: sidebarColor,
          child: Stack(
            children: [
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 12,
                    height: double.infinity,
                    color: deepColor,
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
                    key: ValueKey<bool>(isDarkMode),
                    width: 64,
                    height: 64,
                    child: Image.asset(
                      isDarkMode
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
          child: Stack(
            children: [
              Container(color: isDarkMode ? Colors.black : Colors.white),

              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 900,
                child: FadeTransition(
                  opacity: avatarFade,
                  child: ScaleTransition(
                    scale: avatarScale,
                    child: Image.asset(
                      'assets/avatar.png',
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
              ),

              Positioned(
                left: 100,
                top: 120,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hi There, I'm",
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    Text(
                      "Sarita VORT",
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: deepColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 400),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                      child: const Text(
                        "Telecommunication and Network Engineering Student",
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 400,
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 400),
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                        ),
                        child: const Text(
                          "I am fourth-year student majoring in Telecommunication and Network Engineering at the Institute of Technology of Cambodia (ITC). I thrive in learning and developing both new and existing skills. My approach to work is energetic, focused and i am both determined and decisive. I am eager to take on opportunities where i can grow and improve as a future engineer.",
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: deepColor),
                        const SizedBox(width: 5),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 400),
                          style: TextStyle(
                            fontSize: 13,
                            color: isDarkMode ? Colors.white70 : Colors.black87,
                          ),
                          child: const Text("Based in Cambodia"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    GestureDetector(
                      onTap: _downloadCV,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: deepColor, width: 2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.download, size: 20, color: deepColor),
                            const SizedBox(width: 8),
                            Text(
                              "Download CV",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: deepColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 400),
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode ? Colors.white70 : Colors.black87,
                          ),
                          child: const Text("Follow Me:"),
                        ),
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            GestureDetector(
                              onTap: () =>
                                  _launchURL('https://github.com/VortSarita'),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: deepColor,
                                    width: 2,
                                  ),
                                ),
                                child: FaIcon(
                                  FontAwesomeIcons.github,
                                  size: 18,
                                  color: deepColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            GestureDetector(
                              onTap: () => _launchURL(
                                'https://www.linkedin.com/in/vort-sarita-2482b3369/',
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: deepColor,
                                    width: 2,
                                  ),
                                ),
                                child: FaIcon(
                                  FontAwesomeIcons.linkedin,
                                  size: 18,
                                  color: deepColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            GestureDetector(
                              onTap: () => _launchURL(
                                'https://www.instagram.com/eppy.c0m/',
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: deepColor,
                                    width: 2,
                                  ),
                                ),
                                child: FaIcon(
                                  FontAwesomeIcons.instagram,
                                  size: 18,
                                  color: deepColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Positioned(
                right: 40,
                top: 0,
                bottom: 0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 240,
                      width: 50,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.grey[900]
                            : Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: deepColor.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: ListView.builder(
                        itemCount: themeColors.length,
                        itemBuilder: (context, index) {
                          bool isSelected = selectedColor == index;
                          return GestureDetector(
                            onTap: () => _handleColorChange(index),
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: themeColors[index]['deep'],
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? themeColors[index]['deep']
                                      : Colors.transparent,
                                  width: 2.2,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: themeColors[index]['deep']
                                              .withOpacity(0.4),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : [],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Color",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: deepColor,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
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
                          onTap: _toggleTheme,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            width: 52,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(color: deepColor, width: 2.2),
                            ),
                            child: Stack(
                              children: [
                                AnimatedPositioned(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                  left: isDarkMode ? 26 : 4,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: deepColor.withOpacity(0.3),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),

                                Center(
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: Icon(
                                      isDarkMode
                                          ? Icons.nightlight_round
                                          : Icons.wb_sunny,
                                      key: ValueKey<bool>(isDarkMode),
                                      color: isDarkMode
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
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(Color deepColor) {
    return Stack(
      children: [
        Container(color: isDarkMode ? Colors.black : Colors.white),
        PageView(
          controller: mobilePageController,
          onPageChanged: (page) {
            setState(() {
              currentPage = page;
            });
          },
          physics: const BouncingScrollPhysics(),
          children: [
            // PAGE 1 - Avatar and Basic Info
            Stack(
              children: [
                Column(
                  children: [
                    Container(
                      height: 70,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: deepColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                child: Image.asset(
                                  isDarkMode
                                      ? 'assets/cat_night.png'
                                      : 'assets/cat_day.png',
                                  key: ValueKey<bool>(isDarkMode),
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
                              const SizedBox(width: 33),
                              _buildMobileNavTab("Search", 1),
                              const SizedBox(width: 33),
                              _buildMobileNavTab("Contact", 2),
                            ],
                          ),
                          GestureDetector(
                            onTap: _toggleTheme,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              width: 45,
                              height: 25,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(40),
                                border: Border.all(color: deepColor, width: 2),
                              ),
                              child: Stack(
                                children: [
                                  AnimatedPositioned(
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeInOut,
                                    left: isDarkMode ? 24 : 4,
                                    child: Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: deepColor.withOpacity(0.3),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),

                                  Center(
                                    child: AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      child: Icon(
                                        isDarkMode
                                            ? Icons.nightlight_round
                                            : Icons.wb_sunny,
                                        key: ValueKey<bool>(isDarkMode),
                                        color: deepColor,
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

                    // Avatar Container
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 60),
                        child: Center(
                          child: FadeTransition(
                            opacity: avatarFade,
                            child: ScaleTransition(
                              scale: avatarScale,
                              child: Image.asset(
                                'assets/avatar.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        children: [
                          Text(
                            "Hi There, I'm",
                            style: TextStyle(
                              fontSize: 19,
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),

                          Text(
                            "Sarita VORT",
                            style: TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                              color: deepColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 400),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.black87,
                            ),
                            child: const Text(
                              "Telecommunication and Network Engineering Student",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: 20,
                  bottom: 160,
                  child: GestureDetector(
                    onTap: () {
                      mobilePageController.animateToPage(
                        1,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 1500),
                      curve: Curves.easeInOut,
                      builder: (context, double value, child) {
                        return Transform.translate(
                          offset: Offset(10 * (1 - value), 0),
                          child: Opacity(
                            opacity: 0.5 + (0.5 * value),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: deepColor.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(color: deepColor, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: deepColor.withOpacity(0.3),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: deepColor,
                                size: 18,
                              ),
                            ),
                          ),
                        );
                      },
                      onEnd: () {
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ],
            ),

            // PAGE 2 - Description Page
            Container(
              color: isDarkMode ? Colors.black : Colors.white,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDarkMode
                          ? [
                              Colors.black,
                              deepColor.withOpacity(0.05),
                              Colors.black,
                            ]
                          : [
                              Colors.white,
                              deepColor.withOpacity(0.03),
                              Colors.white,
                            ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),

                        GestureDetector(
                          onTap: () {
                            mobilePageController.animateToPage(
                              0,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: deepColor, width: 2),
                              color: deepColor.withOpacity(0.1),
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              color: deepColor,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 35,
                              decoration: BoxDecoration(
                                color: deepColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(width: 12),

                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 400),
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                              child: const Text("Description"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: deepColor.withOpacity(0.3),
                              width: 1.5,
                            ),
                            color: isDarkMode
                                ? Colors.grey[900]?.withOpacity(0.3)
                                : Colors.white.withOpacity(0.5),
                          ),
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 400),
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.6,
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.black87,
                            ),
                            child: const Text(
                              "I am fourth-year student majoring in Telecommunication and Network Engineering at the Institute of Technology of Cambodia (ITC). I thrive in learning and developing both new and existing skills. My approach to work is energetic, focused and i am both determined and decisive. I am eager to take on opportunities where i can grow and improve as a future engineer.",
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: deepColor.withOpacity(0.3),
                              width: 1.5,
                            ),
                            color: isDarkMode
                                ? Colors.grey[900]?.withOpacity(0.5)
                                : Colors.grey[100],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: deepColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: deepColor,
                                ),
                              ),
                              const SizedBox(width: 10),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 400),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: isDarkMode
                                      ? Colors.white70
                                      : Colors.black87,
                                ),
                                child: const Text("Based in Cambodia"),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        GestureDetector(
                          onTap: _downloadCV,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: deepColor, width: 1.5),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.download,
                                  size: 18,
                                  color: deepColor,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Download CV",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: deepColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),

                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 400),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white70 : Colors.black87,
                          ),
                          child: const Text("Follow Me:"),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            GestureDetector(
                              onTap: () =>
                                  _launchURL('https://github.com/VortSarita'),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: deepColor,
                                    width: 2,
                                  ),
                                  color: Colors.transparent,
                                ),
                                child: FaIcon(
                                  FontAwesomeIcons.github,
                                  size: 20,
                                  color: deepColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            GestureDetector(
                              onTap: () => _launchURL(
                                'https://www.linkedin.com/in/vort-sarita-2482b3369/',
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: deepColor,
                                    width: 2,
                                  ),
                                  color: Colors.transparent,
                                ),
                                child: FaIcon(
                                  FontAwesomeIcons.linkedin,
                                  size: 20,
                                  color: deepColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            GestureDetector(
                              onTap: () => _launchURL(
                                'https://www.instagram.com/eppy.c0m/',
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: deepColor,
                                    width: 2,
                                  ),
                                  color: Colors.transparent,
                                ),
                                child: FaIcon(
                                  FontAwesomeIcons.instagram,
                                  size: 20,
                                  color: deepColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        // COLOR PICKER - Only show on page 0
        if (currentPage == 0)
          Positioned(
            right: 15,
            top: 150,
            child: Container(
              height: 200,
              width: 45,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.grey[900]!.withOpacity(0.9)
                    : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: deepColor.withOpacity(0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode
                        ? Colors.black54
                        : Colors.grey.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: themeColors.length,
                itemBuilder: (context, index) {
                  bool isSelected = selectedColor == index;
                  return GestureDetector(
                    onTap: () => _handleColorChange(index),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: themeColors[index]['deep'],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? themeColors[index]['deep']
                              : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: themeColors[index]['deep'].withOpacity(
                                    0.5,
                                  ),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : [],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
