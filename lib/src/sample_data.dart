import 'package:flutter/material.dart';

import 'models.dart';
import 'theme.dart';

const privacyPolicyUrl = 'https://abm.laozhangchaye.cn/privacy.html';
const privacyPolicyEffectiveDate = '2026 年 5 月 30 日';

const schoolOptions = <SchoolOption>[
  SchoolOption(
    id: 'hotung',
    name: '何東中學',
    campus: '香港銅鑼灣嘉寧徑一號',
    devicePrefix: 'HTSS-HK',
    itTeamName: '何東中學資訊科技支援',
    supportPhone: '(852) 2577 5433',
    supportEmail: '請使用學校官網聯絡頁',
    supportAddress: '正校校務處，香港銅鑼灣嘉寧徑一號',
    officeHours: '上課日 07:45 - 17:30',
    responseSla: '上課時段故障優先處理，一般設備問題於同日回覆',
    networkName: 'HTSS Managed Wi-Fi',
    defaultBorrowDueDate: '2026 年 7 月 15 日',
    schedulePattern: '雙周編排，8 節正課',
    scheduleWindow: '08:15 點名，08:30 起正式上課，15:30 放學',
    defaultClassLabel: '中一級標準課表',
  ),
  SchoolOption(
    id: 'dls',
    name: '新界喇沙中學',
    campus: '新界上水金錢村',
    devicePrefix: 'DLSNT-HK',
    itTeamName: '新界喇沙中學資訊科技支援',
    supportPhone: '(852) 2670 0443',
    supportEmail: 'email@delasalle.edu.hk',
    supportAddress: '校務處，新界上水金錢村',
    officeHours: '上課日 07:50 - 17:15',
    responseSla: '課堂設備或帳號問題即日回覆，非緊急項目 1 個工作天內處理',
    networkName: 'DLSNT Managed Wi-Fi',
    defaultBorrowDueDate: '2026 年 7 月 10 日',
    schedulePattern: 'Day 1 - Day 6 輪轉周',
    scheduleWindow: '08:15 點名，上午 5 節、下午 3 節，午膳後續課',
    defaultClassLabel: '中二級標準課表',
  ),
  SchoolOption(
    id: 'mst',
    name: '聖公會莫壽增會督中學',
    campus: '香港新界大埔運頭角里 26 號',
    devicePrefix: 'MST-HK',
    itTeamName: '莫壽增會督中學 IT 服務台',
    supportPhone: '(852) 2656 7804',
    supportEmail: 'info@mst.edu.hk',
    supportAddress: '校務處，香港新界大埔運頭角里 26 號',
    officeHours: '上課日 07:45 - 17:45',
    responseSla: '課堂網絡與裝置故障優先支援，一般查詢於同日內回覆',
    networkName: 'MST Managed Wi-Fi',
    defaultBorrowDueDate: '2026 年 7 月 17 日',
    schedulePattern: 'Day 1 - Day 6 輪轉周',
    scheduleWindow: '08:15 點名，8 節正課，課後可安排聯課或延伸學習',
    defaultClassLabel: '中三級標準課表',
  ),
];

const seedDeviceBinding = DeviceBinding(
  schoolId: '',
  deviceCode: '',
  assignedTo: '',
  className: '',
  borrowDueDate: '',
  boundAt: '',
);

const campusNotices = <CampusNotice>[
  CampusNotice(
    title: '期終周借用裝置歸還安排更新',
    tag: '借用通知',
    publishedAt: '今天 09:10',
    summary: '借用中的 iPad 歸還窗口延長至 7 月中，歸還時請一併帶回保護殼及充電器。',
    details:
        '為配合香港學校期終周及補課安排，借用中的 iPad 歸還時間將按學校統一安排延後至 2026 年 7 月中。歸還時請同時帶回保護殼、充電器及借用記錄。如曾提交維修單，請在櫃台主動告知工單編號。',
    isPinned: true,
  ),
  CampusNotice(
    title: '下周起按 Day 1 - Day 6 輪轉課表上課',
    tag: '課表公告',
    publishedAt: '昨天 17:40',
    summary: '請留意下周恢復輪轉日制，班主任課、周會與體育課時段已同步更新。',
    details:
        '下周起恢復 Day 1 - Day 6 輪轉課表。班主任課、周會、體育課及聯課活動時段已更新。若裝置已接入學校管理，App 內會直接顯示最新輪轉日課表；若尚未接入，則會顯示學校標準課表供查閱。',
  ),
  CampusNotice(
    title: '星期六 10:00 至 12:00 校園網維護',
    tag: 'IT 公告',
    publishedAt: '05 月 28 日',
    summary: '維護期間可繼續查看已同步課表，報修紀錄會留存在本機並於網絡恢復後再處理。',
    details:
        '校園網將於星期六上午 10:00 至中午 12:00 進行維護。維護期間 App 內已同步的課表、借用資料與隱私政策可正常查看；新提交的報修內容會先保存在本機，待網絡恢復後再由值班 IT 人員跟進。',
  ),
];

