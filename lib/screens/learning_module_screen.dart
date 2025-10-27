import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/learning_content.dart';
import '../widgets/learning_slide_widget.dart';

class LearningModuleScreen extends ConsumerStatefulWidget {
  final String moduleId;

  const LearningModuleScreen({
    super.key,
    required this.moduleId,
  });

  @override
  ConsumerState<LearningModuleScreen> createState() => _LearningModuleScreenState();
}

class _LearningModuleScreenState extends ConsumerState<LearningModuleScreen> {
  late PageController _pageController;
  int _currentSlide = 0;
  LearningModule? _module;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _module = LearningModules.getModuleById(widget.moduleId);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_module == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 20),
              Text(
                'Modulo non trovato',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade600,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => context.go('/impara'),
                child: const Text('Torna alla sezione Impara'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFAFAFA),
              Colors.white,
              Color(0xFFF5F5F5),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header con titolo modulo e exit
              _buildHeader(),
              
              // Slide content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentSlide = index;
                    });
                  },
                  itemCount: _module!.slides.length,
                  itemBuilder: (context, index) {
                    return LearningSlideWidget(
                      slide: _module!.slides[index],
                      currentSlide: index,
                      totalSlides: _module!.slides.length,
                      moduleColor: _getModuleColor(),
                      onNext: index < _module!.slides.length - 1
                          ? () => _nextSlide()
                          : null,
                      onPrevious: index > 0 ? () => _previousSlide() : null,
                      onComplete: index == _module!.slides.length - 1
                          ? () => _completeModule()
                          : null,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Exit button
          IconButton(
            onPressed: () => _showExitDialog(),
            icon: const Icon(Icons.close, size: 28),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          
          const SizedBox(width: 15),
          
          // Module info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _module!.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _getModuleColor(),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_module!.estimatedMinutes} min',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Icon(
                      Icons.signal_cellular_alt,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _module!.difficulty,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Module icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _getModuleColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              _getModuleIcon(),
              color: _getModuleColor(),
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Color _getModuleColor() {
    switch (_module!.color) {
      case 'blue': return Colors.blue.shade600;
      case 'purple': return Colors.purple.shade600;
      case 'green': return Colors.green.shade600;
      case 'orange': return Colors.orange.shade600;
      case 'red': return Colors.red.shade600;
      default: return Colors.blue.shade600;
    }
  }

  IconData _getModuleIcon() {
    switch (_module!.iconData) {
      case 'psychology': return Icons.psychology;
      case 'balance': return Icons.balance;
      case 'trending_up': return Icons.trending_up;
      case 'center_focus_strong': return Icons.center_focus_strong;
      case 'repeat': return Icons.repeat;
      default: return Icons.school;
    }
  }

  void _nextSlide() {
    if (_currentSlide < _module!.slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousSlide() {
    if (_currentSlide > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeModule() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.green.shade50,
                Colors.white,
                Colors.green.shade50,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icona celebrazione animata
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.celebration,
                  color: Colors.green.shade600,
                  size: 50,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Titolo
              Text(
                'Modulo Completato!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 15),
              
              // Messaggio di congratulazioni
              Text(
                'Congratulazioni! Hai completato il modulo "${_module!.title}".',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 25),
              
              // Badge di achievement
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.shade100,
                      Colors.green.shade50,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.green.shade200, width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.emoji_events,
                      color: Colors.green.shade600,
                      size: 30,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nuovo Traguardo!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                          Text(
                            'Hai acquisito nuove conoscenze sulla teoria dei giochi!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Pulsanti azione
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.go('/play');
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Metti in Pratica'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue.shade600,
                        side: BorderSide(color: Colors.blue.shade600),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.go('/impara');
                      },
                      icon: const Icon(Icons.school),
                      label: const Text('Altri Moduli'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 3,
                      ),
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

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icona di avviso
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange.shade600,
                  size: 40,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Titolo
              Text(
                'Uscire dal modulo?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 15),
              
              // Messaggio
              Text(
                'Il tuo progresso non verrà salvato. Sei sicuro di voler uscire?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 25),
              
              // Pulsanti
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade600,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Continua'),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.go('/impara');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child: const Text('Esci'),
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
}