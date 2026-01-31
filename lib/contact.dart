import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'main.dart';
import 'search.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ContactPage extends StatefulWidget {
  final Color themeColor;
  final bool isDarkMode;
  final Function(bool)? onThemeChanged;
  final Function(Color)? onThemeColorChanged;

  const ContactPage({
    super.key,
    required this.themeColor,
    required this.isDarkMode,
    this.onThemeChanged,
    this.onThemeColorChanged,
  });

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage>
    with TickerProviderStateMixin {
  int selectedTab = 2;
  bool _localDarkMode = true;
  bool _isSending = false;
  final ScrollController _scrollController = ScrollController();
  bool _isHoveringSubmit = false;
  int? _hoveredSocialIndex;
  int? _hoveredInfoIndex;

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _floatingController;

  @override
  void initState() {
    super.initState();
    _localDarkMode = widget.isDarkMode;

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _fadeController.forward();
  }

  // SIMPLE NAVIGATION - Use pushReplacement
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

  // SIMPLE NAVIGATION - Use pushReplacement
  void _navigateToSearchPage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => SearchPage(
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
  void didUpdateWidget(ContactPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDarkMode != widget.isDarkMode) {
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

  Future<void> _sendEmail() async {
    // Prevent multiple sends
    if (_isSending) return;

    // Validate all fields first
    if (_nameController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter your name'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    if (_emailController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter your email'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    if (_subjectController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a subject'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    if (_messageController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter your message'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Simple email validation
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(_emailController.text)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid email address'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Start sending process
    setState(() {
      _isSending = true;
    });

    try {
      // Show sending message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Sending message...'),
              ],
            ),
            backgroundColor: widget.themeColor,
            duration: const Duration(seconds: 30),
          ),
        );
      }

      // Send request to FormSubmit
      final response = await http.post(
        Uri.parse('https://formsubmit.co/ajax/saritavort@gmail.com'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': _nameController.text,
          'email': _emailController.text,
          'subject': _subjectController.text,
          'message': _messageController.text,
          '_subject': 'New Message from Portfolio Contact Form',
          '_template': 'table',
          '_autoresponse':
              'Thank you for contacting me! I will get back to you soon.',
          '_captcha': 'false',
        }),
      );

      // Hide loading snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }

      // Check response
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == 'true' ||
            responseData['success'] == true) {
          // Success
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Message sent successfully!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
          }

          // Clear form
          _nameController.clear();
          _emailController.clear();
          _subjectController.clear();
          _messageController.clear();

          // Trigger a small rebuild to show empty fields
          setState(() {});
        } else {
          // FormSubmit returned error
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Failed to send: ${responseData['message'] ?? 'Unknown error'}',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        // HTTP error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Server error: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (error) {
      // Network or other error
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Always re-enable button
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    _fadeController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  // Color getters matching aboutme.dart
  Color get _backgroundColor =>
      _localDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FA);

  Color get _surfaceColor =>
      _localDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

  // SIMPLE DESKTOP NAV TAB - Use pushReplacement
  Widget buildNavTab(String title, int index) {
    bool isActive = selectedTab == index;
    Color activeColor = widget.themeColor;
    Color textColor = _localDarkMode ? Colors.white70 : Colors.black54;

    return GestureDetector(
      onTap: () {
        if (index == 0) {
          _navigateToHomePage();
        } else if (index == 1) {
          _navigateToSearchPage();
        } else {
          setState(() {
            selectedTab = index;
          });
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

  // SIMPLE MOBILE NAV TAB - Use pushReplacement
  Widget _buildMobileNavTab(String title, int index) {
    bool isActive = selectedTab == index;
    Color activeColor = widget.themeColor;
    Color textColor = _localDarkMode ? Colors.white70 : Colors.black87;

    return GestureDetector(
      onTap: () {
        if (index == 0) {
          _navigateToHomePage();
        } else if (index == 1) {
          _navigateToSearchPage();
        } else {
          setState(() {
            selectedTab = index;
          });
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
      backgroundColor: _backgroundColor,
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
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 60),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 15),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Get in touch',
                                      style: TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: _localDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                        height: 1.5,
                                      ),
                                    ),
                                    Text(
                                      'AND CONNECT',
                                      style: TextStyle(
                                        fontSize: 48,
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
                                    const SizedBox(height: 30),
                                    Text(
                                      'Feel free to reach out for always be able to try to stay connect\nI\'m always open to discussing new projects and ideas.',
                                      style: TextStyle(
                                        fontSize: 16,
                                        height: 1.6,
                                        color: _localDarkMode
                                            ? Colors.white.withOpacity(0.9)
                                            : Colors.black.withOpacity(0.9),
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    _buildQuickContactInfo(),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 60),
                              Expanded(flex: 2, child: _buildContactForm()),
                            ],
                          ),
                          const SizedBox(height: 50),
                          _buildSocialSection(),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickContactInfo() {
    final contactItems = [
      {
        'icon': Icons.email_outlined,
        'title': 'Email',
        'value': 'saritavort@gmail.com',
        'url': 'mailto:saritavort@gmail.com',
      },
      {
        'icon': Icons.phone_outlined,
        'title': 'Phone',
        'value': '+855 15 881 107',
        'url': 'tel:+85515881107',
      },
      {
        'icon': Icons.location_on_outlined,
        'title': 'Location',
        'value': 'Phnom Penh, Cambodia',
        'url': 'https://maps.app.goo.gl/9SVjWxk6zFXbkjLP7',
      },
    ];

    return Column(
      children: contactItems.asMap().entries.map((entry) {
        int index = entry.key;
        var item = entry.value;
        bool isHovered = _hoveredInfoIndex == index;

        return MouseRegion(
          onEnter: (_) => setState(() => _hoveredInfoIndex = index),
          onExit: (_) => setState(() => _hoveredInfoIndex = null),
          child: GestureDetector(
            onTap: item['url'] != null
                ? () => _launchURL(item['url'] as String)
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: _localDarkMode
                    ? widget.themeColor.withOpacity(0.15)
                    : widget.themeColor.withOpacity(0.3),
                border: Border.all(
                  color: isHovered
                      ? widget.themeColor
                      : widget.themeColor.withOpacity(0.5),
                  width: isHovered ? 3 : 2.5,
                ),
                boxShadow: isHovered
                    ? [
                        BoxShadow(
                          color: widget.themeColor.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 3,
                        ),
                      ]
                    : [],
              ),
              child: Stack(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: widget.themeColor.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          color: isHovered ? Colors.white : widget.themeColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _localDarkMode
                                    ? Colors.white.withOpacity(0.6)
                                    : Colors.black.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['value'] as String,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isHovered
                                    ? widget.themeColor
                                    : (_localDarkMode
                                          ? Colors.white
                                          : Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (item['url'] != null)
                        AnimatedRotation(
                          duration: const Duration(milliseconds: 200),
                          turns: isHovered ? 0.25 : 0,
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: isHovered
                                ? widget.themeColor
                                : widget.themeColor.withOpacity(0.5),
                          ),
                        ),
                    ],
                  ),
                  if (item['url'] != null && isHovered)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: widget.themeColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Click',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContactForm() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: _surfaceColor,
        border: Border.all(
          color: widget.themeColor.withOpacity(0.5),
          width: 2.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 28,
                decoration: BoxDecoration(
                  color: widget.themeColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Send Message',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _localDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          _buildTextField('Name', _nameController, Icons.person_outline),
          const SizedBox(height: 18),
          _buildTextField('Email', _emailController, Icons.email_outlined),
          const SizedBox(height: 18),
          _buildTextField('Subject', _subjectController, Icons.subject),
          const SizedBox(height: 18),
          _buildTextField(
            'Message',
            _messageController,
            Icons.message_outlined,
            maxLines: 5,
          ),
          const SizedBox(height: 28),
          MouseRegion(
            onEnter: (_) => setState(() => _isHoveringSubmit = true),
            onExit: (_) => setState(() => _isHoveringSubmit = false),
            child: GestureDetector(
              onTap: _isSending ? null : _sendEmail,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: _isHoveringSubmit && !_isSending
                      ? LinearGradient(
                          colors: [
                            widget.themeColor,
                            widget.themeColor.withOpacity(0.8),
                          ],
                        )
                      : null,
                  color: _isSending
                      ? widget.themeColor.withOpacity(0.5)
                      : (_isHoveringSubmit ? null : Colors.transparent),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isSending
                        ? widget.themeColor.withOpacity(0.3)
                        : widget.themeColor,
                    width: 2,
                  ),
                  boxShadow: _isHoveringSubmit && !_isSending
                      ? [
                          BoxShadow(
                            color: widget.themeColor.withOpacity(0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isSending)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    else
                      Text(
                        'Send Message',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _isHoveringSubmit || _isSending
                              ? Colors.white
                              : widget.themeColor,
                        ),
                      ),
                    if (!_isSending) const SizedBox(width: 10),
                    if (!_isSending)
                      Icon(
                        Icons.send,
                        color: _isHoveringSubmit
                            ? Colors.white
                            : widget.themeColor,
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _localDarkMode
                ? Colors.white.withOpacity(0.8)
                : Colors.black.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: maxLines > 1 ? 16 : 14, right: 12),
              child: Icon(icon, color: widget.themeColor, size: 20),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                maxLines: maxLines,
                style: TextStyle(
                  color: _localDarkMode ? Colors.white : Colors.black,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter your $label',
                  hintStyle: TextStyle(
                    color: _localDarkMode
                        ? Colors.white.withOpacity(0.5)
                        : Colors.black.withOpacity(0.5),
                  ),
                  filled: true,
                  fillColor: widget.themeColor.withOpacity(
                    _localDarkMode ? 0.15 : 0.4,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: widget.themeColor.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: widget.themeColor.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: widget.themeColor,
                      width: 2.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
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
          Row(
            children: [
              Container(
                width: 4,
                height: 28,
                decoration: BoxDecoration(
                  color: widget.themeColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Connect With Me',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _localDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Let\'s stay connected! Follow me on social media for fun and UMM !!.',
            style: TextStyle(
              fontSize: 15,
              color: _localDarkMode
                  ? Colors.white.withOpacity(1)
                  : Colors.black.withOpacity(1),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildSocialButton(
                FontAwesomeIcons.github,
                'https://github.com/VortSarita',
                'GitHub',
                0,
              ),
              const SizedBox(width: 16),
              _buildSocialButton(
                FontAwesomeIcons.linkedin,
                'https://www.linkedin.com/in/vort-sarita-2482b3369/',
                'LinkedIn',
                1,
              ),
              const SizedBox(width: 16),
              _buildSocialButton(
                FontAwesomeIcons.instagram,
                'https://www.instagram.com/eppy.c0m/',
                'Instagram',
                2,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(
    IconData icon,
    String url,
    String label,
    int index,
  ) {
    final isHovered = _hoveredSocialIndex == index;

    return Expanded(
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoveredSocialIndex = index),
        onExit: (_) => setState(() => _hoveredSocialIndex = null),
        child: GestureDetector(
          onTap: () => _launchURL(url),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: isHovered
                  ? (_localDarkMode
                        ? Colors.white.withOpacity(0.15)
                        : Colors.black.withOpacity(0.15))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _localDarkMode
                    ? Colors.white.withOpacity(0.6)
                    : Colors.black.withOpacity(0.6),
                width: 1.5,
              ),
              boxShadow: isHovered
                  ? [
                      BoxShadow(
                        color: widget.themeColor.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: Column(
              children: [
                FaIcon(
                  icon,
                  size: 24,
                  color: _localDarkMode ? Colors.white : Colors.black,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _localDarkMode ? Colors.white : Colors.black,
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
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
                  Text(
                    'Get in touch',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _localDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    'AND CONNECT',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: widget.themeColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 60,
                    height: 3,
                    decoration: BoxDecoration(
                      color: widget.themeColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Feel free to reach out for always be able to try to stay connect\nI\'m always open to discussing new projects and ideas !!',
                    style: TextStyle(
                      fontSize: 14,
                      color: _localDarkMode
                          ? Colors.white.withOpacity(1)
                          : Colors.black.withOpacity(1),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildMobileContactForm(),
                  const SizedBox(height: 25),
                  _buildMobileContactInfo(),
                  const SizedBox(height: 25),
                  _buildMobileSocialSection(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileContactForm() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: _surfaceColor,
        border: Border.all(
          color: widget.themeColor.withOpacity(0.5),
          width: 2.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 22,
                decoration: BoxDecoration(
                  color: widget.themeColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Send Message',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _localDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField('Name', _nameController, Icons.person_outline),
          const SizedBox(height: 12),
          _buildTextField('Email', _emailController, Icons.email_outlined),
          const SizedBox(height: 12),
          _buildTextField('Subject', _subjectController, Icons.subject),
          const SizedBox(height: 12),
          _buildTextField(
            'Message',
            _messageController,
            Icons.message_outlined,
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _sendEmail,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.themeColor,
                    widget.themeColor.withOpacity(0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: widget.themeColor.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Send Message',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.send, color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileContactInfo() {
    final contactItems = [
      {
        'icon': Icons.email_outlined,
        'title': 'Email',
        'value': 'saritavort@gmail.com',
        'url': 'mailto:saritavort@gmail.com',
      },
      {
        'icon': Icons.phone_outlined,
        'title': 'Phone',
        'value': '+855 15 881 107',
        'url': 'tel:+85515881107',
      },
      {
        'icon': Icons.location_on_outlined,
        'title': 'Location',
        'value': 'Phnom Penh, Cambodia',
        'url': 'https://maps.app.goo.gl/9SVjWxk6zFXbkjLP7',
      },
    ];

    return Column(
      children: contactItems.asMap().entries.map((entry) {
        int index = entry.key;
        var item = entry.value;
        bool isHovered = _hoveredInfoIndex == index;

        return MouseRegion(
          onEnter: (_) => setState(() => _hoveredInfoIndex = index),
          onExit: (_) => setState(() => _hoveredInfoIndex = null),
          child: GestureDetector(
            onTap: item['url'] != null
                ? () => _launchURL(item['url'] as String)
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: _localDarkMode
                    ? widget.themeColor.withOpacity(0.15)
                    : widget.themeColor.withOpacity(0.3),
                border: Border.all(
                  color: isHovered
                      ? widget.themeColor
                      : widget.themeColor.withOpacity(0.5),
                  width: isHovered ? 3 : 2.5,
                ),
                boxShadow: isHovered
                    ? [
                        BoxShadow(
                          color: widget.themeColor.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 3,
                        ),
                      ]
                    : [],
              ),
              child: Stack(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: widget.themeColor.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          color: isHovered ? Colors.white : widget.themeColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _localDarkMode
                                    ? Colors.white.withOpacity(0.6)
                                    : Colors.black.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['value'] as String,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isHovered
                                    ? widget.themeColor
                                    : (_localDarkMode
                                          ? Colors.white
                                          : Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (item['url'] != null)
                        AnimatedRotation(
                          duration: const Duration(milliseconds: 200),
                          turns: isHovered ? 0.25 : 0,
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: isHovered
                                ? widget.themeColor
                                : widget.themeColor.withOpacity(0.5),
                          ),
                        ),
                    ],
                  ),
                  if (item['url'] != null && isHovered)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: widget.themeColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Click',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMobileSocialSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
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
        border: Border.all(color: widget.themeColor.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: widget.themeColor.withOpacity(_localDarkMode ? 0.45 : 0.30),
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
              Container(
                width: 3,
                height: 22,
                decoration: BoxDecoration(
                  color: widget.themeColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Connect With Me',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _localDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Let\'s stay connected on social media!',
            style: TextStyle(
              fontSize: 13,
              color: _localDarkMode
                  ? Colors.white.withOpacity(1)
                  : Colors.black.withOpacity(1),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildMobileSocialButton(
                FontAwesomeIcons.github,
                'https://github.com/VortSarita',
                'GitHub',
              ),
              const SizedBox(width: 10),
              _buildMobileSocialButton(
                FontAwesomeIcons.linkedin,
                'https://www.linkedin.com/in/vort-sarita-2482b3369/',
                'LinkedIn',
              ),
              const SizedBox(width: 10),
              _buildMobileSocialButton(
                FontAwesomeIcons.instagram,
                'https://www.instagram.com/eppy.c0m/',
                'Instagram',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileSocialButton(IconData icon, String url, String label) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _launchURL(url),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: _localDarkMode
                ? Colors.white.withOpacity(0.15)
                : Colors.black.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _localDarkMode
                  ? Colors.white.withOpacity(0.4)
                  : Colors.black.withOpacity(0.4),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              FaIcon(
                icon,
                size: 20,
                color: _localDarkMode ? Colors.white : Colors.black,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _localDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