const visiblePrivacyScope = PrivacyScope(
  title: '學校可以看到',
  description: '為了設備管理與課務支援，學校只會讀取教學及運維所需資料。',
  accentColor: AppColors.signalBlue,
  items: <String>[
    '設備編號、序列號、系統版本與合規狀態',
    '設備是否已加入學校管理',
    '班別、輪轉日課表與借用到期時間',
    '你主動提交的報修內容與工單進度',
    '校園服務相關的借還、公告確認與處理記錄',
  ],
);

const hiddenPrivacyScope = PrivacyScope(
  title: '學校不能看到',
  description: '本 App 不會讓學校查看私人內容，也不會蒐集與校務無關的資料。',
  accentColor: AppColors.coral,
  items: <String>[
    '個人照片、相簿內容與截圖記錄',
    '私人聊天訊息、郵件正文與社交帳號',
    'Safari 或其他瀏覽器的瀏覽內容',
    '其他非校園 App 的使用行為',
    '持續定位軌跡或背景即時位置',
    '未主動提交的檔案、錄音或備忘錄',
  ],
);

const privacyPolicySections = <PrivacyPolicySection>[
  PrivacyPolicySection(
    title: '一、適用範圍',
    summary: '本政策適用於校園設備助手在 iPhone 和 iPad 內提供的設備識別、課表查閱、公告通知與報修服務。',
    items: <String>[
      '當你使用由學校借用、指派或納管的裝置時，本 App 會展示與該裝置相關的校務服務資訊。',
      '本政策覆蓋客戶端內展示、提交與同步的資料處理活動，不涵蓋學校其他獨立系統的處理規則。',
    ],
  ),
  PrivacyPolicySection(
    title: '二、我們收集的資料',
    summary: '我們只收集完成校園設備管理與服務支援所必需的資料。',
    items: <String>[
      '設備與管理資料：設備編號、序列號、系統版本、納管狀態及網絡接入狀態。',
      '綁定資料：所屬學校、班別或部門、設備識別碼及借用到期時間。',
      '工單資料：你主動提交的故障標題、地點、描述與提交時間。',
    ],
  ),
  PrivacyPolicySection(
    title: '三、資料如何使用',
    summary: '資料只用於設備納管識別、課表呈現、校園公告同步與服務支援。',
    items: <String>[
      '確認設備是否屬於學校管理範圍，並決定可見的校園課表與服務內容。',
      '向裝置呈現所屬學校的輪轉日課表、借用提醒及 IT 公告。',
      '保存並處理你主動發起的報修請求。',
    ],
  ),
  PrivacyPolicySection(
    title: '四、共享、儲存與保留',
    summary: '我們不會將資料出售給第三方，也不會向廣告平台提供無關資料。',
    items: <String>[
      '只有學校授權的設備管理員、教務或 IT 人員可在職務範圍內查看相關資料。',
      '報修記錄會保存在本機，方便你再次開啟 App 時查看處理狀態。',
      '當借用關係結束或學校停用裝置後，相關記錄會按學校資料管理制度處理。',
    ],
  ),
  PrivacyPolicySection(
    title: '五、你的權利',
    summary: '你可以隨時查看目前設備的綁定資訊、隱私說明及工單內容。',
    items: <String>[
      '如發現綁定資料或報修內容有誤，可聯絡學校 IT 服務台更正。',
      '如需了解學校的進一步資料處理規則，可透過本頁提供的政策網址或聯絡方式查詢。',
    ],
  ),
];

