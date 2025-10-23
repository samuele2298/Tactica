/// Loading screen with TacticaFe branding
/// Shows during app initialization or between screens

import 'package:flutter/material.dart';
import 'tacticafe_logo.dart';

class LoadingScreen extends StatelessWidget {
  final String? message;
  final bool showProgress;
  
  const LoadingScreen({
    super.key,
    this.message,
    this.showProgress = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo animato
            TacticafeLogo.large(animated: true),
            
            const SizedBox(height: 32),
            
            // Nome del gioco
            const Text(
              'TacticaFe',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Messaggio opzionale
            if (message != null) ...[
              Text(
                message!,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
            ],
            
            // Indicatore di caricamento
            if (showProgress) ...[
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Loading widget per uso in overlay o dialoghi
class LoadingWidget extends StatelessWidget {
  final String? message;
  final double? size;
  
  const LoadingWidget({
    super.key,
    this.message,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TacticafeLogo(
            size: size != null ? LogoSize.values.firstWhere(
              (s) => s.value >= size!,
              orElse: () => LogoSize.medium,
            ) : LogoSize.medium,
            animated: true,
          ),
          
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          
          const SizedBox(height: 16),
          
          SizedBox(
            width: 120,
            child: LinearProgressIndicator(
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
            ),
          ),
        ],
      ),
    );
  }
}