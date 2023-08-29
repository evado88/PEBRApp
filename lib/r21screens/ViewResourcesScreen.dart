import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pebrapp/components/PEBRAButtonFlat.dart';
import 'package:pebrapp/components/PopupScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:pebrapp/config/PebraCloudConfig.dart';

class R21Resource {
  final int resource_id;
  final String resource_name;
  final String resource_description;
  final String resource_url;
  final int resource_status;

  const R21Resource({
    this.resource_id,
    this.resource_name,
    this.resource_description,
    this.resource_url,
    this.resource_status,
  });

  factory R21Resource.fromJson(Map<String, dynamic> json) {
    return R21Resource(
      resource_id: json['resource_id'] as int,
      resource_name: json['resource_name'] as String,
      resource_description: json['resource_description'] as String,
      resource_status: json['resource_status'] as int,
      resource_url: json['resource_url'] as String,
    );
  }
}

class R21ViewResourcesScreen extends StatefulWidget {
  @override
  createState() => _R21ViewResourcesScreenState();
}

class _R21ViewResourcesScreenState extends State<R21ViewResourcesScreen> {
  List<R21Resource> photos = [];

  Future<List<R21Resource>> fetchPhotos(http.Client client) async {
    final response = await client
        .get(Uri.parse('$PEBRA_CLOUD_API/resource/list'));

    // Use the compute function to run parsePhotos in a separate isolate.
    return parsePhotos(response.body);
  }

// A function that converts a response body into a List<Photo>.
  List<R21Resource> parsePhotos(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

    return parsed.map<R21Resource>((json) => R21Resource.fromJson(json)).toList();
  }

  getPhotos() async {
    List<R21Resource> pics = await fetchPhotos(http.Client());

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
      title: 'View Resources',
      child: Expanded(
        child: SizedBox(
          height: 500.0,
          child: new ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: photos.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(photos[index].resource_name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    )),
                subtitle: Text(photos[index].resource_description),
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
