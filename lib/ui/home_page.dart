import 'package:contact_list/helpers/contac_helper.dart';
import 'package:contact_list/mode/contact.dart';
import 'package:contact_list/ui/template/contact_card_template.dart';
import 'package:flutter/material.dart';

import 'contact_form.dart';

enum OderOptions { orderAz, orderZa }

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Contact> contacts = List();
  ContactHelper contactHelp = ContactHelper();

  @override
  void initState() {
    super.initState();

    _getAllContacts();
  }

  void _getAllContacts() {
    contactHelp.getAllContacts().then((contactList) {
      setState(() {
        contacts = contactList;
      });
    });
  }

  void _showContactPage({Contact contact}) async {
    final recContact = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => ContactForm(contact: contact)));

    if (recContact != null) {
      _getAllContacts();
    }
  }

  void _deleteContactFromList(index) {
    setState(() {
      contactHelp.deleteContact(contacts[index].id);
      contacts.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      floatingActionButton: _addContactFAB(),
      body: _applicationBody(),
    );
  }

  Widget _applicationBody() => ListView.builder(
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        return ContactCarTemplate(context, contacts[index], index)
            .getContactCard(
                function: () => _showContactPage(contact: contacts[index]),
                deletContact: () => _deleteContactFromList(index));
      });

  Widget _addContactFAB() => FloatingActionButton(
        elevation: 15,
        child: Icon(Icons.add),
        backgroundColor: Colors.deepOrange,
        onPressed: _showContactPage,
      );

  Widget _appBar() => AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text("Contas"),
        actions: <Widget>[
          PopupMenuButton<OderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OderOptions>>[
                  const PopupMenuItem<OderOptions>(
                    child: Text("Ondenar de A-Z"),
                    value: OderOptions.orderAz,
                  ),
                  const PopupMenuItem<OderOptions>(
                    child: Text("Ondenar de Z-A"),
                    value: OderOptions.orderZa,
                  ),
                ],
            onSelected: _orderList,
          ),
        ],
      );

  void _orderList(OderOptions result) {
    switch (result) {
      case OderOptions.orderAz:
        contacts.sort((a, b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OderOptions.orderZa:
        contacts.sort((a, b) {
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
    }
    setState(() {});
  }
}
