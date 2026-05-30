import 'package:flutter/material.dart';

@immutable
class DeviceProfile {
  const DeviceProfile({
    required this.deviceName,
    required this.schoolName,
    required this.deviceId,
    required this.className,
    required this.assignedTo,
    required this.borrowDueDate,
    required this.managerName,
    required this.platformVersion,
    required this.serialNumber,
    required this.lastSync,
    required this.networkStatus,
    required this.managementStatus,
  });

  final String deviceName;
  final String schoolName;
  final String deviceId;
  final String className;
  final String assignedTo;
  final String borrowDueDate;
  final String managerName;
  final String platformVersion;
  final String serialNumber;
  final String lastSync;
  final String networkStatus;
  final String managementStatus;
}

@immutable
class CurrentDeviceSnapshot {
  const CurrentDeviceSnapshot({
    required this.deviceName,
    required this.model,
    required this.localizedModel,
    required this.systemName,
    required this.systemVersion,
    required this.machineIdentifier,
    required this.vendorIdentifier,
    required this.isManaged,
    required this.managedConfiguration,
  });

  final String deviceName;
  final String model;
  final String localizedModel;
  final String systemName;
  final String systemVersion;
  final String machineIdentifier;
  final String vendorIdentifier;
  final bool isManaged;
  final Map<String, dynamic> managedConfiguration;

  String get preferredDeviceLabel {
    if (deviceName.isNotEmpty) {
      return deviceName;
    }
    if (localizedModel.isNotEmpty) {
      return localizedModel;
    }
    return model;
  }

  String get fallbackDeviceCode {
    if (vendorIdentifier.length >= 4) {
      return vendorIdentifier
          .substring(vendorIdentifier.length - 4)
          .toUpperCase();
    }
    if (machineIdentifier.length >= 4) {
      return machineIdentifier
          .substring(machineIdentifier.length - 4)
          .toUpperCase();
    }
    return 'LOCAL';
  }

  factory CurrentDeviceSnapshot.fallback() {
    return const CurrentDeviceSnapshot(
      deviceName: '本机设备',
      model: 'iPhone',
      localizedModel: 'iPhone',
      systemName: 'iOS',
      systemVersion: '',
      machineIdentifier: '',
      vendorIdentifier: '',
      isManaged: false,
      managedConfiguration: <String, dynamic>{},
    );
  }
}

@immutable
class TimetableLesson {
  const TimetableLesson({
    required this.slotLabel,
    required this.startTime,
    required this.endTime,
    required this.subject,
    required this.room,
    required this.teacherName,
    required this.note,
    required this.accentColor,
    this.isBreak = false,
  });

  final String slotLabel;
  final String startTime;
  final String endTime;
  final String subject;
  final String room;
  final String teacherName;
  final String note;
  final Color accentColor;
  final bool isBreak;
}

@immutable
class TimetableDay {
  const TimetableDay({
    required this.cycleLabel,
    required this.weekdayLabel,
    required this.classLabel,
    required this.focus,
    required this.notes,
    required this.lessons,
  });

  final String cycleLabel;
  final String weekdayLabel;
  final String classLabel;
  final String focus;
  final String notes;
  final List<TimetableLesson> lessons;
}

@immutable
class CampusNotice {
  const CampusNotice({
    required this.title,
    required this.tag,
    required this.publishedAt,
    required this.summary,
    required this.details,
    this.isPinned = false,
  });

  final String title;
  final String tag;
  final String publishedAt;
  final String summary;
  final String details;
  final bool isPinned;
}

@immutable
class SupportContact {
  const SupportContact({
    required this.teamName,
    required this.phone,
    required this.email,
    required this.officeHours,
    required this.responseSla,
    required this.address,
  });

  final String teamName;
  final String phone;
  final String email;
  final String officeHours;
  final String responseSla;
  final String address;
}

@immutable
class SchoolOption {
  const SchoolOption({
    required this.id,
    required this.name,
    required this.campus,
    required this.devicePrefix,
    required this.itTeamName,
    required this.supportPhone,
    required this.supportEmail,
    required this.supportAddress,
    required this.officeHours,
    required this.responseSla,
    required this.networkName,
    required this.defaultBorrowDueDate,
    required this.schedulePattern,
    required this.scheduleWindow,
    required this.defaultClassLabel,
  });

  final String id;
  final String name;
  final String campus;
  final String devicePrefix;
  final String itTeamName;
  final String supportPhone;
  final String supportEmail;
  final String supportAddress;
  final String officeHours;
  final String responseSla;
  final String networkName;
  final String defaultBorrowDueDate;
  final String schedulePattern;
  final String scheduleWindow;
  final String defaultClassLabel;
}

@immutable
class PrivacyScope {
  const PrivacyScope({
    required this.title,
    required this.description,
    required this.items,
    required this.accentColor,
  });

  final String title;
  final String description;
  final List<String> items;
  final Color accentColor;
}

@immutable
class PrivacyPolicySection {
  const PrivacyPolicySection({
    required this.title,
    required this.summary,
    required this.items,
  });

  final String title;
  final String summary;
  final List<String> items;
}

@immutable
class DeviceBinding {
  const DeviceBinding({
    required this.schoolId,
    required this.deviceCode,
    required this.assignedTo,
    required this.className,
    required this.borrowDueDate,
    required this.boundAt,
  });

  final String schoolId;
  final String deviceCode;
  final String assignedTo;
  final String className;
  final String borrowDueDate;
  final String boundAt;

  DeviceBinding copyWith({
    String? schoolId,
    String? deviceCode,
    String? assignedTo,
    String? className,
    String? borrowDueDate,
    String? boundAt,
  }) {
    return DeviceBinding(
      schoolId: schoolId ?? this.schoolId,
      deviceCode: deviceCode ?? this.deviceCode,
      assignedTo: assignedTo ?? this.assignedTo,
      className: className ?? this.className,
      borrowDueDate: borrowDueDate ?? this.borrowDueDate,
      boundAt: boundAt ?? this.boundAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schoolId': schoolId,
      'deviceCode': deviceCode,
      'assignedTo': assignedTo,
      'className': className,
      'borrowDueDate': borrowDueDate,
      'boundAt': boundAt,
    };
  }

  factory DeviceBinding.fromJson(Map<String, dynamic> json) {
    return DeviceBinding(
      schoolId: json['schoolId'] as String? ?? '',
      deviceCode: json['deviceCode'] as String? ?? '',
      assignedTo: json['assignedTo'] as String? ?? '',
      className: json['className'] as String? ?? '',
      borrowDueDate: json['borrowDueDate'] as String? ?? '',
      boundAt: json['boundAt'] as String? ?? '',
    );
  }
}

@immutable
class SupportTicket {
  const SupportTicket({
    required this.ticketId,
    required this.title,
    required this.category,
    required this.location,
    required this.priority,
    required this.status,
    required this.submittedAt,
    required this.description,
  });

  final String ticketId;
  final String title;
  final String category;
  final String location;
  final String priority;
  final String status;
  final String submittedAt;
  final String description;

  Map<String, dynamic> toJson() {
    return {
      'ticketId': ticketId,
      'title': title,
      'category': category,
      'location': location,
      'priority': priority,
      'status': status,
      'submittedAt': submittedAt,
      'description': description,
    };
  }

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      ticketId: json['ticketId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? '',
      location: json['location'] as String? ?? '',
      priority: json['priority'] as String? ?? '',
      status: json['status'] as String? ?? '',
      submittedAt: json['submittedAt'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}
