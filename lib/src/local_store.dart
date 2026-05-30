import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';
import 'sample_data.dart';

class PersistedCampusState {
  const PersistedCampusState({
    required this.selectedSchoolId,
    required this.binding,
    required this.tickets,
  });

  final String selectedSchoolId;
  final DeviceBinding binding;
  final List<SupportTicket> tickets;
}

class CampusLocalStore {
  static const _selectedSchoolIdKey = 'selected_school_id';
  static const _deviceBindingKey = 'device_binding';
  static const _supportTicketsKey = 'support_tickets';

  Future<PersistedCampusState> load() async {
    final preferences = await SharedPreferences.getInstance();
    final selectedSchoolId =
        preferences.getString(_selectedSchoolIdKey) ?? schoolOptions.first.id;
    final bindingValue = preferences.getString(_deviceBindingKey);
    final ticketsValue = preferences.getString(_supportTicketsKey);

    return PersistedCampusState(
      selectedSchoolId: selectedSchoolId,
      binding: _decodeBinding(bindingValue),
      tickets: _decodeTickets(ticketsValue),
    );
  }

  Future<void> saveSelectedSchoolId(String schoolId) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_selectedSchoolIdKey, schoolId);
  }

  Future<void> saveBinding(DeviceBinding binding) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _deviceBindingKey,
      jsonEncode(binding.toJson()),
    );
  }

  Future<void> saveTickets(List<SupportTicket> tickets) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _supportTicketsKey,
      jsonEncode(tickets.map((ticket) => ticket.toJson()).toList()),
    );
  }

  DeviceBinding _decodeBinding(String? value) {
    if (value == null || value.isEmpty) {
      return seedDeviceBinding;
    }

    return DeviceBinding.fromJson(jsonDecode(value) as Map<String, dynamic>);
  }

  List<SupportTicket> _decodeTickets(String? value) {
    if (value == null || value.isEmpty) {
      return List<SupportTicket>.of(initialTickets);
    }

    final jsonList = jsonDecode(value) as List<dynamic>;
    return jsonList
        .map((item) => SupportTicket.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
