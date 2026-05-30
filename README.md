# CampusLink

校园设备助手的 Flutter 工程，当前版本聚焦 iOS 客户端。

## 功能范围

- 查看设备是否已加入学校管理
- 显示学校名称、设备编号、所属班级与借用到期时间
- 查看香港学校轮转课程表
- 查看校园 IT 公告
- 发起设备故障报修
- 联系 IT 管理员
- 展示学校可见 / 不可见的数据边界

## 当前特性

- 支持 3 所香港学校切换与设备绑定
- 本地保存工单记录
- App 内提供正式隐私政策与网址入口
- 不请求相册、通讯录、定位、麦克风、相机等隐私权限
- iOS 图标、启动页和展示名已替换，去除默认 Flutter 模板痕迹

## iOS 当前配置

- Display Name: `校园设备助手`
- Bundle Identifier: `com.campuslink.deviceassistant`

如果你在 App Store Connect 里已经创建了正式 App ID，请把 bundle identifier 改成你自己的正式值再归档。
