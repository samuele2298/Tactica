import 'package:flutter/material.dart';
import '../models/ai_difficulty.dart';

class StrategySelectionDialog extends StatefulWidget {
  final AIStrategy? currentStrategy;
  final bool isGameStart;
  final VoidCallback? onStart;
  final Function(AIStrategy)? onStrategySelected;
  final VoidCallback? onReplay;

  const StrategySelectionDialog({
    Key? key,
    this.currentStrategy,
    this.isGameStart = true,
    this.onStart,
    this.onStrategySelected,
    this.onReplay,
  }) : super(key: key);

  @override
  State<StrategySelectionDialog> createState() => _StrategySelectionDialogState();
}

class _StrategySelectionDialogState extends State<StrategySelectionDialog>
    with TickerProviderStateMixin {
  late AIDifficulty selectedDifficulty;
  late AIStrategy selectedStrategy;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    if (widget.currentStrategy != null) {
      selectedStrategy = widget.currentStrategy!;
      selectedDifficulty = selectedStrategy.difficulty;
    } else {
      selectedDifficulty = AIDifficulty.medium;
      selectedStrategy = AIStrategy.medium1;
    }

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.shade50,
                      Colors.purple.shade50,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Icon(
                          widget.isGameStart ? Icons.play_circle_fill : Icons.settings,
                          color: Colors.blue.shade700,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.isGameStart 
                                ? 'Scegli la Strategia AI' 
                                : 'Cambia Strategia',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),

                    // Selezione Difficoltà
                    Text(
                      'Difficoltà:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: AIDifficulty.values.map((difficulty) {
                        return _buildDifficultyChip(difficulty);
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Selezione Strategia Specifica
                    Text(
                      'Strategia Specifica:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          children: selectedDifficulty.strategies.map((strategy) {
                            return _buildStrategyOption(strategy);
                          }).toList(),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Pulsanti azione
                    if (widget.isGameStart) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            widget.onStrategySelected?.call(selectedStrategy);
                            widget.onStart?.call();
                          },
                          icon: const Icon(Icons.play_arrow, size: 28),
                          label: const Text(
                            'INIZIA PARTITA',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pop();
                                widget.onReplay?.call();
                              },
                              icon: const Icon(Icons.replay),
                              label: const Text('Rigioca'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pop();
                                widget.onStrategySelected?.call(selectedStrategy);
                                widget.onStart?.call();
                              },
                              icon: const Icon(Icons.auto_fix_high),
                              label: const Text('Cambia'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDifficultyChip(AIDifficulty difficulty) {
    final isSelected = difficulty == selectedDifficulty;
    
    Color backgroundColor;
    Color textColor;
    String label;
    
    switch (difficulty) {
      case AIDifficulty.easy:
        backgroundColor = isSelected ? Colors.green.shade600 : Colors.green.shade100;
        textColor = isSelected ? Colors.white : Colors.green.shade700;
        label = 'Facile';
        break;
      case AIDifficulty.medium:
        backgroundColor = isSelected ? Colors.orange.shade600 : Colors.orange.shade100;
        textColor = isSelected ? Colors.white : Colors.orange.shade700;
        label = 'Medio';
        break;
      case AIDifficulty.hard:
        backgroundColor = isSelected ? Colors.red.shade600 : Colors.red.shade100;
        textColor = isSelected ? Colors.white : Colors.red.shade700;
        label = 'Difficile';
        break;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDifficulty = difficulty;
          selectedStrategy = difficulty.strategies.first;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected ? [
            BoxShadow(
              color: backgroundColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildStrategyOption(AIStrategy strategy) {
    final isSelected = strategy == selectedStrategy;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedStrategy = strategy;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue.shade300 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? Colors.blue.shade600 : Colors.grey.shade400,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strategy.displayName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.blue.shade700 : Colors.grey.shade700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    strategy.description,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
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
}