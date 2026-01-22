import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ev_charge_app/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';
import 'dart:math';
import 'package:ev_charge_app/ev_map_page.dart';
import 'package:ev_charge_app/models/charging_station.dart';
import 'dart:async';

// Minimal model classes (reconstructed) -------------------------------------------------
class Achievement {
  final String id;
  final String title;
  final String description;
  final DateTime? unlockedDate;
  final bool isUnlocked;
  final int requiredPoints;
  final String icon;

  Achievement({
    required this.id,
    required this.title,
    this.description = '',
    this.unlockedDate,
    this.isUnlocked = false,
    this.requiredPoints = 0,
    this.icon = '',
  });

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? unlockedDate,
    bool? isUnlocked,
    int? requiredPoints,
    String? icon,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      unlockedDate: unlockedDate ?? this.unlockedDate,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      requiredPoints: requiredPoints ?? this.requiredPoints,
      icon: icon ?? this.icon,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'unlockedDate': unlockedDate?.toIso8601String(),
    'isUnlocked': isUnlocked,
    'requiredPoints': requiredPoints,
    'icon': icon,
  };

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String? ?? '',
    unlockedDate: json['unlockedDate'] != null
        ? DateTime.parse(json['unlockedDate'] as String)
        : null,
    isUnlocked: json['isUnlocked'] as bool? ?? false,
    requiredPoints: (json['requiredPoints'] as int?) ?? 0,
    icon: (json['icon'] as String?) ?? '',
  );
}

class UserProfile {
  final String name;
  final String email;
  final String password;
  final String initials;
  final double walletBalance;
  final String vehicle;
  final String licensePlate;
  final int ecoPoints;
  final int totalCharges;
  final double totalCO2Saved;
  final String tier;
  final List<Achievement> achievements;
  final String?
  adapterType; // e.g., 'CCS2↔GBT', 'CCS1↔CHAdeMO', 'Tesla↔CCS2', null = none
  final String preferredConnector; // e.g., 'GBT', 'CCS2', 'Type 2'

  UserProfile({
    required this.name,
    required this.email,
    required this.password,
    this.initials = '',
    this.walletBalance = 0.0,
    this.vehicle = 'No vehicle added',
    this.licensePlate = '',
    this.ecoPoints = 0,
    this.totalCharges = 0,
    this.totalCO2Saved = 0.0,
    this.tier = 'Bronze',
    this.achievements = const [],
    this.adapterType,
    this.preferredConnector = 'CCS2',
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? password,
    String? initials,
    double? walletBalance,
    String? vehicle,
    String? licensePlate,
    int? ecoPoints,
    int? totalCharges,
    double? totalCO2Saved,
    String? tier,
    List<Achievement>? achievements,
    String? adapterType,
    String? preferredConnector,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      initials: initials ?? this.initials,
      walletBalance: walletBalance ?? this.walletBalance,
      vehicle: vehicle ?? this.vehicle,
      licensePlate: licensePlate ?? this.licensePlate,
      ecoPoints: ecoPoints ?? this.ecoPoints,
      totalCharges: totalCharges ?? this.totalCharges,
      totalCO2Saved: totalCO2Saved ?? this.totalCO2Saved,
      tier: tier ?? this.tier,
      achievements: achievements ?? this.achievements,
      adapterType: adapterType ?? this.adapterType,
      preferredConnector: preferredConnector ?? this.preferredConnector,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'password': password,
    'initials': initials,
    'walletBalance': walletBalance,
    'vehicle': vehicle,
    'licensePlate': licensePlate,
    'ecoPoints': ecoPoints,
    'totalCharges': totalCharges,
    'totalCO2Saved': totalCO2Saved,
    'tier': tier,
    'achievements': achievements.map((a) => a.toJson()).toList(),
    'adapterType': adapterType,
    'preferredConnector': preferredConnector,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] as String,
    email: json['email'] as String,
    password: json['password'] as String,
    initials: json['initials'] as String? ?? '',
    walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
    vehicle: json['vehicle'] as String? ?? 'No vehicle added',
    licensePlate: json['licensePlate'] as String? ?? '',
    ecoPoints: (json['ecoPoints'] as int?) ?? 0,
    totalCharges: (json['totalCharges'] as int?) ?? 0,
    totalCO2Saved: (json['totalCO2Saved'] as num?)?.toDouble() ?? 0.0,
    tier: json['tier'] as String? ?? 'Bronze',
    achievements:
        (json['achievements'] as List<dynamic>?)
            ?.map((e) => Achievement.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    adapterType: json['adapterType'] as String?,
    preferredConnector: _normalizeConnector(
      json['preferredConnector'] as String?,
    ),
  );
}

/// Normalize legacy/variant connector labels to the exact set used in dropdown items.
String _normalizeConnector(String? raw) {
  final v = (raw ?? 'CCS2').trim();
  final upper = v.toUpperCase();
  switch (upper) {
    case 'CCS':
    case 'CCS2':
      return 'CCS2';
    case 'CCS1':
      return 'CCS1';
    case 'GBT':
    case 'GB/T':
      return 'GBT';
    case 'TYPE2':
    case 'TYPE 2':
    case 'TYPE-2':
    case 'TYPE_2':
      return 'Type 2';
    case 'TYPE1':
    case 'TYPE 1':
    case 'TYPE-1':
    case 'TYPE_1':
      return 'Type 1';
    case 'TESLA':
    case 'NACS':
    case 'TESLA (NACS)':
      return 'Tesla';
    case 'CHADEMO':
      return 'CHAdeMO';
    default:
      return 'CCS2';
  }
}

class ChargingHistory {
  final String stationName;
  final String date;
  final double kwhUsed;
  final double cost;
  final String duration;
  final String chargingType;

  ChargingHistory({
    required this.stationName,
    required this.date,
    required this.kwhUsed,
    required this.cost,
    required this.duration,
    required this.chargingType,
  });

  Map<String, dynamic> toJson() => {
    'stationName': stationName,
    'date': date,
    'kwhUsed': kwhUsed,
    'cost': cost,
    'duration': duration,
    'chargingType': chargingType,
  };

  factory ChargingHistory.fromJson(Map<String, dynamic> json) =>
      ChargingHistory(
        stationName: json['stationName'] as String,
        date: json['date'] as String,
        kwhUsed: (json['kwhUsed'] as num).toDouble(),
        cost: (json['cost'] as num).toDouble(),
        duration: json['duration'] as String,
        chargingType: json['chargingType'] as String,
      );
}

// Global user list and current user notifier
final List<UserProfile> availableProfiles = [];
final ValueNotifier<UserProfile?> currentUser = ValueNotifier(null);
final List<Achievement> availableAchievements = [];

// Dark mode notifier
final ValueNotifier<bool> isDarkMode = ValueNotifier(false);

// Notifications notifier
final ValueNotifier<bool> isNotificationsEnabled = ValueNotifier(true);

const int _achievementRewardAmountAll = 10000;
const String _achievementRewardCouponCode = 'EVCHARGE-10000';

String _rewardKeyForUser(String email) => 'achievementRewardRedeemed_$email';

Future<bool> _isRewardRedeemedForUser(String email) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_rewardKeyForUser(email)) ?? false;
}

