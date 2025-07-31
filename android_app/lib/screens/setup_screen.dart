import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'task_list_screen.dart';

class SetupScreen extends StatefulWidget {
  @override
  _SetupScreenState createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serverUrlController = TextEditingController();
  final _deviceNameController = TextEditingController();
  bool _isLoading = false;
  bool _connectionTested = false;

  @override
  void initState() {
    super.initState();
    _serverUrlController.text = 'http://192.168.1.100:8080'; // 默认服务器地址
    _deviceNameController.text = 'Android设备'; // 默认设备名称
  }

  Future<void> _testConnection() async {
    if (_serverUrlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请输入服务器地址')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    bool success = await ApiService.testConnection(_serverUrlController.text);
    
    setState(() {
      _isLoading = false;
      _connectionTested = success;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? '连接成功！' : '连接失败，请检查服务器地址'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_connectionTested) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请先测试连接')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    bool success = await ApiService.registerDevice(
      _serverUrlController.text,
      _deviceNameController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => TaskListScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('注册失败，请重试'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设备设置'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.settings,
                size: 80,
                color: Colors.blue,
              ),
              SizedBox(height: 32),
              Text(
                '首次使用需要配置服务器连接',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              TextFormField(
                controller: _serverUrlController,
                decoration: InputDecoration(
                  labelText: '服务器地址',
                  hintText: 'http://192.168.1.100:8080',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.cloud),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入服务器地址';
                  }
                  if (!value.startsWith('http://') && !value.startsWith('https://')) {
                    return '请输入有效的URL（以http://或https://开头）';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _connectionTested = false;
                  });
                },
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _testConnection,
                icon: _connectionTested 
                    ? Icon(Icons.check_circle, color: Colors.green)
                    : Icon(Icons.wifi_find),
                label: Text(_connectionTested ? '连接成功' : '测试连接'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _connectionTested ? Colors.green : Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _deviceNameController,
                decoration: InputDecoration(
                  labelText: '设备名称',
                  hintText: '我的手机',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone_android),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入设备名称';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _register,
                icon: _isLoading 
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(Icons.login),
                label: Text(_isLoading ? '注册中...' : '注册设备'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              SizedBox(height: 16),
              Text(
                '注册后设备将连接到任务管理系统',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    _deviceNameController.dispose();
    super.dispose();
  }
}