const initialTickets = <SupportTicket>[
  SupportTicket(
    ticketId: 'SR-1048',
    title: 'Apple Pencil 連接不穩定',
    category: '課室設備',
    location: '課室 3A',
    priority: '中',
    status: '處理中',
    submittedAt: '今天 08:18',
    description: '重新配對後可以使用，但上課約 20 分鐘後再次斷線，需要協助檢查藍牙與筆身設定。',
  ),
  SupportTicket(
    ticketId: 'SR-1039',
    title: '午膳後無法連回校園 Wi-Fi',
    category: '網絡連線',
    location: '圖書館學習共享區',
    priority: '低',
    status: '待回訪',
    submittedAt: '昨天 19:42',
    description: '裝置午膳後返回課室時無法重新連接管理網絡，改用手動加入後問題暫時消失，等待 IT 跟進。',
  ),
];

SupportContact buildSupportContact(SchoolOption school) {
  return SupportContact(
    teamName: school.itTeamName,
    phone: school.supportPhone,
    email: school.supportEmail,
    officeHours: school.officeHours,
    responseSla: school.responseSla,
    address: school.supportAddress,
  );
}

DeviceProfile buildDeviceProfile({
  required SchoolOption school,
  required DeviceBinding? binding,
  required CurrentDeviceSnapshot currentDevice,
}) {
  final managedConfiguration = currentDevice.managedConfiguration;
  final managedSchoolId = managedConfiguration['school_id'] as String?;
  final managedSchoolName = managedConfiguration['school_name'] as String?;
  final managedAssignedTo = managedConfiguration['assigned_to'] as String?;
  final managedClassName = managedConfiguration['class_name'] as String?;
  final managedDeviceCode = managedConfiguration['device_code'] as String?;
  final managedBorrowDueDate =
      managedConfiguration['borrow_due_date'] as String?;
  final managedSerialNumber = managedConfiguration['serial_number'] as String?;
  final effectiveSchool =
      currentDevice.isManaged &&
          managedSchoolId != null &&
          managedSchoolId.isNotEmpty
      ? schoolOptions.firstWhere(
          (option) => option.id == managedSchoolId,
          orElse: () => school,
        )
      : school;
  final isBound = binding != null && binding.schoolId == effectiveSchool.id;
  final schoolName =
      currentDevice.isManaged &&
          managedSchoolName != null &&
          managedSchoolName.isNotEmpty
      ? managedSchoolName
      : effectiveSchool.name;
  final assignedTo =
      currentDevice.isManaged &&
          managedAssignedTo != null &&
          managedAssignedTo.isNotEmpty
      ? managedAssignedTo
      : (isBound ? binding.assignedTo : '待確認使用身份');
  final className =
      currentDevice.isManaged &&
          managedClassName != null &&
          managedClassName.isNotEmpty
      ? managedClassName
      : (isBound ? binding.className : '待同步班別 / 部門');
  final borrowDueDate =
      currentDevice.isManaged &&
          managedBorrowDueDate != null &&
          managedBorrowDueDate.isNotEmpty
      ? managedBorrowDueDate
      : (isBound
            ? binding.borrowDueDate
            : effectiveSchool.defaultBorrowDueDate);
  final deviceCode =
      currentDevice.isManaged &&
          managedDeviceCode != null &&
          managedDeviceCode.isNotEmpty
      ? managedDeviceCode
      : (isBound ? binding.deviceCode : currentDevice.fallbackDeviceCode);
  final serialNumber =
      managedSerialNumber != null && managedSerialNumber.isNotEmpty
      ? managedSerialNumber
      : (currentDevice.vendorIdentifier.isNotEmpty
            ? currentDevice.vendorIdentifier
            : currentDevice.machineIdentifier);

  return DeviceProfile(
    deviceName: currentDevice.preferredDeviceLabel,
    schoolName: schoolName,
    deviceId: '${effectiveSchool.devicePrefix}-$deviceCode',
    className: className,
    assignedTo: assignedTo,
    borrowDueDate: borrowDueDate,
    managerName: effectiveSchool.itTeamName,
    platformVersion:
        '${currentDevice.systemName} ${currentDevice.systemVersion}'.trim(),
    serialNumber: serialNumber.isNotEmpty ? serialNumber : '未提供',
    lastSync: currentDevice.isManaged ? '已讀取目前管理配置' : '未發現學校監管配置',
    networkStatus: currentDevice.isManaged
        ? '${effectiveSchool.networkName} 已接入'
        : '目前裝置未發現校園管理網絡配置',
    managementStatus: currentDevice.isManaged ? '已加入學校管理' : '預設未納入學校監管',
  );
}

