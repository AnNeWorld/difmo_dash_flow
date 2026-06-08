import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dashflow/core/api/api_provider.dart';

const kGoogleApiKey = "AIzaSyClF12i0eHy7Nrig6EYu8Z4U5DA2zC09OI";

class LocationConfirmPage extends ConsumerStatefulWidget {
  final bool isCheckIn;
  final String? employeeId;
  final String? attendanceId;
  const LocationConfirmPage({
    super.key,
    required this.isCheckIn,
    this.employeeId,
    this.attendanceId,
  });

  @override
  ConsumerState<LocationConfirmPage> createState() =>
      _LocationConfirmPageState();
}

class _LocationConfirmPageState extends ConsumerState<LocationConfirmPage> {
  GoogleMapController? mapController;
  LatLng? currentPosition;
  String address = "Fetching address...";
  double accuracy = 0.0;
  final TextEditingController _searchController = TextEditingController();
  bool isWorkFromHome = false;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  @override
  void dispose() {
    mapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    if (!mounted) return;

    setState(() {
      currentPosition = LatLng(position.latitude, position.longitude);
      accuracy = position.accuracy;
    });

    await _getAddressFromLatLng(position);
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      Placemark place = placemarks[0];
      if (!mounted) return;
      setState(() {
        address =
            "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}";
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        address = "Address not found";
      });
    }
  }

  void _refreshLocation() {
    _determinePosition();
  }

  Future<void> _confirmLocation() async {
    debugPrint(
      "DEBUG: Confirm clicked. isCheckIn: ${widget.isCheckIn}, EmployeeID: ${widget.employeeId}, AttendanceID: ${widget.attendanceId}",
    );

    if (currentPosition == null) {
      debugPrint("DEBUG: currentPosition is null");
      return;
    }

    if (widget.isCheckIn) {
      if (widget.employeeId == null) {
        debugPrint("DEBUG: EmployeeID is null");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: Employee ID not found")),
        );
        return;
      }
      debugPrint("DEBUG: Calling checkIn...");
      await ref
          .read(locationActionProvider.notifier)
          .checkIn(
            widget.employeeId!,
            currentPosition!.latitude,
            currentPosition!.longitude,
            address,
            "",
            isWorkFromHome: isWorkFromHome,
          );
      debugPrint("DEBUG: checkIn called");
    } else {
      if (widget.attendanceId == null) {
        debugPrint("DEBUG: AttendanceID is null");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: Attendance ID not found")),
        );
        return;
      }
      debugPrint("DEBUG: Calling checkOut...");
      await ref
          .read(locationActionProvider.notifier)
          .checkOut(
            widget.attendanceId!,
            currentPosition!.latitude,
            currentPosition!.longitude,
            "",
          );
      debugPrint("DEBUG: checkOut called");
    }
  }

  Future<void> _handleSearch() async {
    final TextEditingController searchCtrl = TextEditingController();
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => _PlacesSearchDialog(
        apiKey: kGoogleApiKey,
        searchController: searchCtrl,
      ),
    );

    if (result != null && mounted) {
      final lat = (result['lat'] as num).toDouble();
      final lng = (result['lng'] as num).toDouble();
      setState(() {
        currentPosition = LatLng(lat, lng);
        address = result['address'] as String? ?? 'No address found';
      });
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(lat, lng), zoom: 16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ApiState>(locationActionProvider, (previous, next) {
      if (next.status == ApiStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  next.message ?? "Success",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context, true);
      } else if (next.status == ApiStatus.error) {
        String msg = next.message ?? "An error occurred";
        if (msg.toLowerCase().contains("already checked in")) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    "You are already checked in for today.",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              backgroundColor: Colors.blue.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          Navigator.pop(context, true);
        } else if (msg.toLowerCase().contains("socketexception") ||
            msg.toLowerCase().contains("failed host lookup") ||
            msg.toLowerCase().contains("network error")) {
          _showErrorDialog(
            context,
            "No internet connection. Please check your network and try again.",
          );
        } else {
          _showErrorDialog(context, msg);
        }
      }
    });

    final apiState = ref.watch(locationActionProvider);
    final isLoading = apiState.status == ApiStatus.loading;

    return Scaffold(
      body: Stack(
        children: [
          currentPosition == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: currentPosition!,
                    zoom: 15,
                  ),
                  zoomGesturesEnabled: true,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  onMapCreated: (controller) => mapController = controller,
                ),

          SafeArea(
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: _handleSearch,
                      child: AbsorbPointer(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: "Search location",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Confirm Address",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Accurate to ${accuracy.toStringAsFixed(1)} m",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(address, style: const TextStyle(fontSize: 14)),
                  if (widget.isCheckIn) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.home_work_rounded, color: Color(0xFF2C5282), size: 20),
                            SizedBox(width: 8),
                            Text(
                              "Work From Home",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: isWorkFromHome,
                          activeTrackColor: const Color(0xFF2C5282).withValues(alpha: 0.5),
                          activeThumbColor: const Color(0xFF2C5282),
                          onChanged: (val) {
                            setState(() {
                              isWorkFromHome = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: isLoading ? null : _refreshLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        child: const Text("Refresh"),
                      ),
                      ElevatedButton(
                        onPressed: isLoading ? null : _confirmLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text("Confirm"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String rawMessage) {
    String displayMessage = rawMessage;
    String cleanStr = rawMessage
        .replaceAll("Exception: Check-in failed: ", "")
        .replaceAll("Exception: Check-out failed: ", "")
        .replaceAll("Exception: ", "");

    try {
      if (cleanStr.trim().startsWith("{")) {
        final Map<String, dynamic> errorJson = jsonDecode(cleanStr);
        if (errorJson.containsKey('message')) {
          displayMessage = errorJson['message'];
        }
      } else {
        displayMessage = cleanStr;
      }
    } catch (_) {
      displayMessage = cleanStr;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.location_off,
              color: Theme.of(context).primaryColor,
              size: 28,
            ),
            const SizedBox(width: 10),
            const Text("Location Alert"),
          ],
        ),
        content: Text(displayMessage, style: const TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              "OK",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlacesSearchDialog extends StatefulWidget {
  final String apiKey;
  final TextEditingController searchController;

  const _PlacesSearchDialog({
    required this.apiKey,
    required this.searchController,
  });

  @override
  State<_PlacesSearchDialog> createState() => _PlacesSearchDialogState();
}

class _PlacesSearchDialogState extends State<_PlacesSearchDialog> {
  List<dynamic> _predictions = [];
  bool _isLoading = false;

  Future<void> _fetchPredictions(String input) async {
    if (input.isEmpty) {
      setState(() => _predictions = []);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=${Uri.encodeComponent(input)}'
        '&key=${widget.apiKey}'
        '&language=en'
        '&components=country:in',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _predictions = data['predictions'] ?? [];
        });
      }
    } catch (_) {
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<Map<String, dynamic>?> _getPlaceDetails(String placeId) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json'
      '?place_id=$placeId'
      '&key=${widget.apiKey}'
      '&fields=geometry,formatted_address',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final result = data['result'];
      if (result != null) {
        return {
          'lat': result['geometry']['location']['lat'],
          'lng': result['geometry']['location']['lng'],
          'address': result['formatted_address'],
        };
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Search Location'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: widget.searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Type a location...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _fetchPredictions,
            ),
            const SizedBox(height: 8),
            if (_isLoading) const LinearProgressIndicator(),
            if (_predictions.isNotEmpty)
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _predictions.length,
                  itemBuilder: (ctx, i) {
                    final p = _predictions[i];
                    return ListTile(
                      leading: const Icon(Icons.location_on_outlined),
                      title: Text(
                        p['description'] ?? '',
                        style: const TextStyle(fontSize: 13),
                      ),
                      onTap: () async {
                        final details = await _getPlaceDetails(
                          p['place_id'] ?? '',
                        );
                        if (context.mounted) {
                          Navigator.of(context).pop(details);
                        }
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
