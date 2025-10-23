/// Error screen with TacticaFe branding
/// Shows when something goes wrong with helpful recovery options

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'tacticafe_logo.dart';

class ErrorScreen extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback? onRetry;
  final bool showHomeButton;
  
  const ErrorScreen({
    super.key,
    this.title,
    this.message,
    this.onRetry,
    this.showHomeButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo (statico per l'errore)
              TacticafeLogo.large(),
              
              const SizedBox(height: 32),
              
              // Icona errore
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red.shade400,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Titolo errore
              Text(
                title ?? 'Ops! Qualcosa è andato storto',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Messaggio errore
              Text(
                message ?? 'Si è verificato un errore imprevisto. Riprova o torna alla home.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Pulsanti azione
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (onRetry != null) ...[
                    ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Riprova'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                    if (showHomeButton) const SizedBox(width: 16),
                  ],
                  
                  if (showHomeButton)
                    OutlinedButton.icon(
                      onPressed: () => context.go('/'),
                      icon: const Icon(Icons.home),
                      label: const Text('Home'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 48),
              
              // Footer
              Text(
                'TacticaFe - Impara le Strategie Giocando',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget per errori inline/dialogs
class ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  
  const ErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_rounded,
            color: Colors.red.shade600,
            size: 32,
          ),
          
          const SizedBox(height: 12),
          
          Text(
            message,
            style: TextStyle(
              color: Colors.red.shade700,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: const Text('Riprova'),
            ),
          ],
        ],
      ),
    );
  }
}