List<TimetableDay> buildSchoolTimetable({
  required SchoolOption school,
  required String className,
}) {
  final effectiveClassName = _resolveClassLabel(school, className);
  return switch (school.id) {
    'hotung' => _buildHotungTimetable(effectiveClassName),
    'dls' => _buildDlsTimetable(effectiveClassName),
    'mst' => _buildMstTimetable(effectiveClassName),
    _ => _buildHotungTimetable(effectiveClassName),
  };
}

String _resolveClassLabel(SchoolOption school, String className) {
  if (className.isEmpty || className.startsWith('待')) {
    return school.defaultClassLabel;
  }
  return className;
}

List<TimetableDay> _buildHotungTimetable(String classLabel) {
  return _buildCycleTimetable(
    classLabel: classLabel,
    focuses: const <String>[
      '語文與數理主軸',
      '探究與表達',
      '創科與閱讀',
      '體藝與德育',
      '跨學科延伸',
      '班主任課與總結',
    ],
    notes: const <String>[
      '按雙周編排上課，上午五節、下午三節。',
      '英文及數學課後通常會有短題跟進。',
      '中一可按安排於放學後參加自主學習課。',
      '體育課請攜帶運動服及更換衣物。',
      '下午最後一節常安排專題學習或資訊科技。',
      '周會、班主任課及借用裝置檢查通常安排於 Day 6。',
    ],
    lessonSets: const <List<_LessonSeed>>[
      [
        _LessonSeed('中文', '201 室', '梁老師', '閱讀與寫作'),
        _LessonSeed('英文', '201 室', 'Chan Sir', 'Speaking drill'),
        _LessonSeed('數學', '201 室', '黃老師', '代數練習'),
        _LessonSeed('綜合科學', '實驗室 2', '李老師', '光學實驗'),
        _LessonSeed('中史', '201 室', '鄭老師', '秦漢專題'),
        _LessonSeed('地理', '地理室', 'Ho Sir', '香港城市發展'),
        _LessonSeed('資訊科技', '電腦室 1', '周老師', '試算表'),
        _LessonSeed('體育', '操場', 'Ng Sir', '田徑基礎'),
      ],
      [
        _LessonSeed('數學', '201 室', '黃老師', '幾何作圖'),
        _LessonSeed('中文', '201 室', '梁老師', '古文導讀'),
        _LessonSeed('普通話', '語言室', '何老師', '朗讀訓練'),
        _LessonSeed('英文', '201 室', 'Chan Sir', 'Reading circle'),
        _LessonSeed('生活與社會', '201 室', '林老師', '社區議題'),
        _LessonSeed('視覺藝術', '視藝室', '馮老師', '色彩構成'),
        _LessonSeed('音樂', '音樂室', 'Cheung Miss', '節奏練習'),
        _LessonSeed('班主任課', '201 室', '班主任', '周初事務與借用提醒'),
      ],
      [
        _LessonSeed('英文', '201 室', 'Chan Sir', 'Grammar focus'),
        _LessonSeed('數學', '201 室', '黃老師', '小測訂正'),
        _LessonSeed('綜合科學', '實驗室 1', '李老師', '觀察記錄'),
        _LessonSeed('中國歷史', '201 室', '鄭老師', '史料分析'),
        _LessonSeed('閱讀課', '圖書館', '圖書館主任', '靜讀與借閱'),
        _LessonSeed('設計與科技', 'STEM 室', 'Kwok Sir', '結構模型'),
        _LessonSeed('數學延伸', '201 室', '黃老師', '堂課鞏固'),
        _LessonSeed('自主學習', '自修室', '學習支援組', '中一級可延伸至 16:30'),
      ],
      [
        _LessonSeed('中文', '201 室', '梁老師', '寫作工坊'),
        _LessonSeed('生活與社會', '201 室', '林老師', '公民議題'),
        _LessonSeed('數學', '201 室', '黃老師', '比例與百分率'),
        _LessonSeed('體育', '禮堂', 'Ng Sir', '球類技巧'),
        _LessonSeed('英文', '201 室', 'Chan Sir', 'Listening task'),
        _LessonSeed('音樂', '音樂室', 'Cheung Miss', '合唱排練'),
        _LessonSeed('視覺藝術', '視藝室', '馮老師', '素描'),
        _LessonSeed('德育及周會', '禮堂', '訓導組', '整級活動'),
      ],
      [
        _LessonSeed('綜合科學', '實驗室 2', '李老師', '實驗匯報'),
        _LessonSeed('英文', '201 室', 'Chan Sir', 'Writing workshop'),
        _LessonSeed('中文', '201 室', '梁老師', '語文運用'),
        _LessonSeed('普通話', '語言室', '何老師', '口語互動'),
        _LessonSeed('數學', '201 室', '黃老師', '應用題'),
        _LessonSeed('地理', '地理室', 'Ho Sir', '氣候圖判讀'),
        _LessonSeed('資訊科技', '電腦室 1', '周老師', '簡報製作'),
        _LessonSeed('專題研習', '201 室', '班主任', '跨科題目整理'),
      ],
      [
        _LessonSeed('班主任課', '201 室', '班主任', '回顧本周學習'),
        _LessonSeed('中文', '201 室', '梁老師', '默書訂正'),
        _LessonSeed('英文', '201 室', 'Chan Sir', 'Vocabulary quiz'),
        _LessonSeed('數學', '201 室', '黃老師', '周結練習'),
        _LessonSeed('中史', '201 室', '鄭老師', '單元重點'),
        _LessonSeed('綜合科學', '實驗室 1', '李老師', '概念統整'),
        _LessonSeed('閱讀分享', '圖書館', '圖書館主任', '閱讀報告'),
        _LessonSeed('聯課活動', '指定場地', '活動導師', '課後活動或服務學習'),
      ],
    ],
  );
}

