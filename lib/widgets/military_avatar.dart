import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/global_progress_provider.dart';

/// Avatar militare animato per il main menu
class MilitaryAvatar extends ConsumerStatefulWidget {
  final VoidCallback? onTap;

  const MilitaryAvatar({
    super.key,
    this.onTap,
  });

  @override
  ConsumerState<MilitaryAvatar> createState() => _MilitaryAvatarState();
}

class _MilitaryAvatarState extends ConsumerState<MilitaryAvatar>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _medalController;
  late AnimationController _salutingController;
  
  late Animation<double> _breathingAnimation;
  late Animation<double> _medalAnimation;
  late Animation<double> _salutingAnimation;

  @override
  void initState() {
    super.initState();
    
    // Animazione respirazione continua
    _breathingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _breathingAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));
    
    // Animazione medaglie (lampeggio)
    _medalController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _medalAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _medalController,
      curve: Curves.easeInOut,
    ));
    
    // Animazione saluto occasionale
    _salutingController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _salutingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _salutingController,
      curve: Curves.elasticOut,
    ));
    
    // Saluto casuale ogni tanto
    _startRandomSaluting();
  }

  void _startRandomSaluting() {
    Future.delayed(Duration(seconds: 5 + (DateTime.now().millisecond % 10)), () {
      if (mounted) {
        _salutingController.forward().then((_) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              _salutingController.reverse().then((_) {
                _startRandomSaluting();
              });
            }
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _medalController.dispose();
    _salutingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final globalState = ref.watch(globalProgressProvider);
    
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _breathingAnimation,
          _medalAnimation,
          _salutingAnimation,
        ]),
        builder: (context, child) {
          return Transform.scale(
            scale: _breathingAnimation.value,
            child: Container(
              width: 120,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.green.shade100,
                    Colors.green.shade200,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Avatar principale
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Testa con elmetto
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.brown.shade300,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Stack(
                            children: [
                              // Viso
                              Center(
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.brown.shade200,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Occhi
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: const BoxDecoration(
                                              color: Colors.black,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: const BoxDecoration(
                                              color: Colors.black,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      // Sorriso
                                      Container(
                                        width: 15,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.black,
                                              width: 2,
                                            ),
                                          ),
                                          borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Elmetto
                              Positioned(
                                top: 0,
                                left: 5,
                                right: 5,
                                child: Container(
                                  height: 25,
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade800,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(25),
                                      topRight: Radius.circular(25),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Corpo con divisa
                        Container(
                          width: 45,
                          height: 35,
                          decoration: BoxDecoration(
                            color: Colors.green.shade700,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Bottoni divisa
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: const BoxDecoration(
                                      color: Colors.yellow,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: const BoxDecoration(
                                      color: Colors.yellow,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // Rank
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.yellow.shade700,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            globalState.currentRank,
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Braccio saluto animato
                  if (_salutingAnimation.value > 0.1)
                    Positioned(
                      top: 35,
                      right: 15,
                      child: Transform.rotate(
                        angle: -0.5 * _salutingAnimation.value,
                        origin: const Offset(0, 15),
                        child: Container(
                          width: 20,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.brown.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  
                  // Medaglie
                  Positioned(
                    top: 10,
                    left: 10,
                    child: _buildMedals(globalState),
                  ),
                  
                  // Punteggio
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${globalState.totalScore}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Indicatore touch
                  if (widget.onTap != null)
                    Positioned(
                      top: 5,
                      right: 5,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMedals(GlobalPlayerState globalState) {
    final stats = ref.read(globalProgressProvider.notifier).getGeneralStats();
    
    return AnimatedBuilder(
      animation: _medalAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _medalAnimation.value,
          child: Column(
            children: [
              // Medaglia diamante
              if (stats['diamondMedals'] > 0)
                _buildMedalIcon(MedalType.diamond, stats['diamondMedals']),
              
              // Medaglia platino
              if (stats['platinumMedals'] > 0)
                _buildMedalIcon(MedalType.platinum, stats['platinumMedals']),
              
              // Medaglia oro (mostra solo se non ci sono superiori)
              if (stats['goldMedals'] > 0 && stats['platinumMedals'] == 0 && stats['diamondMedals'] == 0)
                _buildMedalIcon(MedalType.gold, stats['goldMedals']),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMedalIcon(MedalType medal, int count) {
    Color color;
    switch (medal) {
      case MedalType.diamond:
        color = Colors.cyan;
        break;
      case MedalType.platinum:
        color = Colors.grey.shade300;
        break;
      case MedalType.gold:
        color = Colors.yellow.shade700;
        break;
      case MedalType.silver:
        color = Colors.grey.shade400;
        break;
      case MedalType.bronze:
        color = Colors.orange.shade700;
        break;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.military_tech,
            size: 12,
            color: Colors.white,
          ),
          if (count > 1)
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}