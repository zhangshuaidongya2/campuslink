import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'device_service.dart';
import 'local_store.dart';
import 'models.dart';
import 'sample_data.dart';
import 'theme.dart';

class CampusLinkApp extends StatelessWidget {
  const CampusLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '校园设备助手',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const CampusHomeShell(),
    );
  }
}

class CampusHomeShell extends StatefulWidget {
  const CampusHomeShell({super.key});

  @override
  State<CampusHomeShell> createState() => _CampusHomeShellState();
}

class _CampusHomeShellState extends State<CampusHomeShell> {
  final DeviceService _deviceService = DeviceService();
  final CampusLocalStore _store = CampusLocalStore();
  int _selectedIndex = 0;
  bool _isReady = false;
  String _selectedSchoolId = schoolOptions.first.id;
  DeviceBinding _binding = seedDeviceBinding;
  CurrentDeviceSnapshot _currentDevice = CurrentDeviceSnapshot.fallback();
  List<SupportTicket> _tickets = List<SupportTicket>.of(initialTickets);

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final results = await Future.wait<Object>([
      _store.load(),
      _deviceService.fetchCurrentDevice(),
    ]);
    final state = results[0] as PersistedCampusState;
    final currentDevice = results[1] as CurrentDeviceSnapshot;
    final managedSchoolId =
        currentDevice.managedConfiguration['school_id'] as String?;
    final preferredSchoolId =
        managedSchoolId != null && managedSchoolId.isNotEmpty
        ? managedSchoolId
        : state.selectedSchoolId;
    final resolvedSchoolId = _resolveSchoolId(preferredSchoolId);
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedSchoolId = resolvedSchoolId;
      _binding = state.binding;
      _currentDevice = currentDevice;
      _tickets = state.tickets;
      _isReady = true;
    });
  }

  SchoolOption get _selectedSchool {
    return schoolOptions.firstWhere(
      (school) => school.id == _selectedSchoolId,
      orElse: () => schoolOptions.first,
    );
  }

  String _resolveSchoolId(String schoolId) {
    final match = schoolOptions.where((school) => school.id == schoolId);
    return match.isEmpty ? schoolOptions.first.id : schoolId;
  }

  bool get _isManaged => _currentDevice.isManaged;

  bool get _hasManagedBinding {
    final managedSchoolId =
        _currentDevice.managedConfiguration['school_id'] as String?;
    final managedDeviceCode =
        _currentDevice.managedConfiguration['device_code'] as String?;
    return (managedSchoolId != null && managedSchoolId.isNotEmpty) ||
        (managedDeviceCode != null && managedDeviceCode.isNotEmpty);
  }

  bool get _isBound {
    return _hasManagedBinding ||
        (_binding.schoolId == _selectedSchool.id &&
            _binding.deviceCode.isNotEmpty);
  }

  DeviceBinding? get _activeBinding =>
      _binding.deviceCode.isNotEmpty ? _binding : null;

  bool get _selectionLocked {
    final managedSchoolId =
        _currentDevice.managedConfiguration['school_id'] as String?;
    return managedSchoolId != null && managedSchoolId.isNotEmpty;
  }

  DeviceProfile get _device {
    return buildDeviceProfile(
      school: _selectedSchool,
      binding: _activeBinding,
      currentDevice: _currentDevice,
    );
  }

  SupportContact get _contact => buildSupportContact(_selectedSchool);

  List<TimetableDay> get _timetableDays => buildSchoolTimetable(
    school: _selectedSchool,
    className: _device.className,
  );

  void _selectTab(int index) {
    if (_selectedIndex == index) {
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  void _saveSelectedSchool(String schoolId) {
    final resolvedSchoolId = _resolveSchoolId(schoolId);
    setState(() {
      _selectedSchoolId = resolvedSchoolId;
    });
    _store.saveSelectedSchoolId(resolvedSchoolId);
  }

  void _saveBinding(DeviceBinding binding) {
    setState(() {
      _binding = binding;
    });
    _store.saveBinding(binding);
  }

  void _createTicket(SupportTicket ticket) {
    final updated = [ticket, ..._tickets];
    setState(() {
      _tickets = updated;
    });
    _store.saveTickets(updated);
  }

  @override
  Widget build(BuildContext context) {
    final destinations = <_AppDestination>[
      const _AppDestination(label: '總覽', assetPath: _AppAssetPaths.navHome),
      const _AppDestination(
        label: '課程表',
        assetPath: _AppAssetPaths.navCalendar,
      ),
      const _AppDestination(
        label: 'IT 服務',
        assetPath: _AppAssetPaths.navSupport,
      ),
      const _AppDestination(
        label: '隱私政策',
        assetPath: _AppAssetPaths.navPrivacy,
      ),
    ];

    if (!_isReady) {
      return const Scaffold(
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    final pages = <Widget>[
      OverviewTab(
        device: _device,
        timetableDays: _timetableDays,
        notices: campusNotices,
        contact: _contact,
        schools: schoolOptions,
        selectedSchool: _selectedSchool,
        activeBinding: _activeBinding,
        isBound: _isBound,
        isManaged: _isManaged,
        currentDevice: _currentDevice,
        selectionLocked: _selectionLocked,
        privacyPolicyUrl: privacyPolicyUrl,
        onSaveSchool: _saveSelectedSchool,
        onSaveBinding: _saveBinding,
        onOpenTimetable: () => _selectTab(1),
        onOpenService: () => _selectTab(2),
        onOpenPrivacy: () => _selectTab(3),
      ),
      TimetableTab(
        device: _device,
        timetableDays: _timetableDays,
        school: _selectedSchool,
        isBound: _isBound,
        isManaged: _isManaged,
      ),
      ServiceTab(
        device: _device,
        contact: _contact,
        tickets: _tickets,
        isBound: _isBound,
        isManaged: _isManaged,
        onCreateTicket: _createTicket,
      ),
      PrivacyTab(
        visibleScope: visiblePrivacyScope,
        hiddenScope: hiddenPrivacyScope,
        notices: campusNotices,
        school: _selectedSchool,
        contact: _contact,
        policyUrl: privacyPolicyUrl,
        effectiveDate: privacyPolicyEffectiveDate,
        sections: privacyPolicySections,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final useRail = constraints.maxWidth >= 960;

            if (useRail) {
              return Row(
                children: [
                  _DesktopNavigation(
                    destinations: destinations,
                    selectedIndex: _selectedIndex,
                    onSelected: _selectTab,
                    schoolName: _selectedSchool.name,
                    isManaged: _isManaged,
                    isBound: _isBound,
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    child: IndexedStack(index: _selectedIndex, children: pages),
                  ),
                ],
              );
            }

            return Column(
              children: [
                Expanded(
                  child: IndexedStack(index: _selectedIndex, children: pages),
                ),
                NavigationBar(
                  height: 92,
                  selectedIndex: _selectedIndex,
                  destinations: [
                    for (final destination in destinations)
                      NavigationDestination(
                        icon: _AppAssetIcon(
                          assetPath: destination.assetPath,
                          size: 28,
                          opacity: 0.68,
                        ),
                        selectedIcon: _AppAssetIcon(
                          assetPath: destination.assetPath,
                          size: 28,
                        ),
                        label: destination.label,
                      ),
                  ],
                  onDestinationSelected: _selectTab,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class OverviewTab extends StatelessWidget {
  const OverviewTab({
    super.key,
    required this.device,
    required this.timetableDays,
    required this.notices,
    required this.contact,
    required this.schools,
    required this.selectedSchool,
    required this.activeBinding,
    required this.isBound,
    required this.isManaged,
    required this.currentDevice,
    required this.selectionLocked,
    required this.privacyPolicyUrl,
    required this.onSaveSchool,
    required this.onSaveBinding,
    required this.onOpenTimetable,
    required this.onOpenService,
    required this.onOpenPrivacy,
  });

  final DeviceProfile device;
  final List<TimetableDay> timetableDays;
  final List<CampusNotice> notices;
  final SupportContact contact;
  final List<SchoolOption> schools;
  final SchoolOption selectedSchool;
  final DeviceBinding? activeBinding;
  final bool isBound;
  final bool isManaged;
  final CurrentDeviceSnapshot currentDevice;
  final bool selectionLocked;
  final String privacyPolicyUrl;
  final ValueChanged<String> onSaveSchool;
  final ValueChanged<DeviceBinding> onSaveBinding;
  final VoidCallback onOpenTimetable;
  final VoidCallback onOpenService;
  final VoidCallback onOpenPrivacy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _PageScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatusBanner(
            schoolName: selectedSchool.name,
            isBound: isBound,
            isManaged: isManaged,
          ),
          const SizedBox(height: 18),
          _PageHeader(
            eyebrow: 'Campus Device Dashboard',
            title: isManaged ? '当前設備已接入學校管理' : '當前設備預設未納入學校監管',
            description: isManaged
                ? '已從當前設備讀取到學校管理配置。你可以繼續查看課表、公告、借用期限與 IT 支援。'
                : 'App 已讀取目前設備資訊，但未發現學校監管配置。你仍可先選擇香港學校、完成設備綁定並查閱標準課表。',
          ),
          const SizedBox(height: 18),
          _HeroCard(
            device: device,
            isBound: isBound,
            isManaged: isManaged,
            onOpenTimetable: onOpenTimetable,
            onOpenService: onOpenService,
            onOpenPrivacy: onOpenPrivacy,
          ),
          const SizedBox(height: 18),
          AdaptiveGrid(
            minItemWidth: 320,
            children: [
              _SchoolSelectionCard(
                schools: schools,
                selectedSchoolId: selectedSchool.id,
                selectionLocked: selectionLocked,
                onChanged: onSaveSchool,
              ),
              _DeviceBindingCard(
                school: selectedSchool,
                binding: activeBinding,
                isBound: isBound,
                isManaged: isManaged,
                onTapBind: () {
                  _showBindingSheet(
                    context,
                    school: selectedSchool,
                    currentBinding: activeBinding,
                    onSave: onSaveBinding,
                  );
                },
              ),
              _PolicyUrlCard(
                policyUrl: privacyPolicyUrl,
                onOpenPrivacy: onOpenPrivacy,
              ),
            ],
          ),
          const SizedBox(height: 18),
          AdaptiveGrid(
            minItemWidth: 220,
            children: [
              _MetricCard(
                label: '當前學校',
                value: device.schoolName,
                detail: selectedSchool.campus,
                accentColor: AppColors.signalBlue,
              ),
              _MetricCard(
                label: '所屬班別 / 部門',
                value: device.className,
                detail: '目前使用身份: ${device.assignedTo}',
                accentColor: AppColors.amber,
              ),
              _MetricCard(
                label: '借用到期',
                value: device.borrowDueDate,
                detail: isBound ? '到期前 3 天會再次提醒' : '綁定後可按學校規則調整',
                accentColor: AppColors.emerald,
              ),
              _MetricCard(
                label: '监管状态',
                value: isManaged ? '已纳管' : '未纳管',
                detail: contact.responseSla,
                accentColor: AppColors.coral,
              ),
            ],
          ),
          const SizedBox(height: 18),
          _SectionHeading(
            title: '學校課程表',
            actionLabel: '查看完整課表',
            onAction: onOpenTimetable,
          ),
          const SizedBox(height: 12),
          AdaptiveGrid(
            minItemWidth: 280,
            children: timetableDays.take(3).map((day) {
              return _TimetablePreviewCard(day: day);
            }).toList(),
          ),
          const SizedBox(height: 18),
          AdaptiveGrid(
            minItemWidth: 360,
            children: [
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('校園 IT 公告', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(
                      '展示最新借用安排、輪轉課表調整與校園網維護通知。',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 14),
                    for (final notice in notices)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _NoticeRow(notice: notice),
                      ),
                  ],
                ),
              ),
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('聯絡 IT 管理員', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(
                      '遇到課室設備、網絡或借用問題，可直接聯絡學校 IT 服務台。',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 18),
                    _ContactLine(
                      assetPath: _AppAssetPaths.supportAgent,
                      text: contact.teamName,
                    ),
                    _ContactLine(
                      assetPath: _AppAssetPaths.phone,
                      text: contact.phone,
                    ),
                    _ContactLine(
                      assetPath: _AppAssetPaths.mail,
                      text: contact.email,
                    ),
                    _ContactLine(
                      assetPath: _AppAssetPaths.clock,
                      text: contact.officeHours,
                    ),
                    _ContactLine(
                      assetPath: _AppAssetPaths.pin,
                      text: contact.address,
                    ),
                    const SizedBox(height: 18),
                    FilledButton(
                      onPressed: () => _showContactDialog(context, contact),
                      child: const Text('查看聯絡資訊'),
                    ),
                  ],
                ),
              ),
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('隱私範圍摘要', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(
                      '學校只能看到管理與教學必需的資料，不能存取你的私人內容。',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 14),
                    const _PrivacyBullet(
                      label: '學校可見',
                      text: '設備編號、班別課表、借用期限和報修進度。',
                      tone: _PrivacyTone.visible,
                    ),
                    const SizedBox(height: 10),
                    const _PrivacyBullet(
                      label: '學校不可見',
                      text: '個人照片、聊天訊息、瀏覽內容和非校園 App 的使用行為。',
                      tone: _PrivacyTone.hidden,
                    ),
                    const SizedBox(height: 18),
                    OutlinedButton(
                      onPressed: onOpenPrivacy,
                      child: const Text('查看完整隱私政策'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TimetableTab extends StatelessWidget {
  const TimetableTab({
    super.key,
    required this.device,
    required this.timetableDays,
    required this.school,
    required this.isBound,
    required this.isManaged,
  });

  final DeviceProfile device;
  final List<TimetableDay> timetableDays;
  final SchoolOption school;
  final bool isBound;
  final bool isManaged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _PageScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PageHeader(
            eyebrow: 'School Timetable',
            title: '學校課程表',
            description: isManaged
                ? '目前設備已接入 ${school.name} 的管理配置，可查看對應班別的輪轉課表與上課時段。'
                : '目前設備未發現學校監管配置，因此先顯示所選學校的標準課表與輪轉日安排。',
          ),
          const SizedBox(height: 18),
          AdaptiveGrid(
            minItemWidth: 220,
            children: [
              _MetricCard(
                label: '輪轉週期',
                value: '${timetableDays.length} 天',
                detail: school.schedulePattern,
                accentColor: AppColors.signalBlue,
              ),
              _MetricCard(
                label: '班別 / 身份',
                value: device.className.startsWith('待')
                    ? school.defaultClassLabel
                    : device.className,
                detail: '目前使用身份: ${device.assignedTo}',
                accentColor: AppColors.amber,
              ),
              _MetricCard(
                label: '上課時段',
                value: school.scheduleWindow,
                detail: isManaged ? '已按裝置管理配置顯示課表' : '未納管時顯示學校標準課表',
                accentColor: AppColors.emerald,
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (!isManaged)
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: _SectionCard(
                child: Text(
                  '目前設備尚未納入學校管理，因此此處先顯示所選香港學校的標準輪轉課表。當學校後續下發班別或課表配置後，畫面會按目前設備資料更新。',
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ),
          AdaptiveGrid(
            minItemWidth: 320,
            children: [
              for (final day in timetableDays)
                _TimetableDayCard(
                  day: day,
                  onMore: () => _showTimetableDetails(context, day),
                ),
            ],
          ),
          const SizedBox(height: 18),
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('課表說明', style: theme.textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(
                  '目前課表採用香港學校常見的輪轉日編排，包含 08:15 點名、8 節正課、小息與午膳時段。若裝置已由學校納管，班別與日程會以學校下發的配置為準。',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),
                const _TimelineStep(
                  number: '1',
                  title: '先識別所屬學校',
                  description: '課表會先跟隨你在首頁選定或由學校下發的香港學校。',
                ),
                const _TimelineStep(
                  number: '2',
                  title: '再套用班別課表',
                  description: '若目前設備已綁定班別，課表會優先顯示對應班別安排。',
                ),
                const _TimelineStep(
                  number: '3',
                  title: '同步輪轉日與公告',
                  description: '課表調整、周會與網絡維護等資訊會同步反映在課表和公告頁。',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceTab extends StatefulWidget {
  const ServiceTab({
    super.key,
    required this.device,
    required this.contact,
    required this.tickets,
    required this.isBound,
    required this.isManaged,
    required this.onCreateTicket,
  });

  final DeviceProfile device;
  final SupportContact contact;
  final List<SupportTicket> tickets;
  final bool isBound;
  final bool isManaged;
  final ValueChanged<SupportTicket> onCreateTicket;

  @override
  State<ServiceTab> createState() => _ServiceTabState();
}

class _ServiceTabState extends State<ServiceTab> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _locationController;
  late final TextEditingController _descriptionController;
  String _selectedCategory = _categories.first;
  String _selectedPriority = _priorities[1];

  static const _categories = <String>['課室設備', '網絡連線', '借用與歸還', '課表與班別'];
  static const _priorities = <String>['低', '中', '高'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: 'iPad 無法連接校園 Wi-Fi');
    _locationController = TextEditingController(text: '課室 3A');
    _descriptionController = TextEditingController(
      text: '今天第一節課開始前無法連接校園 Wi-Fi，重新啟動後仍會在 5 分鐘後斷開。',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitTicket() {
    if (!_formKey.currentState!.validate() || !widget.isManaged) {
      return;
    }

    final now = DateTime.now();
    final ticket = SupportTicket(
      ticketId: 'SR-${1000 + widget.tickets.length + 1}',
      title: _titleController.text.trim(),
      category: _selectedCategory,
      location: _locationController.text.trim(),
      priority: _selectedPriority,
      status: '已提交',
      submittedAt:
          '${now.month.toString().padLeft(2, '0')} 月 ${now.day.toString().padLeft(2, '0')} 日 ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      description: _descriptionController.text.trim(),
    );

    widget.onCreateTicket(ticket);

    _titleController.text = '課室投影連接後閃退';
    _locationController.text = '圖書館學習共享區';
    _descriptionController.text = '接上投影後畫面短暫顯示，再返回主畫面，需要協助檢查外接顯示設定。';
    setState(() {
      _selectedCategory = _categories.first;
      _selectedPriority = _priorities[1];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('报修已提交: ${ticket.ticketId}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _PageScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PageHeader(
            eyebrow: 'IT Service',
            title: '设备故障报修与支持',
            description: '提交课堂故障、网络异常和借用问题。这里只记录你主动填写的报修信息，不会读取其他个人数据。',
          ),
          const SizedBox(height: 18),
          if (!widget.isManaged)
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: _SectionCard(
                child: Text(
                  '目前設備未發現學校監管配置。接入學校管理後，可提交報修單並在本機持續保存工單記錄。',
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ),
          AdaptiveGrid(
            minItemWidth: 360,
            children: [
              _SectionCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('发起报修', style: theme.textTheme.titleLarge),
                      const SizedBox(height: 6),
                      Text(
                        '當前設備: ${widget.device.deviceName} · ${widget.device.deviceId}',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        items: _categories
                            .map(
                              (item) => DropdownMenuItem<String>(
                                value: item,
                                child: Text(item),
                              ),
                            )
                            .toList(),
                        decoration: const InputDecoration(labelText: '问题类型'),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedPriority,
                        items: _priorities
                            .map(
                              (item) => DropdownMenuItem<String>(
                                value: item,
                                child: Text(item),
                              ),
                            )
                            .toList(),
                        decoration: const InputDecoration(labelText: '紧急程度'),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            _selectedPriority = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(labelText: '問題標題'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '請輸入問題標題';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(labelText: '發生地點'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '請輸入發生地點';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 5,
                        decoration: const InputDecoration(labelText: '問題描述'),
                        validator: (value) {
                          if (value == null || value.trim().length < 10) {
                            return '請補充至少 10 個字的描述';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: widget.isManaged ? _submitTicket : null,
                        child: Text(widget.isManaged ? '提交报修' : '接入管理后可提交'),
                      ),
                    ],
                  ),
                ),
              ),
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('聯絡資訊', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(
                      '課堂問題優先處理。你也可以先聯絡值班 IT 管理員確認處理時段。',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    _ContactLine(
                      assetPath: _AppAssetPaths.supportAgent,
                      text: widget.contact.teamName,
                    ),
                    _ContactLine(
                      assetPath: _AppAssetPaths.phone,
                      text: widget.contact.phone,
                    ),
                    _ContactLine(
                      assetPath: _AppAssetPaths.mail,
                      text: widget.contact.email,
                    ),
                    _ContactLine(
                      assetPath: _AppAssetPaths.clock,
                      text: widget.contact.officeHours,
                    ),
                    _ContactLine(
                      assetPath: _AppAssetPaths.pin,
                      text: widget.contact.address,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.skyWash,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        widget.contact.responseSla,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.primaryAction,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () =>
                          _showContactDialog(context, widget.contact),
                      child: const Text('查看值班說明'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('报修记录', style: theme.textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(
                  '工單會保存在目前設備上，方便你後續繼續查看處理狀態。',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                for (final ticket in widget.tickets)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _TicketRow(ticket: ticket),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PrivacyTab extends StatelessWidget {
  const PrivacyTab({
    super.key,
    required this.visibleScope,
    required this.hiddenScope,
    required this.notices,
    required this.school,
    required this.contact,
    required this.policyUrl,
    required this.effectiveDate,
    required this.sections,
  });

  final PrivacyScope visibleScope;
  final PrivacyScope hiddenScope;
  final List<CampusNotice> notices;
  final SchoolOption school;
  final SupportContact contact;
  final String policyUrl;
  final String effectiveDate;
  final List<PrivacyPolicySection> sections;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _PageScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PageHeader(
            eyebrow: 'Privacy Policy',
            title: '正式隱私政策與資料邊界',
            description: '這裡說明校園設備助手如何處理與校園設備管理相關的資料，以及學校可以看到和不能看到的內容。',
          ),
          const SizedBox(height: 18),
          _SectionCard(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                colors: [AppColors.skyWash, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [cardShadow],
              border: Border.all(color: AppColors.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Tag(label: '正式隱私政策', color: AppColors.signalBlue),
                const SizedBox(height: 12),
                Text(
                  '校園設備助手僅處理學校設備管理、課表查閱、借用管理與報修服務所必需的資料。',
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  '當前學校: ${school.name} · 生效日期: $effectiveDate',
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          AdaptiveGrid(
            minItemWidth: 340,
            children: [
              _PrivacyScopeCard(scope: visibleScope, isVisible: true),
              _PrivacyScopeCard(scope: hiddenScope, isVisible: false),
            ],
          ),
          const SizedBox(height: 18),
          AdaptiveGrid(
            minItemWidth: 340,
            children: [
              _PolicyEntryCard(policyUrl: policyUrl),
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('政策聯絡資訊', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(
                      '如需行使更正、查詢或投訴等權利，可聯絡當前學校的資訊服務窗口。',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 14),
                    _ContactLine(
                      assetPath: _AppAssetPaths.supportAgent,
                      text: contact.teamName,
                    ),
                    _ContactLine(
                      assetPath: _AppAssetPaths.phone,
                      text: contact.phone,
                    ),
                    _ContactLine(
                      assetPath: _AppAssetPaths.mail,
                      text: contact.email,
                    ),
                    _ContactLine(
                      assetPath: _AppAssetPaths.pin,
                      text: contact.address,
                    ),
                  ],
                ),
              ),
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('公告与处理留痕', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(
                      '借用延长、应用更新和网络维护会以公告形式同步给用户。',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 14),
                    for (final notice in notices.take(2))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _NoticeRow(notice: notice),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          for (final section in sections)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _PolicySectionCard(section: section),
            ),
        ],
      ),
    );
  }
}

class _DesktopNavigation extends StatelessWidget {
  const _DesktopNavigation({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    required this.schoolName,
    required this.isManaged,
    required this.isBound,
  });

  final List<_AppDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final String schoolName;
  final bool isManaged;
  final bool isBound;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 256,
      color: AppColors.linenCanvas,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.outline),
              boxShadow: [cardShadow],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Tag(label: '校園設備助手', color: AppColors.signalBlue),
                const SizedBox(height: 10),
                Text('給學生、老師和設備管理員的 iOS 工作台', style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
          const SizedBox(height: 18),
          for (var index = 0; index < destinations.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _RailButton(
                destination: destinations[index],
                selected: index == selectedIndex,
                onTap: () => onSelected(index),
              ),
            ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.skyWash,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isManaged
                  ? '$schoolName 已接入學校管理'
                  : (isBound
                        ? '$schoolName 已保存綁定資訊，等待學校監管接入'
                        : '目前設備預設未納入學校監管'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.primaryAction,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RailButton extends StatelessWidget {
  const _RailButton({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final _AppDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.skyWash : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.signalBlue : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            _AppAssetIcon(
              assetPath: destination.assetPath,
              size: 18,
              opacity: selected ? 1 : 0.58,
            ),
            const SizedBox(width: 10),
            Text(
              destination.label,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: selected ? AppColors.primaryAction : AppColors.slate,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppAssetIcon extends StatelessWidget {
  const _AppAssetIcon({
    required this.assetPath,
    this.size = 24,
    this.opacity = 1,
  });

  final String assetPath;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

class _PageScrollView extends StatelessWidget {
  const _PageScrollView({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: SizedBox(width: double.infinity, child: child),
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.eyebrow,
    required this.title,
    required this.description,
  });

  final String eyebrow;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.signalBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(title, style: theme.textTheme.displaySmall),
        const SizedBox(height: 10),
        Text(
          description,
          style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.ash),
        ),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.schoolName,
    required this.isBound,
    required this.isManaged,
  });

  final String schoolName;
  final bool isBound;
  final bool isManaged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.skyWash,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          const _AppAssetIcon(assetPath: _AppAssetPaths.shieldCheck, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isManaged
                  ? '目前設備已接入 $schoolName 的學校管理，可查看課表、借用資訊、IT 公告和報修記錄。'
                  : (isBound
                        ? '$schoolName 的綁定資訊已保存，但目前設備預設未納入學校監管。'
                        : 'App 已讀取目前設備資訊，預設未納入學校監管。'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.primaryAction,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.device,
    required this.isBound,
    required this.isManaged,
    required this.onOpenTimetable,
    required this.onOpenService,
    required this.onOpenPrivacy,
  });

  final DeviceProfile device;
  final bool isBound;
  final bool isManaged;
  final VoidCallback onOpenTimetable;
  final VoidCallback onOpenService;
  final VoidCallback onOpenPrivacy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _SectionCard(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.outline),
        gradient: const RadialGradient(
          center: Alignment(0.1, -0.8),
          radius: 1.25,
          colors: [AppColors.skyWash, Colors.white],
        ),
        boxShadow: [cardShadow],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 860;

          final summary = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Tag(
                label: isManaged ? '設備已納管' : (isBound ? '設備已綁定' : '預設未納管'),
                color: isManaged
                    ? AppColors.signalBlue
                    : (isBound ? AppColors.amber : AppColors.coral),
              ),
              const SizedBox(height: 14),
              Text(
                isManaged
                    ? '這台 ${device.deviceName} 已被學校管理配置識別。'
                    : '這台 ${device.deviceName} 預設未納入學校監管。',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              Text(
                isManaged
                    ? '你可以在這裡快速確認學校名稱、設備編號、所屬班別、借用到期時間，以及目前設備是否已加入學校管理。'
                    : 'App 已讀取目前設備的系統資訊。若後續由學校透過 MDM 下發管理配置，這裡的納管狀態會自動更新。',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _InfoPill(
                    assetPath: _AppAssetPaths.school,
                    label: device.schoolName,
                  ),
                  _InfoPill(
                    assetPath: _AppAssetPaths.badge,
                    label: device.deviceId,
                  ),
                  _InfoPill(
                    assetPath: _AppAssetPaths.users,
                    label: device.className,
                  ),
                  _InfoPill(
                    assetPath: _AppAssetPaths.date,
                    label: '到期 ${device.borrowDueDate}',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  OutlinedButton(
                    onPressed: onOpenTimetable,
                    child: const Text('查看課程表'),
                  ),
                  FilledButton(
                    onPressed: onOpenService,
                    child: const Text('發起報修'),
                  ),
                  OutlinedButton(
                    onPressed: onOpenPrivacy,
                    child: const Text('隱私政策'),
                  ),
                ],
              ),
            ],
          );

          final statusPanel = Column(
            children: [
              _HighlightPanel(
                title: device.managementStatus,
                subtitle: '由 ${device.managerName} 統一維護',
                items: [
                  '系統版本: ${device.platformVersion}',
                  '設備序列號: ${device.serialNumber}',
                  '最後同步: ${device.lastSync}',
                  '網絡狀態: ${device.networkStatus}',
                ],
                accentColor: isManaged
                    ? AppColors.signalBlue
                    : (isBound ? AppColors.amber : AppColors.coral),
              ),
              const SizedBox(height: 14),
              _HighlightPanel(
                title: '學校只能看到管理必要資訊',
                subtitle: '照片、訊息、瀏覽內容不在管理範圍內',
                items: const ['可見: 設備狀態、班別課表、借用期限、工單進度', '不可見: 私人照片、聊天訊息、瀏覽記錄'],
                accentColor: AppColors.primaryAction,
              ),
            ],
          );

          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [summary, const SizedBox(height: 18), statusPanel],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: summary),
              const SizedBox(width: 18),
              Expanded(flex: 2, child: statusPanel),
            ],
          );
        },
      ),
    );
  }
}

class _HighlightPanel extends StatelessWidget {
  const _HighlightPanel({
    required this.title,
    required this.subtitle,
    required this.items,
    required this.accentColor,
  });

  final String title;
  final String subtitle;
  final List<String> items;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accentColor.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColors.primaryAction,
            ),
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _AppAssetIcon(
                    assetPath: _AppAssetPaths.checkCircle,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(item, style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class AdaptiveGrid extends StatelessWidget {
  const AdaptiveGrid({
    super.key,
    required this.minItemWidth,
    required this.children,
    this.spacing = 16,
  });

  final double minItemWidth;
  final double spacing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = math.max(
          1,
          (constraints.maxWidth / minItemWidth).floor(),
        );
        final itemWidth =
            (constraints.maxWidth - spacing * (count - 1)) / count;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(child: Text(title, style: theme.textTheme.titleLarge)),
        TextButton(onPressed: onAction, child: Text(actionLabel)),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.child,
    this.padding = const EdgeInsets.all(22),
    this.decoration,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Decoration? decoration;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration:
          decoration ??
          BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.outline),
            boxShadow: [cardShadow],
          ),
      child: child,
    );
  }
}

class _SchoolSelectionCard extends StatelessWidget {
  const _SchoolSelectionCard({
    required this.schools,
    required this.selectedSchoolId,
    required this.selectionLocked,
    required this.onChanged,
  });

  final List<SchoolOption> schools;
  final String selectedSchoolId;
  final bool selectionLocked;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final school = schools.firstWhere(
      (item) => item.id == selectedSchoolId,
      orElse: () => schools.first,
    );

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('學校選擇', style: theme.textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            selectionLocked
                ? '目前設備已從學校管理配置中識別出所屬學校。'
                : '目前可在 3 所香港學校之間切換，課表、隱私政策和 IT 聯絡方式會隨之更新。',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: selectedSchoolId,
            items: schools
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item.id,
                    child: Text(item.name),
                  ),
                )
                .toList(),
            decoration: const InputDecoration(labelText: '所屬學校'),
            onChanged: selectionLocked
                ? null
                : (value) {
                    if (value == null) {
                      return;
                    }
                    onChanged(value);
                  },
          ),
          const SizedBox(height: 16),
          _InfoRow(label: '地址', value: school.campus),
          const SizedBox(height: 8),
          _InfoRow(label: '課表模式', value: school.schedulePattern),
          const SizedBox(height: 8),
          _InfoRow(label: '設備前綴', value: school.devicePrefix),
        ],
      ),
    );
  }
}

class _DeviceBindingCard extends StatelessWidget {
  const _DeviceBindingCard({
    required this.school,
    required this.binding,
    required this.isBound,
    required this.isManaged,
    required this.onTapBind,
  });

  final SchoolOption school;
  final DeviceBinding? binding;
  final bool isBound;
  final bool isManaged;
  final VoidCallback onTapBind;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasLocalBinding = binding != null && binding!.deviceCode.isNotEmpty;
    final deviceCodeValue = hasLocalBinding
        ? '${school.devicePrefix}-${binding!.deviceCode}'
        : (isManaged ? '由學校管理配置提供' : '尚未填寫');
    final assignedToValue = hasLocalBinding
        ? binding!.assignedTo
        : (isManaged ? '由學校管理配置提供' : '尚未綁定');
    final classNameValue = hasLocalBinding
        ? binding!.className
        : (isManaged ? '由學校管理配置提供' : '尚未綁定');
    final boundAtValue = hasLocalBinding
        ? binding!.boundAt
        : (isManaged ? '由學校管理配置識別' : '等待綁定');

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('設備綁定', style: theme.textTheme.titleLarge)),
              _StatusChip(label: isBound ? '已綁定' : '待綁定'),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isManaged
                ? '目前設備已接入學校管理，綁定資訊會作為補充說明展示。'
                : (isBound
                      ? '目前設備已保存綁定資訊，但監管狀態仍以設備管理配置為準。'
                      : '輸入設備識別碼、使用身份和班別或部門後，可在本機保存綁定資訊。'),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          _InfoRow(label: '設備識別碼', value: deviceCodeValue),
          const SizedBox(height: 8),
          _InfoRow(label: '使用身份', value: assignedToValue),
          const SizedBox(height: 8),
          _InfoRow(label: '班別 / 部門', value: classNameValue),
          const SizedBox(height: 8),
          _InfoRow(label: '綁定時間', value: boundAtValue),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onTapBind,
            child: Text(isBound ? '重新綁定設備' : '開始綁定設備'),
          ),
        ],
      ),
    );
  }
}

class _PolicyUrlCard extends StatelessWidget {
  const _PolicyUrlCard({required this.policyUrl, required this.onOpenPrivacy});

  final String policyUrl;
  final VoidCallback onOpenPrivacy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('隱私政策入口', style: theme.textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            '你可以在 App 內查看完整政策，也可以透過網址打開正式隱私政策頁面。',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          SelectableText(policyUrl, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton(
                onPressed: () => _openExternalUrl(context, policyUrl),
                child: const Text('打开政策网址'),
              ),
              OutlinedButton(
                onPressed: () =>
                    _copyToClipboard(context, policyUrl, '隱私政策網址已複製'),
                child: const Text('複製網址'),
              ),
              OutlinedButton(
                onPressed: onOpenPrivacy,
                child: const Text('查看政策正文'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PolicyEntryCard extends StatelessWidget {
  const _PolicyEntryCard({required this.policyUrl});

  final String policyUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('隱私政策網址', style: theme.textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            '完整政策已在 App 內展示，同時提供獨立網址入口，便於學校、家長和設備管理員查看。',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          SelectableText(policyUrl, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton(
                onPressed: () => _openExternalUrl(context, policyUrl),
                child: const Text('打开网址'),
              ),
              OutlinedButton(
                onPressed: () =>
                    _copyToClipboard(context, policyUrl, '隱私政策網址已複製'),
                child: const Text('複製網址'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PolicySectionCard extends StatelessWidget {
  const _PolicySectionCard({required this.section});

  final PrivacyPolicySection section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(section.title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(section.summary, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 14),
          for (final item in section.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: const BoxDecoration(
                      color: AppColors.signalBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(item, style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.detail,
    required this.accentColor,
  });

  final String label;
  final String value;
  final String detail;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Tag(label: label, color: accentColor),
          const SizedBox(height: 14),
          Text(value, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(detail, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _TimetablePreviewCard extends StatelessWidget {
  const _TimetablePreviewCard({required this.day});

  final TimetableDay day;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lessons = day.lessons.where((lesson) => !lesson.isBreak).take(3);

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _TimetableBadge(color: AppColors.signalBlue),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${day.cycleLabel} · ${day.weekdayLabel}',
                  style: theme.textTheme.titleMedium,
                ),
              ),
              const _StatusChip(label: '8 節'),
            ],
          ),
          const SizedBox(height: 14),
          Text(day.focus, style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          for (final lesson in lessons)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '${lesson.slotLabel} ${lesson.subject}',
                style: theme.textTheme.bodyMedium,
              ),
            ),
        ],
      ),
    );
  }
}

class _TimetableDayCard extends StatelessWidget {
  const _TimetableDayCard({required this.day, required this.onMore});

  final TimetableDay day;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lessonRows = day.lessons.take(6).toList();

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TimetableBadge(color: AppColors.signalBlue, large: true),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${day.cycleLabel} · ${day.weekdayLabel}',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${day.classLabel} · ${day.focus}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(day.notes, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 14),
          for (final lesson in lessonRows)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _TimetableLessonRow(lesson: lesson),
            ),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: onMore, child: const Text('查看當日課表')),
        ],
      ),
    );
  }
}

class _PrivacyScopeCard extends StatelessWidget {
  const _PrivacyScopeCard({required this.scope, required this.isVisible});

  final PrivacyScope scope;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Tag(label: scope.title, color: scope.accentColor),
          const SizedBox(height: 12),
          Text(scope.description, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 14),
          for (final item in scope.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AppAssetIcon(
                    assetPath: isVisible
                        ? _AppAssetPaths.eye
                        : _AppAssetPaths.eyeOff,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(item, style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _NoticeRow extends StatelessWidget {
  const _NoticeRow({required this.notice});

  final CampusNotice notice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _showNoticeDetails(context, notice),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.linenCanvas,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Tag(
                  label: notice.tag,
                  color: notice.isPinned
                      ? AppColors.coral
                      : AppColors.signalBlue,
                ),
                const Spacer(),
                Text(notice.publishedAt, style: theme.textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 10),
            Text(notice.title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(notice.summary, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _TicketRow extends StatelessWidget {
  const _TicketRow({required this.ticket});

  final SupportTicket ticket;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.linenCanvas,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(ticket.title, style: theme.textTheme.titleMedium),
              ),
              _StatusChip(label: ticket.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${ticket.ticketId} · ${ticket.category} · ${ticket.priority} 优先级',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 6),
          Text(ticket.description, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 10),
          Row(
            children: [
              const _AppAssetIcon(
                assetPath: _AppAssetPaths.pin,
                size: 15,
                opacity: 0.72,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(ticket.location, style: theme.textTheme.bodySmall),
              ),
              Text(ticket.submittedAt, style: theme.textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.number,
    required this.title,
    required this.description,
  });

  final String number;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.skyWash,
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.primaryAction,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(description, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyBullet extends StatelessWidget {
  const _PrivacyBullet({
    required this.label,
    required this.text,
    required this.tone,
  });

  final String label;
  final String text;
  final _PrivacyTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AppAssetIcon(
          assetPath: tone == _PrivacyTone.visible
              ? _AppAssetPaths.checkCircle
              : _AppAssetPaths.cancelCircle,
          size: 18,
          opacity: tone == _PrivacyTone.visible ? 0.96 : 0.92,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium,
              children: [
                TextSpan(
                  text: '$label: ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryAction,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(text: text),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final color = switch (label) {
      '已提交' || '已綁定' || '今日課表' => AppColors.signalBlue,
      '处理中' || '處理中' => AppColors.amber,
      '待回访' || '待回訪' => AppColors.emerald,
      '待綁定' || '未納管' => AppColors.coral,
      _ => AppColors.primaryAction,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.assetPath, required this.label});

  final String assetPath;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _AppAssetIcon(assetPath: assetPath, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.primaryAction,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimetableBadge extends StatelessWidget {
  const _TimetableBadge({required this.color, this.large = false});

  final Color color;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final size = large ? 52.0 : 40.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.16),
            color.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: _AppAssetIcon(
          assetPath: _AppAssetPaths.date,
          size: large ? 26 : 20,
        ),
      ),
    );
  }
}

class _ContactLine extends StatelessWidget {
  const _ContactLine({required this.assetPath, required this.text});

  final String assetPath;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          _AppAssetIcon(assetPath: assetPath, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RichText(
      text: TextSpan(
        style: theme.textTheme.bodyMedium,
        children: [
          TextSpan(
            text: '$label: ',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primaryAction,
            ),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }
}

class _TimetableLessonRow extends StatelessWidget {
  const _TimetableLessonRow({required this.lesson});

  final TimetableLesson lesson;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (lesson.isBreak) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.linenCanvas,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const _AppAssetIcon(
              assetPath: _AppAssetPaths.breakTime,
              size: 18,
              opacity: 0.72,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${lesson.slotLabel} · ${lesson.subject}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.primaryAction,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '${lesson.startTime} - ${lesson.endTime}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: lesson.accentColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: lesson.accentColor.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${lesson.slotLabel} · ${lesson.subject}',
                  style: theme.textTheme.titleMedium,
                ),
              ),
              Text(
                '${lesson.startTime} - ${lesson.endTime}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${lesson.room} · ${lesson.teacherName}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.primaryAction,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(lesson.note, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

void _showTimetableDetails(BuildContext context, TimetableDay day) {
  final theme = Theme.of(context);

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return _BottomSheetShell(
        header: Row(
          children: [
            const _TimetableBadge(color: AppColors.signalBlue, large: true),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${day.cycleLabel} · ${day.weekdayLabel}',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${day.classLabel} · ${day.focus}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(day.notes, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 16),
            for (final lesson in day.lessons)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _TimetableLessonRow(lesson: lesson),
              ),
          ],
        ),
      );
    },
  );
}

void _showNoticeDetails(BuildContext context, CampusNotice notice) {
  final theme = Theme.of(context);

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return _BottomSheetShell(
        header: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Tag(
                  label: notice.tag,
                  color: notice.isPinned
                      ? AppColors.coral
                      : AppColors.signalBlue,
                ),
                const Spacer(),
                Text(notice.publishedAt, style: theme.textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 14),
            Text(notice.title, style: theme.textTheme.titleLarge),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notice.summary, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 12),
            Text(notice.details, style: theme.textTheme.bodyLarge),
          ],
        ),
      );
    },
  );
}

void _showContactDialog(BuildContext context, SupportContact contact) {
  showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('聯絡 IT 管理員'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(contact.teamName),
            const SizedBox(height: 8),
            Text('電話: ${contact.phone}'),
            const SizedBox(height: 4),
            Text('電郵: ${contact.email}'),
            const SizedBox(height: 4),
            Text('值班時間: ${contact.officeHours}'),
            const SizedBox(height: 4),
            Text('地點: ${contact.address}'),
            const SizedBox(height: 8),
            Text(contact.responseSla),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('關閉'),
          ),
        ],
      );
    },
  );
}

void _showBindingSheet(
  BuildContext context, {
  required SchoolOption school,
  required DeviceBinding? currentBinding,
  required ValueChanged<DeviceBinding> onSave,
}) {
  final current = currentBinding;
  final deviceCodeController = TextEditingController(
    text: current?.deviceCode ?? '0148',
  );
  final assignedToController = TextEditingController(
    text: current?.assignedTo ?? '學生借用 / 班主任負責',
  );
  final classController = TextEditingController(
    text: current?.className ?? '中一甲班',
  );
  final borrowDueDateController = TextEditingController(
    text: current?.borrowDueDate ?? school.defaultBorrowDueDate,
  );
  final formKey = GlobalKey<FormState>();

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return _BottomSheetShell(
        header: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '綁定到 ${school.name}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              '填寫學校設備識別碼、使用身份以及班別或部門資訊，完成本機綁定。',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: deviceCodeController,
                decoration: InputDecoration(
                  labelText: '設備識別碼',
                  prefixText: '${school.devicePrefix}-',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '請輸入設備識別碼';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: assignedToController,
                decoration: const InputDecoration(labelText: '使用身份'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '請輸入使用身份';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: classController,
                decoration: const InputDecoration(labelText: '班別 / 部門'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '請輸入班別或部門';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: borrowDueDateController,
                decoration: const InputDecoration(labelText: '借用到期時間'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '請輸入借用到期時間';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) {
                    return;
                  }

                  final now = DateTime.now();
                  final binding = DeviceBinding(
                    schoolId: school.id,
                    deviceCode: deviceCodeController.text.trim(),
                    assignedTo: assignedToController.text.trim(),
                    className: classController.text.trim(),
                    borrowDueDate: borrowDueDateController.text.trim(),
                    boundAt:
                        '${now.year} 年 ${now.month.toString().padLeft(2, '0')} 月 ${now.day.toString().padLeft(2, '0')} 日 ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                  );

                  onSave(binding);
                  Navigator.of(sheetContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${school.name} 設備綁定已保存'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text('保存綁定資訊'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> _openExternalUrl(BuildContext context, String rawUrl) async {
  final uri = Uri.tryParse(rawUrl);
  if (uri == null) {
    _showFailureMessage(context, '隱私政策網址格式無效');
    return;
  }

  final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!opened && context.mounted) {
    _showFailureMessage(context, '暫時無法打開該網址');
  }
}

Future<void> _copyToClipboard(
  BuildContext context,
  String value,
  String message,
) async {
  await Clipboard.setData(ClipboardData(text: value));
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

void _showFailureMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
  );
}

class _BottomSheetShell extends StatelessWidget {
  const _BottomSheetShell({required this.header, required this.child});

  final Widget header;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          MediaQuery.of(context).viewInsets.bottom + 12,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 720,
                  maxHeight: constraints.maxHeight * 0.92,
                ),
                child: Material(
                  color: AppColors.linenCanvas,
                  borderRadius: BorderRadius.circular(28),
                  clipBehavior: Clip.antiAlias,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 12),
                        Container(
                          width: 42,
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppColors.fog,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: header),
                              const SizedBox(width: 12),
                              IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const _AppAssetIcon(
                                  assetPath: _AppAssetPaths.close,
                                  size: 20,
                                ),
                                tooltip: '關閉',
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.primaryAction,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: AppColors.outline),
                        Flexible(
                          fit: FlexFit.loose,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                            child: child,
                          ),
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
    );
  }
}

enum _PrivacyTone { visible, hidden }

class _AppAssetPaths {
  static const navHome = 'assets/icons/generated/home.png';
  static const navCalendar = 'assets/icons/generated/calendar.png';
  static const navSupport = 'assets/icons/generated/support.png';
  static const navPrivacy = 'assets/icons/generated/privacy.png';

  static const supportAgent = 'assets/icons/generated/icon-support-agent.png';
  static const phone = 'assets/icons/generated/icon-phone.png';
  static const mail = 'assets/icons/generated/icon-mail.png';
  static const clock = 'assets/icons/generated/icon-clock.png';
  static const pin = 'assets/icons/generated/icon-pin.png';
  static const shieldCheck = 'assets/icons/generated/icon-shield-check.png';
  static const school = 'assets/icons/generated/icon-school.png';
  static const badge = 'assets/icons/generated/icon-badge.png';
  static const users = 'assets/icons/generated/icon-users.png';
  static const date = 'assets/icons/generated/icon-date.png';
  static const eye = 'assets/icons/generated/icon-eye.png';
  static const eyeOff = 'assets/icons/generated/icon-eye-off.png';
  static const checkCircle = 'assets/icons/generated/icon-check-circle.png';
  static const cancelCircle = 'assets/icons/generated/icon-cancel-circle.png';
  static const breakTime = 'assets/icons/generated/icon-break.png';
  static const close = 'assets/icons/generated/icon-close.png';
}

class _AppDestination {
  const _AppDestination({required this.label, required this.assetPath});

  final String label;
  final String assetPath;
}