List<TimetableDay> _buildDlsTimetable(String classLabel) {
  return _buildCycleTimetable(
    classLabel: classLabel,
    focuses: const <String>[
      '語文與數學基礎',
      '人文與宗教',
      '科學與電腦素養',
      '藝術與表達',
      '跨課程閱讀',
      '班級總結與聯課',
    ],
    notes: const <String>[
      '依 Day 1 - Day 6 輪轉，初中課表以語文及數學為主軸。',
      '宗教及倫理課會按學校課程安排輪替。',
      'Science 與 Computer Literacy 以雙課節或實作課為主。',
      '下午時段常安排音樂、視藝或體育。',
      '課程結構含中史、歷史及生活與社會。',
      '周內會視情況安排班主任課、周會或聯課活動。',
    ],
    lessonSets: const <List<_LessonSeed>>[
      [
        _LessonSeed('中文語文', '2A 課室', '陳老師', '閱讀策略'),
        _LessonSeed('英文語文', '2A 課室', 'Lee Miss', 'Speaking task'),
        _LessonSeed('數學', '2A 課室', 'Wong Sir', '整式與因式'),
        _LessonSeed('Science', 'Science Lab 1', 'Yip Sir', '實驗安全'),
        _LessonSeed('Life and Society', '2A 課室', 'Tsui Miss', '社會參與'),
        _LessonSeed('中國歷史', '2A 課室', '馬老師', '唐宋單元'),
        _LessonSeed('Computer Literacy', '電腦室', 'Lam Sir', 'Keyboarding'),
        _LessonSeed('體育', '操場', 'Poon Sir', '團隊合作'),
      ],
      [
        _LessonSeed('英文語文', '2A 課室', 'Lee Miss', 'Reading journal'),
        _LessonSeed('數學', '2A 課室', 'Wong Sir', '比例與方程'),
        _LessonSeed('普通話', '語言室', '張老師', '語音練習'),
        _LessonSeed('中文語文', '2A 課室', '陳老師', '寫作修訂'),
        _LessonSeed('History', '2A 課室', 'Au Sir', '古文明'),
        _LessonSeed('Ethics & Religious Studies', '宗教室', 'Ho Miss', '價值反思'),
        _LessonSeed('Visual Arts', '視藝室', 'Ng Miss', '平面設計'),
        _LessonSeed('Music', '音樂室', 'Cheung Sir', '節拍與合奏'),
      ],
      [
        _LessonSeed('數學', '2A 課室', 'Wong Sir', '堂課練習'),
        _LessonSeed('Science', 'Science Lab 2', 'Yip Sir', '觀察與記錄'),
        _LessonSeed('中文語文', '2A 課室', '陳老師', '文言詞彙'),
        _LessonSeed('英文語文', '2A 課室', 'Lee Miss', 'Writing focus'),
        _LessonSeed('Computer Literacy', '電腦室', 'Lam Sir', '程式邏輯'),
        _LessonSeed('Design & Technology', 'DT Room', 'Lau Sir', '模型製作'),
        _LessonSeed('閱讀課', '圖書館', '圖書館主任', '館藏閱讀'),
        _LessonSeed('班主任課', '2A 課室', '班主任', '級務與週記'),
      ],
      [
        _LessonSeed('中文語文', '2A 課室', '陳老師', '聽說訓練'),
        _LessonSeed('Life and Society', '2A 課室', 'Tsui Miss', '生活議題'),
        _LessonSeed('數學', '2A 課室', 'Wong Sir', '圖表解讀'),
        _LessonSeed('Science', 'Science Lab 1', 'Yip Sir', '實驗匯報'),
        _LessonSeed('英文語文', '2A 課室', 'Lee Miss', 'Listening notes'),
        _LessonSeed('體育', '禮堂', 'Poon Sir', '基本體能'),
        _LessonSeed('中國歷史', '2A 課室', '馬老師', '歷史人物'),
        _LessonSeed('聯課活動', '指定場地', '活動導師', '課後社團準備'),
      ],
      [
        _LessonSeed('英文語文', '2A 課室', 'Lee Miss', 'Vocabulary review'),
        _LessonSeed('普通話', '語言室', '張老師', '情境對話'),
        _LessonSeed('中文語文', '2A 課室', '陳老師', '修辭運用'),
        _LessonSeed('數學', '2A 課室', 'Wong Sir', '小測講評'),
        _LessonSeed('History', '2A 課室', 'Au Sir', '因果分析'),
        _LessonSeed('Ethics & Religious Studies', '宗教室', 'Ho Miss', '信仰與生活'),
        _LessonSeed('Visual Arts', '視藝室', 'Ng Miss', '版畫練習'),
        _LessonSeed('專題研習', '2A 課室', '班主任', '跨科匯報'),
      ],
      [
        _LessonSeed('班主任課', '2A 課室', '班主任', '本周總結'),
        _LessonSeed('中文語文', '2A 課室', '陳老師', '默書與訂正'),
        _LessonSeed('英文語文', '2A 課室', 'Lee Miss', 'Dictation follow-up'),
        _LessonSeed('數學', '2A 課室', 'Wong Sir', '統整練習'),
        _LessonSeed('Science', 'Science Lab 2', 'Yip Sir', '概念整理'),
        _LessonSeed('Life and Society', '2A 課室', 'Tsui Miss', '反思紀錄'),
        _LessonSeed('Music', '音樂室', 'Cheung Sir', '合唱排練'),
        _LessonSeed('周會 / 服務學習', '禮堂', '訓輔組', '整級活動或講座'),
      ],
    ],
  );
}

