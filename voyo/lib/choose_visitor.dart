import 'dart:async';

import 'package:flutter/material.dart';
import 'pay.dart';
import 'globals.dart' as AppGlobal;
import "availibility.dart";
import 'profile.dart';

// ignore: must_be_immutable
class VisitePage extends StatefulWidget {
  VisitePage({
    Key? key,
    required this.title,
    required this.idVisitor,
    required this.houseType,
  }) : super(key: key);

  final String title;
  final int idVisitor;
  String houseType;

  @override
  State<VisitePage> createState() => _VisitePageState();
}

class _VisitePageState extends State<VisitePage> {
  String? selectedHousingType;
  List<String> items = [];
  List<TextEditingController> pointToCheck = [TextEditingController()];
  TextEditingController villeController = TextEditingController();
  TextEditingController rueController = TextEditingController();
  TextEditingController CPController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String? visitorName = "";
  String? visitorSurname = "";
  String? visitorCity = "";
  String? visitorHoulyRate = "";
  String? visitorCost = "";
  String? visitorPrice = "";
  int? visitorRating = 0;
  String imageUrl = "";

  bool isInvalid = false;
  int idDemande = -1;

  @override
  void initState() {
    super.initState();
    selectedHousingType = widget.houseType;
    fetchVisitors(selectedHousingType!);
    AppGlobal.fetchData('${AppGlobal.UrlServer}House/GetTypeHouse')
        .then((List<dynamic>? jsonData) {
      if (jsonData != null) {
        List<String> stringArray = jsonData.cast<String>();
        setState(() {
          items = stringArray;
        });
      }
    }).catchError((error) {
      print('$error');
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> fetchVisitors(String selectedOption) async {
    try {
      final Map<String, dynamic>? jsonData = await AppGlobal.fetchDataMap(
          '${AppGlobal.UrlServer}Visitor/GetVisitorById?id=${widget.idVisitor}&typeHouse=$selectedHousingType');
      if (jsonData != null) {
        setState(() {
          visitorSurname = jsonData['User']['FirstName'];
          visitorName = jsonData['User']['Name'];
          visitorCity = jsonData['User']['City'];
          imageUrl = jsonData['User']['ProfilPicture'];
          visitorHoulyRate = jsonData['HourlyRate'].toString();
          visitorCost = jsonData['Cost'].toString();
          visitorPrice = jsonData['Price'].toString();
          visitorRating = jsonData['Rating'];
          idDemande = jsonData['idDemande'];
        });
      }
    } catch (error) {
      print('Error fetching visitors: $error');
    }
  }

  Future<bool> SendDemandeVisit() async {
    if (villeController.text.isEmpty ||
        rueController.text.isEmpty ||
        CPController.text.isEmpty) {
      setState(() {
        isInvalid = true;
      });
      return false;
    }
    String concatenatedPTC = '';
    for (int i = 0; i < pointToCheck.length; i++) {
      if (i > 0) {
        concatenatedPTC += ',';
      }
      concatenatedPTC += pointToCheck[i].text;
    }
    var url =
        '${AppGlobal.UrlServer}visit/CreateDemande?housingType=$selectedHousingType&visitorId=${widget.idVisitor}&userId=${AppGlobal.idUser}&city=${villeController.text}&street=${rueController.text}&postalCode=${CPController.text}&points=${concatenatedPTC}';
    AppGlobal.fetchDataInt(url).then((int? idVisit) {
      if (idVisit != null) {
        idDemande = idVisit;
        if (idDemande != -1) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PayPage(title: 'Pay', idDemande: idDemande),
            ),          );
        }
      }
    });
    setState(() {
      isInvalid = false;
    });
    
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return AppGlobal.Menu(
      SingleChildScrollView(
        child: Column(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButtonFormField(
                    value: selectedHousingType,
                    decoration: InputDecoration(
                      hintText: 'Type de logement',
                      filled: true,
                      fillColor: AppGlobal.buttonback,
                    ),
                    dropdownColor: Colors.amber,
                    items: items.map((item) {
                      return DropdownMenuItem(value: item, child: Text(item));
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedHousingType = newValue;
                      });
                      fetchVisitors(newValue!);
                    },
                  ),
                ),
                if (isInvalid)
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Veuiller compléter les champs adresses',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: villeController,
                          textAlign: TextAlign.left,
                          decoration: InputDecoration(
                            hintText: "Ville",
                            filled: true,
                            fillColor: AppGlobal.buttonback,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: rueController,
                          textAlign: TextAlign.left,
                          decoration: InputDecoration(
                            hintText: "Rue",
                            filled: true,
                            fillColor: AppGlobal.buttonback,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: CPController,
                          textAlign: TextAlign.left,
                          decoration: InputDecoration(
                            hintText: "code postale",
                            filled: true,
                            fillColor: AppGlobal.buttonback,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: AppGlobal.secondaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onPressed: () => _selectDate(context),
                      child: Text(
                        "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(width: 20.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: AppGlobal.secondaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onPressed: () => _selectTime(context),
                      child: Text(
                        translateTime(selectedTime, "h"),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
                Visitor(context, widget.idVisitor, visitorName, visitorSurname,
                    visitorCity, visitorHoulyRate, visitorCost, visitorPrice,
                    visitorRating, imageUrl),
                for (TextEditingController point in pointToCheck)
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: TextFormField(
                            controller: point,
                            textAlign: TextAlign.left,
                            decoration: InputDecoration(
                              hintText: "ex: WC séparé",
                              filled: true,
                              fillColor: AppGlobal.buttonback,
                            ),
                          ),
                        ),
                        Visibility(
                            visible: true,
                            child: IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                setState(() {
                                  pointToCheck.remove(point);
                                });
                              },
                            ))
                      ],
                    ),
                  ),
                Container(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        child: FloatingActionButton(
                          backgroundColor: AppGlobal.secondaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          onPressed: () {
                            setState(() {
                              pointToCheck.add(TextEditingController());
                            });
                          },
                          child: const Text(
                            "+",
                            style: TextStyle(
                              fontSize: 25.0,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8, right: 8),
                          child: FloatingActionButton(
                            backgroundColor: AppGlobal.secondaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            onPressed: () {
                              SendDemandeVisit();
                            },
                            child: const Expanded(
                              child: Text(
                                "Valider et payer",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
      widget,
      context,
    );
  }
}

Padding Visitor(context, id, name, surname, city, rate, cost, price, star,
    imageUrl) =>
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: Expanded(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppGlobal.inputColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: Row(
            children: [
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.all(8.0),
                height: 100,
                width: 100,
                color: AppGlobal.subInputColor,
                child: Image.network(
                    "${AppGlobal.UrlServer}image/$imageUrl",
                    width: 100,
                    height: 100,
                    errorBuilder: (context, error, stackTrace) =>
                        Image.asset("assets/images/placeholder.webp",
                            width: 100, height: 100)),
              ),
              Expanded(
                flex: 8,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    direction: Axis.vertical,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        surname,
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        city,
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        rate + "€/h",
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      AppGlobal.etoile(star, 20, 50)
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    alignment: Alignment.center,
                    height: 100,
                    width: 100,
                    child: Text(price + "€",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black,
                        )),
                  ),
                ),
              ),
            ],
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProfilePage(
                    title: 'Profile',
                    idUser: id,
                  )),
            );
          },
        ),
      ),
    );
