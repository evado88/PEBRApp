import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pebrapp/components/PEBRAButtonFlat.dart';
import 'package:pebrapp/components/PopupScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:pebrapp/config/PebraCloudConfig.dart';

class R21Facility {
  final int facility_id;
  final String facility_name;
  final String facility_address;
  final String facility_whatsapp;
  final String facility_website;

  const R21Facility({
    this.facility_id,
    this.facility_name,
    this.facility_address,
    this.facility_whatsapp,
    this.facility_website,
  });

  factory R21Facility.fromJson(Map<String, dynamic> json) {
    return R21Facility(
      facility_id: json['facility_id'] as int,
      facility_name: json['facility_name'] as String,
      facility_address: json['facility_address'] as String,
      facility_website: json['facility_website'] as String,
      facility_whatsapp: json['facility_whatsapp'] as String,
    );
  }
}

class R21ChooseFacilityScreen extends StatefulWidget {
  @override
  createState() => _R21ChooseFacilityScreenState();
}

class _R21ChooseFacilityScreenState extends State<R21ChooseFacilityScreen> {
  List<R21Facility> photos = [];

  Future<List<R21Facility>> fetchPhotos(http.Client client) async {
    final response = await client
        .get(Uri.parse('$PEBRA_CLOUD_API/facility/list'));

    // Use the compute function to run parsePhotos in a separate isolate.
    return parsePhotos(response.body);
  }

// A function that converts a response body into a List<Photo>.
  List<R21Facility> parsePhotos(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

    return parsed.map<R21Facility>((json) => R21Facility.fromJson(json)).toList();
  }

  getPhotos() async {
    List<R21Facility> pics = await fetchPhotos(http.Client());

    setState(() {
      photos = pics;
    });
  }

  @override
  void initState() {
    super.initState();
    getPhotos();
/*
    Photo photo = Photo(
        facility_id: 1,
        id: 2,
        title: 'accusamus beatae ad facilis cum similique qui sunt',
        url: 'https://via.placeholder.com/600/92c952',
        thumbnailUrl: 'https://via.placeholder.com/150/92c95');

    photos.add(photo);*/
  }

  @override
  Widget build(BuildContext context) {
    return PopupScreen(
      title: 'Choose Facility',
      child: Expanded(
        child: SizedBox(
          height: 500.0,
          child: new ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: photos.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(photos[index].facility_name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    )),
                subtitle: Text(photos[index].facility_address),
                leading: Icon(
                  Icons.local_hospital,
                  color: Colors.purple,
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(),
          ),
        ),
      ),
    );
  }
}