List<TimetableDay> _buildMstTimetable(String classLabel) {
  return _buildCycleTimetable(
    classLabel: classLabel,
    focuses: const <String>[
      '語文與科學',
      '價值教育與人文',
      'STEM 與資訊科技',
      '藝術與體育',
      '閱讀與探究',
      '班級經營與聯課',
    ],
    notes: const <String>[
      'Day 1 著重語文、數學及科學基礎。',
      '宗教教育及價值教育會按循環周安排。',
      'STEM 和 Computer Literacy 於初中課程中佔較高比重。',
      '體育及美藝課多安排在下午時段。',
      '圖書館閱讀與專題探究按班別輪替。',
      'Day 6 常用作班主任課、周會或服務學習總結。',
    ],
    lessonSets: const <List<_LessonSeed>>[
      [
        _LessonSeed('中文語文', '3A 課室', '周老師', '寫作與閱讀'),
        _LessonSeed('英文語文', '3A 課室', 'Yeung Miss', 'Listening & speaking'),
        _LessonSeed('數學', '3A 課室', 'Mak Sir', '代數運算'),
        _LessonSeed('Science', '實驗室 3', 'Chan Sir', '熱能單元'),
        _LessonSeed('中國歷史', '3A 課室', '葉老師', '史料分析'),
        _LessonSeed('地理', '地理室', 'Lau Miss', '人口分布'),
        _LessonSeed('Computer Literacy', '電腦室 2', 'Ng Sir', 'Python 基礎'),
        _LessonSeed('體育', '操場', 'Cheung Sir', '耐力訓練'),
      ],
      [
        _LessonSeed('英文語文', '3A 課室', 'Yeung Miss', 'Reading response'),
        _LessonSeed('數學', '3A 課室', 'Mak Sir', '幾何與證明'),
        _LessonSeed('普通話', '語言室', '林老師', '口語表達'),
        _LessonSeed('中文語文', '3A 課室', '周老師', '文學作品'),
        _LessonSeed('宗教教育', '宗教室', 'Ho Miss', '價值反思'),
        _LessonSeed('生活教育', '3A 課室', '班主任', '生涯規劃'),
        _LessonSeed('視覺藝術', '視藝室', 'Fung Miss', '媒材實驗'),
        _LessonSeed('音樂', '音樂室', 'Tsang Sir', '節奏創作'),
      ],
      [
        _LessonSeed('數學', '3A 課室', 'Mak Sir', '小測講評'),
        _LessonSeed('Science', '實驗室 2', 'Chan Sir', '數據紀錄'),
        _LessonSeed('中文語文', '3A 課室', '周老師', '修辭與表達'),
        _LessonSeed('英文語文', '3A 課室', 'Yeung Miss', 'Writing workshop'),
        _LessonSeed('Computer Literacy', '電腦室 2', 'Ng Sir', 'Micro:bit 專題'),
        _LessonSeed('STEM', '創科室', 'STEM Team', '跨科實作'),
        _LessonSeed('閱讀課', '圖書館', '圖書館主任', '主題閱讀'),
        _LessonSeed('班主任課', '3A 課室', '班主任', '班務與借用檢查'),
      ],
      [
        _LessonSeed('中文語文', '3A 課室', '周老師', '口語報告'),
        _LessonSeed('公民與社會', '3A 課室', 'Lee Sir', '時事討論'),
        _LessonSeed('數學', '3A 課室', 'Mak Sir', '應用題訓練'),
        _LessonSeed('體育', '禮堂', 'Cheung Sir', '球類合作'),
        _LessonSeed('英文語文', '3A 課室', 'Yeung Miss', 'Listening quiz'),
        _LessonSeed('音樂', '音樂室', 'Tsang Sir', '合奏排練'),
        _LessonSeed('視覺藝術', '視藝室', 'Fung Miss', '構圖練習'),
        _LessonSeed('周會', '禮堂', '學生成長組', '級本活動'),
      ],
      [
        _LessonSeed('Science', '實驗室 3', 'Chan Sir', '實驗匯報'),
        _LessonSeed('英文語文', '3A 課室', 'Yeung Miss', 'Vocabulary review'),
        _LessonSeed('中文語文', '3A 課室', '周老師', '文言選篇'),
        _LessonSeed('普通話', '語言室', '林老師', '朗讀演說'),
        _LessonSeed('數學', '3A 課室', 'Mak Sir', '周練跟進'),
        _LessonSeed('地理', '地理室', 'Lau Miss', '地圖判讀'),
        _LessonSeed('STEM', '創科室', 'STEM Team', '專題原型'),
        _LessonSeed('專題研習', '3A 課室', '班主任', '跨科匯報整理'),
      ],
      [
        _LessonSeed('班主任課', '3A 課室', '班主任', '本周總結'),
        _LessonSeed('中文語文', '3A 課室', '周老師', '默書回饋'),
        _LessonSeed('英文語文', '3A 課室', 'Yeung Miss', 'Grammar check'),
        _LessonSeed('數學', '3A 課室', 'Mak Sir', '統整練習'),
        _LessonSeed('中國歷史', '3A 課室', '葉老師', '單元整理'),
        _LessonSeed('Science', '實驗室 2', 'Chan Sir', '概念鞏固'),
        _LessonSeed('服務學習', '指定場地', '學生支援組', '班級或社區服務'),
        _LessonSeed('聯課活動', '指定場地', '活動導師', '社團或校隊訓練'),
      ],
    ],
  );
}

