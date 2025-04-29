import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class KYCIdProof extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function(String, dynamic) updateData;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const KYCIdProof({
    Key? key,
    required this.data,
    required this.updateData,
    required this.onNext,
    required this.onBack,
  }) : super(key: key);

  @override
  _KYCIdProofState createState() => _KYCIdProofState();
}

class _KYCIdProofState extends State<KYCIdProof> {
  String? _idProofFileError;

  Future<void> _pickIdProofFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileSize = await file.length();
        if (fileSize > 100 * 1024) {
          // File size exceeds 100KB
          setState(() {
            _idProofFileError = 'File size exceeds 100KB';
            widget.updateData('idProofFile', null);
          });
          return;
        }
        setState(() {
          _idProofFileError = null;
          widget.updateData('idProofFile', file);
        });
      } else {
        setState(() {
          _idProofFileError = 'No file selected';
          widget.updateData('idProofFile', null);
        });
      }
    } catch (e) {
      setState(() {
        _idProofFileError = 'Error selecting file: $e';
        widget.updateData('idProofFile', null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          const Text(
            'ID Proof Details',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // ID Proof Name Field
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'ID Proof Name',
              border: OutlineInputBorder(),
            ),
            initialValue: widget.data['idProofName'] ?? '',
            onChanged: (value) => widget.updateData('idProofName', value),
          ),
          const SizedBox(height: 16),

          // ID Proof Number Field
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'ID Proof Number',
              border: OutlineInputBorder(),
            ),
            initialValue: widget.data['idProofNumber'] ?? '',
            onChanged: (value) => widget.updateData('idProofNumber', value),
          ),
          const SizedBox(height: 16),

          // File Selection Row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _idProofFileError != null
                      ? Text(
                          _idProofFileError!,
                          style: const TextStyle(color: Colors.red),
                        )
                      : widget.data['idProofFile'] != null
                          ? Text(
                              widget.data['idProofFile'].path.split('/').last,
                              style: const TextStyle(color: Colors.black),
                            )
                          : const Text(
                              'No file chosen',
                              style: TextStyle(color: Colors.grey),
                            ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _pickIdProofFile,
                child: const Text('Upload'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Size Limitation Text
          const Text(
            'Image size < 100KB (JPG, JPEG, PNG)',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),

          // Displaying Image Preview
          if (widget.data['idProofFile'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    widget.data['idProofFile'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Text(
                          'Invalid image data',
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),

          // Navigation Buttons (Back and Next)
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onBack,
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.onNext,
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