Future<void> _setRewardRedeemedForUser(String email, bool value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_rewardKeyForUser(email), value);
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _vehicleController = TextEditingController();
  final _licensePlateController = TextEditingController();
  String _adapterType = ''; // Empty string means no adapter
  String _preferredConnector = 'CCS2';

  @override
  void initState() {
    super.initState();
    final user = currentUser.value;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _passwordController.text = user.password;
      if (user.vehicle != 'No vehicle added') {
        _vehicleController.text = user.vehicle;
      }
      _licensePlateController.text = user.licensePlate;
      _adapterType = user.adapterType ?? ''; // Convert null to empty string
      _preferredConnector = _normalizeConnector(user.preferredConnector);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _vehicleController.dispose();
    _licensePlateController.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    final user = currentUser.value;
    if (user == null) return;

    final name = _nameController.text.trim().isEmpty
        ? user.name
        : _nameController.text.trim();
    final email = _emailController.text.trim().isEmpty
        ? user.email
        : _emailController.text.trim();
    final password = _passwordController.text.trim().isEmpty
        ? user.password
        : _passwordController.text.trim();

    final vehicle = _vehicleController.text.trim().isEmpty
        ? 'No vehicle added'
        : _vehicleController.text.trim();
    final licensePlate = _licensePlateController.text.trim();

    // compute initials from name
    String initials = '';
    final nameParts = name.split(' ');
    if (nameParts.isNotEmpty) {
      initials = nameParts[0].isNotEmpty ? nameParts[0][0].toUpperCase() : '';
      if (nameParts.length > 1 && nameParts[1].isNotEmpty) {
        initials += nameParts[1][0].toUpperCase();
      }
    }

    // Update user in the list
    final index = availableProfiles.indexWhere((p) => p.email == user.email);
    if (index != -1) {
      final updated = UserProfile(
        name: name,
        email: email,
        password: password,
        initials: initials.isNotEmpty ? initials : user.initials,
        walletBalance: user.walletBalance,
        vehicle: vehicle,
        licensePlate: licensePlate,
        ecoPoints: user.ecoPoints,
        totalCharges: user.totalCharges,
        totalCO2Saved: user.totalCO2Saved,
        tier: user.tier,
        achievements: user.achievements,
        adapterType: _adapterType.isEmpty ? null : _adapterType,
        preferredConnector: _preferredConnector,
      );

      availableProfiles[index] = updated;
      currentUser.value = updated;
      await saveUserProfiles();
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Color(0xFF2DBE6C),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          TextButton(
            onPressed: _saveChanges,
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profile Information',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'e.g., John Doe',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'name@example.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              const Text(
                'Vehicle Information',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _vehicleController,
                decoration: InputDecoration(
                  labelText: 'Vehicle Model',
                  hintText: 'e.g., Tesla Model 3, BMW iX',
                  prefixIcon: const Icon(Icons.directions_car),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _licensePlateController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'License Plate',
                  hintText: 'e.g., AB 123 CD',
                  prefixIcon: const Icon(Icons.confirmation_number_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Preferred connector type
              const Text(
                'Lloji i karikuesit për makinën tënde',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _preferredConnector,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.power),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'CCS2', child: Text('CCS2 (EU)')),
                  DropdownMenuItem(value: 'CCS1', child: Text('CCS1 (NA)')),
                  DropdownMenuItem(value: 'GBT', child: Text('GBT (GB/T)')),
                  DropdownMenuItem(value: 'Type 2', child: Text('Type 2 (AC)')),
                  DropdownMenuItem(value: 'Type 1', child: Text('Type 1 (AC)')),
                  DropdownMenuItem(value: 'Tesla', child: Text('Tesla (NACS)')),
                  DropdownMenuItem(value: 'CHAdeMO', child: Text('CHAdeMO')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _preferredConnector = v);
                },
              ),
              const SizedBox(height: 24),
              // Adapter option - now a dropdown with multiple adapter choices
              const Text(
                'Adapter (opsional)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _adapterType,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.cable),
                  hintText: 'Zgjidh adapterin nëse ke',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: '', child: Text('Asnjë adapter')),
                  DropdownMenuItem(
                    value: 'CCS2↔GBT',
                    child: Text('CCS2 ↔ GBT'),
                  ),
                  DropdownMenuItem(
                    value: 'CCS1↔CHAdeMO',
                    child: Text('CCS1 ↔ CHAdeMO'),
                  ),
                  DropdownMenuItem(
                    value: 'Tesla↔CCS2',
                    child: Text('Tesla ↔ CCS2'),
                  ),
                  DropdownMenuItem(
                    value: 'Tesla↔CCS1',
                    child: Text('Tesla ↔ CCS1'),
                  ),
                  DropdownMenuItem(
                    value: 'Type1↔Type2',
                    child: Text('Type 1 ↔ Type 2'),
                  ),
                  DropdownMenuItem(
                    value: 'CHAdeMO↔CCS2',
                    child: Text('CHAdeMO ↔ CCS2'),
                  ),
                ],
                onChanged: (v) => setState(() => _adapterType = v ?? ''),
              ),
              const SizedBox(height: 16),
              const Text(
                'Popular Electric Vehicles',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    [
                      'Tesla Model 3',
                      'Tesla Model Y',
                      'BMW iX',
                      'Audi e-tron',
                      'Mercedes EQS',
                      'Porsche Taycan',
                      'Nissan Leaf',
                      'Hyundai Ioniq 5',
                      'Volkswagen ID.4',
                      'Ford Mustang Mach-E',
                    ].map((car) {
                      return ActionChip(
                        label: Text(car),
                        onPressed: () {
                          setState(() {
                            _vehicleController.text = car;
                          });
                        },
                        backgroundColor: Colors.grey[100],
                        side: BorderSide(color: Colors.grey[300]!),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2DBE6C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Global charging history (per user email)
final Map<String, List<ChargingHistory>> userChargingHistory = {};

// Deposit History Model
class DepositHistory {
  final String date;
  final double amount;
  final String method; // 'card', 'location', 'points', or 'coupon'
  final String?
  paymentDetails; // e.g., 'Visa **** 1234', 'Achievement Reward', 'Coupon EVCHARGE-10000'

  DepositHistory({
    required this.date,
    required this.amount,
    required this.method,
    this.paymentDetails,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() => {
    'date': date,
    'amount': amount,
    'method': method,
    'paymentDetails': paymentDetails,
  };

  // Create from JSON
  factory DepositHistory.fromJson(Map<String, dynamic> json) => DepositHistory(
    date: json['date'] as String,
    amount: (json['amount'] as num).toDouble(),
    method: json['method'] as String,
    paymentDetails: json['paymentDetails'] as String?,
  );
}

// Global deposit history (per user email)
final Map<String, List<DepositHistory>> userDepositHistory = {};

// Save and load functions for user profiles
Future<void> saveUserProfiles() async {
  final prefs = await SharedPreferences.getInstance();
  final List<Map<String, dynamic>> profilesJson = availableProfiles
      .map((profile) => profile.toJson())
      .toList();
  await prefs.setString('userProfiles', jsonEncode(profilesJson));
}

Future<void> loadUserProfiles() async {
  final prefs = await SharedPreferences.getInstance();
  final String? data = prefs.getString('userProfiles');
  if (data != null) {
    final List<dynamic> decoded = jsonDecode(data);
    availableProfiles.clear();
    availableProfiles.addAll(
      decoded.map((item) => UserProfile.fromJson(item)).toList(),
    );
  }
}

// Save and load functions for persistence
Future<void> saveChargingHistory() async {
  final prefs = await SharedPreferences.getInstance();
  final Map<String, dynamic> data = {};
  userChargingHistory.forEach((email, history) {
    data[email] = history.map((h) => h.toJson()).toList();
  });
  await prefs.setString('chargingHistory', jsonEncode(data));
}

Future<void> loadChargingHistory() async {
  final prefs = await SharedPreferences.getInstance();
  final String? data = prefs.getString('chargingHistory');
  if (data != null) {
    final Map<String, dynamic> decoded = jsonDecode(data);
    decoded.forEach((email, historyJson) {
      userChargingHistory[email] = (historyJson as List)
          .map((item) => ChargingHistory.fromJson(item))
          .toList();
    });
  }
}

Future<void> saveDepositHistory() async {
  final prefs = await SharedPreferences.getInstance();
  final Map<String, dynamic> data = {};
  userDepositHistory.forEach((email, history) {
    data[email] = history.map((h) => h.toJson()).toList();
  });
  await prefs.setString('depositHistory', jsonEncode(data));
}

Future<void> loadDepositHistory() async {
  final prefs = await SharedPreferences.getInstance();
  final String? data = prefs.getString('depositHistory');
  if (data != null) {
    final Map<String, dynamic> decoded = jsonDecode(data);
    decoded.forEach((email, historyJson) {
      userDepositHistory[email] = (historyJson as List)
          .map((item) => DepositHistory.fromJson(item))
          .toList();
    });
  }
}

// Save/load/clear the active (in-progress) charging session per user so we
// can restore it if the app is closed and the user returns later.
Future<void> saveCurrentChargingSessionForUser(String email) async {
  final prefs = await SharedPreferences.getInstance();
  final session = currentChargingSession.value;
  if (session == null) {
    await prefs.remove('currentSession_$email');
    return;
  }
  await prefs.setString('currentSession_$email', jsonEncode(session.toJson()));
}

Future<void> loadCurrentChargingSessionForUser(String email) async {
  final prefs = await SharedPreferences.getInstance();
  final String? data = prefs.getString('currentSession_$email');
  if (data != null) {
    try {
      final Map<String, dynamic> decoded = jsonDecode(data);
      currentChargingSession.value = ChargingSession.fromJson(decoded);
    } catch (_) {
      // ignore malformed saved session
    }
  }
}

Future<void> clearCurrentChargingSessionForUser(String email) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('currentSession_$email');
}

// Global charging state with live data
class ChargingSession {
  final ChargingStationLocation station;
  final Connector connector;
  double batteryPercentage;
  double currentPower;
  double totalKwh;
  final double batteryCapacityKwh;
  final DateTime startTime;
  double targetPercentage; // Target % to stop charging (default 100%)

  ChargingSession(
    this.station,
    this.connector, {
    this.batteryPercentage = 45.0,
    this.currentPower = 120.0,
    this.totalKwh = 0.0,
    double? batteryCapacityKwh,
    DateTime? startTime,
    this.targetPercentage = 100.0,
  }) : batteryCapacityKwh =
           batteryCapacityKwh ?? (75 + Random().nextInt(26)).toDouble(),
       startTime = startTime ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'stationName': station.name,
    'stationCity': station.city,
    'stationCode': station.code,
    'connectorType': connector.type,
    'connectorPrice': connector.pricePerKwh,
    'batteryCapacityKwh': batteryCapacityKwh,
    'batteryPercentage': batteryPercentage,
    'currentPower': currentPower,
    'totalKwh': totalKwh,
    'startTime': startTime.toIso8601String(),
    'targetPercentage': targetPercentage,
    // Include station coordinates so we can restore sessions fully
    'stationLatitude': station.latitude,
    'stationLongitude': station.longitude,
  };

  factory ChargingSession.fromJson(Map<String, dynamic> json) {
    final station = ChargingStationLocation(
      id: json['stationName'] ?? 'unknown',
      code: json['stationCode'] ?? 'EV000',
      name: json['stationName'] ?? 'Unknown Station',
      address: json['stationName'] ?? '',
      city: json['stationCity'] ?? '',
      distance: '',
      connectors: [
        Connector(
          type: json['connectorType'] ?? 'Unknown',
          pricePerKwh: (json['connectorPrice'] as int?) ?? 0,
          powerKw: 100,
        ),
      ],
      latitude: (json['stationLatitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['stationLongitude'] as num?)?.toDouble() ?? 0.0,
    );

    final connector = station.connectors.first;

    return ChargingSession(
      station,
      connector,
      batteryCapacityKwh: (json['batteryCapacityKwh'] as num?)?.toDouble(),
      batteryPercentage: (json['batteryPercentage'] as num?)?.toDouble() ?? 0.0,
      currentPower: (json['currentPower'] as num?)?.toDouble() ?? 0.0,
      totalKwh: (json['totalKwh'] as num?)?.toDouble() ?? 0.0,
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : DateTime.now(),
      targetPercentage: (json['targetPercentage'] as num?)?.toDouble() ?? 100.0,
    );
  }
}

final ValueNotifier<ChargingSession?> currentChargingSession = ValueNotifier(
  null,
);

// App-wide locale notifier (null means follow system)
final ValueNotifier<Locale?> appLocale = ValueNotifier<Locale?>(null);

Future<void> loadAppLocale() async {
  final prefs = await SharedPreferences.getInstance();
  final code = prefs.getString('appLocale');
  if (code != null && code.isNotEmpty) {
    appLocale.value = Locale(code);
  }
}

Future<void> saveAppLocale(String code) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('appLocale', code);
  appLocale.value = Locale(code);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadUserProfiles();
  await loadChargingHistory();
  await loadDepositHistory();
  await loadAppLocale();
  await loadDarkModeSetting();
  await loadNotificationsSetting();
  _ensureDefaultAchievements();
  _normalizeType2PowerInStations();
  runApp(const EVChargeApp());
}

// Load dark mode setting from SharedPreferences
Future<void> loadDarkModeSetting() async {
  final prefs = await SharedPreferences.getInstance();
  isDarkMode.value = prefs.getBool('isDarkMode') ?? false;
}

// Save dark mode setting to SharedPreferences
Future<void> saveDarkModeSetting(bool value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isDarkMode', value);
}

// Load notifications setting from SharedPreferences
Future<void> loadNotificationsSetting() async {
  final prefs = await SharedPreferences.getInstance();
  isNotificationsEnabled.value =
      prefs.getBool('isNotificationsEnabled') ?? true;
}

// Save notifications setting to SharedPreferences
Future<void> saveNotificationsSetting(bool value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isNotificationsEnabled', value);
}

// Show a local notification (used when notifications are enabled)
void showAppNotification(
  BuildContext context,
  String title,
  String message, {
  IconData? icon,
}) {
  if (!isNotificationsEnabled.value) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(icon ?? Icons.notifications, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(message, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF2DBE6C),
      duration: const Duration(seconds: 4),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

void _ensureDefaultAchievements() {
  // Keep exactly 10 achievements available in the app.
  // If these were previously removed or the list is empty, restore them.
  if (availableAchievements.length == 10) return;

  availableAchievements
    ..clear()
    ..addAll([
      Achievement(
        id: 'ach_first_charge',
        title: 'First Charge',
        description: 'Complete your first charging session',
        requiredPoints: 0,
        icon: '⚡',
      ),
      Achievement(
        id: 'ach_eco_starter_500',
        title: 'Eco Starter',
        description: 'Reach 500 eco points',
        requiredPoints: 500,
        icon: '🌱',
      ),
      Achievement(
        id: 'ach_green_driver_1000',
        title: 'Green Driver',
        description: 'Reach 1,000 eco points',
        requiredPoints: 1000,
        icon: '🚗',
      ),
      Achievement(
        id: 'ach_city_explorer_2000',
        title: 'City Explorer',
        description: 'Charge across multiple cities',
        requiredPoints: 2000,
        icon: '🗺️',
      ),
      Achievement(
        id: 'ach_charge_master_10',
        title: 'Charge Master',
        description: 'Complete 10 charging sessions',
        requiredPoints: 3000,
        icon: '🏁',
      ),
      Achievement(
        id: 'ach_fast_charger',
        title: 'Fast Charger',
        description: 'Use a fast charger (50kW+)',
        requiredPoints: 3500,
        icon: '🚀',
      ),
      Achievement(
        id: 'ach_co2_saver_50',
        title: 'CO₂ Saver',
        description: 'Save 50 kg of CO₂',
        requiredPoints: 4000,
        icon: '🌍',
      ),
      Achievement(
        id: 'ach_regular_5000',
        title: 'Regular',
        description: 'Reach 5,000 eco points',
        requiredPoints: 5000,
        icon: '⭐',
      ),
      Achievement(
        id: 'ach_elite_8000',
        title: 'Elite',
        description: 'Reach 8,000 eco points',
        requiredPoints: 8000,
        icon: '🏆',
      ),
      Achievement(
        id: 'ach_legend_10000',
        title: 'Legend',
        description: 'Reach 10,000 eco points',
        requiredPoints: 10000,
        icon: '👑',
      ),
    ]);
}

class EVChargeApp extends StatelessWidget {
  const EVChargeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: appLocale,
      builder: (context, locale, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: isDarkMode,
          builder: (context, darkMode, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              onGenerateTitle: (ctx) => AppLocalizations.of(ctx)!.appTitle,
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
              theme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.light,
                colorSchemeSeed: const Color(0xFF2DBE6C),
                scaffoldBackgroundColor: Colors.grey[50],
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.dark,
                colorSchemeSeed: const Color(0xFF2DBE6C),
                scaffoldBackgroundColor: const Color(0xFF121212),
                cardColor: const Color(0xFF1E1E1E),
                appBarTheme: const AppBarTheme(
                  backgroundColor: Color(0xFF1A1A1A),
                  foregroundColor: Colors.white,
                ),
                bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                  backgroundColor: Color(0xFF1A1A1A),
                  selectedItemColor: Color(0xFF2DBE6C),
                  unselectedItemColor: Colors.grey,
                ),
                dialogTheme: const DialogThemeData(
                  backgroundColor: Color(0xFF1E1E1E),
                ),
                dividerColor: Colors.grey[800],
              ),
              home: const WelcomePage(),
            );
          },
        );
      },
    );
  }
}

/// ---------------- WELCOME PAGE ----------------
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1B5E20), Color(0xFF2DBE6C), Color(0xFF66BB6A)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Animated car and charger illustration
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      height: 200,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Green leaves background
                          Positioned(
                            top: 20,
                            left: 40,
                            child: Icon(
                              Icons.eco,
                              color: Colors.white.withOpacity(0.3),
                              size: 60,
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 50,
                            child: Icon(
                              Icons.eco,
                              color: Colors.white.withOpacity(0.25),
                              size: 50,
                            ),
                          ),
                          Positioned(
                            bottom: 30,
                            left: 30,
                            child: Icon(
                              Icons.eco,
                              color: Colors.white.withOpacity(0.2),
                              size: 45,
                            ),
                          ),

                          // Electric car icon
                          Positioned(
                            bottom: 40,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.electric_car,
                                size: 80,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          // EV Charger icon
                          Positioned(
                            top: 50,
                            right: 40,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.ev_station,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // App title
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        const Text(
                          'EV Charge',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Charge your future, sustainably',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Get Started button
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF2DBE6C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ---------------- LOGIN / SIGN UP PAGE ----------------
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Check if user exists by email
    final existing = availableProfiles.firstWhere(
      (p) => p.email == email,
      orElse: () => UserProfile(
        name: '',
        email: '',
        password: '',
        initials: '',
        walletBalance: 0,
        vehicle: '',
        licensePlate: '',
      ),
    );

    if (existing.email.isEmpty) {
      setState(() {
        errorMessage = 'User not found';
      });
      return;
    }

    // If user exists, validate password
    if (existing.password != password) {
      setState(() {
        errorMessage = 'Invalid password';
      });
      return;
    }

    // Set current user
    currentUser.value = existing;

    // Try to restore any in-progress charging session for this user so
    // achievements / eco points won't be lost if they return later.
    await loadCurrentChargingSessionForUser(existing.email);

    // Navigate to main screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }

  // Forgot Password: simple local reset flow (demo)
  void _showForgotPasswordSheet() {
    final emailCtrl = TextEditingController(text: _emailController.text.trim());
    final newPwCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    String? localError;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            Future<void> submit() async {
              if (isSubmitting) return;
              setSheetState(() {
                isSubmitting = true;
                localError = null;
              });

              final email = emailCtrl.text.trim();
              final newPw = newPwCtrl.text;
              final confirm = confirmCtrl.text;

              if (email.isEmpty || !email.contains('@')) {
                setSheetState(() {
                  localError = 'Please enter a valid email';
                  isSubmitting = false;
                });
                return;
              }
              final index = availableProfiles.indexWhere(
                (p) => p.email == email,
              );
              if (index == -1) {
                setSheetState(() {
                  localError = 'Email not found';
                  isSubmitting = false;
                });
                return;
              }
              if (newPw.length < 8) {
                setSheetState(() {
                  localError = 'Password must be at least 8 characters';
                  isSubmitting = false;
                });
                return;
              }
              if (newPw != confirm) {
                setSheetState(() {
                  localError = 'Passwords do not match';
                  isSubmitting = false;
                });
                return;
              }

              // Update password
              final old = availableProfiles[index];
              availableProfiles[index] = old.copyWith(password: newPw);
              await saveUserProfiles();

              // If current user matches email, update in-memory too
              if (currentUser.value?.email == email) {
                currentUser.value = availableProfiles[index];
              }

              if (mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password reset successfully.'),
                    backgroundColor: Color(0xFF2DBE6C),
                  ),
                );
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Text(
                    'Reset Password',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your account email and choose a new password.',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newPwCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      hintText: 'Minimum 8 characters',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmCtrl,
                    obscureText: true,
                    onSubmitted: (_) => submit(),
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  if (localError != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade700,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              localError!,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: isSubmitting ? null : submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF2DBE6C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            isSubmitting ? 'Please wait…' : 'Reset Password',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      emailCtrl.dispose();
      newPwCtrl.dispose();
      confirmCtrl.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2DBE6C), Color(0xFF66BB6A)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Welcome back text
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Sign in to continue charging',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 40),

                // EV Icon
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.electric_car,
                    size: 80,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 40),

                // Login options card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Error message
                      if (errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  errorMessage!,
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Email TextField
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          if (errorMessage != null) {
                            setState(() => errorMessage = null);
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter your email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFF2DBE6C),
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Password TextField
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        onChanged: (value) {
                          if (errorMessage != null) {
                            setState(() => errorMessage = null);
                          }
                        },
                        onSubmitted: (value) => _handleLogin(),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFF2DBE6C),
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _showForgotPasswordSheet,
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Color(0xFF2DBE6C),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Sign In Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          onPressed: _handleLogin,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF2DBE6C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey[300])),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Or continue with',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey[300])),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUpPage(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFF2DBE6C),
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                "Don't have an account? ",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF2DBE6C),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Terms and Privacy
                Text(
                  'By continuing, you agree to our Terms & Privacy Policy',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ---------------- SIGN UP PAGE ----------------
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _vehicleController = TextEditingController();
  final _licensePlateController = TextEditingController();
  String? errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _vehicleController.dispose();
    _licensePlateController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    // Gather inputs
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final vehicle = _vehicleController.text.trim();
    final licensePlate = _licensePlateController.text.trim();

    // Validation
    if (name.isEmpty) {
      setState(() => errorMessage = 'Please enter your name');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      setState(() => errorMessage = 'Please enter a valid email');
      return;
    }
    if (password.length < 8) {
      setState(() => errorMessage = 'Password must be at least 8 characters');
      return;
    }
    if (password != confirmPassword) {
      setState(() => errorMessage = 'Passwords do not match');
      return;
    }

    // Check if email already exists
    final existingUser = availableProfiles.firstWhere(
      (p) => p.email == email,
      orElse: () => UserProfile(
        name: '',
        email: '',
        password: '',
        initials: '',
        walletBalance: 0,
        vehicle: '',
        licensePlate: '',
      ),
    );

    if (existingUser.email.isNotEmpty) {
      setState(() => errorMessage = 'Email already registered');
      return;
    }

    // Create initials from name
    final nameParts = name.split(' ');
    String initials = '';
    if (nameParts.isNotEmpty) {
      initials = nameParts[0][0].toUpperCase();
      if (nameParts.length > 1) {
        initials += nameParts[1][0].toUpperCase();
      }
    }

    // Create new user profile
    final newUser = UserProfile(
      name: name,
      email: email,
      password: password,
      initials: initials,
      walletBalance: 0.0,
      vehicle: vehicle.isNotEmpty ? vehicle : 'No vehicle added',
      licensePlate: licensePlate,
    );

    // Add to available profiles
    availableProfiles.add(newUser);

    // Save profiles to persistent storage
    await saveUserProfiles();

    // Set as current user
    currentUser.value = newUser;

    // Navigate to main screen (ensure widget still mounted after async work)
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2DBE6C), Color(0xFF66BB6A)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),

                const SizedBox(height: 20),

                // Create Account text
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Join us to start charging',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 40),

                // Sign Up Form Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Error message
                      if (errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  errorMessage!,
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Name TextField
                      TextField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        onChanged: (value) {
                          if (errorMessage != null) {
                            setState(() => errorMessage = null);
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          hintText: 'Enter your full name',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFF2DBE6C),
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Email TextField
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          if (errorMessage != null) {
                            setState(() => errorMessage = null);
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter your email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFF2DBE6C),
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Password TextField
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        onChanged: (value) {
                          if (errorMessage != null) {
                            setState(() => errorMessage = null);
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Minimum 8 characters',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFF2DBE6C),
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Confirm Password TextField
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        onChanged: (value) {
                          if (errorMessage != null) {
                            setState(() => errorMessage = null);
                          }
                        },
                        onSubmitted: (value) => _handleSignUp(),
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          hintText: 'Re-enter your password',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFF2DBE6C),
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Vehicle Model TextField
                      TextField(
                        controller: _vehicleController,
                        textCapitalization: TextCapitalization.words,
                        onChanged: (value) {
                          if (errorMessage != null) {
                            setState(() => errorMessage = null);
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Vehicle Model (optional)',
                          hintText: 'e.g. Tesla Model 3',
                          prefixIcon: const Icon(Icons.directions_car_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFF2DBE6C),
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // License Plate TextField
                      TextField(
                        controller: _licensePlateController,
                        textCapitalization: TextCapitalization.characters,
                        onChanged: (value) {
                          if (errorMessage != null) {
                            setState(() => errorMessage = null);
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'License Plate (optional)',
                          hintText: 'e.g. AB 123 CD',
                          prefixIcon: const Icon(
                            Icons.confirmation_number_outlined,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFF2DBE6C),
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          onPressed: _handleSignUp,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF2DBE6C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Already have account
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: RichText(
                          text: const TextSpan(
                            text: 'Already have an account? ',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                            children: [
                              TextSpan(
                                text: 'Sign In',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF2DBE6C),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Terms and Privacy
                Text(
                  'By signing up, you agree to our Terms & Privacy Policy',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ---------------- MAIN SCREEN (BOTTOM NAV) ----------------
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  final pages = const [
    MapPlaceholderPage(),
    ScanUiPage(),
    WalletUiPage(),
    ProfileUiPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          pages[currentIndex],
          ValueListenableBuilder<ChargingSession?>(
            valueListenable: currentChargingSession,
            builder: (context, session, child) {
              if (session == null) return const SizedBox.shrink();

              return Positioned(
                bottom: 80,
                right: 16,
                child: ChargingFloatingWidget(
                  station: session.station,
                  connector: session.connector,
                  onStop: () {
                    currentChargingSession.value = null;
                    clearCurrentChargingSessionForUser(
                      currentUser.value?.email ?? 'guest',
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => setState(() => currentIndex = i),
        selectedItemColor: const Color(0xFF2DBE6C),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: ''),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: '',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}

/// ---------------- CHARGING STATIONS LIST ----------------
// Global stations list so scanner / manual code entry can find stations by
// their printed code (e.g. EV001, EV002...). Added two new stations in
// Lushnje and Divjakë as requested; connectors are active.
final List<ChargingStationLocation> allStations = [
  ChargingStationLocation(
    id: '1',
    code: 'EV001',
    name: 'EV Charge Tirana Center',
    address: 'Rruga Barrikadave, Tirana 1001',
    city: 'Tirana',
    distance: '2.3 km',
    latitude: 41.3275,
    longitude: 19.8187,
    connectors: [
      Connector(
        type: 'CCS2',
        pricePerKwh: 50,
        powerKw: 120,
        isAvailable: false,
        currentUser: 'Ardi M.',
        batteryPercentage: 67,
      ),
      Connector(type: 'GBT', pricePerKwh: 50, powerKw: 80, isAvailable: true),
      Connector(
        type: 'Type 2',
        pricePerKwh: 50,
        powerKw: 22,
        isAvailable: true,
      ),
    ],
  ),
  ChargingStationLocation(
    id: '2',
    code: 'EV002',
    name: 'EV Charge Tirana Mall',
    address: 'Rruga e Kavajes, Tirana 1023',
    city: 'Tirana',
    distance: '3.8 km',
    latitude: 41.3270,
    longitude: 19.8050,
    connectors: [
      Connector(type: 'CCS2', pricePerKwh: 40, powerKw: 120, isAvailable: true),
      Connector(
        type: 'Type 2',
        pricePerKwh: 40,
        powerKw: 22,
        isAvailable: false,
        currentUser: 'Elona K.',
        batteryPercentage: 89,
      ),
    ],
  ),
  ChargingStationLocation(
    id: '3',
    code: 'EV003',
    name: 'EV Charge Tirana Airport',
    address: 'Rruga Nene Tereza, Rinas',
    city: 'Tirana',
    distance: '18.5 km',
    latitude: 41.4145,
    longitude: 19.7200,
    connectors: [
      Connector(type: 'GBT', pricePerKwh: 50, powerKw: 80, isAvailable: true),
      Connector(
        type: 'CCS2',
        pricePerKwh: 50,
        powerKw: 120,
        isAvailable: false,
        currentUser: 'Besnik H.',
        batteryPercentage: 45,
      ),
      Connector(
        type: 'Type 2',
        pricePerKwh: 50,
        powerKw: 22,
        isAvailable: true,
      ),
    ],
  ),
  ChargingStationLocation(
    id: '4',
    code: 'EV004',
    name: 'EV Charge Durres Port',
    address: 'Rruga Taulantia, Durres 2001',
    city: 'Durres',
    distance: '38.2 km',
    latitude: 41.3230,
    longitude: 19.4414,
    connectors: [
      Connector(type: 'CCS2', pricePerKwh: 30, powerKw: 120, isAvailable: true),
      Connector(
        type: 'Type 2',
        pricePerKwh: 30,
        powerKw: 22,
        isAvailable: true,
      ),
    ],
  ),
  ChargingStationLocation(
    id: '5',
    code: 'EV005',
    name: 'EV Charge Durres Beach',
    address: 'Shkembi Kavajes, Durres 2504',
    city: 'Durres',
    distance: '42.1 km',
    latitude: 41.3080,
    longitude: 19.4390,
    connectors: [
      Connector(type: 'CCS2', pricePerKwh: 30, powerKw: 120, isAvailable: true),
      Connector(type: 'GBT', pricePerKwh: 30, powerKw: 80, isAvailable: true),
      Connector(
        type: 'Type 2',
        pricePerKwh: 30,
        powerKw: 22,
        isAvailable: true,
      ),
    ],
  ),
  ChargingStationLocation(
    id: '6',
    code: 'EV006',
    name: 'EV Charge Vlore Center',
    address: 'Rruga Independence, Vlore 9401',
    city: 'Vlore',
    distance: '150.3 km',
    latitude: 40.4668,
    longitude: 19.4897,
    connectors: [
      Connector(
        type: 'CCS2',
        pricePerKwh: 40,
        powerKw: 120,
        isAvailable: false,
        isOffline: true,
      ),
      Connector(
        type: 'GBT',
        pricePerKwh: 40,
        powerKw: 80,
        isAvailable: false,
        isOffline: true,
      ),
      Connector(
        type: 'Type 2',
        pricePerKwh: 40,
        powerKw: 22,
        isAvailable: false,
        isOffline: true,
      ),
    ],
  ),
  ChargingStationLocation(
    id: '7',
    code: 'EV007',
    name: 'EV Charge Shkoder North',
    address: 'Rruga Studenti, Shkoder 4001',
    city: 'Shkoder',
    distance: '102.5 km',
    latitude: 42.0687,
    longitude: 19.5126,
    connectors: [
      Connector(type: 'CCS2', pricePerKwh: 40, powerKw: 120, isAvailable: true),
      Connector(type: 'GBT', pricePerKwh: 40, powerKw: 80, isAvailable: true),
      Connector(
        type: 'Type 2',
        pricePerKwh: 40,
        powerKw: 22,
        isAvailable: true,
      ),
    ],
  ),
  ChargingStationLocation(
    id: '8',
    code: 'EV008',
    name: 'EV Charge Elbasan Center',
    address: 'Bulevardi Qemal Stafa, Elbasan 3001',
    city: 'Elbasan',
    distance: '54.7 km',
    latitude: 41.1192,
    longitude: 20.0822,
    connectors: [
      Connector(type: 'CCS2', pricePerKwh: 30, powerKw: 120, isAvailable: true),
      Connector(type: 'GBT', pricePerKwh: 30, powerKw: 80, isAvailable: true),
      Connector(
        type: 'Type 2',
        pricePerKwh: 30,
        powerKw: 22,
        isAvailable: true,
      ),
    ],
  ),
  ChargingStationLocation(
    id: '9',
    code: 'EV009',
    name: 'EV Charge Korce Highland',
    address: 'Bulevardi Republika, Korce 7001',
    city: 'Korce',
    distance: '178.3 km',
    latitude: 40.6167,
    longitude: 20.7833,
    connectors: [
      Connector(type: 'CCS2', pricePerKwh: 50, powerKw: 120, isAvailable: true),
      Connector(type: 'GBT', pricePerKwh: 50, powerKw: 80, isAvailable: true),
      Connector(
        type: 'Type 2',
        pricePerKwh: 50,
        powerKw: 22,
        isAvailable: true,
      ),
    ],
  ),
  ChargingStationLocation(
    id: '10',
    code: 'EV010',
    name: 'EV Charge Berat Castle View',
    address: 'Rruga Antipatrea, Berat 5001',
    city: 'Berat',
    distance: '122.8 km',
    latitude: 40.7069,
    longitude: 19.9526,
    connectors: [
      Connector(type: 'CCS2', pricePerKwh: 40, powerKw: 120, isAvailable: true),
      Connector(type: 'GBT', pricePerKwh: 40, powerKw: 80, isAvailable: true),
      Connector(
        type: 'Type 2',
        pricePerKwh: 40,
        powerKw: 22,
        isAvailable: true,
      ),
    ],
  ),
  // New station: Lushnje
  ChargingStationLocation(
    id: '11',
    code: 'EV011',
    name: 'EV Charge Lushnje Center',
    address: 'Rruga Kryesore, Lushnje',
    city: 'Lushnje',
    distance: '85.0 km',
    latitude: 40.9447,
    longitude: 19.7136,
    connectors: [
      Connector(type: 'CCS2', pricePerKwh: 30, powerKw: 120, isAvailable: true),
      Connector(type: 'GBT', pricePerKwh: 30, powerKw: 80, isAvailable: true),
      Connector(
        type: 'Type 2',
        pricePerKwh: 30,
        powerKw: 22,
        isAvailable: true,
      ),
    ],
  ),
  // New station: Divjakë
  // Replaced Divjakë with multiple new stations in cities that lacked chargers
  ChargingStationLocation(
    id: '12',
    code: 'EV012',
    name: 'EV Charge Fier Central',
    address: 'Rruga 1 Maj, Fier',
    city: 'Fier',
    distance: '95.0 km',
    latitude: 40.7267,
    longitude: 19.5546,
    connectors: [
      Connector(type: 'CCS2', pricePerKwh: 30, powerKw: 120, isAvailable: true),
      Connector(
        type: 'Type 2',
        pricePerKwh: 30,
        powerKw: 22,
        isAvailable: true,
      ),
    ],
  ),
  ChargingStationLocation(
    id: '13',
    code: 'EV013',
    name: 'EV Charge Gjirokaster Old Bazaar',
    address: 'Sheshi Demokracia, Gjirokaster',
    city: 'Gjirokaster',
    distance: '245.2 km',
    latitude: 40.0753,
    longitude: 20.1389,
    connectors: [
      Connector(type: 'GBT', pricePerKwh: 35, powerKw: 22, isAvailable: true),
      Connector(
        type: 'Type 2',
        pricePerKwh: 35,
        powerKw: 22,
        isAvailable: true,
      ),
    ],
  ),
  ChargingStationLocation(
    id: '14',
    code: 'EV014',
    name: 'EV Charge Pogradec Lakefront',
    address: 'Bulevardi Liqeni, Pogradec',
    city: 'Pogradec',
    distance: '310.6 km',
    latitude: 40.9170,
    longitude: 20.6566,
    connectors: [
      Connector(type: 'CCS2', pricePerKwh: 40, powerKw: 22, isAvailable: true),
      Connector(type: 'GBT', pricePerKwh: 40, powerKw: 22, isAvailable: true),
      Connector(
        type: 'Type 2',
        pricePerKwh: 40,
        powerKw: 22,
        isAvailable: true,
      ),
    ],
  ),

  // New stations to bring total to 20
  ChargingStationLocation(
    id: '15',
    code: 'EV015',
    name: 'EV Charge Sarande Seafront',
    address: 'Rruga Butrinti, Sarande',
    city: 'Sarande',
    distance: '280.0 km',
    latitude: 39.8756,
    longitude: 20.0067,
    connectors: [
      Connector(type: 'CCS2', pricePerKwh: 45, powerKw: 120, isAvailable: true),
      Connector(
        type: 'Type 2',
        pricePerKwh: 45,
        powerKw: 22,
        isAvailable: true,
      ),
    ],
  ),
  ChargingStationLocation(
    id: '16',
    code: 'EV016',
    name: 'EV Charge Kukes Center',
    address: 'Bulevardi i Ri, Kukes',
    city: 'Kukes',
    distance: '150.0 km',
    latitude: 42.0767,
    longitude: 20.4211,
    connectors: [
      Connector(type: 'GBT', pricePerKwh: 35, powerKw: 22, isAvailable: true),
      Connector(
        type: 'Type 2',
        pricePerKwh: 35,
        powerKw: 22,
        isAvailable: true,
      ),
    ],
  ),
  ChargingStationLocation(
    id: '17',
    code: 'EV017',
    name: 'EV Charge Lezhe Center',
    address: 'Sheshi Gjergj Kastrioti, Lezhe',
    city: 'Lezhe',
    distance: '60.0 km',
    latitude: 41.7861,
    longitude: 19.6464,
    connectors: [
      Connector(type: 'CCS2', pricePerKwh: 35, powerKw: 120, isAvailable: true),
      Connector(type: 'GBT', pricePerKwh: 35, powerKw: 80, isAvailable: true),
      Connector(
        type: 'Type 2',
        pricePerKwh: 35,
        powerKw: 22,
        isAvailable: true,
      ),
    ],
  ),
  ChargingStationLocation(
    id: '18',
    code: 'EV018',
    name: 'EV Charge Peshkopi Center',
    address: 'Rruga e Dibrës, Peshkopi',
    city: 'Peshkopi',
    distance: '165.0 km',
    latitude: 41.6828,
    longitude: 20.4283,
    connectors: [
      Connector(type: 'GBT', pricePerKwh: 30, powerKw: 22, isAvailable: true),
      Connector(
        type: 'Type 2',
        pricePerKwh: 30,
        powerKw: 22,
        isAvailable: true,
      ),
    ],
  ),
  ChargingStationLocation(
    id: '19',
    code: 'EV019',
    name: 'EV Charge Kruje Castle',
    address: 'Rruga e Kalasë, Kruje',
    city: 'Kruje',
    distance: '35.0 km',
    latitude: 41.5092,
    longitude: 19.7928,
    connectors: [
      Connector(type: 'CCS2', pricePerKwh: 35, powerKw: 120, isAvailable: true),
      Connector(
        type: 'Type 2',
        pricePerKwh: 35,
        powerKw: 22,
        isAvailable: true,
      ),
    ],
  ),
  ChargingStationLocation(
    id: '20',
    code: 'EV020',
    name: 'EV Charge Himare Beach',
    address: 'Rruga e Plazhit, Himare',
    city: 'Himare',
    distance: '210.0 km',
    latitude: 40.1022,
    longitude: 19.7447,
    connectors: [
      Connector(type: 'CCS2', pricePerKwh: 45, powerKw: 120, isAvailable: true),
      Connector(type: 'GBT', pricePerKwh: 45, powerKw: 80, isAvailable: true),
      Connector(
        type: 'Type 2',
        pricePerKwh: 45,
        powerKw: 22,
        isAvailable: true,
      ),
    ],
  ),
  // New station: Divjakë-Karavasta National Park
  ChargingStationLocation(
    id: '21',
    code: 'EV021',
    name: 'EV Charge Divjakë-Karavasta Park',
    address: 'Parku Kombëtar Divjakë-Karavasta',
    city: 'Divjakë',
    distance: '95.0 km',
    latitude: 40.9728,
    longitude: 19.4801,
    connectors: [
      Connector(type: 'CCS2', pricePerKwh: 40, powerKw: 120, isAvailable: true),
      Connector(type: 'GBT', pricePerKwh: 40, powerKw: 80, isAvailable: true),
      Connector(
        type: 'Type 2',
        pricePerKwh: 40,
        powerKw: 22,
        isAvailable: true,
      ),
    ],
  ),
  // New station: Tirana - American Style Connectors
  ChargingStationLocation(
    id: '22',
    code: 'EV022',
    name: 'EV Charge Tirana American Hub',
    address: 'Rruga e Elbasanit, Tirana',
    city: 'Tirana',
    distance: '4.2 km',
    latitude: 41.3180,
    longitude: 19.8350,
    connectors: [
      Connector(
        type: 'Type 1',
        pricePerKwh: 45,
        powerKw: 19,
        isAvailable: true,
      ),
      Connector(
        type: 'Tesla',
        pricePerKwh: 50,
        powerKw: 150,
        isAvailable: true,
      ),
      Connector(type: 'CCS1', pricePerKwh: 50, powerKw: 120, isAvailable: true),
      Connector(
        type: 'CHAdeMO',
        pricePerKwh: 45,
        powerKw: 62,
        isAvailable: true,
      ),
    ],
  ),
  // New station: Durrës - American Style Connectors
  ChargingStationLocation(
    id: '23',
    code: 'EV023',
    name: 'EV Charge Durrës American Hub',
    address: 'Rruga Aleksandër Goga, Durrës',
    city: 'Durrës',
    distance: '38.5 km',
    latitude: 41.3200,
    longitude: 19.4500,
    connectors: [
      Connector(
        type: 'Type 1',
        pricePerKwh: 45,
        powerKw: 19,
        isAvailable: true,
      ),
      Connector(
        type: 'Tesla',
        pricePerKwh: 50,
        powerKw: 150,
        isAvailable: true,
      ),
      Connector(type: 'CCS1', pricePerKwh: 50, powerKw: 120, isAvailable: true),
      Connector(
        type: 'CHAdeMO',
        pricePerKwh: 45,
        powerKw: 62,
        isAvailable: true,
      ),
    ],
  ),
  // 10 new Tirana stations with 2 connectors each
  // EV024: CCS2 + GBT
  ChargingStationLocation(
    id: '24',
    code: 'EV024',
    name: 'EV Charge Tirana Blloku',
    address: 'Rruga Ismail Qemali, Blloku',
    city: 'Tirana',
    distance: '1.5 km',
    latitude: 41.3190,
    longitude: 19.8210,
    connectors: [
      Connector(type: 'CCS2', pricePerKwh: 45, powerKw: 120, isAvailable: true),
      Connector(type: 'GBT', pricePerKwh: 45, powerKw: 80, isAvailable: true),
    ],
  ),
  // EV025: Type 2 + Type 1
  ChargingStationLocation(
    id: '25',
    code: 'EV025',
    name: 'EV Charge Tirana Pazari i Ri',
    address: 'Pazari i Ri, Tirana',
    city: 'Tirana',
    distance: '2.0 km',
    latitude: 41.3295,
    longitude: 19.8230,
    connectors: [
      Connector(
        type: 'Type 2',
        pricePerKwh: 40,
        powerKw: 22,
        isAvailable: true,
      ),
      Connector(
        type: 'Type 1',
        pricePerKwh: 40,
        powerKw: 19,
        isAvailable: true,
      ),
    ],
  ),
  // EV026: Tesla + CHAdeMO
  ChargingStationLocation(
    id: '26',
    code: 'EV026',
    name: 'EV Charge Tirana Lake Park',
    address: 'Parku i Liqenit Artificial, Tirana',
    city: 'Tirana',
    distance: '3.0 km',
    latitude: 41.3120,
    longitude: 19.8320,
    connectors: [
      Connector(
        type: 'Tesla',
        pricePerKwh: 50,
        powerKw: 150,
        isAvailable: true,
      ),
      Connector(
        type: 'CHAdeMO',
        pricePerKwh: 45,
        powerKw: 62,
        isAvailable: true,
      ),
    ],
  ),
  // EV027: GBT + GBT
  ChargingStationLocation(
    id: '27',
    code: 'EV027',
    name: 'EV Charge Tirana 21 Dhjetori',
    address: 'Sheshi 21 Dhjetori, Tirana',
    city: 'Tirana',
    distance: '1.8 km',
    latitude: 41.3260,
    longitude: 19.8150,
    connectors: [
      Connector(type: 'GBT', pricePerKwh: 42, powerKw: 80, isAvailable: true),
      Connector(type: 'GBT', pricePerKwh: 42, powerKw: 60, isAvailable: true),
    ],
  ),
  // EV028: CCS1 + CCS2
  ChargingStationLocation(
    id: '28',
    code: 'EV028',
    name: 'EV Charge Tirana Komuna e Parisit',
    address: 'Rruga Komuna e Parisit, Tirana',
    city: 'Tirana',
    distance: '2.5 km',
    latitude: 41.3310,
    longitude: 19.8100,
    connectors: [
      Connector(type: 'CCS1', pricePerKwh: 48, powerKw: 120, isAvailable: true),
      Connector(type: 'CCS2', pricePerKwh: 48, powerKw: 150, isAvailable: true),
    ],
  ),
  // EV029: CCS2 + CCS2 - OFFLINE
  ChargingStationLocation(
    id: '29',
    code: 'EV029',
    name: 'EV Charge Tirana TEG',
    address: 'TEG Shopping Center, Tirana',
    city: 'Tirana',
    distance: '5.0 km',
    latitude: 41.3450,
    longitude: 19.7950,
    connectors: [
      Connector(
        type: 'CCS2',
        pricePerKwh: 45,
        powerKw: 150,
        isAvailable: false,
        isOffline: true,
      ),
      Connector(
        type: 'CCS2',
        pricePerKwh: 45,
        powerKw: 120,
        isAvailable: false,
        isOffline: true,
      ),
    ],
  ),
  // EV030: CCS2 + GBT - OFFLINE
  ChargingStationLocation(
    id: '30',
    code: 'EV030',
    name: 'EV Charge Tirana Kombinat',
    address: 'Rruga Dritan Hoxha, Kombinat',
    city: 'Tirana',
    distance: '6.0 km',
    latitude: 41.3150,
    longitude: 19.7800,
    connectors: [
      Connector(
        type: 'CCS2',
        pricePerKwh: 40,
        powerKw: 100,
        isAvailable: false,
        isOffline: true,
      ),
      Connector(
        type: 'GBT',
        pricePerKwh: 40,
        powerKw: 60,
        isAvailable: false,
        isOffline: true,
      ),
    ],
  ),
  // EV031: Type 2 + Type 1
  ChargingStationLocation(
    id: '31',
    code: 'EV031',
    name: 'EV Charge Tirana Selvia',
    address: 'Rruga e Dibres, Selvia',
    city: 'Tirana',
    distance: '4.0 km',
    latitude: 41.3400,
    longitude: 19.8280,
    connectors: [
      Connector(
        type: 'Type 2',
        pricePerKwh: 38,
        powerKw: 22,
        isAvailable: true,
      ),
      Connector(
        type: 'Type 1',
        pricePerKwh: 38,
        powerKw: 19,
        isAvailable: true,
      ),
    ],
  ),
  // EV032: Tesla + CHAdeMO
  ChargingStationLocation(
    id: '32',
    code: 'EV032',
    name: 'EV Charge Tirana Sauk',
    address: 'Rruga e Saukut, Tirana',
    city: 'Tirana',
    distance: '5.5 km',
    latitude: 41.3050,
    longitude: 19.8400,
    connectors: [
      Connector(
        type: 'Tesla',
        pricePerKwh: 52,
        powerKw: 250,
        isAvailable: true,
      ),
      Connector(
        type: 'CHAdeMO',
        pricePerKwh: 46,
        powerKw: 50,
        isAvailable: true,
      ),
    ],
  ),
  // EV033: CCS2 + CCS2 - OFFLINE
  ChargingStationLocation(
    id: '33',
    code: 'EV033',
    name: 'EV Charge Tirana Porcelan',
    address: 'Rruga e Porcelanit, Tirana',
    city: 'Tirana',
    distance: '3.5 km',
    latitude: 41.3380,
    longitude: 19.7880,
    connectors: [
      Connector(
        type: 'CCS2',
        pricePerKwh: 44,
        powerKw: 180,
        isAvailable: false,
        isOffline: true,
      ),
      Connector(
        type: 'CCS2',
        pricePerKwh: 44,
        powerKw: 180,
        isAvailable: false,
        isOffline: true,
      ),
    ],
  ),
  // EV034: Lezhë
  ChargingStationLocation(
    id: '34',
    code: 'EV034',
    name: 'EV Charge Lezhë Qendër',
    address: 'Bulevardi Gjergj Fishta, Lezhë',
    city: 'Lezhë',
    distance: '62.0 km',
    latitude: 41.7836,
    longitude: 19.6436,
    connectors: [
      Connector(type: 'CCS2', pricePerKwh: 42, powerKw: 120, isAvailable: true),
      Connector(type: 'GBT', pricePerKwh: 42, powerKw: 80, isAvailable: true),
      Connector(
        type: 'Type 2',
        pricePerKwh: 38,
        powerKw: 22,
        isAvailable: true,
      ),
    ],
  ),
  // EV035: Krujë
  ChargingStationLocation(
    id: '35',
    code: 'EV035',
    name: 'EV Charge Krujë Kalaja',
    address: 'Rruga e Kalasë, Krujë',
    city: 'Krujë',
    distance: '32.0 km',
    latitude: 41.5089,
    longitude: 19.7928,
    connectors: [
      Connector(type: 'CCS2', pricePerKwh: 45, powerKw: 100, isAvailable: true),
      Connector(
        type: 'Type 2',
        pricePerKwh: 40,
        powerKw: 22,
        isAvailable: true,
      ),
    ],
  ),
  // EV036: Kavajë
  ChargingStationLocation(
    id: '36',
    code: 'EV036',
    name: 'EV Charge Kavajë Qendër',
    address: 'Sheshi Kryesor, Kavajë',
    city: 'Kavajë',
    distance: '45.0 km',
    latitude: 41.1856,
    longitude: 19.5569,
    connectors: [
      Connector(type: 'GBT', pricePerKwh: 40, powerKw: 80, isAvailable: true),
      Connector(type: 'GBT', pricePerKwh: 40, powerKw: 60, isAvailable: true),
    ],
  ),
  // EV037: Peqin
  ChargingStationLocation(
    id: '37',
    code: 'EV037',
    name: 'EV Charge Peqin',
    address: 'Rruga Nacionale, Peqin',
    city: 'Peqin',
    distance: '55.0 km',
    latitude: 41.0467,
    longitude: 19.7500,
    connectors: [
      Connector(type: 'CCS2', pricePerKwh: 42, powerKw: 120, isAvailable: true),
      Connector(
        type: 'CHAdeMO',
        pricePerKwh: 42,
        powerKw: 62,
        isAvailable: true,
      ),
    ],
  ),
  // EV038: Gramsh
  ChargingStationLocation(
    id: '38',
    code: 'EV038',
    name: 'EV Charge Gramsh',
    address: 'Bulevardi Kryesor, Gramsh',
    city: 'Gramsh',
    distance: '85.0 km',
    latitude: 40.8697,
    longitude: 20.1847,
    connectors: [
      Connector(
        type: 'Type 2',
        pricePerKwh: 38,
        powerKw: 22,
        isAvailable: true,
      ),
      Connector(
        type: 'Type 1',
        pricePerKwh: 38,
        powerKw: 19,
        isAvailable: true,
      ),
    ],
  ),
  // EV039: Librazhd
  ChargingStationLocation(
    id: '39',
    code: 'EV039',
    name: 'EV Charge Librazhd',
    address: 'Rruga Kryesore, Librazhd',
    city: 'Librazhd',
    distance: '95.0 km',
    latitude: 41.1797,
    longitude: 20.3189,
    connectors: [
      Connector(type: 'CCS2', pricePerKwh: 44, powerKw: 100, isAvailable: true),
      Connector(type: 'GBT', pricePerKwh: 44, powerKw: 80, isAvailable: true),
    ],
  ),
  // EV040: Bulqizë
  ChargingStationLocation(
    id: '40',
    code: 'EV040',
    name: 'EV Charge Bulqizë',
    address: 'Sheshi i Qytetit, Bulqizë',
    city: 'Bulqizë',
    distance: '110.0 km',
    latitude: 41.4917,
    longitude: 20.2219,
    connectors: [
      Connector(
        type: 'Tesla',
        pricePerKwh: 50,
        powerKw: 150,
        isAvailable: true,
      ),
      Connector(type: 'CCS2', pricePerKwh: 45, powerKw: 120, isAvailable: true),
    ],
  ),
  // EV041: Pukë
  ChargingStationLocation(
    id: '41',
    code: 'EV041',
    name: 'EV Charge Pukë',
    address: 'Rruga Kryesore, Pukë',
    city: 'Pukë',
    distance: '130.0 km',
    latitude: 42.0444,
    longitude: 19.8992,
    connectors: [
      Connector(type: 'GBT', pricePerKwh: 42, powerKw: 80, isAvailable: true),
      Connector(
        type: 'Type 2',
        pricePerKwh: 40,
        powerKw: 22,
        isAvailable: true,
      ),
    ],
  ),
  // EV042: Tropojë
  ChargingStationLocation(
    id: '42',
    code: 'EV042',
    name: 'EV Charge Tropojë Bajram Curri',
    address: 'Sheshi Bajram Curri, Tropojë',
    city: 'Tropojë',
    distance: '180.0 km',
    latitude: 42.3581,
    longitude: 20.0761,
    connectors: [
      Connector(type: 'CCS2', pricePerKwh: 48, powerKw: 150, isAvailable: true),
      Connector(
        type: 'CHAdeMO',
        pricePerKwh: 45,
        powerKw: 62,
        isAvailable: true,
      ),
      Connector(
        type: 'Type 2',
        pricePerKwh: 42,
        powerKw: 22,
        isAvailable: true,
      ),
    ],
  ),
  // EV043: Malësi e Madhe (Koplik)
  ChargingStationLocation(
    id: '43',
    code: 'EV043',
    name: 'EV Charge Koplik',
    address: 'Rruga Nacionale, Koplik',
    city: 'Malësi e Madhe',
    distance: '120.0 km',
    latitude: 42.2136,
    longitude: 19.4367,
    connectors: [
      Connector(type: 'CCS2', pricePerKwh: 44, powerKw: 120, isAvailable: true),
      Connector(type: 'GBT', pricePerKwh: 44, powerKw: 80, isAvailable: true),
    ],
  ),
  // EV044: Has (Krumë)
  ChargingStationLocation(
    id: '44',
    code: 'EV044',
    name: 'EV Charge Krumë',
    address: 'Sheshi Kryesor, Krumë',
    city: 'Has',
    distance: '160.0 km',
    latitude: 42.1997,
    longitude: 20.4142,
    connectors: [
      Connector(
        type: 'Tesla',
        pricePerKwh: 52,
        powerKw: 250,
        isAvailable: true,
      ),
      Connector(type: 'CCS1', pricePerKwh: 48, powerKw: 120, isAvailable: true),
    ],
  ),
  // EV045: Mirditë (Rrëshen)
  ChargingStationLocation(
    id: '45',
    code: 'EV045',
    name: 'EV Charge Rrëshen',
    address: 'Bulevardi Kryesor, Rrëshen',
    city: 'Mirditë',
    distance: '75.0 km',
    latitude: 41.7678,
    longitude: 20.0075,
    connectors: [
      Connector(type: 'CCS2', pricePerKwh: 42, powerKw: 100, isAvailable: true),
      Connector(
        type: 'Type 2',
        pricePerKwh: 38,
        powerKw: 22,
        isAvailable: true,
      ),
    ],
  ),
  // EV046: Mat (Burrel)
  ChargingStationLocation(
    id: '46',
    code: 'EV046',
    name: 'EV Charge Burrel',
    address: 'Rruga Kryesore, Burrel',
    city: 'Mat',
    distance: '90.0 km',
    latitude: 41.6100,
    longitude: 20.0092,
    connectors: [
      Connector(type: 'GBT', pricePerKwh: 40, powerKw: 80, isAvailable: true),
      Connector(type: 'GBT', pricePerKwh: 40, powerKw: 60, isAvailable: true),
    ],
  ),
  // EV047: Kurbin (Laç)
  ChargingStationLocation(
    id: '47',
    code: 'EV047',
    name: 'EV Charge Laç',
    address: 'Bulevardi Kryesor, Laç',
    city: 'Kurbin',
    distance: '50.0 km',
    latitude: 41.6358,
    longitude: 19.7128,
    connectors: [
      Connector(type: 'CCS2', pricePerKwh: 44, powerKw: 150, isAvailable: true),
      Connector(type: 'CCS2', pricePerKwh: 44, powerKw: 120, isAvailable: true),
    ],
  ),
  // EV048: Mallakastër (Ballsh)
  ChargingStationLocation(
    id: '48',
    code: 'EV048',
    name: 'EV Charge Ballsh',
    address: 'Sheshi i Qytetit, Ballsh',
    city: 'Mallakastër',
    distance: '140.0 km',
    latitude: 40.5997,
    longitude: 19.9894,
    connectors: [
      Connector(
        type: 'CHAdeMO',
        pricePerKwh: 45,
        powerKw: 62,
        isAvailable: true,
      ),
      Connector(
        type: 'Type 2',
        pricePerKwh: 40,
        powerKw: 22,
        isAvailable: true,
      ),
    ],
  ),
  // EV049: Selenicë
  ChargingStationLocation(
    id: '49',
    code: 'EV049',
    name: 'EV Charge Selenicë',
    address: 'Rruga Nacionale, Selenicë',
    city: 'Selenicë',
    distance: '150.0 km',
    latitude: 40.5300,
    longitude: 19.6358,
    connectors: [
      Connector(type: 'CCS2', pricePerKwh: 46, powerKw: 120, isAvailable: true),
      Connector(type: 'GBT', pricePerKwh: 44, powerKw: 80, isAvailable: true),
    ],
  ),
  // EV050: Delvinë
  ChargingStationLocation(
    id: '50',
    code: 'EV050',
    name: 'EV Charge Delvinë',
    address: 'Sheshi Kryesor, Delvinë',
    city: 'Delvinë',
    distance: '220.0 km',
    latitude: 39.9511,
    longitude: 20.0978,
    connectors: [
      Connector(
        type: 'Tesla',
        pricePerKwh: 50,
        powerKw: 150,
        isAvailable: true,
      ),
      Connector(type: 'CCS2', pricePerKwh: 46, powerKw: 120, isAvailable: true),
      Connector(
        type: 'Type 2',
        pricePerKwh: 42,
        powerKw: 22,
        isAvailable: true,
      ),
    ],
  ),
];

// Ensure Type 2 connectors use power between 60 and 120 kW (instead of 22 kW).
void _normalizeType2PowerInStations() {
  final rnd = Random();
  for (final st in allStations) {
    for (var i = 0; i < st.connectors.length; i++) {
      final c = st.connectors[i];
      if (c.type.toLowerCase() == 'type 2' && (c.powerKw < 60)) {
        final newPower = 60 + rnd.nextInt(61); // 60..120
        st.connectors[i] = Connector(
          type: c.type,
          pricePerKwh: c.pricePerKwh,
          powerKw: newPower,
          isAvailable: c.isAvailable,
          isOffline: c.isOffline,
          currentUser: c.currentUser,
          batteryPercentage: c.batteryPercentage,
        );
      }
    }
  }
}

class MapPlaceholderPage extends StatefulWidget {
  const MapPlaceholderPage({super.key});

  @override
  State<MapPlaceholderPage> createState() => _MapPlaceholderPageState();
}

class _MapPlaceholderPageState extends State<MapPlaceholderPage> {
  // Use global `allStations` defined further up so other pages (scanner)
  // can query station codes and navigate directly.
  final List<ChargingStationLocation> stations = allStations;

  ChargingStationLocation? selectedStation;
  Connector? selectedConnector;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  // Filters
  final Set<String> connectorFilters = <String>{};
  bool onlyAvailable = false;
  Timer? _connectorRotateTimer;
  final List<String> _busyNames = const [
    'Ardi M.',
    'Elona K.',
    'Besnik H.',
    'Dorina P.',
    'Klajdi S.',
    'Megi T.',
    'Luan R.',
    'Eva N.',
    'Altin D.',
    'Sara P.',
  ];

  // Helper to get connector icon path
  String _getConnectorIconPath(String connectorType) {
    switch (connectorType.toLowerCase()) {
      case 'type 1':
        return 'assets/icon/connectors/type1.png';
      case 'type 2':
        return 'assets/icon/connectors/type2.png';
      case 'gbt':
        return 'assets/icon/connectors/gbtdc.png';
      case 'tesla':
        return 'assets/icon/connectors/tesla.png';
      case 'ccs1':
        return 'assets/icon/connectors/ccs1.png';
      case 'ccs':
      case 'ccs2':
        return 'assets/icon/connectors/ccs2.png';
      case 'chademo':
      case 'chade':
        return 'assets/icon/connectors/chade.png';
      default:
        return 'assets/icon/connectors/type2.png';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _connectorRotateTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Periodically update charging progress for busy connectors
    // Every 3 seconds: increase battery % realistically and free up when 100%
    _connectorRotateTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      final rnd = Random();
      bool needsUpdate = false;

      for (final st in stations) {
        for (var i = 0; i < st.connectors.length; i++) {
          final c = st.connectors[i];
          if (c.isOffline) continue;

          if (!c.isAvailable && c.batteryPercentage != null) {
            // Currently charging - increase battery percentage
            final currentPct = c.batteryPercentage!;
            // Charging speed: ~1-3% per 3 seconds based on power
            // Higher power = faster charging
            final chargeRate = c.powerKw >= 100 ? 3 : (c.powerKw >= 50 ? 2 : 1);
            final newPct = currentPct + chargeRate;

            if (newPct >= 100) {
              // Charging complete - free up the connector
              st.connectors[i] = Connector(
                type: c.type,
                pricePerKwh: c.pricePerKwh,
                powerKw: c.powerKw,
                isAvailable: true,
                isOffline: false,
                currentUser: null,
                batteryPercentage: null,
              );
            } else {
              // Update battery percentage
              st.connectors[i] = Connector(
                type: c.type,
                pricePerKwh: c.pricePerKwh,
                powerKw: c.powerKw,
                isAvailable: false,
                isOffline: false,
                currentUser: c.currentUser,
                batteryPercentage: newPct,
              );
            }
            needsUpdate = true;
          } else if (c.isAvailable) {
            // Very small chance (~1%) for a new user to start charging
            // But only if we have fewer than 5 busy connectors total
            int totalBusy = 0;
            for (final station in stations) {
              for (final conn in station.connectors) {
                if (!conn.isAvailable &&
                    !conn.isOffline &&
                    conn.currentUser != null) {
                  totalBusy++;
                }
              }
            }

            if (totalBusy < 5) {
              final startCharging = rnd.nextDouble() < 0.01; // 1% chance
              if (startCharging) {
                final newName = _busyNames[rnd.nextInt(_busyNames.length)];
                final startPct = 20 + rnd.nextInt(40); // Start between 20-60%
                st.connectors[i] = Connector(
                  type: c.type,
                  pricePerKwh: c.pricePerKwh,
                  powerKw: c.powerKw,
                  isAvailable: false,
                  isOffline: false,
                  currentUser: newName,
                  batteryPercentage: startPct,
                );
                needsUpdate = true;
              }
            }
          }
        }
      }

      if (needsUpdate && mounted) setState(() {});
    });
  }

  List<ChargingStationLocation> get filteredStations {
    var base = stations.toList();

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      final searchLower = searchQuery.toLowerCase();
      base = base.where((station) {
        return station.name.toLowerCase().contains(searchLower) ||
            station.address.toLowerCase().contains(searchLower) ||
            station.city.toLowerCase().contains(searchLower);
      }).toList();
    }

    // Apply availability-only filter
    if (onlyAvailable) {
      base = base
          .where((st) => st.connectors.any((c) => c.isAvailable))
          .toList();
    }

    // Apply connector-type filters (CCS2, GBT, Type 2, etc.)
    if (connectorFilters.isNotEmpty) {
      base = base
          .where(
            (st) => st.connectors.any(
              (c) =>
                  connectorFilters.contains(c.type) &&
                  (!onlyAvailable || c.isAvailable),
            ),
          )
          .toList();
    }

    return base;
  }

  void _showFilterSheet() {
    final allTypes = <String>{};
    for (final s in stations) {
      for (final c in s.connectors) {
        allTypes.add(c.type);
      }
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx2, setStateSheet) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.7,
              minChildSize: 0.4,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 16,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                    ),
                    child: ListView(
                      controller: scrollController,
                      children: [
                        const Text(
                          'Filter stations',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile(
                          title: const Text('Only show available connectors'),
                          value: onlyAvailable,
                          onChanged: (v) =>
                              setStateSheet(() => onlyAvailable = v),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Connector types',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        ...allTypes.map((type) {
                          return CheckboxListTile(
                            dense: true,
                            title: Text(type),
                            value: connectorFilters.contains(type),
                            onChanged: (v) => setStateSheet(() {
                              if (v == true) {
                                connectorFilters.add(type);
                              } else {
                                connectorFilters.remove(type);
                              }
                            }),
                          );
                        }).toList(),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  connectorFilters.clear();
                                  onlyAvailable = false;
                                });
                                Navigator.pop(ctx);
                              },
                              child: const Text('Clear'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {});
                                Navigator.pop(ctx);
                              },
                              child: const Text('Apply'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1B5E20), Color(0xFF2DBE6C)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.ev_station,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Find Charging',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Stations nearby',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2DBE6C),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${filteredStations.length}',
                                style: const TextStyle(
                                  color: Color(0xFF1B5E20),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Search bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Color(0xFF2DBE6C)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                setState(() {
                                  searchQuery = value;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Search stations...',
                                hintStyle: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (searchQuery.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  searchQuery = '';
                                });
                              },
                            ),

                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF2DBE6C,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: InkWell(
                                  onTap: _showFilterSheet,
                                  borderRadius: BorderRadius.circular(10),
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.tune,
                                      color: Color(0xFF2DBE6C),
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Map button: opens EvMapPage with the station list
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.map,
                                    color: Color(0xFF1B5E20),
                                  ),
                                  onPressed: () {
                                    // Build a lightweight ChargingStation list from our internal station model
                                    final mappedStations = stations.map((s) {
                                      // Build connector availability map
                                      final availMap = <String, bool>{};
                                      for (final c in s.connectors) {
                                        if (!availMap.containsKey(c.type)) {
                                          availMap[c.type] =
                                              c.isAvailable && !c.isOffline;
                                        } else if (c.isAvailable &&
                                            !c.isOffline) {
                                          availMap[c.type] = true;
                                        }
                                      }

                                      // Determine station status
                                      final allOffline = s.connectors.every(
                                        (c) => c.isOffline,
                                      );
                                      final allBusy =
                                          !allOffline &&
                                          s.connectors.every(
                                            (c) =>
                                                !c.isAvailable || c.isOffline,
                                          );

                                      return ChargingStation(
                                        id: s.code,
                                        name: s.name,
                                        lat: s.latitude,
                                        lng: s.longitude,
                                        city: s.city,
                                        address: s.address,
                                        connectorTypes: s.connectors
                                            .map((c) => c.type)
                                            .toList(),
                                        connectorPowers: s.connectors
                                            .map((c) => c.powerKw.toDouble())
                                            .toList(),
                                        hasAvailableConnector: s.connectors.any(
                                          (c) => c.isAvailable,
                                        ),
                                        connectorAvailability: availMap,
                                        isOffline: allOffline,
                                        isBusy: allBusy,
                                      );
                                    }).toList();

                                    // Get user's connector type and adapter from profile
                                    final user = currentUser.value;
                                    final userConnType =
                                        user?.preferredConnector;
                                    final adapterType = user?.adapterType;

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => EvMapPage(
                                          stations: mappedStations,
                                          userConnectorType: userConnType,
                                          adapterType: adapterType,
                                          onStationTap: (cs) {
                                            // Close the map and show details for the tapped station
                                            Navigator.pop(context);
                                            try {
                                              final found = stations.firstWhere(
                                                (st) => st.code == cs.id,
                                              );
                                              setState(() {
                                                selectedStation = found;
                                                selectedConnector = null;
                                              });
                                              _showStationDetails(
                                                context,
                                                found,
                                              );
                                            } catch (_) {
                                              // ignore if not found
                                            }
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Stations List
              Expanded(
                child: filteredStations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 80,
                              color: Colors.white.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No stations found',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try a different search term',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: filteredStations.length,
                        itemBuilder: (context, index) {
                          final station = filteredStations[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(24),
                                onTap: () {
                                  setState(() {
                                    selectedStation = station;
                                    selectedConnector = null;
                                  });
                                  _showStationDetails(context, station);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xFF2DBE6C),
                                                  Color(0xFF1B5E20),
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(
                                                    0xFF2DBE6C,
                                                  ).withOpacity(0.3),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.ev_station,
                                              color: Colors.white,
                                              size: 32,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  station.name,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.location_on,
                                                      size: 16,
                                                      color: Colors.grey[600],
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        station.address,
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color:
                                                              Colors.grey[600],
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF2DBE6C,
                                          ).withOpacity(0.05),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: const Color(
                                              0xFF2DBE6C,
                                            ).withOpacity(0.2),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: _buildStationInfo(
                                                Icons.cable,
                                                '${station.connectors.length} Types',
                                                const Color(0xFF2DBE6C),
                                              ),
                                            ),
                                            Container(
                                              width: 1,
                                              height: 40,
                                              color: Colors.grey[300],
                                            ),
                                            Expanded(
                                              child: _buildStationInfo(
                                                Icons.navigation,
                                                station.distance,
                                                const Color(0xFF1B5E20),
                                              ),
                                            ),
                                            Container(
                                              width: 1,
                                              height: 40,
                                              color: Colors.grey[300],
                                            ),
                                            Expanded(
                                              child: _buildStationInfo(
                                                Icons.payments,
                                                '${station.connectors.first.pricePerKwh} ALL',
                                                const Color(0xFFFFB300),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: station.id == '6'
                                                  ? Colors.orange.withOpacity(
                                                      0.1,
                                                    )
                                                  : Colors.green.withOpacity(
                                                      0.1,
                                                    ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration: BoxDecoration(
                                                    color: station.id == '6'
                                                        ? Colors.orange[700]
                                                        : Colors.green[700],
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  station.id == '6'
                                                      ? 'Unavailable'
                                                      : 'Available Now',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: station.id == '6'
                                                        ? Colors.orange[700]
                                                        : Colors.green[700],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          ...station.connectors
                                              .map(
                                                (c) => Container(
                                                  margin: const EdgeInsets.only(
                                                    right: 6,
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 6,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFF2DBE6C,
                                                    ).withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    c.type,
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: Color(0xFF1B5E20),
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isConnectorCompatible(String connectorType, String? vehicle) {
    final user = currentUser.value;
    final adapterType = user?.adapterType;
    final type = connectorType.toUpperCase();
    final userConn = user?.preferredConnector.toUpperCase() ?? '';

    // First check direct compatibility with user's preferred connector
    if (userConn.isNotEmpty &&
        type == (userConn == 'CCS' ? 'CCS2' : userConn)) {
      return true;
    }

    // Check adapter compatibility if user has one
    if (adapterType != null && adapterType.isNotEmpty) {
      final alternates = _getAlternatesForAdapter(
        adapterType,
        userConn.isEmpty ? type : userConn,
      );
      for (final alt in alternates) {
        if (type == alt || type == (alt == 'CCS' ? 'CCS2' : alt)) {
          return true;
        }
      }
    }

    if (vehicle == null || vehicle.isEmpty) return true;

    // Tesla compatibility: CCS2 connectors
    if (vehicle.toLowerCase().contains('tesla')) {
      return type == 'CCS2' || type == 'CCS' || type == 'TESLA';
    }

    // Avatr compatibility: GBT connectors
    if (vehicle.toLowerCase().contains('avatr')) {
      return type == 'GBT' || type == 'GB/T';
    }

    // Other vehicles are compatible with all connectors
    return true;
  }

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

  Widget _buildStationInfo(IconData icon, String text, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Colors.grey[800],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  // Directions flow removed: the 'Get Directions' button and its dialog
  // were intentionally removed per request. Navigation helpers were also
  // removed to keep the code clean; add url_launcher-based helpers if
  // you want to restore external navigation later.

  void _showStationDetails(
    BuildContext context,
    ChargingStationLocation station,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _StationDetailSheet(
        station: station,
        stations: stations,
        getConnectorIconPath: _getConnectorIconPath,
        isConnectorCompatible: _isConnectorCompatible,
      ),
    );
  }
}

/// ---------------- STATION DETAIL SHEET WITH LIVE UPDATES ----------------
class _StationDetailSheet extends StatefulWidget {
  final ChargingStationLocation station;
  final List<ChargingStationLocation> stations;
  final String Function(String) getConnectorIconPath;
  final bool Function(String, String?) isConnectorCompatible;

  const _StationDetailSheet({
    required this.station,
    required this.stations,
    required this.getConnectorIconPath,
    required this.isConnectorCompatible,
  });

  @override
  State<_StationDetailSheet> createState() => _StationDetailSheetState();
}

class _StationDetailSheetState extends State<_StationDetailSheet> {
  Timer? _refreshTimer;
  Connector? selectedConnector;
  late ChargingStationLocation _currentStation;

  @override
  void initState() {
    super.initState();
    _currentStation = widget.station;
    // Refresh UI every 3 seconds to show live charging progress
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        // Find the updated station from the stations list
        final updatedStation = widget.stations.firstWhere(
          (s) => s.id == widget.station.id,
          orElse: () => widget.station,
        );
        setState(() {
          _currentStation = updatedStation;
        });
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  bool _wouldBeIncompatibleWithoutAdapter(
    String connectorType,
    String? vehicle,
    String? adapterType,
  ) {
    if (adapterType == null || adapterType.isEmpty) return false;

    final type = connectorType.toUpperCase();

    // Parse adapter type: expects format 'A↔B' or 'A<->B'
    final parts = adapterType.replaceAll('<->', '↔').split('↔');
    if (parts.length != 2) return false;

    final a = parts[0].trim().toUpperCase();
    final b = parts[1].trim().toUpperCase();

    // Normalize CCS to CCS2 for matching
    String normalize(String s) => s == 'CCS' ? 'CCS2' : s;

    final normA = normalize(a);
    final normB = normalize(b);
    final normType = normalize(type);

    // Connector is "via adapter" if it matches one side of the adapter
    // but is not the user's native connector type
    return normType == normA || normType == normB;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2DBE6C).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.ev_station,
                          color: Color(0xFF2DBE6C),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentStation.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currentStation.address,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Select connector:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  ..._currentStation.connectors.map((connector) {
                    final user = currentUser.value;
                    final isCompatible = widget.isConnectorCompatible(
                      connector.type,
                      user?.vehicle,
                    );
                    final adapterType = user?.adapterType;
                    final type = connector.type.toUpperCase();
                    final isViaAdapter =
                        adapterType != null &&
                        adapterType.isNotEmpty &&
                        _wouldBeIncompatibleWithoutAdapter(
                          type,
                          user?.vehicle,
                          adapterType,
                        );
                    final isSelected =
                        selectedConnector?.type == connector.type;
                    final canSelect =
                        connector.isAvailable &&
                        !connector.isOffline &&
                        isCompatible;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: canSelect
                            ? () {
                                setState(() {
                                  selectedConnector = connector;
                                });
                              }
                            : null,
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: canSelect
                                ? (isSelected
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFF2DBE6C),
                                            Color(0xFF1B5E20),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null)
                                : LinearGradient(
                                    colors: [
                                      Colors.grey[300]!,
                                      Colors.grey[400]!,
                                    ],
                                  ),
                            color: canSelect && !isSelected
                                ? Colors.grey[100]
                                : null,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF2DBE6C)
                                  : canSelect
                                  ? Colors.grey[300]!
                                  : Colors.grey[400]!,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: 0.2)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Image.asset(
                                  widget.getConnectorIconPath(connector.type),
                                  width: 32,
                                  height: 32,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(
                                        Icons.power,
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xFF2DBE6C),
                                        size: 28,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          connector.type,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                        if (isViaAdapter) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.withValues(
                                                alpha: 0.2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              'via adapter',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.orange[800],
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${connector.powerKw} kW • ${connector.pricePerKwh} ALL/kWh',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isSelected
                                            ? Colors.white.withValues(
                                                alpha: 0.8,
                                              )
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (connector.isOffline)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Offline',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.red,
                                    ),
                                  ),
                                )
                              else if (!connector.isAvailable &&
                                  connector.currentUser != null)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFF2DBE6C,
                                            ).withValues(alpha: 0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.person,
                                            color: Color(0xFF2DBE6C),
                                            size: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          connector.currentUser!,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SizedBox(
                                          width: 45,
                                          height: 45,
                                          child: CircularProgressIndicator(
                                            value:
                                                (connector.batteryPercentage ??
                                                    0) /
                                                100,
                                            strokeWidth: 4,
                                            backgroundColor: Colors.grey[300],
                                            valueColor:
                                                const AlwaysStoppedAnimation<
                                                  Color
                                                >(Color(0xFF2DBE6C)),
                                          ),
                                        ),
                                        Text(
                                          '${connector.batteryPercentage?.toInt() ?? 0}%',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF2DBE6C),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              else if (!isCompatible)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Incompatible',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.orange,
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white.withValues(alpha: 0.2)
                                        : const Color(
                                            0xFF2DBE6C,
                                          ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Available',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF2DBE6C),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  if (selectedConnector != null)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          // Require minimum 500 ALL to start charging
                          final user = currentUser.value;
                          final balance = user?.walletBalance ?? 0.0;
                          if (balance < 500) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Nuk ke mjaftueshëm balance (min. 500 ALL) për të nisur karikimin. Rimbush portofolin.',
                                ),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            return;
                          }
                          Navigator.pop(context);
                          // Navigate to charging page
                          final random = Random();
                          final randomBatteryLevel =
                              20.0 + random.nextDouble() * 40.0;

                          currentChargingSession.value = ChargingSession(
                            _currentStation,
                            selectedConnector!,
                            batteryPercentage: randomBatteryLevel,
                          );

                          saveCurrentChargingSessionForUser(
                            currentUser.value?.email ?? 'guest',
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChargingPage(
                                station: _currentStation,
                                connector: selectedConnector!,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.bolt),
                        label: const Text(
                          'Start Charging',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF2DBE6C),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------- CHARGING PAGE (FULL SCREEN) ----------------
class ChargingPage extends StatefulWidget {
  final ChargingStationLocation station;
  final Connector connector;
  final bool autoCompleteCharging;
  final String? stopReason; // e.g., 'budget' for balance limit

  const ChargingPage({
    super.key,
    required this.station,
    required this.connector,
    this.autoCompleteCharging = false,
    this.stopReason,
  });

  @override
  State<ChargingPage> createState() => _ChargingPageState();
}

class _ChargingPageState extends State<ChargingPage>
    with TickerProviderStateMixin {
  late AnimationController _carController;
  late AnimationController _batteryController;
  late AnimationController _pulseController;
  late AnimationController _confettiController;

  late Animation<double> _pulseAnimation;

  bool isCharging = true;
  int currentTipIndex = 0;
  bool showConfetti = false;
  bool _hasPlayedTargetSound = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<String> motivationalMessages = [
    "🌱 You're saving the planet!",
    "⚡ Clean energy in action!",
    "🌍 Every kWh counts!",
    "💚 Eco-warrior mode activated!",
    "🔋 Powering the future!",
    "✨ Zero emissions = Pure magic!",
  ];

  final List<Map<String, String>> funFacts = [
    {
      'icon': '🚗',
      'fact': 'EVs convert 77% of energy to movement vs 12-30% for gas cars!',
    },
    {
      'icon': '🔌',
      'fact': 'Charging at home costs about 1/3 the price of gasoline!',
    },
    {
      'icon': '🌳',
      'fact': 'One EV can save 1.5 million grams of CO2 per year!',
    },
    {'icon': '⚡', 'fact': 'EVs have instant torque - 0 to 60mph in seconds!'},
    {'icon': '🔧', 'fact': 'EVs have 90% fewer moving parts than gas cars!'},
    {
      'icon': '🎯',
      'fact': 'Most EV charging happens overnight while you sleep!',
    },
  ];

  @override
  void initState() {
    super.initState();

    // Car sliding animation
    _carController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Battery fill animation
    _batteryController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Pulse animation for charging icon
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Confetti animation
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _carController.forward();
    _batteryController.repeat();

    // Rotate tips every 5 seconds
    _rotateTips();

    // Start charging simulation - only if not already running
    if (currentChargingSession.value != null) {
      _startChargingSimulation();
    }

    // If autoCompleteCharging is true, show receipt immediately
    if (widget.autoCompleteCharging) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _stopCharging(reason: widget.stopReason);
      });
    }
  }

  void _rotateTips() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 5));
      if (!mounted || !isCharging) return false;

      setState(() {
        currentTipIndex = (currentTipIndex + 1) % funFacts.length;
      });

      return true;
    });
  }

  void _startChargingSimulation() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted || currentChargingSession.value == null) return false;

      final session = currentChargingSession.value!;
      final targetPct = session.targetPercentage;

      // Wallet budget stop: compute how many kWh the current wallet can afford
      final user = currentUser.value;
      final price = widget.connector.pricePerKwh <= 0
          ? 0
          : widget.connector.pricePerKwh;
      final wallet = user?.walletBalance ?? double.infinity;
      final maxAffordableKwh = price > 0 ? (wallet / price) : double.infinity;
      final remainingAffordableKwh = maxAffordableKwh - session.totalKwh;

      // Check if target reached - stop and play sound
      if (session.batteryPercentage >= targetPct && !_hasPlayedTargetSound) {
        _hasPlayedTargetSound = true;
        _playChargingCompleteSound();
        _showTargetReachedNotification(targetPct);
        return false; // Stop simulation - target reached
      }

      // Convert % progress into realistic energy delivered (kWh) based on
      // a per-session battery capacity.
      final previousBatteryPercentage = session.batteryPercentage;

      // Base step increment
      double stepPct = 0.5;
      // If budget is nearly exhausted, limit the step so we don't exceed it
      if (remainingAffordableKwh.isFinite && remainingAffordableKwh <= 0) {
        // Already at budget limit -> stop with reason
        await _stopCharging(reason: 'budget');
        return false;
      }

      // Planned kWh for this step
      final plannedKwh = session.batteryCapacityKwh * (stepPct / 100.0);
      if (remainingAffordableKwh.isFinite &&
          plannedKwh > remainingAffordableKwh) {
        // Reduce step to fit the remaining budget
        stepPct = (remainingAffordableKwh / session.batteryCapacityKwh) * 100.0;
      }

      // Update global session data - clamp to target percentage as well
      session.batteryPercentage = (session.batteryPercentage + stepPct).clamp(
        0,
        targetPct,
      );
      final deltaPct = (session.batteryPercentage - previousBatteryPercentage)
          .clamp(0, 100);
      final appliedKwh = session.batteryCapacityKwh * (deltaPct / 100.0);
      session.totalKwh += appliedKwh;
      session.currentPower = 115 + (DateTime.now().second % 10);

      // Notify listeners - preserve targetPercentage
      currentChargingSession.value = ChargingSession(
        session.station,
        session.connector,
        batteryPercentage: session.batteryPercentage,
        currentPower: session.currentPower,
        totalKwh: session.totalKwh,
        batteryCapacityKwh: session.batteryCapacityKwh,
        targetPercentage: targetPct,
      );

      setState(() {
        // Show confetti when reaching milestones or target
        if (session.batteryPercentage == 50 ||
            session.batteryPercentage == 75 ||
            session.batteryPercentage >= targetPct) {
          showConfetti = true;
          _confettiController.forward(from: 0);
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() => showConfetti = false);
            }
          });
        }
      });

      // Check if target reached after update
      if (session.batteryPercentage >= targetPct && !_hasPlayedTargetSound) {
        _hasPlayedTargetSound = true;
        _playChargingCompleteSound();
        _showTargetReachedNotification(targetPct);
        return false;
      }

      // If wallet budget reached (or exceeded due to precision), stop
      if (remainingAffordableKwh.isFinite &&
          (session.totalKwh + 1e-6) >= maxAffordableKwh) {
        await _stopCharging(reason: 'budget');
        return false;
      }

      return session.batteryPercentage < targetPct;
    });
  }

  Future<void> _playChargingCompleteSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/charging_complete.mp3'));
    } catch (e) {
      // Fallback: use a URL-based sound if asset not available
      try {
        await _audioPlayer.play(
          UrlSource(
            'https://assets.mixkit.co/active_storage/sfx/2869/2869-preview.mp3',
          ),
        );
      } catch (_) {
        // Ignore if sound fails
      }
    }
  }

  void _showTargetReachedNotification(double targetPct) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '🎉 Karikimi u plotësua! Bateria arriti ${targetPct.toInt()}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF2DBE6C),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  void dispose() {
    _carController.dispose();
    _batteryController.dispose();
    _pulseController.dispose();
    _confettiController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  String _getAchievement() {
    final session = currentChargingSession.value;
    if (session == null) return '🌱 Green Starter!';

    if (session.batteryPercentage >= 100) {
      return '⚡ Full Tank Champion!';
    } else if (session.batteryPercentage >= 80) {
      return '🌟 Power Player!';
    } else if (session.batteryPercentage >= 50) {
      return '💚 Eco Warrior!';
    } else if (session.totalKwh > 10) {
      return '🔋 Energy Enthusiast!';
    } else {
      return '🌱 Green Starter!';
    }
  }

  String _calculateTier(int ecoPoints) {
    if (ecoPoints >= 1000) return 'Platinum';
    if (ecoPoints >= 500) return 'Gold';
    if (ecoPoints >= 200) return 'Silver';
    return 'Bronze';
  }

  void _showAchievementUnlockedDialog(List<Achievement> achievements) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF1A1A2E),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Text('🏆', style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Achievement Unlocked!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: achievements
              .map(
                (achievement) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber.withValues(alpha: 0.3),
                        Colors.orange.withValues(alpha: 0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        achievement.icon.isNotEmpty ? achievement.icon : '⭐',
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              achievement.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              achievement.description,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
            child: const Text('Awesome! 🎉'),
          ),
        ],
      ),
    );
  }

  List<Achievement> _checkAndUnlockAchievements(
    List<Achievement> currentAchievements,
    int ecoPoints,
    int totalCharges,
    double totalCO2Saved,
    String currentCity,
  ) {
    final List<Achievement> updated = List.from(currentAchievements);

    for (final achievement in availableAchievements) {
      // Check if already unlocked
      final existingIndex = updated.indexWhere((a) => a.id == achievement.id);
      if (existingIndex >= 0 && updated[existingIndex].isUnlocked) {
        continue; // Already unlocked
      }

      bool shouldUnlock = false;

      // Check unlock conditions based on actual achievement IDs
      switch (achievement.id) {
        case 'ach_first_charge':
          // Unlock after completing first charging session
          shouldUnlock = totalCharges >= 1;
          break;
        case 'ach_eco_starter_500':
          // Unlock when reaching 500 eco points
          shouldUnlock = ecoPoints >= 500;
          break;
        case 'ach_green_driver_1000':
          // Unlock when reaching 1000 eco points
          shouldUnlock = ecoPoints >= 1000;
          break;
        case 'ach_city_explorer_2000':
          // Unlock when reaching 2000 eco points (charging in multiple cities)
          shouldUnlock = ecoPoints >= 2000;
          break;
        case 'ach_charge_master_10':
          // Unlock after completing 10 charging sessions
          shouldUnlock = totalCharges >= 10;
          break;
        case 'ach_fast_charger':
          // Unlock when using a fast charger (check if any session used 50kW+)
          // For now, unlock based on points threshold
          shouldUnlock = ecoPoints >= 3500;
          break;
        case 'ach_co2_saver_50':
          // Unlock when saving 50 kg of CO2
          shouldUnlock = totalCO2Saved >= 50;
          break;
        case 'ach_regular_5000':
          // Unlock when reaching 5000 eco points
          shouldUnlock = ecoPoints >= 5000;
          break;
        case 'ach_elite_8000':
          // Unlock when reaching 8000 eco points
          shouldUnlock = ecoPoints >= 8000;
          break;
        case 'ach_legend_10000':
          // Unlock when reaching 10000 eco points
          shouldUnlock = ecoPoints >= 10000;
          break;
      }

      if (shouldUnlock) {
        final unlockedAchievement = achievement.copyWith(
          isUnlocked: true,
          unlockedDate: DateTime.now(),
        );
        if (existingIndex >= 0) {
          updated[existingIndex] = unlockedAchievement;
        } else {
          updated.add(unlockedAchievement);
        }
      }
    }

    return updated;
  }

  Future<void> _stopCharging({String? reason}) async {
    final session = currentChargingSession.value;
    if (session == null) return;

    // Calculate total cost
    final totalCost = session.totalKwh * widget.connector.pricePerKwh;

    // Check if user has enough balance
    final user = currentUser.value;
    if (user != null && user.walletBalance < totalCost && reason != 'budget') {
      // Only show insufficient balance dialog if NOT stopped due to budget exhaustion
      // If stopped due to budget, we continue to show the invoice
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Insufficient Balance'),
          content: Text(
            'You need ${totalCost.toStringAsFixed(2)} ALL but only have ${user.walletBalance.toStringAsFixed(2)} ALL in your wallet.\n\nPlease top up your wallet to complete this charging session.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      isCharging = false;
      showConfetti = true;
    });

    _confettiController.forward(from: 0);

    // Calculate achievements and duration
    final String achievement = _getAchievement();
    final double co2Saved = session.totalKwh * 0.5;
    final duration = DateTime.now().difference(session.startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final durationText = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';

    // Determine charging type
    String chargingType = 'Standard charging';
    if (session.currentPower >= 100) {
      chargingType = 'Fast charging';
    } else if (session.currentPower >= 50) {
      chargingType = 'Medium charging';
    }

    // Deduct from wallet and add to history
    if (user != null) {
      // Calculate eco points earned (10 points per kWh + bonus for CO2 saved)
      final pointsEarned =
          (session.totalKwh * 10).toInt() + (co2Saved * 2).toInt();
      final newEcoPoints = user.ecoPoints + pointsEarned;
      final newTotalCharges = user.totalCharges + 1;
      final newTotalCO2Saved = user.totalCO2Saved + co2Saved;
      final newTier = _calculateTier(newEcoPoints);

      // Check for newly unlocked achievements
      final updatedAchievements = _checkAndUnlockAchievements(
        user.achievements,
        newEcoPoints,
        newTotalCharges,
        newTotalCO2Saved,
        widget.station.city,
      );

      // Find newly unlocked achievements to show notification
      final newlyUnlocked = updatedAchievements.where((updated) {
        final wasUnlocked = user.achievements.any(
          (old) => old.id == updated.id && old.isUnlocked,
        );
        return updated.isUnlocked && !wasUnlocked;
      }).toList();

      // Update wallet balance
      final index = availableProfiles.indexWhere((p) => p.email == user.email);
      if (index != -1) {
        availableProfiles[index] = user.copyWith(
          walletBalance: user.walletBalance - totalCost,
          ecoPoints: newEcoPoints,
          totalCharges: newTotalCharges,
          totalCO2Saved: newTotalCO2Saved,
          tier: newTier,
          achievements: updatedAchievements,
        );
        currentUser.value = availableProfiles[index];
      }

      // Show achievement unlock notification after a short delay
      if (newlyUnlocked.isNotEmpty && mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _showAchievementUnlockedDialog(newlyUnlocked);
          }
        });
      }

      // Add to charging history
      if (!userChargingHistory.containsKey(user.email)) {
        userChargingHistory[user.email] = [];
      }

      final now = DateTime.now();
      final dateStr =
          '${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}/${now.year}';

      userChargingHistory[user.email]!.insert(
        0, // Insert at beginning for most recent first
        ChargingHistory(
          stationName: widget.station.name,
          date: dateStr,
          kwhUsed: session.totalKwh,
          cost: totalCost,
          duration: durationText,
          chargingType: chargingType,
        ),
      );

      // Save to persistent storage
      await saveChargingHistory();
      await saveUserProfiles(); // Save updated profiles

      // Clear the persisted in-progress session for this user since we've
      // moved it into the finalized charging history.
      await clearCurrentChargingSessionForUser(user.email);
    }

    if (reason == 'budget' && mounted) {
      // Optional quick heads-up
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Karikimi u ndal: balanca u shterua.'),
          backgroundColor: Colors.orange,
        ),
      );
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2DBE6C).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events,
                color: Color(0xFFFFD700),
                size: 48,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              reason == 'budget' ? 'Charging Stopped' : 'Charging Complete!',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (reason == 'budget') ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orangeAccent),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.account_balance_wallet, color: Colors.orange),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Karikimi u ndal sepse balanca e portofolit u arrit.',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              // Thank you message with emojis
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2DBE6C), Color(0xFF66BB6A)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  children: [
                    Text(
                      '🎉 Thank you for choosing us! 🎉',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Together we\'re building a greener future!',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Achievement badge
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFD700), width: 2),
                ),
                child: Row(
                  children: [
                    const Text('🏆', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Achievement Unlocked!',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFB8860B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              achievement,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Stats summary
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow(
                      '🔋 Battery Level',
                      '${session.batteryPercentage.toInt()}%',
                    ),
                    const Divider(height: 20),
                    _buildSummaryRow(
                      '⚡ Energy Used',
                      '${session.totalKwh.toStringAsFixed(2)} kWh',
                    ),
                    const Divider(height: 20),
                    _buildSummaryRow(
                      '💰 Total Cost',
                      '${(session.totalKwh * widget.connector.pricePerKwh).toStringAsFixed(0)} ALL',
                    ),
                    const Divider(height: 20),
                    _buildSummaryRow(
                      '🌱 CO₂ Saved',
                      '${co2Saved.toStringAsFixed(1)} kg',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Environmental impact
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2DBE6C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Text('🌍', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'That\'s like planting ${(co2Saved / 21).toStringAsFixed(1)} trees!',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () {
              // Clear global charging session
              currentChargingSession.value = null;
              clearCurrentChargingSessionForUser(
                currentUser.value?.email ?? 'guest',
              );

              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close charging page
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2DBE6C),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Done',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = currentChargingSession.value;
    if (session == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Charging Session'),
          backgroundColor: Colors.green[700],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'No active charging session',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.home),
                label: const Text('Kthehu në faqen kryesore'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final totalCost = session.totalKwh * widget.connector.pricePerKwh;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1B5E20), Color(0xFF2DBE6C), Color(0xFF66BB6A)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Main scrollable content
              SingleChildScrollView(
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),
                          const Expanded(
                            child: Text(
                              'Charging Session',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Animated Car
                    SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(-1, 0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _carController,
                              curve: Curves.easeOut,
                            ),
                          ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Car icon
                            Container(
                              padding: const EdgeInsets.all(30),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.electric_car,
                                size: 120,
                                color: Colors.white,
                              ),
                            ),

                            // Charging bolt
                            Positioned(
                              right: 40,
                              child: ScaleTransition(
                                scale: _pulseAnimation,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: const BoxDecoration(
                                    color: Colors.amber,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.bolt,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Motivational message
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Container(
                        key: ValueKey(currentTipIndex),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          motivationalMessages[currentTipIndex %
                              motivationalMessages.length],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Battery percentage
                    Text(
                      '${session.batteryPercentage.toInt()}%',
                      style: const TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Battery progress
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 60),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: session.batteryPercentage / 100,
                              backgroundColor: Colors.white.withOpacity(0.3),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              minHeight: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Charging to ${session.targetPercentage.toInt()}%...',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Target percentage slider
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '🎯 Charge Target',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${session.targetPercentage.toInt()}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: Colors.white,
                              inactiveTrackColor: Colors.white.withOpacity(0.3),
                              thumbColor: Colors.amber,
                              overlayColor: Colors.amber.withOpacity(0.2),
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 12,
                              ),
                              trackHeight: 8,
                            ),
                            child: Slider(
                              value: session.targetPercentage,
                              min: session.batteryPercentage.clamp(20, 100),
                              max: 100,
                              divisions:
                                  ((100 -
                                              session.batteryPercentage.clamp(
                                                20,
                                                100,
                                              )) /
                                          5)
                                      .round()
                                      .clamp(1, 16),
                              onChanged: (value) {
                                setState(() {
                                  session.targetPercentage = value;
                                  currentChargingSession.value =
                                      ChargingSession(
                                        session.station,
                                        session.connector,
                                        batteryPercentage:
                                            session.batteryPercentage,
                                        currentPower: session.currentPower,
                                        totalKwh: session.totalKwh,
                                        batteryCapacityKwh:
                                            session.batteryCapacityKwh,
                                        targetPercentage: value,
                                      );
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Estimated time and cost
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildEstimateItem(
                                '⏱️',
                                'Est. Time',
                                _calculateEstimatedTime(session),
                              ),
                              _buildEstimateItem(
                                '💰',
                                'Est. Cost',
                                _calculateEstimatedCost(session),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Fun Fact Card
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: Row(
                          key: ValueKey('fact_$currentTipIndex'),
                          children: [
                            Text(
                              funFacts[currentTipIndex]['icon']!,
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Did you know?',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    funFacts[currentTipIndex]['fact']!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Stats card
                    Container(
                      margin: const EdgeInsets.all(24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Color(0xFF2DBE6C),
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.station.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      widget.station.address,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                Icons.flash_on,
                                'Power',
                                '${session.currentPower.toStringAsFixed(1)} kW',
                              ),
                              Container(
                                width: 1,
                                height: 50,
                                color: Colors.grey[300],
                              ),
                              _buildStatItem(
                                Icons.speed,
                                'Energy',
                                '${session.totalKwh.toStringAsFixed(2)} kWh',
                              ),
                              Container(
                                width: 1,
                                height: 50,
                                color: Colors.grey[300],
                              ),
                              _buildStatItem(
                                Icons.payments,
                                'Cost',
                                '${totalCost.toStringAsFixed(0)} ALL',
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: FilledButton(
                              onPressed: _stopCharging,
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Stop Charging',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Reminder message
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.blue[200]!,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.blue[700],
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Kur të përfundojë karikimi, ju lutemi lëvizni veturën tuaj nga vendi i karikimit, duke e liruar për veturat e tjera.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue[900],
                                      fontWeight: FontWeight.w600,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Confetti effect overlay
              if (showConfetti)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: ConfettiPainter(_confettiController),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF2DBE6C), size: 28),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }

  Widget _buildEstimateItem(String icon, String label, String value) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  String _calculateEstimatedTime(ChargingSession session) {
    // Calculate remaining kWh needed
    final remainingPct = session.targetPercentage - session.batteryPercentage;
    final remainingKwh = session.batteryCapacityKwh * (remainingPct / 100);
    // Estimate time based on current power (in hours)
    final avgPower = session.currentPower > 0 ? session.currentPower : 100;
    final hoursRemaining = remainingKwh / avgPower;
    final minutes = (hoursRemaining * 60).round();

    if (minutes < 1) return '< 1 min';
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h ${mins}m';
  }

  String _calculateEstimatedCost(ChargingSession session) {
    // Calculate total kWh needed to reach target
    final remainingPct = session.targetPercentage - session.batteryPercentage;
    final remainingKwh = session.batteryCapacityKwh * (remainingPct / 100);
    final totalKwhAtEnd = session.totalKwh + remainingKwh;
    final estimatedCost = totalKwhAtEnd * widget.connector.pricePerKwh;
    return '${estimatedCost.toStringAsFixed(0)} ALL';
  }
}

/// ---------------- CONFETTI PAINTER ----------------
class ConfettiPainter extends CustomPainter {
  final Animation<double> animation;

  ConfettiPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Generate confetti particles
    for (int i = 0; i < 50; i++) {
      final double progress = animation.value;
      final double x = (i * 37.5) % size.width;
      final double y = (progress * size.height) - ((i * 23.7) % 200);

      if (y < size.height && y > -50) {
        paint.color = [
          const Color(0xFF2DBE6C),
          const Color(0xFFFFD700),
          const Color(0xFF4CAF50),
          const Color(0xFF66BB6A),
          Colors.amber,
          Colors.yellow,
        ][i % 6];

        final double rotation = (i * 0.5 + progress * 360) * 3.14159 / 180;

        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(rotation);

        // Draw different shapes
        if (i % 3 == 0) {
          // Circle
          canvas.drawCircle(Offset.zero, 5, paint);
        } else if (i % 3 == 1) {
          // Rectangle
          canvas.drawRect(const Rect.fromLTWH(-4, -4, 8, 8), paint);
        } else {
          // Triangle
          final path = Path()
            ..moveTo(0, -6)
            ..lineTo(-5, 4)
            ..lineTo(5, 4)
            ..close();
          canvas.drawPath(path, paint);
        }

        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => true;
}

/// ---------------- CHARGING FLOATING WIDGET ----------------
class ChargingFloatingWidget extends StatefulWidget {
  final ChargingStationLocation station;
  final Connector connector;
  final VoidCallback onStop;

  const ChargingFloatingWidget({
    super.key,
    required this.station,
    required this.connector,
    required this.onStop,
  });

  @override
  State<ChargingFloatingWidget> createState() => _ChargingFloatingWidgetState();
}

class _ChargingFloatingWidgetState extends State<ChargingFloatingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _hasPlayedTargetSound = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Simulate charging - update global session
    Future.delayed(const Duration(seconds: 1), () {
      _startChargingSimulation();
    });
  }

  Future<void> _playChargingCompleteSound() async {
    try {
      // Play a system notification sound
      await _audioPlayer.play(AssetSource('sounds/charging_complete.mp3'));
    } catch (e) {
      // Fallback: use a URL-based sound if asset not available
      try {
        await _audioPlayer.play(
          UrlSource(
            'https://assets.mixkit.co/active_storage/sfx/2869/2869-preview.mp3',
          ),
        );
      } catch (_) {
        // Ignore if sound fails
      }
    }
  }

  void _stopChargingAutomatically({String? reason}) {
    // Play sound
    _playChargingCompleteSound();

    // Navigate to ChargingPage with autoComplete flag to show receipt
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChargingPage(
            station: widget.station,
            connector: widget.connector,
            autoCompleteCharging: true, // This will trigger showing receipt
            stopReason: reason,
          ),
        ),
      ).then((_) {
        // After returning from ChargingPage, trigger stop
        widget.onStop();
      });
    }
  }

  void _startChargingSimulation() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted || currentChargingSession.value == null) return false;

      final session = currentChargingSession.value!;
      final targetPct = session.targetPercentage;
      // Wallet budget stop: compute how many kWh the current wallet can afford
      final user = currentUser.value;
      final price = widget.connector.pricePerKwh <= 0
          ? 0
          : widget.connector.pricePerKwh;
      final wallet = user?.walletBalance ?? double.infinity;
      final maxAffordableKwh = price > 0 ? (wallet / price) : double.infinity;
      final remainingAffordableKwh = maxAffordableKwh - session.totalKwh;

      // Check if target reached
      if (session.batteryPercentage >= targetPct && !_hasPlayedTargetSound) {
        _hasPlayedTargetSound = true;
        _stopChargingAutomatically();
        return false; // Stop simulation
      }

      // Update global session data using capacity-based kWh mapping.
      // 100% equals `batteryCapacityKwh` energy. Each delta % adds
      // capacity * (delta% / 100) kWh.
      final prevPct = session.batteryPercentage;
      // Base step
      double stepPct = 0.5;
      if (remainingAffordableKwh.isFinite && remainingAffordableKwh <= 0) {
        _stopChargingAutomatically();
        return false;
      }
      final plannedKwh = session.batteryCapacityKwh * (stepPct / 100.0);
      if (remainingAffordableKwh.isFinite &&
          plannedKwh > remainingAffordableKwh) {
        stepPct = (remainingAffordableKwh / session.batteryCapacityKwh) * 100.0;
      }

      session.batteryPercentage = (session.batteryPercentage + stepPct).clamp(
        0,
        targetPct,
      );
      final deltaPct = (session.batteryPercentage - prevPct).clamp(0, 100);
      final appliedKwh = session.batteryCapacityKwh * (deltaPct / 100.0);
      session.totalKwh += appliedKwh;
      session.currentPower = 115 + (DateTime.now().second % 10);

      // Notify listeners
      currentChargingSession.value = ChargingSession(
        session.station,
        session.connector,
        batteryPercentage: session.batteryPercentage,
        currentPower: session.currentPower,
        totalKwh: session.totalKwh,
        batteryCapacityKwh: session.batteryCapacityKwh,
        targetPercentage: session.targetPercentage,
      );

      // Persist updated in-progress session so progress and intermediate
      // earned points are not lost if the app is closed.
      await saveCurrentChargingSessionForUser(
        currentUser.value?.email ?? 'guest',
      );

      // Force rebuild
      if (mounted) setState(() {});

      // If wallet budget reached (or exceeded due to precision), stop
      if (remainingAffordableKwh.isFinite &&
          (session.totalKwh + 1e-6) >= maxAffordableKwh) {
        _stopChargingAutomatically(reason: 'budget');
        return false;
      }

      return session.batteryPercentage < session.targetPercentage;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = currentChargingSession.value;
    if (session == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        // Navigate back to charging page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChargingPage(
              station: widget.station,
              connector: widget.connector,
            ),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 80,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2DBE6C), Color(0xFF28A75E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2DBE6C).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _buildCollapsedView(),
      ),
    );
  }

  Widget _buildCollapsedView() {
    final session = currentChargingSession.value;
    if (session == null) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: _pulseAnimation,
          child: const Icon(Icons.bolt, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 8),
        Text(
          '${session.batteryPercentage.toInt()}%',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

// Models
class ChargingStationLocation {
  final String id;
  final String code;
  final String name;
  final String address;
  final String city;
  final String distance;
  final double latitude;
  final double longitude;
  final List<Connector> connectors;

  ChargingStationLocation({
    required this.id,
    required this.code,
    required this.name,
    required this.address,
    required this.city,
    required this.distance,
    required this.latitude,
    required this.longitude,
    required this.connectors,
  });
}

// Models (shared between pages)
class Connector {
  final String type;
  final int pricePerKwh;
  final bool isAvailable;
  final bool isOffline; // Station not working at all
  final String? currentUser;
  final int? batteryPercentage;
  final int powerKw;

  Connector({
    required this.type,
    required this.pricePerKwh,
    required this.powerKw,
    this.isAvailable = true,
    this.isOffline = false,
    this.currentUser,
    this.batteryPercentage,
  });
}

/// ---------------- SCAN UI (frontend only) ----------------
class ScanUiPage extends StatelessWidget {
  const ScanUiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                  const Spacer(),
                  const Text(
                    'Scan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 14),

              const Text(
                'Scan QR code on the charger',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // camera preview placeholder
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF151515),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white24,
                            size: 80,
                          ),
                        ),
                      ),
                      // frame
                      Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 4),
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      // small hint inside
                      const Positioned(
                        bottom: 40,
                        child: Text(
                          'Place QR inside the frame',
                          style: TextStyle(color: Colors.white60),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    _showManualCodeEntry(context);
                  },
                  child: const Text('Enter manually'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showManualCodeEntry(BuildContext context) {
    final TextEditingController codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Enter Station Code',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the code found on the charging station:',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              decoration: InputDecoration(
                labelText: 'Station Code',
                hintText: 'e.g., EV001, EV002',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.qr_code),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2DBE6C).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF2DBE6C), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'The station code is printed on the charger',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              // Normalize input like "ev 002" -> "EV002"
              final raw = codeController.text.trim();
              final code = raw.replaceAll(RegExp(r"\\s+"), "").toUpperCase();
              if (code.isEmpty) return;

              // Find the exact station by code
              final matches = allStations.where(
                (s) => s.code.toUpperCase() == code,
              );
              if (matches.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Station code not found')),
                );
                return;
              }

              final station = matches.first;

              // Close dialog and scanner, then open the station page
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // close scanner

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      _ScannedStationPage(station: station, enteredCode: code),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2DBE6C),
            ),
            child: const Text('Find Station'),
          ),
        ],
      ),
    );
  }
}

