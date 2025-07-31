# 任务管理系统

一个完整的任务管理解决方案，包含Python Flask后端服务、Web管理界面和Android移动应用。系统允许通过Web界面创建和分配任务给连接的Android设备，设备可以接收任务并报告执行结果。

## 📋 项目概述

### 系统架构
- **后端服务**: Python Flask + Flask-CORS
- **Web管理界面**: HTML5 + Bootstrap 5 + JavaScript
- **Android应用**: Flutter/Dart

### 主要功能
- ✅ Web界面创建和管理任务
- ✅ Android设备注册和连接
- ✅ 实时任务分发和状态跟踪
- ✅ 任务执行结果记录
- ✅ 设备在线状态监控
- ✅ 历史记录查看

## 🚀 快速开始

### 环境要求

**后端服务:**
- Python 3.7+
- pip

**Android应用:**
- Flutter SDK 3.0+
- Dart SDK
- Android Studio (可选)

### 1. 后端服务部署

#### 安装依赖
```bash
# 克隆项目
git clone <repository-url>
cd task-management-system

# 安装Python依赖
pip install -r requirements.txt
```

#### 启动服务器
```bash
# 方法1: 使用启动脚本（推荐）
python start_server.py

# 方法2: 直接运行Flask应用
python app.py
```

服务器启动后会显示：
```
==================================================
任务管理系统启动
==================================================
✓ 依赖包检查通过
启动Flask服务器...
Web管理界面: http://localhost:8080
按 Ctrl+C 停止服务器
--------------------------------------------------
```

### 2. Web管理界面使用

打开浏览器访问 `http://localhost:8080` 进入管理界面。

#### 功能说明:
- **任务管理**: 创建、分配和发送任务
- **设备管理**: 查看已连接的设备状态
- **历史记录**: 查看任务执行历史

#### 创建任务流程:
1. 确保有设备已连接（设备列表中显示）
2. 在"创建新任务"区域填写任务信息
3. 选择要分配的设备
4. 点击"创建任务"
5. 在任务列表中点击"发送"按钮将任务发送给设备

### 3. Android应用安装和使用

#### 构建应用
```bash
cd android_app

# 获取依赖
flutter pub get

# 构建APK
flutter build apk

# 或者直接运行（需要连接设备或启动模拟器）
flutter run
```

#### 首次配置
1. 打开应用，进入设备设置页面
2. 输入服务器地址，例如: `http://192.168.1.100:8080`
3. 点击"测试连接"确保能连接到服务器
4. 输入设备名称（如：我的手机）
5. 点击"注册设备"完成配置

#### 使用说明
- 应用会自动每30秒刷新任务列表
- 收到新任务时会显示在任务列表中
- 点击任务可查看详细信息
- 对于"已发送"状态的任务，可以标记为"完成"或"失败"
- 可以添加执行结果或失败原因

## 🔧 配置说明

### 服务器配置
- **端口**: 默认8080，可在 `app.py` 中修改
- **主机**: 默认绑定所有网络接口 (`0.0.0.0`)
- **调试模式**: 开发环境默认开启

### 网络配置
为了让Android设备能够连接到服务器，需要：

1. **本地网络**: 确保设备和服务器在同一局域网
2. **防火墙**: 开放8080端口
3. **IP地址**: 在Android应用中使用服务器的实际IP地址

#### 获取服务器IP地址:
```bash
# Linux/Mac
ip addr show | grep inet

# Windows
ipconfig
```

### 内网穿透（可选）
如果需要外网访问，可以使用内网穿透工具如：
- ngrok
- frp
- 花生壳

## 📊 API文档

### 设备注册
```http
POST /api/register
Content-Type: application/json

{
    "device_name": "设备名称"
}
```

### 获取任务
```http
GET /api/tasks/{device_id}
```

### 更新任务状态
```http
POST /api/tasks/{task_id}/status
Content-Type: application/json

{
    "device_id": "设备ID",
    "status": "completed|failed",
    "result": "执行结果"
}
```

### 获取设备列表
```http
GET /api/devices
```

## 🗂️ 项目结构

```
task-management-system/
├── app.py                          # Flask主应用
├── start_server.py                 # 服务器启动脚本
├── requirements.txt                # Python依赖
├── templates/
│   └── index.html                  # Web管理界面
├── static/                         # 静态资源目录
├── android_app/                    # Android应用
│   ├── pubspec.yaml               # Flutter项目配置
│   ├── lib/
│   │   ├── main.dart              # 应用入口
│   │   ├── models/
│   │   │   └── task.dart          # 任务数据模型
│   │   ├── services/
│   │   │   └── api_service.dart   # API服务
│   │   └── screens/
│   │       ├── setup_screen.dart  # 设置页面
│   │       └── task_list_screen.dart # 任务列表页面
│   └── android/
│       └── app/src/main/
│           └── AndroidManifest.xml # Android配置
└── README.md                       # 项目文档
```

## 🔍 故障排除

### 常见问题

#### 1. Android应用无法连接服务器
- 检查IP地址是否正确
- 确保设备和服务器在同一网络
- 检查防火墙设置
- 尝试在浏览器中访问服务器地址

#### 2. 任务不显示
- 确保设备已正确注册
- 检查服务器日志
- 在Web界面确认任务已分配给正确的设备

#### 3. Flask服务无法启动
- 检查Python版本 (需要3.7+)
- 确保已安装所有依赖: `pip install -r requirements.txt`
- 检查端口8080是否被占用

#### 4. Flutter构建失败
- 运行 `flutter doctor` 检查环境
- 确保Flutter SDK版本 >= 3.0
- 运行 `flutter clean` 清除缓存

### 调试技巧
- 查看Flask控制台输出获取API调用日志
- 在Android应用中查看logcat输出
- 使用浏览器开发者工具查看网络请求

## 🔒 安全注意事项

⚠️ **重要**: 当前版本仅适用于本地开发和测试环境

**生产环境部署时请考虑：**
- 添加用户认证和授权
- 使用HTTPS加密通信
- 添加输入验证和数据清理
- 实施API访问限制
- 使用数据库持久化存储

## 🚀 部署选项

### 本地部署
适用于开发和测试，按照快速开始指南即可。

### 生产部署
建议使用：
- **Web服务器**: Nginx + Gunicorn
- **数据库**: PostgreSQL 或 MySQL
- **缓存**: Redis
- **监控**: Prometheus + Grafana

## 📝 更新日志

### v1.0.0 (当前版本)
- ✅ 实现基础任务管理功能
- ✅ Web管理界面
- ✅ Android应用
- ✅ RESTful API
- ✅ 实时状态同步

### 未来计划
- 🔲 用户认证系统
- 🔲 任务模板功能
- 🔲 推送通知
- 🔲 数据持久化
- 🔲 批量任务处理

## 🤝 贡献指南

欢迎提交Issue和Pull Request！

1. Fork本项目
2. 创建特性分支: `git checkout -b feature/amazing-feature`
3. 提交更改: `git commit -m 'Add some amazing feature'`
4. 推送分支: `git push origin feature/amazing-feature`
5. 提交Pull Request

## 📄 许可证

本项目采用MIT许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 💬 支持

如果你遇到问题或有疑问，请：
1. 查看本文档的故障排除部分
2. 搜索已有的Issues
3. 创建新的Issue描述问题

---

**快速测试任务示例:**
1. 启动服务器: `python start_server.py`
2. 打开 http://localhost:8080
3. 安装并配置Android应用
4. 创建任务"去扫地"并分配给设备
5. 在手机上查看任务并标记完成

享受你的任务管理系统！🎉