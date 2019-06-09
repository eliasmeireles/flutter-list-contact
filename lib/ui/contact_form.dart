import 'dart:io';

import 'package:contact_list/helpers/contac_helper.dart';
import 'package:contact_list/mode/contact.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ContactForm extends StatefulWidget {
  Contact contact;

  ContactForm({this.contact});

  @override
  _ContactFormState createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  ContactHelper contactHelp = ContactHelper();
  var _contactHasChanged = false;
  final _contactNameController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();

  final _name = FocusNode();
  final _email = FocusNode();
  final _phone = FocusNode();

  var nameLabel = "";
  var emailLabel = "";
  var phoneLabel = "";

  Contact _editedContact;

  @override
  void initState() {
    super.initState();

    if (widget.contact == null) {
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact.toMap());
      _contactNameController.text = _editedContact.name;
      _contactEmailController.text = _editedContact.email;
      _contactPhoneController.text = _editedContact.phone;
    }
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
        child: Scaffold(
          appBar: _appBar(),
          floatingActionButton: _buttonApply(),
          body: _formContainer(),
        ),
        onWillPop: () {
          _requestPop();
        },
      );

  Widget _formContainer() => SingleChildScrollView(
        padding: EdgeInsets.only(left: 16.0, right: 16.0),
        child: Column(
          children: <Widget>[
            _userImage(),
            _contactTextFieldName(),
            _contactTextFieldEmail(),
            _contactTextFieldPhone(),
          ],
        ),
      );

  Widget _contactTextFieldName() => Column(
        children: <Widget>[
          TextField(
            decoration: InputDecoration(labelText: "Name"),
            controller: _contactNameController,
            focusNode: _name,
            onChanged: (text) {
              setState(() {
                _contactHasChanged = true;
                _editedContact.name = text;
              });
            },
          ),
          _validationLable(nameLabel),
        ],
      );

  Widget _contactTextFieldEmail() => Column(
        children: <Widget>[
          TextField(
            keyboardType: TextInputType.emailAddress,
            controller: _contactEmailController,
            focusNode: _email,
            decoration: InputDecoration(labelText: "Email"),
            onChanged: (text) {
              setState(() {
                _contactHasChanged = true;
                _editedContact.email = text;
              });
            },
          ),
          _validationLable(emailLabel),
        ],
      );

  Widget _contactTextFieldPhone() => Column(
        children: <Widget>[
          TextField(
            keyboardType: TextInputType.phone,
            controller: _contactPhoneController,
            focusNode: _phone,
            decoration: InputDecoration(labelText: "Phone"),
            onChanged: (text) {
              setState(() {
                _contactHasChanged = true;
                _editedContact.phone = text;
              });
            },
          ),
          _validationLable(phoneLabel),
        ],
      );

  Widget _validationLable(String message) => Container(
        padding: EdgeInsets.only(top: 8),
        alignment: Alignment.centerLeft,
        child: Text(
          message,
          style: TextStyle(color: Colors.redAccent),
          textAlign: TextAlign.left,
        ),
      );

  Widget _userImage() => GestureDetector(
      child: Container(
        height: 120,
        width: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: _editedContact.img != null
                ? FileImage(File(_editedContact.img))
                : AssetImage("images/person.png"),
            fit: BoxFit.cover,
          ),
        ),
      ),
      onTap: () {
        ImagePicker.pickImage(source: ImageSource.gallery).then((file) {
          if (file == null) return;
          setState(() {
            _editedContact.img = file.path;
          });
        });
      });

  Widget _buttonApply() => FloatingActionButton(
        child: Icon(Icons.save),
        backgroundColor: Colors.deepOrange,
        onPressed: () {
          setState(() {
            if (!_inputFieldHasError()) _saveContact();
          });
        },
      );

  bool _inputFieldHasError() {
    bool hasError = false;
    nameLabel = "";
    emailLabel = "";
    phoneLabel = "";

    if (_editedContact.name == null || _editedContact.name.isEmpty) {
      nameLabel = "Required field!";
      hasError = true;
      FocusScope.of(context).requestFocus(_name);
    }

    if (_editedContact.email == null || _editedContact.email.isEmpty) {
      emailLabel = "Required field!";

      if (!hasError) {
        FocusScope.of(context).requestFocus(_email);
      }

      hasError = true;
    }

    if (_editedContact.phone == null || _editedContact.phone.isEmpty) {
      phoneLabel = "Required field!";
      if (!hasError) {
        FocusScope.of(context).requestFocus(_phone);
      }
      hasError = true;
    }

    return hasError;
  }

  void _saveContact() async {
    final savedContact = _editedContact.id == null
        ? await contactHelp.saveContact(_editedContact)
        : contactHelp.updateContact(_editedContact);
    if (savedContact != null) {
      Navigator.pop(context, _editedContact);
    }
  }

  Widget _appBar() => AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text(_editedContact.name ?? "New Contact"),
      );

  Future<bool> _requestPop() {
    if (_contactHasChanged) {
      showDialog(
        context: context,
        builder: (context) {
          return _dialogLeaveConfirmation(context);
        },
      );
      return Future.value(false);
    } else {
      Navigator.pop(context);
      return Future.value(true);
    }
  }

  Widget _dialogLeaveConfirmation(BuildContext context) => AlertDialog(
        title: Text("Discard changes?"),
        content: Text("If you leave now, the changes will be lost!"),
        actions: <Widget>[
          FlatButton(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          FlatButton(
            child: Text(
              "Leave anyway.",
              style: TextStyle(color: Colors.redAccent),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ],
      );
}
