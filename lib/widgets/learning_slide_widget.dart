import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  Widget _buildIntroSlide() {
    return Container(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),
          
          const SizedBox(height: 30),
          
          // Hero icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.purple.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(60),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              _getIconData(widget.slide.iconData ?? 'star'),
              size: 60,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Title
          Text(
            widget.slide.title,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 20),
          
          // Content
          Text(
            widget.slide.content,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 40),
          
          // Bullet points
          if (widget.slide.bulletPoints != null) ...[
            ...widget.slide.bulletPoints!.map((point) => _buildBulletPoint(point)),
          ],
          
          const Spacer(),
          
          // Navigation
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildConceptSlide() {
    return Container(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress
          _buildProgressIndicator(),
          
          const SizedBox(height: 20),
          
          // Title with icon
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  _getIconData(widget.slide.iconData ?? 'lightbulb'),
                  color: Colors.green.shade600,
                  size: 30,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  widget.slide.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 30),
          
          // Content
          Text(
            widget.slide.content,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade700,
              height: 1.6,
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Example box
          if (widget.slide.example != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                widget.slide.example!,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue.shade700,
                  height: 1.5,
                ),
              ),
            ),
          
          // Bullet points
          if (widget.slide.bulletPoints != null) ...[
            const SizedBox(height: 20),
            ...widget.slide.bulletPoints!.map((point) => _buildBulletPoint(point)),
          ],
          
          const Spacer(),
          
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildExampleSlide() {
    return Container(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          _buildProgressIndicator(),
          
          const SizedBox(height: 20),
          
          // Title
          Text(
            widget.slide.title,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 20),
          
          // Content
          Text(
            widget.slide.content,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 30),
          
          // Example card
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade50, Colors.yellow.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: Colors.orange.shade600,
                          size: 30,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Esempio Pratico',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (widget.slide.example != null)
                      Text(
                        widget.slide.example!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade800,
                          height: 1.6,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildInteractiveSlide() {
    return Container(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          _buildProgressIndicator(),
          
          const SizedBox(height: 20),
          
          // Title
          Text(
            widget.slide.title,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 20),
          
          // Content
          Text(
            widget.slide.content,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 30),
          
          // Interactive content
          Expanded(
            child: _buildInteractiveContent(),
          ),
          
          const SizedBox(height: 20),
          
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildSummarySlide() {
    return Container(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          _buildProgressIndicator(),
          
          const SizedBox(height: 30),
          
          // Success icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade400, Colors.blue.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_circle,
              size: 50,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Title
          Text(
            widget.slide.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 20),
          
          // Content
          Text(
            widget.slide.content,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 30),
          
          // Quote
          if (widget.slide.quote != null)
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Text(
                widget.slide.quote!,
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.green.shade700,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          
          const SizedBox(height: 30),
          
          // Achievement points
          if (widget.slide.bulletPoints != null) ...[
            Text(
              'Cosa hai imparato:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 15),
            ...widget.slide.bulletPoints!.map((point) => _buildAchievementPoint(point)),
          ],
          
          const Spacer(),
          
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildInteractiveContent() {
    final data = widget.slide.interactiveData;
    if (data == null) return const SizedBox();

    if (data.containsKey('matrix')) {
      return _buildMatrixVisualization(data['matrix']);
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
          Text(
            'Matrice dei Risultati',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade700,
            ),
          ),
          const SizedBox(height: 20),
          Table(
            border: TableBorder.all(color: Colors.purple.shade300),
            children: [
              // Header
              TableRow(
                decoration: BoxDecoration(color: Colors.purple.shade100),
                children: [
                  _buildTableCell('', isHeader: true),
                  _buildTableCell('🤝 Coopera', isHeader: true),
                  _buildTableCell('💥 Tradisce', isHeader: true),
                ],
              ),
              // Row 1
              TableRow(
                children: [
                  _buildTableCell('🤝 Coopera', isHeader: true),
                  _buildTableCell(matrix['cooperate_cooperate'] ?? ''),
                  _buildTableCell(matrix['cooperate_betray'] ?? ''),
                ],
              ),
              // Row 2
              TableRow(
                children: [
                  _buildTableCell('💥 Tradisce', isHeader: true),
                  _buildTableCell(matrix['betray_cooperate'] ?? ''),
                  _buildTableCell(matrix['betray_betray'] ?? ''),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isHeader ? 14 : 13,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? Colors.purple.shade700 : Colors.grey.shade800,
        ),
        textAlign: TextAlign.center,
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
          Text(
            data['question'] ?? '',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            'Risposta: ${data['explanation'] ?? ''}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

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
                color: i <= widget.currentSlide 
                    ? activeColor 
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        const SizedBox(width: 10),
        Text(
          '${widget.currentSlide + 1}/${widget.totalSlides}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    final Color activeColor = widget.moduleColor ?? Colors.blue.shade600;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 12),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: activeColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementPoint(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green.shade600,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        // Previous button
        if (widget.currentSlide > 0)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: widget.onPrevious,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Indietro'),
            ),
          )
        else
          const Expanded(child: SizedBox()),
        
        const SizedBox(width: 15),
        
        // Next/Complete button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: widget.currentSlide < widget.totalSlides - 1 
                ? widget.onNext 
                : widget.onComplete,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.currentSlide < widget.totalSlides - 1 
                  ? Colors.blue.shade600 
                  : Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: Icon(
              widget.currentSlide < widget.totalSlides - 1 
                  ? Icons.arrow_forward 
                  : Icons.check,
            ),
            label: Text(
              widget.currentSlide < widget.totalSlides - 1 
                  ? 'Avanti' 
                  : 'Completa',
            ),
          ),
        ),
      ],
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