List<TimetableDay> _buildCycleTimetable({
  required String classLabel,
  required List<String> focuses,
  required List<String> notes,
  required List<List<_LessonSeed>> lessonSets,
}) {
  return List<TimetableDay>.generate(lessonSets.length, (index) {
    return TimetableDay(
      cycleLabel: 'Day ${index + 1}',
      weekdayLabel: _weekdayLabels[index],
      classLabel: classLabel,
      focus: focuses[index],
      notes: notes[index],
      lessons: _buildLessonTimeline(lessonSets[index]),
    );
  });
}

List<TimetableLesson> _buildLessonTimeline(List<_LessonSeed> seeds) {
  return <TimetableLesson>[
    _breakLesson('點名', '08:15', '08:30', '班主任點名', '確認出席與裝置狀態'),
    _lesson('第 1 節', '08:30', '09:10', seeds[0]),
    _lesson('第 2 節', '09:10', '09:50', seeds[1]),
    _lesson('第 3 節', '09:50', '10:30', seeds[2]),
    _breakLesson('小息', '10:30', '10:50', '小息', '課間休息'),
    _lesson('第 4 節', '10:50', '11:30', seeds[3]),
    _lesson('第 5 節', '11:30', '12:10', seeds[4]),
    _breakLesson('午膳', '12:10', '13:20', '午膳 / 午會', '按學校安排進行午膳或午會'),
    _lesson('第 6 節', '13:20', '14:00', seeds[5]),
    _lesson('第 7 節', '14:00', '14:40', seeds[6]),
    _breakLesson('轉堂', '14:40', '14:50', '轉堂', '前往下午最後一節課室'),
    _lesson('第 8 節', '14:50', '15:30', seeds[7]),
  ];
}

