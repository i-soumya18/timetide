import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AvatarPicker extends StatelessWidget {
  final String? avatarUrl;
  final File? avatarFile;
  final VoidCallback onPickImage;

  const AvatarPicker({
    super.key,
    this.avatarUrl,
    this.avatarFile,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPickImage,
      child: CircleAvatar(
        radius: 50,
        backgroundColor: const Color(0xFF8ECAE6),
        child: avatarFile != null
            ? ClipOval(
          child: Image.file(
            avatarFile!,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        )
            : avatarUrl != null
            ? ClipOval(
          child: CachedNetworkImage(
            imageUrl: avatarUrl!,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
            const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(
              Icons.person,
              size: 50,
              color: Colors.white,
            ),
          ),
        )
            : const Icon(
          Icons.person,
          size: 50,
          color: Colors.white,
        ),
      ),
    );
  }
}