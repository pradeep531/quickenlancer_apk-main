import 'package:flutter/material.dart';

class KYCPersonalInfo extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function(String, dynamic) updateData;
  final VoidCallback onNext;

  const KYCPersonalInfo({
    Key? key,
    required this.data,
    required this.updateData,
    required this.onNext,
  }) : super(key: key);

  @override
  _KYCPersonalInfoState createState() => _KYCPersonalInfoState();
}

class _KYCPersonalInfoState extends State<KYCPersonalInfo> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...[
              'First Name',
              'Last Name',
              'Email',
              'Gender',
              'Mobile Number',
              'Country',
              'State',
              'City',
              'Address'
            ].map((label) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: label,
                    border: const OutlineInputBorder(),
                  ),
                  initialValue:
                      widget.data[label.toLowerCase().replaceAll(' ', '')],
                  onChanged: (value) {
                    widget.updateData(
                        label.toLowerCase().replaceAll(' ', ''), value);
                  },
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                  keyboardType: label == 'Email'
                      ? TextInputType.emailAddress
                      : label == 'Mobile Number'
                          ? TextInputType.phone
                          : null,
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  widget.onNext();
                }
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