TimetableLesson _lesson(
  String slotLabel,
  String startTime,
  String endTime,
  _LessonSeed seed,
) {
  return TimetableLesson(
    slotLabel: slotLabel,
    startTime: startTime,
    endTime: endTime,
    subject: seed.subject,
    room: seed.room,
    teacherName: seed.teacherName,
    note: seed.note,
    accentColor: _accentColorForSubject(seed.subject),
  );
}

TimetableLesson _breakLesson(
  String slotLabel,
  String startTime,
  String endTime,
  String subject,
  String note,
) {
  return TimetableLesson(
    slotLabel: slotLabel,
    startTime: startTime,
    endTime: endTime,
    subject: subject,
    room: '',
    teacherName: '',
    note: note,
    accentColor: AppColors.outline,
    isBreak: true,
  );
}

const _weekdayLabels = <String>['星期一', '星期二', '星期三', '星期四', '星期五', '循環周'];

class _LessonSeed {
  const _LessonSeed(this.subject, this.room, this.teacherName, this.note);

  final String subject;
  final String room;
  final String teacherName;
  final String note;
}

Color _accentColorForSubject(String subject) {
  if (subject.contains('英文') || subject.contains('English')) {
    return AppColors.signalBlue;
  }
  if (subject.contains('數學') || subject.contains('Math')) {
    return AppColors.amber;
  }
  if (subject.contains('科學') || subject.contains('Science')) {
    return AppColors.emerald;
  }
  if (subject.contains('體育') ||
      subject.contains('音樂') ||
      subject.contains('藝術')) {
    return AppColors.coral;
  }
  return AppColors.primaryAction;
}