/// Page displayed after entering a station code
class _ScannedStationPage extends StatelessWidget {
  final ChargingStationLocation station;
  final String enteredCode;

  const _ScannedStationPage({required this.station, required this.enteredCode});

  @override
  Widget build(BuildContext context) {
    Future<void> goHome() async {
      // Replace the stack with a fresh MainScreen (home at index 0)
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (route) => false,
      );
    }

    return WillPopScope(
      onWillPop: () async {
        await goHome();
        return false; // we've handled navigation
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0A0A0A),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: goHome,
          ),
          title: const Text(
            'Station Found',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Success banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2DBE6C).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2DBE6C), width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2DBE6C),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Station Found!',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Code entered: $enteredCode',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Station info card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2DBE6C).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.ev_station,
                            color: Color(0xFF2DBE6C),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                station.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                station.code,
                                style: const TextStyle(
                                  color: Color(0xFF2DBE6C),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 16),

                    // Address
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.white54,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            station.address,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // City
                    Row(
                      children: [
                        const Icon(
                          Icons.location_city,
                          color: Colors.white54,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          station.city,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Distance
                    Row(
                      children: [
                        const Icon(
                          Icons.directions_car,
                          color: Colors.white54,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          station.distance,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Connectors section
              const Text(
                'Available Connectors',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 14),

              ...station.connectors.map(
                (connector) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: connector.isAvailable
                          ? const Color(0xFF2DBE6C).withOpacity(0.5)
                          : Colors.white12,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: connector.isAvailable
                              ? const Color(0xFF2DBE6C).withOpacity(0.2)
                              : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.power,
                          color: connector.isAvailable
                              ? const Color(0xFF2DBE6C)
                              : Colors.white54,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              connector.type,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${connector.powerKw} kW • ${connector.pricePerKwh} Lekë/kWh',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: connector.isAvailable
                              ? const Color(0xFF2DBE6C).withOpacity(0.2)
                              : Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          connector.isAvailable ? 'Available' : 'In Use',
                          style: TextStyle(
                            color: connector.isAvailable
                                ? const Color(0xFF2DBE6C)
                                : Colors.orange,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Start Charging button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: station.connectors.any((c) => c.isAvailable)
                      ? () {
                          // Require minimum 500 ALL to start charging
                          final user = currentUser.value;
                          final balance = user?.walletBalance ?? 0.0;
                          if (balance < 500) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Nuk ke mjaftueshëm balance (min. 500 ALL) për të nisur karikimin. Rimbush portofolin.',
                                ),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            return;
                          }

                          // Find first available connector
                          final availableConnector = station.connectors
                              .firstWhere(
                                (c) => c.isAvailable,
                                orElse: () => station.connectors.first,
                              );

                          // Initialize a charging session before navigating
                          final random = Random();
                          final randomBatteryLevel =
                              20.0 + random.nextDouble() * 40.0;
                          currentChargingSession.value = ChargingSession(
                            station,
                            availableConnector,
                            batteryPercentage: randomBatteryLevel,
                          );
                          saveCurrentChargingSessionForUser(
                            currentUser.value?.email ?? 'guest',
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChargingPage(
                                station: station,
                                connector: availableConnector,
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2DBE6C),
                    disabledBackgroundColor: Colors.grey.shade800,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Start Charging',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class WalletUiPage extends StatefulWidget {
  const WalletUiPage({super.key});

  @override
  State<WalletUiPage> createState() => _WalletUiPageState();
}

class _WalletUiPageState extends State<WalletUiPage> {
  int tab = 0; // 0 deposits, 1 charging sessions

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserProfile?>(
      valueListenable: currentUser,
      builder: (context, user, child) {
        final balance = user?.walletBalance ?? 0.0;

        // Calculate user statistics
        final userHistory =
            user != null && userChargingHistory.containsKey(user.email)
            ? userChargingHistory[user.email]!
            : <ChargingHistory>[];

        final totalKwhUsed = userHistory.fold<double>(
          0.0,
          (sum, history) => sum + history.kwhUsed,
        );
        final totalSessions = userHistory.length;
        // Calculate CO2 saved (kg)
        final co2Saved = totalKwhUsed * 0.5; // kg CO2

        return Scaffold(
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Wallet',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 20),

                // Enhanced balance card with gradient
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2DBE6C), Color(0xFF1B8F4E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2DBE6C).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.trending_up,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '+12%',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Available balance',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${balance.toStringAsFixed(2)} ALL',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _balanceInfoItem(
                              icon: Icons.electric_bolt,
                              label: 'kWh used',
                              value: totalKwhUsed.toStringAsFixed(0),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 30,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          Expanded(
                            child: _balanceInfoItem(
                              icon: Icons.ev_station,
                              label: 'Sessions',
                              value: totalSessions.toString(),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 30,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          Expanded(
                            child: _balanceInfoItem(
                              icon: Icons.eco_outlined,
                              label: 'CO₂ Saved',
                              value: '${co2Saved.toStringAsFixed(0)} kg',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Action button
                SizedBox(
                  width: double.infinity,
                  child: _actionButton(
                    icon: Icons.add,
                    label: 'Top up',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2DBE6C), Color(0xFF28A75E)],
                    ),
                    onTap: () => _showTopUpDialog(context),
                  ),
                ),

                const SizedBox(height: 14),
                // segmented tabs
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _segButton(
                          text: 'Deposits',
                          selected: tab == 0,
                          onTap: () => setState(() => tab = 0),
                        ),
                      ),
                      Expanded(
                        child: _segButton(
                          text: 'Charging sessions',
                          selected: tab == 1,
                          onTap: () => setState(() => tab = 1),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      tab == 0 ? 'Recent deposits' : 'Recent charging sessions',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AllTransactionsPage(isDeposits: tab == 0),
                          ),
                        );
                      },
                      child: Text(
                        'See all',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2DBE6C),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // list items
                if (tab == 0) ...[
                  // Real deposit history from user
                  if (user != null &&
                      userDepositHistory.containsKey(user.email) &&
                      userDepositHistory[user.email]!.isNotEmpty)
                    ...userDepositHistory[user.email]!.map((deposit) {
                      // Format method display for subtitle
                      String methodDisplay;
                      if (deposit.method == 'card') {
                        methodDisplay = deposit.paymentDetails ?? 'Bank Card';
                      } else if (deposit.method == 'points') {
                        methodDisplay = 'Pikë Eco';
                      } else if (deposit.method == 'location') {
                        methodDisplay =
                            deposit.paymentDetails ?? 'Payment Location';
                      } else {
                        methodDisplay = deposit.method;
                      }

                      return _enhancedTxCard(
                        icon: Icons.add_circle,
                        iconColor: const Color(0xFF2DBE6C),
                        title: 'Deposit',
                        subtitle: '${deposit.date} • $methodDisplay',
                        amount: '+ ${deposit.amount.toStringAsFixed(2)} ALL',
                        positive: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => InvoicePage(
                                type: 'deposit',
                                depositHistory: deposit,
                              ),
                            ),
                          );
                        },
                      );
                    }).toList()
                  else
                  // Demo data if no deposit history
                  ...[
                    _enhancedTxCard(
                      icon: Icons.info_outline,
                      iconColor: Colors.grey,
                      title: 'No deposits yet',
                      subtitle: 'Tap "Top up" to add funds',
                      amount: '',
                      positive: true,
                    ),
                  ],
                ] else ...[
                  // Real charging history from user
                  if (user != null &&
                      userChargingHistory.containsKey(user.email) &&
                      userChargingHistory[user.email]!.isNotEmpty)
                    ...userChargingHistory[user.email]!.map((history) {
                      return _enhancedTxCard(
                        icon: Icons.electric_bolt,
                        iconColor: Colors.amber,
                        title:
                            'Charging session: ${history.kwhUsed.toStringAsFixed(1)} kWh',
                        subtitle: '${history.stationName} • ${history.date}',
                        amount: '- ${history.cost.toStringAsFixed(2)} ALL',
                        positive: false,
                        extraInfo:
                            '${history.duration} • ${history.chargingType}',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => InvoicePage(
                                type: 'charging',
                                chargingHistory: history,
                              ),
                            ),
                          );
                        },
                      );
                    }).toList()
                  else
                  // Demo data if no history
                  ...[
                    _enhancedTxCard(
                      icon: Icons.electric_bolt,
                      iconColor: Colors.amber,
                      title: 'Charging session: 52 kWh',
                      subtitle: 'EV Charge Tirana Center • Dec 18',
                      amount: '- 2,076.40 ALL',
                      positive: false,
                      extraInfo: '2h 15m • Fast charging',
                    ),
                    _enhancedTxCard(
                      icon: Icons.electric_bolt,
                      iconColor: Colors.amber,
                      title: 'Charging session: 18 kWh',
                      subtitle: 'EV Charge Airport • Dec 10',
                      amount: '- 720.00 ALL',
                      positive: false,
                      extraInfo: '45m • Standard charging',
                    ),
                    _enhancedTxCard(
                      icon: Icons.electric_bolt,
                      iconColor: Colors.amber,
                      title: 'Charging session: 65 kWh',
                      subtitle: 'EV Charge Tirana Mall • Dec 5',
                      amount: '- 2,600.00 ALL',
                      positive: false,
                      extraInfo: '3h 10m • Fast charging',
                    ),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTopUpDialog(BuildContext context) {
    final amountController = TextEditingController();
    // Controllers for card input fields
    final cardNumberController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();
    final cardNameController = TextEditingController();
    // Coupon controller and toggle for payment locations
    bool showCouponField = false;
    final couponController = TextEditingController();

    String selectedPaymentMethod = 'card'; // 'card' or 'location'

    showDialog(
      context: context,
      // Card details form (show only when card is selected)
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Top up wallet',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter amount in ALL:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '0.00',
                    prefixText: 'ALL ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF3F4F6),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Quick amounts:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [500, 1000, 2000, 5000].map((amt) {
                    return ActionChip(
                      label: Text('$amt ALL'),
                      onPressed: () {
                        amountController.text = amt.toString();
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Payment method:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                // Bank card option
                GestureDetector(
                  onTap: () {
                    setDialogState(() {
                      selectedPaymentMethod = 'card';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: selectedPaymentMethod == 'card'
                          ? const Color(0xFF2DBE6C).withOpacity(0.1)
                          : const Color(0xFFF3F4F6),
                      border: Border.all(
                        color: selectedPaymentMethod == 'card'
                            ? const Color(0xFF2DBE6C)
                            : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.credit_card,
                          color: selectedPaymentMethod == 'card'
                              ? const Color(0xFF2DBE6C)
                              : Colors.black54,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bank Card',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: selectedPaymentMethod == 'card'
                                      ? Colors.black
                                      : Colors.black87,
                                ),
                              ),
                              Text(
                                'Pay with credit or debit card',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: selectedPaymentMethod == 'card'
                                      ? Colors.black87
                                      : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (selectedPaymentMethod == 'card')
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF2DBE6C),
                          ),
                      ],
                    ),
                  ),
                ),
                // Eco points option
                GestureDetector(
                  onTap: () {
                    setDialogState(() {
                      selectedPaymentMethod = 'points';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: selectedPaymentMethod == 'points'
                          ? const Color(0xFF2DBE6C).withOpacity(0.1)
                          : const Color(0xFFF3F4F6),
                      border: Border.all(
                        color: selectedPaymentMethod == 'points'
                            ? const Color(0xFF2DBE6C)
                            : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.eco,
                          color: selectedPaymentMethod == 'points'
                              ? const Color(0xFF2DBE6C)
                              : Colors.black54,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Eco Points',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: selectedPaymentMethod == 'points'
                                      ? Colors.black
                                      : Colors.black87,
                                ),
                              ),
                              Text(
                                'Use eco points to top up (1 point = 1 ALL)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: selectedPaymentMethod == 'points'
                                      ? Colors.black87
                                      : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (selectedPaymentMethod == 'points')
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF2DBE6C),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Payment location option
                GestureDetector(
                  onTap: () {
                    setDialogState(() {
                      selectedPaymentMethod = 'location';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: selectedPaymentMethod == 'location'
                          ? const Color(0xFF2DBE6C).withOpacity(0.1)
                          : const Color(0xFFF3F4F6),
                      border: Border.all(
                        color: selectedPaymentMethod == 'location'
                            ? const Color(0xFF2DBE6C)
                            : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: selectedPaymentMethod == 'location'
                              ? const Color(0xFF2DBE6C)
                              : Colors.black54,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'EV Charge Payment Points',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: selectedPaymentMethod == 'location'
                                      ? Colors.black
                                      : Colors.black87,
                                ),
                              ),
                              Text(
                                'Pay at nearest payment location',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: selectedPaymentMethod == 'location'
                                      ? Colors.black87
                                      : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (selectedPaymentMethod == 'location')
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF2DBE6C),
                          ),
                      ],
                    ),
                  ),
                ),
                // Card details form (show only when card is selected)
                if (selectedPaymentMethod == 'card') ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Card details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: cardNumberController,
                    decoration: InputDecoration(
                      labelText: 'Card number',
                      hintText: '1234 5678 9012 3456',
                      prefixIcon: const Icon(Icons.credit_card),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: expiryController,
                          decoration: InputDecoration(
                            labelText: 'Expiry date',
                            hintText: 'MM/YY',
                            prefixIcon: const Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.datetime,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: cvvController,
                          decoration: InputDecoration(
                            labelText: 'CVV',
                            hintText: '123',
                            prefixIcon: const Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          obscureText: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: cardNameController,
                    decoration: InputDecoration(
                      labelText: 'Cardholder name',
                      hintText: 'JOHN DOE',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                ],
                // Eco points info (shown when Eco Points selected)
                if (selectedPaymentMethod == 'points') ...[
                  const SizedBox(height: 12),
                  Text(
                    'You have ${currentUser.value?.ecoPoints ?? 0} Eco Points',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '1 point = 1 ALL. Shkruani shumën që dëshironi të përdorni në fushën e sipërme.',
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
                ],
                // Coupon UI for payment locations
                if (selectedPaymentMethod == 'location') ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        setDialogState(() {
                          showCouponField = !showCouponField;
                        });
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF2DBE6C),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        showCouponField ? 'Hide coupon' : 'Use a coupon',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  if (showCouponField) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: couponController,
                      decoration: InputDecoration(
                        hintText: 'XXXX-XXXX',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF3F4F6),
                      ),
                      textCapitalization: TextCapitalization.characters,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          final code = couponController.text
                              .trim()
                              .toUpperCase();
                          final valid = RegExp(
                            r'^[A-Z0-9]{4}-[A-Z0-9]{4}$',
                          ).hasMatch(code);
                          if (code.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Ju lutem futni kuponin'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            return;
                          }
                          if (valid) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Kuponi $code u verifikua me sukses',
                                ),
                                backgroundColor: const Color(0xFF2DBE6C),
                              ),
                            );
                            // Here you could apply discount logic or mark coupon applied
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Kupon i pavlefshëm. Përdorni formatin XXXX-XXXX',
                                ),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        },
                        child: const Text('Validate coupon'),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Këto kupone blehen në pikat më të afërta të karikimit, si markete, karburante, kioska etj.',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (amountController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter an amount'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }

                final amount = double.tryParse(amountController.text);
                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid amount'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }

                // If paying by card, ensure card details are filled
                if (selectedPaymentMethod == 'card') {
                  if (cardNumberController.text.isEmpty ||
                      expiryController.text.isEmpty ||
                      cvvController.text.isEmpty ||
                      cardNameController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ju lutem plotëso të dhënat e kartës'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return;
                  }
                }

                // Update user wallet balance (handle different payment methods)
                final user = currentUser.value;
                if (user != null) {
                  final index = availableProfiles.indexWhere(
                    (p) => p.email == user.email,
                  );
                  if (index != -1) {
                    if (selectedPaymentMethod == 'points') {
                      // Use eco points: 1 point = 1 ALL
                      final int pointsNeeded = amount.round();
                      if (pointsNeeded > user.ecoPoints) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Nuk keni pike të mjaftueshme'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }

                      availableProfiles[index] = UserProfile(
                        name: user.name,
                        email: user.email,
                        password: user.password,
                        initials: user.initials,
                        walletBalance: user.walletBalance + amount,
                        vehicle: user.vehicle,
                        licensePlate: user.licensePlate,
                        ecoPoints: user.ecoPoints - pointsNeeded,
                        // preserve other stats
                        totalCharges: user.totalCharges,
                        totalCO2Saved: user.totalCO2Saved,
                        tier: user.tier,
                        achievements: user.achievements,
                      );
                    } else {
                      // Card or location: just add funds
                      availableProfiles[index] = UserProfile(
                        name: user.name,
                        email: user.email,
                        password: user.password,
                        initials: user.initials,
                        walletBalance: user.walletBalance + amount,
                        vehicle: user.vehicle,
                        licensePlate: user.licensePlate,
                        ecoPoints: user.ecoPoints,
                        totalCharges: user.totalCharges,
                        totalCO2Saved: user.totalCO2Saved,
                        tier: user.tier,
                        achievements: user.achievements,
                      );
                    }

                    currentUser.value = availableProfiles[index];

                    // Add to deposit history
                    if (!userDepositHistory.containsKey(user.email)) {
                      userDepositHistory[user.email] = [];
                    }
                    final now = DateTime.now();
                    final dateStr =
                        '${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}/${now.year}';

                    // Determine payment details based on method
                    String? paymentDetails;
                    if (selectedPaymentMethod == 'card') {
                      // Mask card number (show last 4 digits)
                      final cardNum = cardNumberController.text.replaceAll(
                        ' ',
                        '',
                      );
                      if (cardNum.length >= 4) {
                        final lastFour = cardNum.substring(cardNum.length - 4);
                        paymentDetails = 'Visa/MC **** $lastFour';
                      } else {
                        paymentDetails = 'Kartë krediti/debiti';
                      }
                    } else if (selectedPaymentMethod == 'points') {
                      paymentDetails = 'Pikë Eco (${amount.round()} points)';
                    } else if (selectedPaymentMethod == 'location') {
                      final coupon = couponController.text.trim();
                      if (coupon.isNotEmpty) {
                        paymentDetails = 'Kupon: $coupon';
                      } else {
                        paymentDetails = 'Kupon në pikë pagese';
                      }
                    }

                    userDepositHistory[user.email]!.insert(
                      0,
                      DepositHistory(
                        date: dateStr,
                        amount: amount,
                        method: selectedPaymentMethod,
                        paymentDetails: paymentDetails,
                      ),
                    );

                    // Save to persistent storage
                    saveDepositHistory();
                    saveUserProfiles(); // Save updated profiles
                  }
                }

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Successfully added ${amount.toStringAsFixed(2)} ALL to your wallet!',
                    ),
                    backgroundColor: const Color(0xFF2DBE6C),
                  ),
                );

                // Refresh the page
                setState(() {});
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _segButton({
    required String text,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: selected ? Colors.black : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _balanceInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Gradient gradient,
    Color textColor = Colors.white,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: textColor == Colors.white
              ? [
                  BoxShadow(
                    color: const Color(0xFF2DBE6C).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _enhancedTxCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String amount,
    required bool positive,
    String? extraInfo,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    iconColor.withOpacity(0.15),
                    iconColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  if (extraInfo != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        extraInfo,
                        style: TextStyle(
                          color: iconColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (amount.isNotEmpty)
              Text(
                amount,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: positive ? const Color(0xFF2DBE6C) : Colors.redAccent,
                ),
              ),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              Icon(Icons.receipt_long, color: Colors.grey.shade400, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}

/// ---------------- ALL TRANSACTIONS PAGE ----------------
class AllTransactionsPage extends StatelessWidget {
  final bool isDeposits;

  const AllTransactionsPage({super.key, required this.isDeposits});

  @override
  Widget build(BuildContext context) {
    final user = currentUser.value;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          isDeposits ? 'All Deposits' : 'All Charging Sessions',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: user == null
          ? const Center(child: Text('Please login to view transactions'))
          : isDeposits
          ? _buildDepositsList(user)
          : _buildChargingSessionsList(user),
    );
  }

  Widget _buildDepositsList(UserProfile user) {
    final deposits = userDepositHistory[user.email] ?? [];

    if (deposits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No deposits yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Top up your wallet to see deposits here',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: deposits.length,
      itemBuilder: (context, index) {
        final deposit = deposits[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2DBE6C).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.add_circle,
                  color: Color(0xFF2DBE6C),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Deposit',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${deposit.date} • ${deposit.method == 'card' ? 'Bank Card' : 'Payment Location'}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Text(
                '+ ${deposit.amount.toStringAsFixed(0)} ALL',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2DBE6C),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChargingSessionsList(UserProfile user) {
    final sessions = userChargingHistory[user.email] ?? [];

    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.ev_station, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No charging sessions yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start charging to see your history here',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.electric_bolt,
                      color: Colors.amber,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.stationName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          session.date,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '- ${session.cost.toStringAsFixed(0)} ALL',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSessionStat(
                      '⚡',
                      '${session.kwhUsed.toStringAsFixed(1)} kWh',
                    ),
                    Container(width: 1, height: 30, color: Colors.grey[300]),
                    _buildSessionStat('⏱️', session.duration),
                    Container(width: 1, height: 30, color: Colors.grey[300]),
                    _buildSessionStat(
                      '🔌',
                      session.chargingType.replaceAll(' charging', ''),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSessionStat(String icon, String value) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

/// ---------------- PROFILE UI (frontend only) ----------------
class ProfileUiPage extends StatelessWidget {
  const ProfileUiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserProfile?>(
      valueListenable: currentUser,
      builder: (context, user, child) {
        // Default user if not logged in
        final profile =
            user ??
            UserProfile(
              name: AppLocalizations.of(context)!.guestUser,
              email: 'guest@example.com',
              password: '',
              initials: 'GU',
              walletBalance: 0,
              vehicle: AppLocalizations.of(context)!.noVehicle,
              licensePlate: '',
            );

        return Scaffold(
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.profileTitle,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () => _showSettingsDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // user card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color(0xFF2DBE6C),
                          child: Text(
                            profile.initials,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${profile.walletBalance.toStringAsFixed(2)} ALL',
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () => _showAddVehicleDialog(context),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2DBE6C),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.add, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Eco Points & Tier Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2DBE6C), Color(0xFF1B5E20)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2DBE6C).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.ecoPointsTitle,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${profile.ecoPoints}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  _getTierIcon(profile.tier),
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  profile.tier,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              '🔋',
                              '${profile.totalCharges}',
                              AppLocalizations.of(context)!.totalCharges,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.white30,
                          ),
                          Expanded(
                            child: _buildStatItem(
                              '🌱',
                              '${profile.totalCO2Saved.toStringAsFixed(0)} kg',
                              AppLocalizations.of(context)!.co2Saved,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Personal Information & Vehicle (moved above Achievements)
                _menuCard(
                  icon: Icons.directions_car,
                  title: AppLocalizations.of(context)!.personalInfoVehicleTitle,
                  subtitle: profile.licensePlate.isNotEmpty
                      ? '${profile.vehicle} • ${profile.licensePlate}'
                      : profile.vehicle,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfilePage(),
                      ),
                    );
                  },
                ),

                // Achievements Card
                _menuCard(
                  icon: Icons.emoji_events,
                  title: AppLocalizations.of(context)!.achievementsTitle,
                  subtitle:
                      '${profile.achievements.where((a) => a.isUnlocked).length}/${availableAchievements.length} ${AppLocalizations.of(context)!.unlocked}',
                  onTap: () => _showAchievementsDialog(context, profile),
                ),

                // Leaderboard Card
                _menuCard(
                  icon: Icons.leaderboard,
                  title: AppLocalizations.of(context)!.leaderboardTitle,
                  subtitle: AppLocalizations.of(context)!.leaderboardSubtitle,
                  onTap: () => _showLeaderboardDialog(context),
                ),

                const SizedBox(height: 10),
                _menuCard(
                  icon: Icons.info_outline,
                  title: AppLocalizations.of(context)!.aboutTitle,
                  subtitle: AppLocalizations.of(context)!.aboutSubtitle,
                  onTap: () => _showAboutDialog(context),
                ),

                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () {
                      _showLogoutDialog(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.logOut,
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => _showDeleteAccountDialog(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.deleteAccount,
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final user = currentUser.value;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2DBE6C), Color(0xFF1B8F4E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.waving_hand,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.goodbyeTitle,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              user != null
                  ? AppLocalizations.of(
                      context,
                    )!.thanksWithName(user.name.split(' ')[0])
                  : AppLocalizations.of(context)!.thanksGeneric,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.goodbyeMessage,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2DBE6C).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.eco, color: Color(0xFF2DBE6C), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.greenTip,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // Clear current user and any persisted session for them
              final String? userEmail = currentUser.value?.email;
              currentUser.value = null;
              currentChargingSession.value = null;
              clearCurrentChargingSessionForUser(userEmail ?? 'guest');

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const WelcomePage()),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2DBE6C),
            ),
            child: Text(
              AppLocalizations.of(context)!.logOut,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    final user = currentUser.value;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          AppLocalizations.of(context)!.deleteAccount,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        content: Text(
          user != null
              ? AppLocalizations.of(context)!.deleteConfirmWithName(user.name)
              : AppLocalizations.of(context)!.deleteConfirmGeneric,
          style: TextStyle(color: Colors.grey[700], height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              if (user != null) {
                // Remove user profile
                availableProfiles.removeWhere((p) => p.email == user.email);

                // Remove user histories
                userDepositHistory.remove(user.email);
                userChargingHistory.remove(user.email);

                // Persist changes
                await saveUserProfiles();
                await saveDepositHistory();
                await saveChargingHistory();
              }

              // Clear current session and user
              currentUser.value = null;
              currentChargingSession.value = null;

              // Navigate to welcome/login
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const WelcomePage()),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text(
              AppLocalizations.of(context)!.deleteAccount,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2DBE6C).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.settings,
                color: Color(0xFF2DBE6C),
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              AppLocalizations.of(context)!.settingsTitle,
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: ValueListenableBuilder<bool>(
                valueListenable: isNotificationsEnabled,
                builder: (context, enabled, _) {
                  return Icon(
                    enabled
                        ? Icons.notifications_active
                        : Icons.notifications_outlined,
                    color: enabled ? const Color(0xFF2DBE6C) : null,
                  );
                },
              ),
              title: Text(AppLocalizations.of(context)!.notificationsTitle),
              subtitle: Text(
                AppLocalizations.of(context)!.notificationsSubtitle,
              ),
              trailing: ValueListenableBuilder<bool>(
                valueListenable: isNotificationsEnabled,
                builder: (context, enabled, _) {
                  return Switch(
                    value: enabled,
                    onChanged: (value) {
                      isNotificationsEnabled.value = value;
                      saveNotificationsSetting(value);
                      // Show feedback
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(
                                value
                                    ? Icons.notifications_active
                                    : Icons.notifications_off,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                value
                                    ? 'Notifications enabled'
                                    : 'Notifications disabled',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: value
                              ? const Color(0xFF2DBE6C)
                              : Colors.grey[700],
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                    activeColor: const Color(0xFF2DBE6C),
                  );
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: Icon(
                isDarkMode.value ? Icons.dark_mode : Icons.dark_mode_outlined,
                color: isDarkMode.value ? const Color(0xFF2DBE6C) : null,
              ),
              title: Text(AppLocalizations.of(context)!.darkModeTitle),
              subtitle: Text(AppLocalizations.of(context)!.darkModeSubtitle),
              trailing: ValueListenableBuilder<bool>(
                valueListenable: isDarkMode,
                builder: (context, darkMode, _) {
                  return Switch(
                    value: darkMode,
                    onChanged: (value) {
                      isDarkMode.value = value;
                      saveDarkModeSetting(value);
                    },
                    activeColor: const Color(0xFF2DBE6C),
                  );
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(AppLocalizations.of(context)!.languageTitle),
              subtitle: Text(_currentLanguageName(context)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).pop();
                _showLanguageDialog(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.close,
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  String _currentLanguageName(BuildContext context) {
    final code = appLocale.value?.languageCode ?? 'en';
    if (code == 'sq') return AppLocalizations.of(context)!.albanian;
    return AppLocalizations.of(context)!.english;
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(AppLocalizations.of(context)!.selectLanguageTitle),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(context).pop();
              saveAppLocale('en');
            },
            child: Row(
              children: [
                const Icon(Icons.flag_outlined),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.english,
                  style: TextStyle(
                    fontWeight: (appLocale.value?.languageCode ?? 'en') == 'en'
                        ? FontWeight.w800
                        : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(context).pop();
              saveAppLocale('sq');
            },
            child: Row(
              children: [
                const Icon(Icons.flag_outlined),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.albanian,
                  style: TextStyle(
                    fontWeight: (appLocale.value?.languageCode ?? 'en') == 'sq'
                        ? FontWeight.w800
                        : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2DBE6C), Color(0xFF1B8F4E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.electric_car,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.aboutAppName,
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24),
            ),
            Text(
              AppLocalizations.of(context)!.version('1.0.0'),
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.aboutDescription,
              style: TextStyle(color: Colors.grey[700], height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            ListTile(
              dense: true,
              leading: const Icon(Icons.policy, size: 20),
              title: Text(
                AppLocalizations.of(context)!.privacyPolicy,
                style: const TextStyle(fontSize: 14),
              ),
              onTap: () {
                Navigator.of(context).pop();
                Future.microtask(() => _showPrivacyPolicyDialog(context));
              },
            ),
            ListTile(
              dense: true,
              leading: const Icon(Icons.description, size: 20),
              title: Text(
                AppLocalizations.of(context)!.termsOfService,
                style: const TextStyle(fontSize: 14),
              ),
              onTap: () {
                Navigator.of(context).pop();
                Future.microtask(() => _showTermsOfServiceDialog(context));
              },
            ),
            ListTile(
              dense: true,
              leading: const Icon(Icons.contact_support, size: 20),
              title: Text(
                AppLocalizations.of(context)!.contactSupport,
                style: const TextStyle(fontSize: 14),
              ),
              isThreeLine: true,
              subtitle: const Text(
                'Tel: +35541234567 / 0697777778\nEmail: info@evcharge.al',
                style: TextStyle(fontSize: 12),
              ),
              onTap: () {},
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2DBE6C),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Në rregull',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Privacy Policy',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'We respect your privacy. This policy explains what data we collect and how we use it.',
                  style: TextStyle(height: 1.5),
                ),
                SizedBox(height: 12),
                Text(
                  'Information we collect',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 6),
                Text(
                  '• Profile information you provide (name, email, vehicle).',
                ),
                Text(
                  '• App usage data (searches, station views, charging sessions).',
                ),
                Text(
                  '• Device info for diagnostics (model, OS version, app version).',
                ),
                SizedBox(height: 12),
                Text(
                  'How we use your data',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 6),
                Text('• To provide, improve, and secure the app experience.'),
                Text('• To personalize station recommendations and features.'),
                Text('• To detect abuse and ensure service reliability.'),
                SizedBox(height: 12),
                Text(
                  'Data retention',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 6),
                Text(
                  'We retain your data only as long as necessary for the purposes above or as required by law.',
                ),
                SizedBox(height: 12),
                Text(
                  'Your rights',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 6),
                Text(
                  'You may request access, correction, or deletion of your personal data. Contact us at evcharging@gmail.com.',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfServiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Terms of Service',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'By using EVCharge, you agree to these terms.',
                  style: TextStyle(height: 1.5),
                ),
                SizedBox(height: 12),
                Text(
                  'Use of Service',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 6),
                Text('• You must use the app lawfully and responsibly.'),
                Text('• We may update features and content at any time.'),
                SizedBox(height: 12),
                Text('Accounts', style: TextStyle(fontWeight: FontWeight.w800)),
                SizedBox(height: 6),
                Text(
                  '• You are responsible for maintaining the confidentiality of your account.',
                ),
                SizedBox(height: 12),
                Text(
                  'Charging Sessions & Safety',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 6),
                Text(
                  '• Always follow station safety instructions and local regulations.',
                ),
                Text(
                  '• Prices and availability may change and can vary by location.',
                ),
                SizedBox(height: 12),
                Text(
                  'Limitation of Liability',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 6),
                Text(
                  '• EVCharge is provided “as is” without warranties. We are not liable for indirect or incidental damages.',
                ),
                SizedBox(height: 12),
                Text('Changes', style: TextStyle(fontWeight: FontWeight.w800)),
                SizedBox(height: 6),
                Text(
                  '• We may modify these terms; continued use constitutes acceptance.',
                ),
                SizedBox(height: 12),
                Text('Contact', style: TextStyle(fontWeight: FontWeight.w800)),
                SizedBox(height: 6),
                Text(
                  'For questions, contact evcharging@gmail.com or 0697777778.',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAddVehicleDialog(BuildContext context) {
    final vehicleController = TextEditingController();
    final licensePlateController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2DBE6C).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.directions_car,
                color: Color(0xFF2DBE6C),
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Shto Makinë',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Shto informacionin për makinën tënde të dytë elektrike:',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: vehicleController,
              decoration: InputDecoration(
                labelText: 'Modeli i makinës',
                hintText: 'Tesla Model Y',
                prefixIcon: const Icon(Icons.electric_car),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: licensePlateController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: 'Targa',
                hintText: 'AB 123 AL',
                prefixIcon: const Icon(Icons.pin),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Just pop the dialog; controllers will be disposed after dialog is closed
              Navigator.pop(dialogContext);
            },
            child: const Text(
              'Anulo',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          FilledButton(
            onPressed: () async {
              final vehicle = vehicleController.text.trim();
              final licensePlate = licensePlateController.text.trim();

              if (vehicle.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ju lutem fusni modelin e makinës'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }

              // Update in-memory profile immediately so UI reflects change
              final user = currentUser.value;
              if (user != null) {
                final updated = user.copyWith(
                  vehicle: vehicle,
                  licensePlate: licensePlate,
                );

                // Update profiles list if user exists in availableProfiles
                final idx = availableProfiles.indexWhere(
                  (p) => p.email == user.email,
                );
                if (idx != -1) {
                  availableProfiles[idx] = updated;
                }

                // Update current user notifier so UI updates
                currentUser.value = updated;
              }

              // Close dialog first (use dialogContext)
              Navigator.pop(dialogContext);

              // Show success message on the underlying scaffold (use outer context)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Makina u shtua!',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              '$vehicle - ${licensePlate.isNotEmpty ? licensePlate : "Pa targë"}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: const Color(0xFF2DBE6C),
                  duration: const Duration(seconds: 3),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );

              // Persist change (async) but avoid using `context` after await
              await saveUserProfiles();
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2DBE6C),
            ),
            child: const Text(
              'Shto',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  String _getTierIcon(String tier) {
    switch (tier) {
      case 'Platinum':
        return '💎';
      case 'Gold':
        return '🥇';
      case 'Silver':
        return '🥈';
      default:
        return '🥉';
    }
  }

  Widget _buildStatItem(String icon, String value, String label) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showAchievementsDialog(BuildContext context, UserProfile profile) {
    final unlockedCount = profile.achievements
        .where((a) => a.isUnlocked)
        .length;
    final allUnlocked =
        availableAchievements.isNotEmpty &&
        unlockedCount >= availableAchievements.length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.emoji_events, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(
              AppLocalizations.of(context)!.achievementsTitle,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              ...List.generate(availableAchievements.length, (index) {
                final achievement = availableAchievements[index];
                final isUnlocked = profile.achievements.any(
                  (a) => a.id == achievement.id && a.isUnlocked,
                );

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? const Color(0xFFFFD700).withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isUnlocked
                          ? const Color(0xFFFFD700)
                          : Colors.grey.withOpacity(0.3),
                      width: isUnlocked ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        achievement.icon,
                        style: TextStyle(
                          fontSize: 32,
                          color: isUnlocked ? null : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    achievement.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: isUnlocked ? null : Colors.grey,
                                    ),
                                  ),
                                ),
                                if (isUnlocked)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF2DBE6C),
                                    size: 20,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              achievement.description,
                              style: TextStyle(
                                fontSize: 13,
                                color: isUnlocked
                                    ? Colors.grey[600]
                                    : Colors.grey,
                              ),
                            ),
                            if (!isUnlocked) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Requires ${achievement.requiredPoints} points',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 8),

              // Reward coupon section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2DBE6C).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF2DBE6C).withOpacity(0.25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2DBE6C).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.confirmation_number,
                            color: Color(0xFF2DBE6C),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.couponCodeTitle,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      allUnlocked
                          ? AppLocalizations.of(
                              context,
                            )!.couponUnlockedDescription(
                              _achievementRewardAmountAll,
                            )
                          : AppLocalizations.of(
                              context,
                            )!.couponLockedDescription,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: allUnlocked
                            ? () async {
                                final email = profile.email;
                                final redeemed = await _isRewardRedeemedForUser(
                                  email,
                                );
                                if (!context.mounted) return;

                                if (redeemed) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.rewardAlreadyRedeemed,
                                      ),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                  return;
                                }

                                // Credit wallet.
                                final current = currentUser.value;
                                if (current != null) {
                                  final index = availableProfiles.indexWhere(
                                    (p) => p.email == current.email,
                                  );
                                  if (index != -1) {
                                    final updated = current.copyWith(
                                      walletBalance:
                                          current.walletBalance +
                                          _achievementRewardAmountAll,
                                    );
                                    availableProfiles[index] = updated;
                                    currentUser.value = updated;
                                    await saveUserProfiles();

                                    // Add to deposit history with achievement reward details
                                    if (!userDepositHistory.containsKey(
                                      current.email,
                                    )) {
                                      userDepositHistory[current.email] = [];
                                    }
                                    final now = DateTime.now();
                                    final dateStr =
                                        '${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}/${now.year}';
                                    userDepositHistory[current.email]!.insert(
                                      0,
                                      DepositHistory(
                                        date: dateStr,
                                        amount: _achievementRewardAmountAll
                                            .toDouble(),
                                        method: 'points',
                                        paymentDetails:
                                            'Shpërblim Achievement: $_achievementRewardCouponCode',
                                      ),
                                    );
                                    await saveDepositHistory();
                                  }
                                }

                                await _setRewardRedeemedForUser(email, true);

                                if (!context.mounted) return;
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.couponRevealedSnack(
                                        _achievementRewardCouponCode,
                                        _achievementRewardAmountAll,
                                      ),
                                    ),
                                    backgroundColor: const Color(0xFF2DBE6C),
                                  ),
                                );
                              }
                            : null,
                        icon: const Icon(Icons.lock_open, color: Colors.white),
                        label: Text(
                          allUnlocked
                              ? AppLocalizations.of(context)!.revealCoupon
                              : AppLocalizations.of(context)!.locked,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: allUnlocked
                              ? const Color(0xFF2DBE6C)
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  void _showLeaderboardDialog(BuildContext context) {
    // Sort users by eco points
    final sortedUsers = List<UserProfile>.from(availableProfiles)
      ..sort((a, b) => b.ecoPoints.compareTo(a.ecoPoints));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2DBE6C), Color(0xFF1B5E20)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.leaderboard, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Text(
              'Leaderboard',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2DBE6C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Text('🏆', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Top Eco Champions',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ...sortedUsers.asMap().entries.map((entry) {
                final rank = entry.key + 1;
                final user = entry.value;
                final isCurrentUser = currentUser.value?.email == user.email;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isCurrentUser
                        ? const Color(0xFF2DBE6C).withOpacity(0.1)
                        : Colors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCurrentUser
                          ? const Color(0xFF2DBE6C)
                          : Colors.grey.withOpacity(0.2),
                      width: isCurrentUser ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: rank <= 3
                              ? LinearGradient(
                                  colors: rank == 1
                                      ? [
                                          const Color(0xFFFFD700),
                                          const Color(0xFFFF8C00),
                                        ]
                                      : rank == 2
                                      ? [
                                          const Color(0xFFC0C0C0),
                                          const Color(0xFF808080),
                                        ]
                                      : [
                                          const Color(0xFFCD7F32),
                                          const Color(0xFF8B4513),
                                        ],
                                )
                              : null,
                          color: rank > 3 ? Colors.grey[300] : null,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            rank <= 3 ? ['🥇', '🥈', '🥉'][rank - 1] : '#$rank',
                            style: TextStyle(
                              fontSize: rank <= 3 ? 20 : 14,
                              fontWeight: FontWeight.w900,
                              color: rank > 3 ? Colors.black54 : null,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    user.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                Text(
                                  _getTierIcon(user.tier),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.stars,
                                  size: 14,
                                  color: Color(0xFFFFD700),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${user.ecoPoints} points',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(
                                  Icons.eco,
                                  size: 14,
                                  color: Color(0xFF2DBE6C),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${user.totalCO2Saved.toStringAsFixed(0)} kg CO₂',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _menuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

// (Removed duplicate, corrupted EditProfilePage implementation. See the
// clean implementation earlier in this file.)

// Invoice/Receipt Page for Charging Sessions and Deposits
class InvoicePage extends StatelessWidget {
  final String type; // 'charging' or 'deposit'
  final ChargingHistory? chargingHistory;
  final DepositHistory? depositHistory;

  const InvoicePage({
    super.key,
    required this.type,
    this.chargingHistory,
    this.depositHistory,
  });

  @override
  Widget build(BuildContext context) {
    final user = currentUser.value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();

    // Generate invoice number (timestamp-based)
    String invoiceNumber;
    String transactionDate;

    if (type == 'charging' && chargingHistory != null) {
      invoiceNumber =
          'CHG-${now.millisecondsSinceEpoch.toString().substring(5)}';
      transactionDate = chargingHistory!.date;
    } else if (type == 'deposit' && depositHistory != null) {
      invoiceNumber =
          'DEP-${now.millisecondsSinceEpoch.toString().substring(5)}';
      transactionDate = depositHistory!.date;
    } else {
      invoiceNumber = 'INV-000000';
      transactionDate = 'N/A';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Faturë / Invoice'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Shpërndaj faturën',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fatura u kopjua në clipboard')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00C853), Color(0xFF00B0FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.electric_bolt,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'EV Charge Albania',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rruga "Dëshmorët e 4 Shkurtit"\nTirana, Albania 1001',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'NIPT: AL K12345678L\nTel: +355 4 123 4567\nEmail: info@evcharge.al',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Divider(thickness: 2),
                const SizedBox(height: 16),

                // Invoice Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'FATURË / INVOICE',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C853).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'PAGUAR',
                        style: TextStyle(
                          color: const Color(0xFF00C853),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Invoice Details
                _buildInfoRow('Nr. Fature:', invoiceNumber),
                _buildInfoRow('Data:', transactionDate),
                _buildInfoRow(
                  'Ora:',
                  '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                ),
                const SizedBox(height: 24),

                // Customer Details
                const Text(
                  'Klienti / Customer:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildInfoRow('Emër:', user?.name ?? 'Guest User'),
                _buildInfoRow('Email:', user?.email ?? 'guest@example.com'),
                if (user != null && user.vehicle.isNotEmpty)
                  _buildInfoRow('Makina:', user.vehicle),
                const SizedBox(height: 24),
                const Divider(thickness: 1),
                const SizedBox(height: 16),

                // Transaction Details
                if (type == 'charging' && chargingHistory != null)
                  _buildChargingDetails(chargingHistory!)
                else if (type == 'deposit' && depositHistory != null)
                  _buildDepositDetails(depositHistory!),

                const SizedBox(height: 24),
                const Divider(thickness: 2),
                const SizedBox(height: 16),

                // Footer
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Faleminderit për përdorimin e EV Charge Albania!',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Për pyetje ose reklama: support@evcharge.al',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.qr_code, size: 80),
                            const SizedBox(height: 4),
                            Text(
                              'Skanoni për verifikim',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChargingDetails(ChargingHistory history) {
    // Calculate breakdown
    final subtotal = history.cost / 1.20; // Assuming 20% VAT included
    final vat = history.cost - subtotal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detaje të Karikimit / Charging Details:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildInfoRow('Stacioni:', history.stationName),
        _buildInfoRow('Lloji:', history.chargingType),
        _buildInfoRow('Kohëzgjatja:', history.duration),
        _buildInfoRow(
          'Energji përdorur:',
          '${history.kwhUsed.toStringAsFixed(2)} kWh',
        ),
        _buildInfoRow(
          'Çmimi për kWh:',
          '${(subtotal / history.kwhUsed).toStringAsFixed(2)} ALL/kWh',
        ),
        const SizedBox(height: 16),
        const Divider(thickness: 1),
        const SizedBox(height: 8),

        // Price Breakdown
        _buildPriceRow(
          'Nëntotali:',
          '${subtotal.toStringAsFixed(2)} ALL',
          false,
        ),
        _buildPriceRow('TVSH (20%):', '${vat.toStringAsFixed(2)} ALL', false),
        const SizedBox(height: 8),
        const Divider(thickness: 2),
        const SizedBox(height: 8),
        _buildPriceRow(
          'TOTALI:',
          '${history.cost.toStringAsFixed(2)} ALL',
          true,
        ),
      ],
    );
  }

  Widget _buildDepositDetails(DepositHistory history) {
    // Determine fee based on method
    double fee;
    String feeLabel;

    if (history.method == 'card') {
      fee = history.amount * 0.015; // 1.5% card fee
      feeLabel = 'Tarifa kartë (1.5%):';
    } else if (history.method == 'points') {
      fee = 0; // No fee for points
      feeLabel = 'Tarifa:';
    } else {
      fee = history.amount * 0.01; // 1% for coupon/location
      feeLabel = 'Tarifa (1%):';
    }

    final netAmount = history.amount - fee;

    // Format method display
    String methodDisplay;
    if (history.method == 'card') {
      methodDisplay = 'Kartë krediti/debiti';
    } else if (history.method == 'points') {
      methodDisplay = 'Pikë Eco';
    } else if (history.method == 'location') {
      methodDisplay = 'Kupon në pikë pagese';
    } else {
      methodDisplay = history.method;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detaje të Depozitës / Deposit Details:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildInfoRow('Metoda:', methodDisplay),
        if (history.paymentDetails != null)
          _buildInfoRow('Detaje pagese:', history.paymentDetails!),
        _buildInfoRow('Data e transaksionit:', history.date),
        if (history.method == 'card')
          _buildInfoRow('Procesor pagese:', 'Visa/Mastercard via Bank Albania'),
        if (history.method == 'points')
          _buildInfoRow('Burim:', 'Konvertim nga Pikë Eco në ALL'),
        const SizedBox(height: 16),
        const Divider(thickness: 1),
        const SizedBox(height: 8),

        // Price Breakdown
        _buildPriceRow(
          'Shuma e depozituar:',
          '${history.amount.toStringAsFixed(2)} ALL',
          false,
        ),
        if (fee > 0)
          _buildPriceRow(feeLabel, '- ${fee.toStringAsFixed(2)} ALL', false)
        else
          _buildPriceRow(feeLabel, '0.00 ALL', false),
        const SizedBox(height: 8),
        const Divider(thickness: 2),
        const SizedBox(height: 8),
        _buildPriceRow(
          'SHUMA NETO:',
          '${netAmount.toStringAsFixed(2)} ALL',
          true,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF00C853).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFF00C853),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Depozita u kredi në llogarinë tuaj me sukses',
                  style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value, bool isBold) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 16 : 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 18 : 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isBold ? const Color(0xFF00C853) : null,
            ),
          ),
        ],
      ),
    );
  }
}
