import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ev_charge_app/models/charging_station.dart';
import 'package:ev_charge_app/main.dart' show currentChargingSession;

class EvMapPage extends StatefulWidget {
  final List<ChargingStation> stations;
  final void Function(ChargingStation)? onStationTap;
  final String? userConnectorType; // e.g., 'GBT', 'CCS2', 'Type 2'
  final String? adapterType; // e.g., 'CCS2↔GBT', 'Tesla↔CCS2', null = none

  const EvMapPage({
    super.key,
    required this.stations,
    this.onStationTap,
    this.userConnectorType,
    this.adapterType,
  });
  @override
  _EvMapPageState createState() => _EvMapPageState();
}

class _EvMapPageState extends State<EvMapPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  final MapController _mapController = MapController();
  late LatLng _currentCenter;
  double _currentZoom = 12.0;
  Color _markerUnavailable = Colors.red;
  Color _markerAvailableCompatible = Colors.green;
  Color _markerAvailableIncompatible = Colors.blue;

  static const _kKeyMarkerUnavailable = 'map_marker_unavailable';
  static const _kKeyMarkerAvailableCompatible = 'map_marker_avail_compat';
  static const _kKeyMarkerAvailableIncompatible = 'map_marker_avail_incompat';
  LatLng? _myLocation;

  // Quick filter state
  bool _onlyAvailable = false;
  bool _quickFilterFast = false;
  bool _quickFilterSlow = false;
  final Set<String> _connectorFilters = <String>{};

  // Advanced filter state
  String _selectedRegion = 'All Markets';
  String? _selectedAcConnector;
  String? _selectedDcConnector;

  final List<String> _regions = [
    'N.America',
    'Japan',
    'EU',
    'China',
    'All Markets',
  ];

  final Map<String, List<String>> _acConnectorsByRegion = {
    'N.America': ['Type 1', 'Tesla'],
    'Japan': ['Type 1', 'CHAdeMO'],
    'EU': ['Type 2'],
    'China': ['GBT'],
    'All Markets': ['Type 1', 'Type 2', 'GBT', 'Tesla'],
  };

  final Map<String, List<String>> _dcConnectorsByRegion = {
    'N.America': ['CCS1', 'CHAdeMO', 'Tesla'],
    'Japan': ['CHAdeMO', 'CCS1'],
    'EU': ['CCS2', 'CHAdeMO'],
    'China': ['GBT'],
    'All Markets': ['CCS1', 'CCS2', 'CHAdeMO', 'GBT'],
  };

  /// Given an adapter type (e.g., 'CCS2↔GBT') and the user's connector,
  /// returns a list of alternative connector types the user can also use.
  List<String> _getAlternatesForAdapter(String adapterType, String userConn) {
    final alternates = <String>[];
    final userUpper = userConn.toUpperCase();

    // Parse adapter type: expects format 'A↔B' or 'A<->B'
    final parts = adapterType.replaceAll('<->', '↔').split('↔');
    if (parts.length != 2) return alternates;

    final a = parts[0].trim().toUpperCase();
    final b = parts[1].trim().toUpperCase();

    // Normalize CCS to CCS2 for matching
    String normalize(String s) => s == 'CCS' ? 'CCS2' : s;

    final normA = normalize(a);
    final normB = normalize(b);
    final normUser = normalize(userUpper);

    // If user's connector matches one side, they can use the other side
    if (normUser == normA || normUser.startsWith(normA)) {
      alternates.add(normB);
    }
    if (normUser == normB || normUser.startsWith(normB)) {
      alternates.add(normA);
    }

    return alternates;
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text.trim();
      });
    });
    // Load persisted marker colors
    _loadMarkerColors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _locateMe() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aktivizo shërbimet e lokacionit në pajisje'),
          ),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Leja e lokacionit u mohua')),
        );
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final here = LatLng(pos.latitude, pos.longitude);
      if (!mounted) return;
      setState(() {
        _myLocation = here;
        _currentCenter = here;
        _currentZoom = 15.0;
      });
      _mapController.move(_currentCenter, _currentZoom);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Nuk u mor lokacioni: $e')));
    }
  }

  List<ChargingStation> get _filteredStations {
    var base = widget.stations.toList();

    // Apply search filter
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      base = base.where((s) {
        final city = (s.city ?? '').toLowerCase();
        final name = s.name.toLowerCase();
        return city.contains(q) || name.contains(q);
      }).toList();
    }

    // Apply availability filter
    if (_onlyAvailable) {
      base = base.where((s) => s.hasAvailableConnector).toList();
    }

    // Apply connector type filters
    if (_connectorFilters.isNotEmpty) {
      base = base
          .where(
            (s) => s.connectorTypes.any((t) => _connectorFilters.contains(t)),
          )
          .toList();
    }

    // Apply Fast filter (>50kW)
    if (_quickFilterFast) {
      base = base.where((s) => s.connectorPowers.any((p) => p > 50)).toList();
    }

    // Apply Slow filter (≤50kW)
    if (_quickFilterSlow) {
      base = base.where((s) => s.connectorPowers.any((p) => p <= 50)).toList();
    }

    // Apply advanced AC/DC connector filters
    if (_selectedAcConnector != null) {
      base = base
          .where((s) => s.connectorTypes.contains(_selectedAcConnector))
          .toList();
    }
    if (_selectedDcConnector != null) {
      base = base
          .where((s) => s.connectorTypes.contains(_selectedDcConnector))
          .toList();
    }

    return base;
  }

  void _showFilterBottomSheet() {
    const green = Color(0xFF00C853);
    const blue = Color(0xFF00B0FF);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String tempRegion = _selectedRegion;
        String? tempAc = _selectedAcConnector;
        String? tempDc = _selectedDcConnector;

        return StatefulBuilder(
          builder: (context, setModalState) {
            final acList = _acConnectorsByRegion[tempRegion] ?? [];
            final dcList = _dcConnectorsByRegion[tempRegion] ?? [];

            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [green, blue],
                  begin: Alignment.topLeft,
                  end: Alignment.topRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              'Filter',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),

                  // White card with filters
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Connector Type',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Region chips
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _regions.map((r) {
                                final bool selected = r == tempRegion;
                                return ChoiceChip(
                                  label: Text(r),
                                  selected: selected,
                                  selectedColor: const Color(0xFFE8F5E9),
                                  backgroundColor: Colors.white,
                                  side: BorderSide(
                                    color: selected
                                        ? green
                                        : Colors.grey.shade300,
                                  ),
                                  labelStyle: TextStyle(
                                    color: selected
                                        ? green
                                        : Colors.grey.shade800,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  onSelected: (_) {
                                    setModalState(() {
                                      tempRegion = r;
                                      tempAc = null;
                                      tempDc = null;
                                    });
                                  },
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 24),

                            // AC row
                            _buildConnectorRow(
                              title: 'AC',
                              connectors: acList,
                              selected: tempAc,
                              onSelected: (value) {
                                setModalState(() => tempAc = value);
                              },
                            ),

                            const SizedBox(height: 16),

                            // DC row
                            _buildConnectorRow(
                              title: 'DC',
                              connectors: dcList,
                              selected: tempDc,
                              onSelected: (value) {
                                setModalState(() => tempDc = value);
                              },
                            ),

                            const SizedBox(height: 32),

                            // Apply button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.check),
                                label: const Text(
                                  'Apply',
                                  style: TextStyle(fontSize: 16),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  backgroundColor: green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _selectedRegion = tempRegion;
                                    _selectedAcConnector = tempAc;
                                    _selectedDcConnector = tempDc;
                                  });
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Clear All button
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.delete_outline),
                                label: const Text(
                                  'Clear All Filters',
                                  style: TextStyle(fontSize: 16),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () {
                                  setModalState(() {
                                    tempRegion = 'All Markets';
                                    tempAc = null;
                                    tempDc = null;
                                  });
                                  setState(() {
                                    _selectedRegion = 'All Markets';
                                    _selectedAcConnector = null;
                                    _selectedDcConnector = null;
                                    _onlyAvailable = false;
                                    _quickFilterFast = false;
                                    _quickFilterSlow = false;
                                    _connectorFilters.clear();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
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

  String _getConnectorIconPath(String connectorType, String rowType) {
    // rowType: 'AC' or 'DC'
    switch (connectorType.toLowerCase()) {
      case 'type 1':
        return 'assets/icon/connectors/type1.png';
      case 'type 2':
        return 'assets/icon/connectors/type2.png';
      case 'gbt':
        return rowType == 'AC'
            ? 'assets/icon/connectors/gbtac.png'
            : 'assets/icon/connectors/gbtdc.png';
      case 'tesla':
        return 'assets/icon/connectors/tesla.png';
      case 'ccs1':
        return 'assets/icon/connectors/ccs1.png';
      case 'ccs2':
        return 'assets/icon/connectors/ccs2.png';
      case 'chademo':
      case 'chade':
        return 'assets/icon/connectors/chade.png';
      default:
        return 'assets/icon/connectors/type2.png';
    }
  }

  Widget _buildConnectorRow({
    required String title,
    required List<String> connectors,
    required String? selected,
    required ValueChanged<String> onSelected,
  }) {
    const green = Color(0xFF00C853);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 40,
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: connectors.map((c) {
              final isSelected = c == selected;
              final iconPath = _getConnectorIconPath(c, title);
              return GestureDetector(
                onTap: () => onSelected(c),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: isSelected
                        ? const Border.fromBorderSide(
                            BorderSide(color: green, width: 2),
                          )
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: const Color(0xFFF5F5F5),
                        child: ClipOval(
                          child: Image.asset(
                            iconPath,
                            width: 38,
                            height: 38,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.electric_car,
                                size: 28,
                                color: isSelected
                                    ? green
                                    : Colors.grey.shade600,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        c,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? green : Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Persisted marker colors: load from SharedPreferences
  Future<void> _loadMarkerColors() async {
    final prefs = await SharedPreferences.getInstance();
    final unavail = prefs.getInt(_kKeyMarkerUnavailable);
    final availCompat = prefs.getInt(_kKeyMarkerAvailableCompatible);
    final availIncompat = prefs.getInt(_kKeyMarkerAvailableIncompatible);

    if (!mounted) return;
    setState(() {
      if (unavail != null) {
        _markerUnavailable = Color(unavail);
      }
      if (availCompat != null) {
        _markerAvailableCompatible = Color(availCompat);
      }
      if (availIncompat != null) {
        _markerAvailableIncompatible = Color(availIncompat);
      }
    });
  }

  Future<void> _saveMarkerColors() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kKeyMarkerUnavailable, _markerUnavailable.value);
    await prefs.setInt(
        _kKeyMarkerAvailableCompatible, _markerAvailableCompatible.value);
    await prefs.setInt(
        _kKeyMarkerAvailableIncompatible, _markerAvailableIncompatible.value);
  }

  void _showMarkerColorSettings() {
    // Use a bottom sheet with simple color choices for each category
    final List<Color> palette = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.brown,
      Colors.pink,
      Colors.black,
      Colors.grey,
    ];

    Color tempUnavailable = _markerUnavailable;
    Color tempAvailCompat = _markerAvailableCompatible;
    Color tempAvailIncompat = _markerAvailableIncompatible;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Widget buildPaletteRow(String title, Color current,
                ValueChanged<Color> onPick) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: current,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black12),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final c in palette)
                        GestureDetector(
                          onTap: () => setModalState(() => onPick(c)),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: c == current
                                    ? Colors.black
                                    : Colors.black12,
                                width: c == current ? 2 : 1,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            }

            return SafeArea(
              child: Padding(
                padding:
                    EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.palette),
                            SizedBox(width: 8),
                            Text('Ngjyrat e Markuesve',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        buildPaletteRow('Jo i disponueshëm', tempUnavailable,
                            (c) => tempUnavailable = c),
                        const SizedBox(height: 12),
                        buildPaletteRow('I disponueshëm (përputhshëm)',
                            tempAvailCompat, (c) => tempAvailCompat = c),
                        const SizedBox(height: 12),
                        buildPaletteRow('I disponueshëm (jo përputhshëm)',
                            tempAvailIncompat, (c) => tempAvailIncompat = c),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Anulo'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  setState(() {
                                    _markerUnavailable = tempUnavailable;
                                    _markerAvailableCompatible =
                                        tempAvailCompat;
                                    _markerAvailableIncompatible =
                                        tempAvailIncompat;
                                  });
                                  await _saveMarkerColors();
                                  if (mounted) Navigator.of(context).pop();
                                },
                                child: const Text('Ruaj'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final stations = _filteredStations;
    final center = stations.isNotEmpty
        ? LatLng(stations.first.lat, stations.first.lng)
        : const LatLng(41.3275, 19.8187);
    _currentCenter = center;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Harta e Stacioneve'),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette),
            tooltip: 'Përzgjidh ngjyrat e markuesve',
            onPressed: _showMarkerColorSettings,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56.0),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: SizedBox(
              height: 40,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Kerko qytetin...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => setState(() {}),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: _currentZoom,
              onPositionChanged: (pos, bool hasGesture) {
                setState(() {
                  _currentCenter = pos.center;
                  _currentZoom = pos.zoom;
                });
              },
            ),
            children: [
              TileLayer(
                // Use NetworkTileProvider with headers to comply with OSM usage policy
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                tileProvider: NetworkTileProvider(
                  headers: {
                    'User-Agent':
                        'EVCharge/1.0 (+https://example.com; support@example.com)',
                    'Referer': 'https://example.com',
                  },
                ),
              ),

              MarkerLayer(
                markers: () {
                  final markers = stations.map((s) {
                    // Determine marker color based on availability and user compatibility
                    // - RED: station s'ka asnjë konektor të lirë (unavailable)
                    // - GREEN: ka konektor të lirë që i përshtatet makinës së përdoruesit (ose përmes adapterit)
                    // - BLUE: ka konektorë aktivë, por asnjë nuk i përshtatet përdoruesit
                    Color markerColor;

                    if (!s.hasAvailableConnector) {
                      // Asnjë konektor i lirë (mund të jetë offline ose i zënë) => KUQE
                      markerColor = _markerUnavailable;
                    } else {
                      // Ka të paktën një konektor të lirë; kontrollo përputhshmërinë me përdoruesin
                      String? userConn = widget.userConnectorType;
                      if (userConn != null && userConn.isNotEmpty) {
                        // Normalizo 'CCS' -> 'CCS2' që të përputhet me listat tona
                        final userNorm = userConn.toUpperCase() == 'CCS'
                            ? 'CCS2'
                            : userConn;

                        bool compatible = s.connectorAvailability[userNorm] ?? false;

                        // Nëse nuk gjendet i drejtpërdrejtë dhe përdoruesi ka adapter, kontrollo alternativën
                        if (!compatible && widget.adapterType != null) {
                          final alternates = _getAlternatesForAdapter(widget.adapterType!, userNorm);
                          for (final alt in alternates) {
                            if (s.connectorAvailability[alt] == true) {
                              compatible = true;
                              break;
                            }
                          }
                        }

                        markerColor = compatible
                            ? _markerAvailableCompatible
                            : _markerAvailableIncompatible;
                      } else {
                        // Pa preferencë përdoruesi: ka konektorë aktivë => JESHILE
                        markerColor = _markerAvailableCompatible;
                      }
                    }

                    return Marker(
                      point: LatLng(s.lat, s.lng),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () {
                          if (widget.onStationTap != null) {
                            widget.onStationTap!(s);
                            return;
                          }
                          showModalBottomSheet(
                            context: context,
                            builder: (_) => Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.name,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  if (s.city != null) Text('Qyteti: ${s.city}'),
                                  if (s.address != null)
                                    Text('Adresa: ${s.address}'),
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('Mbyll'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Icon(
                          Icons.ev_station,
                          color: markerColor,
                          size: 32,
                        ),
                      ),
                    );
                  }).toList();
                  
                  // Add user's current location marker
                  if (_myLocation != null) {
                    markers.add(
                      Marker(
                        point: _myLocation!,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.blueAccent,
                          size: 28,
                        ),
                      ),
                    );
                  }
                  
                  // Add car marker at charging station if session is active
                  final activeSession = currentChargingSession.value;
                  if (activeSession != null) {
                    final chargingLat = activeSession.station.latitude;
                    final chargingLng = activeSession.station.longitude;
                    markers.add(
                      Marker(
                        point: LatLng(chargingLat, chargingLng),
                        width: 50,
                        height: 50,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.directions_car,
                            color: Colors.blue,
                            size: 32,
                          ),
                        ),
                      ),
                    );
                  }
                  
                  return markers;
                }(),
              ),
            ],
          ),

          // Zoom controls
          Positioned(
            right: 12,
            bottom: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'zoom_in',
                  mini: true,
                  onPressed: () {
                    final newZoom = (_currentZoom + 1).clamp(1.0, 18.0);
                    _mapController.move(_currentCenter, newZoom);
                  },
                  child: const Icon(Icons.add, size: 20),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'zoom_out',
                  mini: true,
                  onPressed: () {
                    final newZoom = (_currentZoom - 1).clamp(1.0, 18.0);
                    _mapController.move(_currentCenter, newZoom);
                  },
                  child: const Icon(Icons.remove, size: 20),
                ),
              ],
            ),
          ),

          // Locate-me button: centers map on user's current location
          Positioned(
            left: 12,
            bottom: 24,
            child: FloatingActionButton(
              heroTag: 'locate_me',
              mini: true,
              onPressed: _locateMe,
              child: const Icon(Icons.my_location, size: 20),
            ),
          ),
          // Quick filter buttons - positioned at top
          Positioned(
            top: 8,
            left: 12,
            right: 60,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickFilterChip(
                    icon: Icons.tune,
                    label: 'Filter',
                    isSelected:
                        _onlyAvailable ||
                        _quickFilterFast ||
                        _quickFilterSlow ||
                        _connectorFilters.isNotEmpty ||
                        _selectedAcConnector != null ||
                        _selectedDcConnector != null,
                    onTap: _showFilterBottomSheet,
                  ),
                  const SizedBox(width: 6),
                  _buildQuickFilterChip(
                    icon: Icons.check_circle_outline,
                    label: 'Available',
                    isSelected: _onlyAvailable,
                    onTap: () =>
                        setState(() => _onlyAvailable = !_onlyAvailable),
                  ),
                  const SizedBox(width: 6),
                  _buildQuickFilterChip(
                    icon: Icons.flash_on,
                    label: 'Fast',
                    isSelected: _quickFilterFast,
                    onTap: () =>
                        setState(() => _quickFilterFast = !_quickFilterFast),
                  ),
                  const SizedBox(width: 6),
                  _buildQuickFilterChip(
                    icon: Icons.speed,
                    label: 'Slow',
                    isSelected: _quickFilterSlow,
                    onTap: () =>
                        setState(() => _quickFilterSlow = !_quickFilterSlow),
                  ),
                  const SizedBox(width: 6),
                  _buildQuickFilterChip(
                    icon: Icons.power,
                    label: 'CCS2',
                    isSelected: _connectorFilters.contains('CCS2'),
                    onTap: () => setState(() {
                      if (_connectorFilters.contains('CCS2')) {
                        _connectorFilters.remove('CCS2');
                      } else {
                        _connectorFilters.add('CCS2');
                      }
                    }),
                  ),
                  const SizedBox(width: 6),
                  _buildQuickFilterChip(
                    icon: Icons.power,
                    label: 'GBT',
                    isSelected: _connectorFilters.contains('GBT'),
                    onTap: () => setState(() {
                      if (_connectorFilters.contains('GBT')) {
                        _connectorFilters.remove('GBT');
                      } else {
                        _connectorFilters.add('GBT');
                      }
                    }),
                  ),
                  const SizedBox(width: 6),
                  _buildQuickFilterChip(
                    icon: Icons.electrical_services,
                    label: 'Type 2',
                    isSelected: _connectorFilters.contains('Type 2'),
                    onTap: () => setState(() {
                      if (_connectorFilters.contains('Type 2')) {
                        _connectorFilters.remove('Type 2');
                      } else {
                        _connectorFilters.add('Type 2');
                      }
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
