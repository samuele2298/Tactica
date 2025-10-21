import 'package:flutter/material.dart';

class GameTheoryHint extends StatefulWidget {
  final String gameMode;
  final String title;
  final String concept;
  final String learning;
  final String experience;
  final Color themeColor;

  const GameTheoryHint({
    super.key,
    required this.gameMode,
    required this.title,
    required this.concept,
    required this.learning,
    required this.experience,
    required this.themeColor,
  });

  @override
  State<GameTheoryHint> createState() => _GameTheoryHintState();
}

class _GameTheoryHintState extends State<GameTheoryHint>
    with TickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late AnimationController _pulseController;
  late Animation<double> _expandAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleHint() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
        _pulseController.stop();
      } else {
        _controller.reverse();
        _pulseController.repeat();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Pulsante lampadina
        AnimatedBuilder(
          animation: _isExpanded ? _expandAnimation : _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _isExpanded ? 1.0 : _pulseAnimation.value,
              child: FloatingActionButton(
                onPressed: _toggleHint,
                backgroundColor: widget.themeColor,
                foregroundColor: Colors.white,
                child: AnimatedRotation(
                  turns: _isExpanded ? 0.25 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(
                    Icons.lightbulb,
                    size: 28,
                  ),
                ),
              ),
            );
          },
        ),
        
        // Pannello espandibile con gli hint
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          height: _isExpanded ? null : 0,
          child: _isExpanded
              ? Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: widget.themeColor.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.themeColor.withOpacity(0.2),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Icon(
                            Icons.psychology,
                            color: widget.themeColor,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.title,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: widget.themeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Concetto teorico
                      _buildSection(
                        'Concetto di Teoria dei Giochi',
                        widget.concept,
                        Icons.school,
                        Colors.blue,
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Cosa si impara
                      _buildSection(
                        'Cosa Impari',
                        widget.learning,
                        Icons.emoji_objects,
                        Colors.orange,
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Esperienza del giocatore
                      _buildSection(
                        'Cosa Sperimenterai',
                        widget.experience,
                        Icons.sports_esports,
                        Colors.green,
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildSection(String title, String content, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}