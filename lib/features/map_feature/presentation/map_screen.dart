import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:recycleorigindriver/core/models/region.dart';
import 'package:recycleorigindriver/core/models/request/address.dart';
import 'package:recycleorigindriver/core/theme/app_theme.dart';
import 'package:recycleorigindriver/core/widgets/info_edit_item.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

/// Add-address screen using OpenStreetMap tiles ([flutter_map]), same stack as
/// the admin panel (no Google Maps SDK / API key).
class MapScreen extends StatefulWidget {
  static const routeName = '/mapScreen';

  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
  static final LatLng _defaultCenter = LatLng(38.074065, 46.312711);

  bool _isInit = true;
  var _isLoading;

  final MapController _mapController = MapController();

  LatLng _selectedPosition = _defaultCenter;

  final nameController = TextEditingController();
  final addressController = TextEditingController();

  List<Address> addressList = [];

  dynamic regionValue;
  List<String> regionValueList = [];
  List<Region> regionList = [];
  late Region selectedRegion;

  late FocusNode nameNode;
  late FocusNode regionNode;
  late FocusNode addressNode;

  bool _myLocationButtonVisible = false;

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      await retrieveRegions();
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> _refreshLocationPermission() async {
    var allow = false;
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.unableToDetermine) {
        perm = await Geolocator.requestPermission();
      }
      allow = perm == LocationPermission.whileInUse ||
          perm == LocationPermission.always;
    } catch (e, st) {
      debugPrint('_refreshLocationPermission: $e\n$st');
      allow = false;
    }
    if (!mounted) {
      return;
    }
    setState(() => _myLocationButtonVisible = allow);
  }

  Future<void> _centerOnDeviceLocation() async {
    await _refreshLocationPermission();
    if (!_myLocationButtonVisible || !mounted) {
      return;
    }
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(const Duration(seconds: 8));
      if (!mounted) {
        return;
      }
      final here = LatLng(pos.latitude, pos.longitude);
      setState(() => _selectedPosition = here);
      _mapController.move(here, 15);
    } catch (e) {
      debugPrint('_centerOnDeviceLocation: $e');
    }
  }

  void _onMapTap(LatLng point) {
    setState(() => _selectedPosition = point);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    nameNode = FocusNode();
    regionNode = FocusNode();
    addressNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          _refreshLocationPermission();
        }
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshLocationPermission();
    }
  }

  Future<void> saveAddress() async {
    setState(() {
      _isLoading = true;
    });
    await context.read<AuthBloc>().getAddresses();

    addressList = context.read<AuthBloc>().state.addressItems;

    addressList.add(Address(
      name: nameController.text,
      address: addressController.text,
      region:
          Region(term_id: selectedRegion.term_id, name: '', collect_hour: []),
      latitude: _selectedPosition.latitude.toString(),
      longitude: _selectedPosition.longitude.toString(),
    ));

    await context.read<AuthBloc>().updateAddress(addressList);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> retrieveRegions() async {
    setState(() {
      _isLoading = true;
    });
    await context.read<AuthBloc>().retrieveRegionList();

    regionList = context.read<AuthBloc>().state.regionItems;
    for (int i = 0; i < regionList.length; i++) {
      regionValueList.add(regionList[i].name);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _openOsmCopyright() async {
    final uri = Uri.parse('https://www.openstreetmap.org/copyright');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mapController.dispose();
    nameController.dispose();
    addressController.dispose();

    nameNode.dispose();
    regionNode.dispose();
    addressNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.sizeOf(context).height;
    final deviceWidth = MediaQuery.sizeOf(context).width;
    final textScaleFactor = MediaQuery.textScalerOf(context).scale(1);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.newAddressLabel,
          style: const TextStyle(),
        ),
        backgroundColor: AppTheme.appBarColor,
        iconTheme: const IconThemeData(color: AppTheme.appBarIconColor),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: deviceHeight * 0.4,
              child: Card(
                clipBehavior: Clip.antiAlias,
                margin: const EdgeInsets.all(8),
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _selectedPosition,
                        initialZoom: 12,
                        onTap: (TapPosition _, LatLng point) =>
                            _onMapTap(point),
                        onLongPress: (TapPosition _, LatLng point) =>
                            _onMapTap(point),
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all,
                        ),
                        onMapReady: () {
                          Future<void>.delayed(
                            const Duration(milliseconds: 100),
                            () {
                              if (mounted) {
                                _refreshLocationPermission();
                              }
                            },
                          );
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName:
                              'com.recycleorigin.recycleorigindriver',
                          maxNativeZoom: 19,
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _selectedPosition,
                              width: 44,
                              height: 44,
                              alignment: Alignment.bottomCenter,
                              child: Icon(
                                Icons.location_on_rounded,
                                size: 44,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                        SimpleAttributionWidget(
                          source: Text(
                            context.l10n.openStreetMapAttributionShort,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 11,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          onTap: _openOsmCopyright,
                        ),
                      ],
                    ),
                    if (_myLocationButtonVisible)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Material(
                          color: Colors.white,
                          elevation: 2,
                          shape: const CircleBorder(),
                          child: IconButton(
                            tooltip: context.l10n.mapScreenMyLocation,
                            icon: Icon(
                              Icons.my_location_rounded,
                              color: AppTheme.primary,
                            ),
                            onPressed: _centerOnDeviceLocation,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            InfoEditItem(
              title: context.l10n.addressNameLabel,
              controller: nameController,
              bgColor: AppTheme.bg,
              iconColor: const Color(0xffA67FEC),
              keybordType: TextInputType.text,
              fieldHeight: deviceHeight * 0.06,
              thisFocusNode: nameNode,
              newFocusNode: regionNode,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: SizedBox(
                width: deviceWidth * 0.78,
                child: Text(
                  context.l10n.areasLabel,
                  style: TextStyle(
                    color: AppTheme.h1,
                    fontSize: textScaleFactor * 14.0,
                  ),
                ),
              ),
            ),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  width: deviceWidth * 0.78,
                  height: deviceHeight * 0.05,
                  alignment: Alignment.centerRight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: AppTheme.white,
                    border: Border.all(color: AppTheme.h1, width: 0.6),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.only(right: 8.0, left: 8, top: 6),
                    child: DropdownButton<String>(
                      hint: Text(
                        context.l10n.selectAreaMessage,
                        style: TextStyle(
                          color: AppTheme.grey,
                          fontSize: textScaleFactor * 13.0,
                        ),
                      ),
                      value: regionValue as String?,
                      focusNode: regionNode,
                      icon: Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Icon(
                          Icons.arrow_drop_down,
                          color: AppTheme.black,
                          size: 20,
                        ),
                      ),
                      dropdownColor: AppTheme.white,
                      style: TextStyle(
                        color: AppTheme.black,
                        fontSize: textScaleFactor * 13.0,
                      ),
                      isDense: true,
                      onChanged: (String? newValue) {
                        setState(() {
                          regionValue = newValue;
                          selectedRegion = regionList[
                              regionValueList.lastIndexOf(newValue!)];
                          FocusScope.of(context).requestFocus(addressNode);
                        });
                      },
                      items: regionValueList
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 3.0),
                              child: Text(
                                value,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppTheme.black,
                                  fontSize: textScaleFactor * 13.0,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
            InfoEditItem(
              title: context.l10n.addressLabel,
              controller: addressController,
              bgColor: AppTheme.bg,
              iconColor: const Color(0xffA67FEC),
              keybordType: TextInputType.text,
              fieldHeight: deviceHeight * 0.2,
              maxLine: 10,
              thisFocusNode: addressNode,
              newFocusNode: FocusNode(),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          onPressed: () async {
            await saveAddress();
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          backgroundColor: AppTheme.primary,
          child: Icon(
            Icons.check,
            color: AppTheme.white,
          ),
        ),
      ),
    );
  }
}
