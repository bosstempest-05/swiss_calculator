import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class VaultGallery extends StatefulWidget {
  const VaultGallery({super.key});

  @override
  State<VaultGallery> createState() => _VaultGalleryState();
}

class _VaultGalleryState extends State<VaultGallery> {
  List<File> _hiddenImages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHiddenImages();
  }

  // Looks inside the app's secret sandbox directory for saved photos
  Future<void> _loadHiddenImages() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      // We look for a specific folder we create for vault images
      final vaultDir = Directory('${directory.path}/vault_images');

      if (!await vaultDir.exists()) {
        await vaultDir.create();
      }

      final List<FileSystemEntity> files = vaultDir.listSync();

      setState(() {
        // Filter out anything that isn't a file (like sub-directories)
        _hiddenImages = files.whereType<File>().toList();
        // Sort them so the newest ones show up first
        _hiddenImages.sort(
          (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Error loading images: $e");
    }
  }

  // Opens the public gallery, copies the chosen photo to the vault
  Future<void> _importPhoto() async {
    final ImagePicker picker = ImagePicker();
    // Pick an image from the public gallery
    final XFile? publicImage = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (publicImage != null) {
      setState(() => _isLoading = true);

      final directory = await getApplicationDocumentsDirectory();
      final vaultDir = Directory('${directory.path}/vault_images');

      // Create a unique file name using the current timestamp
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File newHiddenImage = File('${vaultDir.path}/$fileName');

      // Copy the public image into the secret vault directory
      await File(publicImage.path).copy(newHiddenImage.path);

      // Reload the grid to show the new image
      await _loadHiddenImages();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Imported! Remember to delete the original from your main gallery.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.teal,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  // Delete a photo from the vault
  Future<void> _deletePhoto(File imageFile) async {
    await imageFile.delete();
    _loadHiddenImages();
  }

  void _viewFullscreen(File imageFile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          // We keep the fullscreen viewer strictly black for the best photo viewing experience!
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () {
                  Navigator.pop(context);
                  _deletePhoto(imageFile);
                },
              ),
            ],
          ),
          body: Center(
            child: InteractiveViewer(
              // Allows you to pinch and zoom the photo!
              child: Image.file(imageFile),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ---> NEW: Adaptive theme colors for the gallery dashboard <---
    bool isLightMode = Theme.of(context).brightness == Brightness.light;
    Color adaptiveBgColor = isLightMode
        ? Colors.grey[100]!
        : const Color(0xFF0A0A0A);
    Color adaptiveTextColor = isLightMode ? Colors.black87 : Colors.white;

    return Scaffold(
      backgroundColor: adaptiveBgColor,
      appBar: AppBar(
        title: Text(
          'Private Gallery',
          style: TextStyle(color: adaptiveTextColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: adaptiveTextColor),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.pinkAccent),
            )
          : _hiddenImages.isEmpty
          ? const Center(
              child: Text(
                'No hidden photos yet.\nTap + to import.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 18),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _hiddenImages.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _viewFullscreen(_hiddenImages[index]),
                  child: Hero(
                    tag: _hiddenImages[index].path,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _hiddenImages[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _importPhoto,
        backgroundColor: Colors.pinkAccent,
        icon: const Icon(Icons.add_photo_alternate, color: Colors.white),
        label: const Text(
          'IMPORT',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
