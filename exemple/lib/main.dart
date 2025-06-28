import 'package:flutter/material.dart';
import 'package:caller/caller.dart'; // Assure-toi que ce chemin d'import est correct pour ton projet
import 'package:permission_handler/permission_handler.dart'; // Import du package
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Caller Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CallerTestScreen(),
    );
  }
}

class CallerTestScreen extends StatefulWidget {
  const CallerTestScreen({super.key});

  @override
  State<CallerTestScreen> createState() => _CallerTestScreenState();
}

class _CallerTestScreenState extends State<CallerTestScreen> {
  // Contrôleurs pour les champs de texte
  final _numeroController = TextEditingController();
  final _montantController = TextEditingController();
  final _pinController = TextEditingController();

  // Variables pour afficher le statut des permissions
  String _accessibilityPermissionStatus = "Permission inconnue";
  String _callPermissionStatus = "Permission d'appel inconnue";

  // Instance de la classe Caller
  final _caller = Caller();

  @override
  void initState() {
    super.initState();
    // Vérifier les statuts des permissions au démarrage
    _checkAccessibilityPermissionStatus();
    _checkCallPermissionStatus();
  }

  @override
  void dispose() {
    _numeroController.dispose();
    _montantController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  // --- Méthodes pour la permission d'accessibilité ---
  Future<void> _checkAccessibilityPermissionStatus() async {
    final isEnabled = await Caller.isAccessibilityPermissionEnabled();
    setState(() {
      _accessibilityPermissionStatus = isEnabled ? "✅ Accordée" : "❌ Refusée";
    });
  }

  Future<void> _requestAccessibilityPermission() async {
    final permissionGranted = await Caller.requestAccessibilityPermission();
    if (permissionGranted) {
      await _checkAccessibilityPermissionStatus();
    }
  }

  // --- Méthodes pour la permission d'appel ---
  Future<void> _checkCallPermissionStatus() async {
    final status = await Permission.phone.status;
    setState(() {
      _callPermissionStatus = _getPermissionStatusText(status);
    });
  }

  Future<void> _requestCallPermission() async {
    final status = await Permission.phone.request();
    setState(() {
      _callPermissionStatus = _getPermissionStatusText(status);
    });
  }

  String _getPermissionStatusText(PermissionStatus status) {
    if (status.isGranted) return "✅ Accordée";
    if (status.isPermanentlyDenied) return "🚫 Refusée définitivement";
    return "❌ Refusée";
  }


  // --- Méthode pour l'appel USSD ---
  Future<void> _makeUssdCall() async {
    // 1. On vérifie d'abord la permission d'appel
    final status = await Permission.phone.status;

    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez d'abord accorder la permission d'appel.")),
      );
      // On demande la permission si elle n'est pas accordée
      await _requestCallPermission();
      return;
    }

    // 2. Si la permission est accordée, on continue
    final String num = _numeroController.text;
    final String montant = _montantController.text;
    final String pin = _pinController.text;

    if (num.isEmpty || montant.isEmpty || pin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    final String ussdCode = "*144*2*1*$num*$montant*$pin#";

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Lancement USSD : $ussdCode')),
    );
    _caller.call(ussdCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test du Package Caller'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Section 1: Gestion des Permissions d'Accessibilité ---
              Text('Permission d\'Accessibilité', style: Theme.of(context).textTheme.titleLarge),
              Text('Statut : $_accessibilityPermissionStatus', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: ElevatedButton(onPressed: _checkAccessibilityPermissionStatus, child: const Text('Vérifier'))),
                  const SizedBox(width: 8),
                  Expanded(child: ElevatedButton(onPressed: _requestAccessibilityPermission, child: const Text('Demander'))),
                ],
              ),
              const Divider(height: 32),

              // --- Section 2: Gestion de la Permission d'Appel ---
              Text('Permission d\'Appel (CALL_PHONE)', style: Theme.of(context).textTheme.titleLarge),
              Text('Statut : $_callPermissionStatus', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: ElevatedButton(onPressed: _checkCallPermissionStatus, child: const Text('Vérifier'))),
                  const SizedBox(width: 8),
                  Expanded(child: ElevatedButton(onPressed: _requestCallPermission, child: const Text('Demander'))),
                ],
              ),
              if (_callPermissionStatus.contains("Refusée définitivement"))
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextButton(onPressed: openAppSettings, child: const Text("Ouvrir les paramètres de l'app")),
                ),
              const Divider(height: 32),

              // --- Section 3: Appel USSD ---
              Text('Effectuer un appel USSD', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(controller: _numeroController, decoration: const InputDecoration(labelText: 'Numéro du destinataire', border: OutlineInputBorder()), keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              TextField(controller: _montantController, decoration: const InputDecoration(labelText: 'Montant', border: OutlineInputBorder()), keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              TextField(controller: _pinController, decoration: const InputDecoration(labelText: 'Code PIN', border: OutlineInputBorder()), keyboardType: TextInputType.number, obscureText: true),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _makeUssdCall, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text("Lancer l'appel USSD")),
              const Divider(height: 32),

              // --- Section 4: Écoute du Stream ---
              Text('Événements d\'accessibilité', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              StreamBuilder<String>(
                stream: Caller.accessStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: Text("En attente d'événements..."));
                  if (snapshot.hasError) return Center(child: Text('Erreur: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                  if (snapshot.hasData) return Text('Dernier événement reçu :\n${snapshot.data}', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.green.shade800));
                  return const Text('Aucun événement reçu pour le moment.');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
