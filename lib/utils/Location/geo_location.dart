// import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';

// class LocationPage extends StatefulWidget {
//   const LocationPage({Key? key}) : super(key: key);

//   @override
//   State<LocationPage> createState() => _LocationPageState();
// }

// class _LocationPageState extends State<LocationPage> {
//   String? _currentAddress;
//   Position? _currentPosition;

//   Future<bool> _handleLocationPermission() async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//           content: Text(
//               'Location services are disabled. Please enable the services')));
//       return false;
//     }
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Location permissions are denied')));
//         return false;
//       }
//     }
//     if (permission == LocationPermission.deniedForever) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//           content: Text(
//               'Location permissions are permanently denied, we cannot request permissions.')));
//       return false;
//     }
//     return true;
//   }

//   Future<void> _getCurrentPosition() async {
//     final hasPermission = await _handleLocationPermission();

//     if (!hasPermission) return;
//     await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
//         .then((Position position) {
//       setState(() => _currentPosition = position);
//       _getAddressFromLatLng(_currentPosition!);
//     }).catchError((e) {
//       debugPrint(e);
//     });
//   }

//   Future<void> _getAddressFromLatLng(Position position) async {
//     await placemarkFromCoordinates(
//             _currentPosition!.latitude, _currentPosition!.longitude)
//         .then((List<Placemark> placemarks) {
//       Placemark place = placemarks[0];
//       setState(() {
//         _currentAddress =
//             '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
//       });
//     }).catchError((e) {
//       debugPrint(e);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Location Page")),
//       body: SafeArea(
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text('LAT: ${_currentPosition?.latitude ?? ""}'),
//               Text('LNG: ${_currentPosition?.longitude ?? ""}'),
//               Text('ADDRESS: ${_currentAddress ?? ""}'),
//               const SizedBox(height: 32),
//               ElevatedButton(
//                 onPressed: _getCurrentPosition,
//                 child: const Text("Get Current Location"),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


// // import 'package:flutter/material.dart';
// // import 'package:location/location.dart';
// // import 'package:geocoding/geocoding.dart';

// // void main() => runApp(const MyApp());

// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});

// //   // This widget is the root of your application.
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'SOS Buzzer',
// //       theme: ThemeData(
// //         primarySwatch: Colors.blue,
// //       ),
// //       home: MyHomePage(title: 'SOS Buzzer'),
// //     );
// //   }
// // }

// // class MyHomePage extends StatefulWidget {
// //   const MyHomePage({required Key key, required this.title}) : super(key: key);
// //   final String title;
// //   @override
// //   _MyHomePageState createState() => _MyHomePageState();
// // }

// // class _MyHomePageState extends State<MyHomePage> {
// //   _database() async {
// //     LocationData currentLocation;

// //     var location = new Location();
// //     try {
// //       currentLocation = await location.getLocation();

// //       double lat = currentLocation.latitude;
// //       double lng = currentLocation.longitude;
// //       // final response = await http.post(
// //       //     "http://192.168.1.107/sahyog/views/sahyogflutter/helper/demo/geocode.php",
// //       //     body: {
// //       //       "lat": lat.toString(),
// //       //       "lng": lng.toString(),
// //       //       "action": "geo_loc",
// //       //     });
// //       // Map<String, dynamic> _data = jsonDecode(response.body);
// //       final coordinates = new Coordinates(lat, lng);
// //       var addresses =
// //           await Geocoder.local.findAddressesFromCoordinates(coordinates);
// //       var first = addresses.first;
// //       print("${first.featureName} : ${first.addressLine}");
// //       _neverSatisfied(first);
// //     } catch (e) {
// //       print("error");
// //       print(e);
// //     }
// //   }

// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text("Send Alert"),
// //       ),
// //       body: bodyData(),
// //     );
// //   }

// //   Future<void> _neverSatisfied(var first) async {
// //     return showDialog<void>(
// //       context: context,
// //       barrierDismissible: false, // user must tap button!
// //       builder: (BuildContext context) {
// //         return AlertDialog(
// //           title: Text('Your Location'),
// //           content: SingleChildScrollView(
// //             child: ListBody(
// //               children: <Widget>[Text("${first.addressLine}")],
// //             ),
// //           ),
// //           actions: <Widget>[
// //             FlatButton(
// //               child: Text('Close'),
// //               onPressed: () {
// //                 Navigator.of(context).pop();
// //               },
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }

// //   Widget bodyData() => Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: <Widget>[
// //             Ink(
// //                 decoration: ShapeDecoration(
// //                   color: Colors.black,
// //                   shape: CircleBorder(),
// //                 ),
// //                 child: IconButton(
// //                   icon: Icon(
// //                     Icons.all_inclusive,
// //                     color: Colors.blueAccent,
// //                   ),
// //                   iconSize: 150.0,
// //                   splashColor: Colors.redAccent,
// //                   padding: EdgeInsets.all(40.0),
// //                   onPressed: () {
// //                     _database();
// //                   },
// //                 )),
// //             Padding(
// //               padding: EdgeInsets.all(25.0),
// //             ),
// //             Text(
// //               "Send Emergency Alert.",
// //               style: TextStyle(
// //                   color: Colors.black,
// //                   fontSize: 22.2,
// //                   fontWeight: FontWeight.bold),
// //             )
// //           ],
// //         ),
// //       );
// // }
