import 'dart:io';

import 'package:contact_list/mode/contact.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactCarTemplate {
  Contact contact;
  BuildContext context;
  int index;

  ContactCarTemplate(this.context, this.contact, this.index);

  Widget getContactCard({Function function, Function deletContact}) =>
      GestureDetector(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: <Widget>[
                _userImage(),
                _userData(),
              ],
            ),
          ),
        ),
        onTap: () {
          _showOptions(function: function, deleContact: deletContact);
        },
      );

  void _showOptions({Function function, Function deleContact}) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
          onClosing: () {},
          builder: (context) {
            return Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: FlatButton(
                      child: Text(
                        "Ligar",
                        style:
                            TextStyle(color: Colors.redAccent, fontSize: 18.0),
                      ),
                      onPressed: () {
                        launch("tel:${contact.phone}");
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: FlatButton(
                      child: Text(
                        "Editar",
                        style:
                            TextStyle(color: Colors.redAccent, fontSize: 18.0),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        function();
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: FlatButton(
                      child: Text(
                        "Excluir",
                        style:
                            TextStyle(color: Colors.redAccent, fontSize: 18.0),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (context) {
                            return _dialogLeaveConfirmation(
                                context, deleContact);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _dialogLeaveConfirmation(
          BuildContext context, Function deletContact) =>
      AlertDialog(
        title: Text("Remove contact from the list!"),
        content: Text(
            "Do you realy want do delet ${contact.name} from you contac list?"),
        actions: <Widget>[
          FlatButton(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          FlatButton(
            child: Text(
              "Ok",
              style: TextStyle(color: Colors.redAccent),
            ),
            onPressed: () {
              Navigator.pop(context);
              deletContact();
            },
          ),
        ],
      );

  _userData() => Padding(
        padding: EdgeInsets.only(left: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              contact.name ?? "",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            Text(
              contact.email ?? "",
              style: TextStyle(fontSize: 16.0),
            ),
            Text(
              contact.phone ?? "",
              style: TextStyle(fontSize: 14.0),
            ),
          ],
        ),
      );

  Widget _userImage() {
    return Container(
      height: 80,
      width: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: contact.img != null
              ? FileImage(File(contact.img))
              : AssetImage("images/person.png"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
