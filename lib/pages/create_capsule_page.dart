import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/capsule_provider.dart';

class CreateCapsulePage extends StatefulWidget {
  const CreateCapsulePage({super.key});

  @override
  State<CreateCapsulePage> createState() => _CreateCapsulePageState();
}

class _CreateCapsulePageState extends State<CreateCapsulePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  
  File? _selectedImage;
  bool _isUploading = false;

  // --- 1. La fonction de sécurité pour le GPS ---
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test si le GPS est activé
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Le service de localisation est désactivé. Activez le GPS.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('La permission de localisation a été refusée.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Les permissions sont définitivement refusées. Allez dans les paramètres pour autoriser.');
    }

    return await Geolocator.getCurrentPosition();
  }

  // --- 2. Choisir une image ---
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    // imageQuality: 50 permet de réduire la taille du fichier pour l'upload
    final pickedFile = await picker.pickImage(source: source, imageQuality: 50);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // --- 3. Envoyer le formulaire ---
  Future<void> _submitCapsule() async {
    if (!_formKey.currentState!.validate() || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tout et ajouter une photo !')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      // ÉTAPE CRUCIALE : On demande la permission AVANT de récupérer la position
      Position position = await _determinePosition();

      // Envoi au backend via le Provider
      await Provider.of<CapsuleProvider>(context, listen: false).addCapsule(
        title: _titleController.text,
        description: _descController.text,
        imageFile: _selectedImage!,
        lat: position.latitude,
        long: position.longitude,
      );

      if (mounted) {
        Navigator.pop(context); // Retour à l'accueil
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Capsule enterrée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enterrer une Capsule')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Zone de l'image
              GestureDetector(
                onTap: () => _pickImage(ImageSource.camera), 
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                    image: _selectedImage != null
                        ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: _selectedImage == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                            Text("Appuyer pour prendre une photo"),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 20),

              // Champs texte
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre du souvenir',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Titre requis' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description (optionnel)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 30),

              // Bouton d'envoi
              _isUploading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _submitCapsule,
                      icon: const Icon(Icons.save),
                      label: const Text("Enterrer la Capsule"),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}