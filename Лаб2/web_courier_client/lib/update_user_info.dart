import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class UpdateUserInfo extends StatefulWidget {
  final String uid;

  UpdateUserInfo({required this.uid});

  @override
  _UpdateUserInfoState createState() => _UpdateUserInfoState();
}

class _UpdateUserInfoState extends State<UpdateUserInfo> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  File? _photo;
  String _statusMessage = '';

  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update User Info')),
      body: Column(
        children: [
          TextField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
          ),
          TextField(
            controller: _addressController,
            decoration: InputDecoration(labelText: 'Address'),
          ),
          ElevatedButton(
            onPressed: _pickImage,
            child: Text('Choose Photo'),
          ),
          _photo != null ? Image.file(_photo!) : Container(),
          ElevatedButton(
            onPressed: _updateUserInfo,
            child: Text('Update Info'),
          ),
          Text(_statusMessage),  // Display the status message
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _photo = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateUserInfo() async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.0.2.2:8000/api/client/update/'),
    );
    request.fields['uid'] = widget.uid;
    request.fields['email'] = _emailController.text;
    request.fields['address'] = _addressController.text;
    if (_photo != null) {
      request.files.add(await http.MultipartFile.fromPath('photo', _photo!.path));
    }

    var response = await request.send();
    if (response.statusCode == 200) {
      setState(() {
        _statusMessage = 'Successfully updated';
      });
    } else {
      setState(() {
        _statusMessage = 'Failed to update: ${response.reasonPhrase}';
      });
    }
  }
}