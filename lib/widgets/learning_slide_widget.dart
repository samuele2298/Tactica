import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/learning_content.dart';

class LearningSlideWidget extends ConsumerStatefulWidget {
  final LearningSlide slide;
  final int currentSlide;
  final int totalSlides;
  final Color? moduleColor;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final VoidCallback? onComplete;

  const LearningSlideWidget({
    super.key,
    required this.slide,
    required this.currentSlide,
    required this.totalSlides,
    this.moduleColor,
    this.onNext,
    this.onPrevious,
    this.onComplete,
  });

  @override
  ConsumerState<LearningSlideWidget> createState() => _LearningSlideWidgetState();
}

class _LearningSlideWidgetState extends ConsumerState<LearningSlideWidget> 
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: _buildSlideContent(),
      ),
    );
  }

  Widget _buildSlideContent() {
    switch (widget.slide.type) {
      case SlideType.intro:
        return _buildIntroSlide();
      case SlideType.concept:
        return _buildConceptSlide();
      case SlideType.example:
        return _buildExampleSlide();
      case SlideType.interactive:
        return _buildInteractiveSlide();
      case SlideType.summary:
        return _buildSummarySlide();
    }
  }

  /// --- BUILDER SLIDES ---

  Widget _buildIntroSlide() {
    return _baseSlideLayout(
      titleColor: Colors.blue.shade700,
      iconColor: Colors.white,
      iconBgGradient: LinearGradient(
        colors: [Colors.blue.shade400, Colors.purple.shade400],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  Widget _buildConceptSlide() {
    return _baseSlideLayout(
      titleColor: Colors.green.shade700,
      iconColor: Colors.green.shade600,
      iconBgGradient: LinearGradient(
        colors: [Colors.green.shade50, Colors.green.shade100],
      ),
    );
  }

  Widget _buildExampleSlide() {
    return _baseSlideLayout(
      titleColor: Colors.orange.shade700,
      iconColor: Colors.orange.shade600,
      iconBgGradient: LinearGradient(
        colors: [Colors.orange.shade50, Colors.yellow.shade50],
      ),
    );
  }

  Widget _buildInteractiveSlide() {
    return _baseSlideLayout(
      titleColor: Colors.purple.shade700,
      iconColor: Colors.purple.shade600,
      iconBgGradient: LinearGradient(
        colors: [Colors.purple.shade50, Colors.purple.shade100],
      ),
      interactiveContent: widget.slide.interactiveData,
    );
  }

  Widget _buildSummarySlide() {
    return _baseSlideLayout(
      titleColor: Colors.green.shade700,
      iconColor: Colors.green.shade700,
      iconBgGradient: LinearGradient(
        colors: [Colors.green.shade50, Colors.green.shade100],
      ),
    );
  }

  /// --- BASE SLIDE LAYOUT CON MARKDOWN ---
  Widget _baseSlideLayout({
    required Color titleColor,
    required Color iconColor,
    required Gradient iconBgGradient,
    Map<String, dynamic>? interactiveContent,
  }) {
    return Container(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          _buildProgressIndicator(),
          const SizedBox(height: 20),

          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: iconBgGradient,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              _getIconData(widget.slide.iconData ?? 'star'),
              color: iconColor,
              size: 40,
            ),
          ),

          const SizedBox(height: 20),

          // Title
          MarkdownBody(
            data: '# ${widget.slide.title}',
            styleSheet: MarkdownStyleSheet(
              h1: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
          ),
          const SizedBox(height: 15),

          // Content
          if (widget.slide.content.isNotEmpty)
            MarkdownBody(
              data: widget.slide.content,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(fontSize: 16, color: Colors.grey.shade700, height: 1.5),
                strong: const TextStyle(fontWeight: FontWeight.bold),
                em: const TextStyle(fontStyle: FontStyle.italic),
                listBullet: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
            ),

          const SizedBox(height: 20),

          // Example
          if (widget.slide.example != null)
            Container(
              padding: const EdgeInsets.all(15),
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: MarkdownBody(
                data: widget.slide.example!,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(fontSize: 15, color: Colors.grey.shade800, height: 1.4),
                  strong: const TextStyle(fontWeight: FontWeight.bold),
                  listBullet: TextStyle(fontSize: 15, color: Colors.grey.shade800),
                ),
              ),
            ),

          // Bullet points
          if (widget.slide.bulletPoints != null)
            ...widget.slide.bulletPoints!.map((b) => _buildBulletPoint(b)),

          // Interactive
          if (interactiveContent != null)
            Expanded(child: _buildInteractiveContent(interactiveContent)),

          const Spacer(),

          _buildNavigationButtons(),
        ],
      ),
    );
  }

  /// --- INTERACTIVE CONTENT ---
  Widget _buildInteractiveContent(Map<String, dynamic> data) {
    if (data.containsKey('matrix')) {
      final matrix = data['matrix'] as Map<String, dynamic>;
      return _buildMatrixVisualization(matrix);
    } else if (data.containsKey('question')) {
      return _buildQuizContent(data);
    }
    return const SizedBox();
  }

  Widget _buildMatrixVisualization(Map<String, dynamic> matrix) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        children: [
          Text('Matrice dei Risultati', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.purple.shade700)),
          const SizedBox(height: 15),
          Table(
            border: TableBorder.all(color: Colors.purple.shade300),
            children: [
              TableRow(
                decoration: BoxDecoration(color: Colors.purple.shade100),
                children: [
                  _buildTableCell(''),
                  _buildTableCell('🤝 Coopera', isHeader: true),
                  _buildTableCell('💥 Tradisce', isHeader: true),
                ],
              ),
              TableRow(children: [
                _buildTableCell('🤝 Coopera', isHeader: true),
                _buildTableCell(matrix['cooperate_cooperate'] ?? ''),
                _buildTableCell(matrix['cooperate_betray'] ?? ''),
              ]),
              TableRow(children: [
                _buildTableCell('💥 Tradisce', isHeader: true),
                _buildTableCell(matrix['betray_cooperate'] ?? ''),
                _buildTableCell(matrix['betray_betray'] ?? ''),
              ]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuizContent(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        children: [
          Text(data['question'] ?? '', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.purple.shade700)),
          const SizedBox(height: 10),
          Text('Risposta: ${data['explanation'] ?? ''}', style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  /// --- BULLETS & ACHIEVEMENTS ---
  Widget _buildBulletPoint(String text) {
    final Color activeColor = widget.moduleColor ?? Colors.blue.shade600;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 12),
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: activeColor, borderRadius: BorderRadius.circular(4)),
          ),
          Expanded(child: MarkdownBody(data: text)),
        ],
      ),
    );
  }

  /// --- NAVIGATION ---
  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (widget.currentSlide > 0)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: widget.onPrevious,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Indietro'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          )
        else
          const Expanded(child: SizedBox()),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: widget.currentSlide < widget.totalSlides - 1 ? widget.onNext : widget.onComplete,
            icon: Icon(widget.currentSlide < widget.totalSlides - 1 ? Icons.arrow_forward : Icons.check),
            label: Text(widget.currentSlide < widget.totalSlides - 1 ? 'Avanti' : 'Completa'),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.currentSlide < widget.totalSlides - 1 ? Colors.blue.shade600 : Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }

  /// --- PROGRESS ---
  Widget _buildProgressIndicator() {
    final Color activeColor = widget.moduleColor ?? Colors.blue.shade600;
    return Row(
      children: [
        for (int i = 0; i < widget.totalSlides; i++)
          Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: i < widget.totalSlides - 1 ? 5 : 0),
              decoration: BoxDecoration(
                color: i <= widget.currentSlide ? activeColor : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        const SizedBox(width: 10),
        Text('${widget.currentSlide + 1}/${widget.totalSlides}', style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, fontWeight: isHeader ? FontWeight.bold : FontWeight.normal, color: isHeader ? Colors.purple.shade700 : Colors.grey.shade800),
        textAlign: TextAlign.center,
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'games': return Icons.sports_esports;
      case 'list': return Icons.list;
      case 'back_hand': return Icons.back_hand;
      case 'icecream': return Icons.icecream;
      case 'lightbulb': return Icons.lightbulb;
      case 'auto_stories': return Icons.auto_stories;
      case 'account_balance': return Icons.account_balance;
      case 'table_chart': return Icons.table_chart;
      case 'groups': return Icons.groups;
      case 'psychology': return Icons.psychology;
      case 'emoji_events': return Icons.emoji_events;
      case 'star': return Icons.star;
      case 'smart_toy': return Icons.smart_toy;
      case 'military_tech': return Icons.military_tech;
      case 'school': return Icons.school;
      case 'balance': return Icons.balance;
      case 'traffic': return Icons.traffic;
      case 'quiz': return Icons.quiz;
      case 'celebration': return Icons.celebration;
      case 'refresh': return Icons.refresh;
      case 'favorite': return Icons.favorite;
      case 'handshake': return Icons.handshake;
      case 'auto_awesome': return Icons.auto_awesome;
      default: return Icons.star;
    }
  }
}
